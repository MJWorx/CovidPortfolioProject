-- Covid19 Data Exploration Aanalysis

-- Select Database

USE PortfolioProject;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

SELECT * FROM CovidDeaths;

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths INT;

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases INT;

UPDATE CovidDeaths
SET total_deaths = NULL
WHERE total_deaths = 0;

UPDATE CovidDeaths
SET total_cases = NULL
WHERE total_cases = 0;

SELECT * FROM CovidDeaths;

SELECT location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths FLOAT;

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases FLOAT;

SELECT location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'South Africa'
ORDER BY 1,2

-- Total Cases vs Total Population
-- % by Population

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'South Africa'
ORDER BY 1,2


SELECT location, date, population, total_cases, (total_cases/population)*100 AS Infected_Population_Percentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


SELECT location, date, population, total_cases, 
(CONVERT(FLOAT,total_cases)/NULLIF(CONVERT(FLOAT, population), 0))*100 AS Infected_Population_Percentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

ALTER TABLE CovidDeaths
ALTER COLUMN population FLOAT;

SELECT * FROM CovidDeaths;

-- Highest Infection Rate by Country per Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, 
MAX((CONVERT(FLOAT,total_cases)/NULLIF(CONVERT(FLOAT, population), 0)))*100 AS Infected_Population_Percentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 1,2

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, 
MAX((CONVERT(FLOAT,total_cases)/NULLIF(CONVERT(FLOAT, population), 0)))*100 AS Infected_Population_Percentage
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY Infected_Population_Percentage DESC;

-- Highest Death Rate by Country per Population

SELECT location, 
MAX(CAST(total_deaths AS INT)) AS Total_Death_Count 
FROM PortfolioProject..CovidDeaths
GROUP BY location
ORDER BY Total_Death_Count DESC;

SELECT * FROM CovidDeaths;


-- Need to set NULL in continent blank spaces

UPDATE CovidDeaths
SET continent = NULL
WHERE continent = '';


SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT location, 
MAX(CAST(total_deaths AS INT)) AS Total_Death_Count 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;

SELECT location, 
MAX(CAST(total_deaths AS INT)) AS Total_Death_Count 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;

-- Continent with highest Total Deaths

SELECT continent, 
MAX(CAST(total_deaths AS INT)) AS Total_Death_Count 
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;

-- Global Numbers

SELECT date, SUM(CAST(new_cases AS INT)) AS total_cases,
SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT))/SUM(CAST(new_cases AS INT))*100 AS Death_Percentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT * FROM CovidDeaths;

UPDATE CovidDeaths
SET new_deaths = NULL
WHERE new_deaths = '';

-- Joining Tables

SELECT * FROM CovidVaccinations;

SELECT * FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date

-- Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

UPDATE CovidVaccinations
SET new_vaccinations = NULL
WHERE new_vaccinations = '';

SELECT * FROM CovidVaccinations;

-- CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_Vaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_Vaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT * FROM PopvsVac
