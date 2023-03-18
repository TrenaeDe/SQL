SELECT *
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 3,4;

/* SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
ORDER BY 3,4 */


-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of death for contracting Covid in your country.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of the population contracted Covid.

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2;


-- Looking at Countries with Highest Infection Rate Compared to Population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc;


-- Showing  Countries with the Highest Death Count per Population

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;


/* LET'S BREAK THINGS DOWN BY CONTINENT */

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc;


-- Showing Continents with the Highest Death Count per Population

SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2;

-- ACROSS THE WORLD
SELECT SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;



-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;
--Going deeper for the Total Rolling Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	  ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
	  , dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	  ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
	  , dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingVacPercentage
FROM PopvsVac;

-- TEMP TABLE

--DROP TABLE if exists #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	  ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
	  , dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingVacPercentage
FROM #PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	  ,SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
	  , dea.date) as RollingPeopleVaccinated
FROM CovidDeaths as dea
JOIN CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated;
