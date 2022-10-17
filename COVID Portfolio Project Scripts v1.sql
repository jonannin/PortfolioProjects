/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT *
--FROM [PortfolioProject]..[CovidVaccinations]

-- Verify data in table
--SELECT *
--FROM [PortfolioProject]..[CovidDeaths]


-- Select data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [PortfolioProject]..[CovidDeaths]
ORDER BY 1, 2


-- Total Cases vs Total Deaths
--Shows likelihood of dying if your contract COVID in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM [PortfolioProject]..[CovidDeaths]
WHERE location = 'Ghana'
ORDER BY 1, 2


-- Total Cases vs Population
--Shows percentage of COVID cases in your country
SELECT location, date, population, total_cases, (total_cases/population) * 100 as PercentagePopulationInfected
FROM [PortfolioProject]..[CovidDeaths]
WHERE location = 'Ghana'
ORDER BY 1, 2


-- Countries with highest infection rate compared to population
SELECT location, MAX(population), MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population) * 100 as PercentagePopulationInfected
FROM [PortfolioProject]..[CovidDeaths]
GROUP BY location
ORDER BY PercentagePopulationInfected DESC


-- Countries with highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM [PortfolioProject]..[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Countries/Locations with highest death count per continent
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM [PortfolioProject]..[CovidDeaths]
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Continents with highest death count per continent
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM [PortfolioProject]..[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Continents with highest death count per continent
SELECT continent, SUM(new_cases) as NewCasesCount, SUM(CAST(new_deaths AS INT)) as DeathsCount, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 as DeathPercentage
FROM [PortfolioProject]..[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY DeathPercentage DESC


-- GLOBAL NUMNBERS


SELECT SUM(new_cases) as NewCasesCount, SUM(CAST(new_deaths AS INT)) as DeathsCount, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 as DeathPercentage
FROM [PortfolioProject]..[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY DeathPercentage DESC



-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3



-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3


-- USE CTE

WITH PopVsVac --(Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/ population) * 100
FROM PopVsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
--
CREATE TABLE #PercentPopulationVaccinated
(
	Continent NVARCHAR(255),
	Location NVARCHAR(255),
	Date DATETIME,
	Population BIGINT,
	NewVaccinations BIGINT,
	RollingPeopleVaccinated decimal
)
--
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--
SELECT *, (RollingPeopleVaccinated/ population) * 100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated
AS (
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 1, 2, 3
)

SELECT *
FROM PercentPopulationVaccinated