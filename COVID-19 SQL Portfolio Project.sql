/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4 asc

-- to convert varchar column into date column
update CovidDeaths
    set date = coalesce(try_convert(date, date, 103),
                             convert(date, date)
                            );

alter table CovidDeaths alter column date date;

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/NULLIF(total_cases,0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'


-- Total Cases vs Population
-- Shows what percentage of population got infected with Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like '%India%'


-- Countries with Highest Infection Rate compared to Population

SELECT location, population ,MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/NULLIF(population,0))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Group by location, population
order by PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE ISNULL(continent,'') <> ''
Group by location
order by Total_Death_Count DESC


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT location, MAX(total_deaths) AS Total_Death_Count
FROM PortfolioProject..CovidDeaths
WHERE NULLIF(continent, '') IS NULL
Group by location
order by Total_Death_Count DESC


-- Global Numbers

SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE ISNULL(continent,'') <> ''
--Group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY  dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE ISNULL(dea.continent,'') <> ''
Order By 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY  dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE ISNULL(dea.continent,'') <> ''
)
SELECT *,(RollingPeopleVaccinated/NULLIF(population,0))*100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, CAST(vac.new_vaccinations as INT),
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY  dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE ISNULL(dea.continent,'') <> ''

SELECT *,(CAST(RollingPeopleVaccinated AS INT))/(NULLIF(population,0))*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY  dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE ISNULL(dea.continent,'') <> ''

SELECT *
FROM PercentPopulationVaccinated