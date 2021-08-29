
SELECT*
FROM[dbo].[CovidDeaths]
WHERE continent is not null
order by 3,4

--SELECT*
--FROM[dbo].[CovidVaccination]
--order by 3,4

--select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM[dbo].[CovidDeaths]
ORder by 1, 2

-- Lokking at Total Cases Vs Total Deaths
--Show likehood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage
FROM[dbo].[CovidDeaths]
WHERE location like '%Ivoire'
WHERE continent is not null
ORder by 1, 2

--Looking at total cases Vs Population
-- Show what percent of population got covid
SELECT Location, date, population,total_cases, (total_cases/population) *100 AS InfectPercentage
FROM[dbo].[CovidDeaths]
--WHERE location like '%Ivoire'
ORder by 1, 2


--Looking at country with highest infection rate compared to population
SELECT Location, population,Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) *100 AS InfectedPopulationPercentage
FROM[dbo].[CovidDeaths]
--WHERE location like '%Ivoire'
group by location, population
ORder by InfectedPopulationPercentage desc


-- Showing countries with highest count population

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM[dbo].[CovidDeaths]
--WHERE location like '%Ivoire'
WHERE continent is  null
group by location
ORder by TotalDeathCount desc


-- LET'S BREAK THINGS BY CONTINENT

SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM[dbo].[CovidDeaths]
--WHERE location like '%Ivoire'
WHERE continent is not null
group by continent
ORder by TotalDeathCount desc


-- Showing the continent with the highest death count per population

SELECT Location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM[dbo].[CovidDeaths]
--WHERE location like '%Ivoire'
WHERE continent is not null
group by location, population
ORder by TotalDeathCount desc

--GLOBAL NUMBERS
SELECT sum(new_cases), sum(cast(new_deaths as int)), sum(cast (new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
FROM[dbo].[CovidDeaths]
--WHERE location like '%Ivoire'
WHERE continent is not null
--group by date
order by 1,2

-- JOIN OUR TWO TABLES
SELECT *
from CovidDeaths dea
join [dbo].[CovidVaccination] vac
on dea.location = vac.location
and dea.date = vac.date

---Looking at Total population Vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location) AS RollingPeopleVaccination,
--(RollingPeopleVaccination/population)*100
FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
order by 1, 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location) AS RollingPeopleVaccination
--(RollingPeopleVaccination/population)*100
FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 1, 2,3
) 
SELECT*, (RollingPeopleVaccination/Population)*100 AS Rating
FROM PopvsVac



-- TEM TABLE

DROP TABLE if exists #PercentPoplulationVaccinated
create table #PercentPoplulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
new_vaccination numeric, 
RollingPeopleVaccination numeric
)
insert into #PercentPoplulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location) AS RollingPeopleVaccination
--(RollingPeopleVaccination/population)*100
FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 1, 2,3
SELECT*, (RollingPeopleVaccination/Population)*100
FROM #PercentPoplulationVaccinated



-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPoplulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (partition by dea.location ORDER BY dea.location) AS RollingPeopleVaccination
--(RollingPeopleVaccination/population)*100
FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--order by 1, 2,3

SELECT*
FROM PercentPoplulationVaccinated