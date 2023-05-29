---- Observing dataset

SELECT *
FROM CovidDeaths;

SELECT *
FROM CovidVaccinations;

---- Ordering by location and date

SELECT *
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4;

---- Selecting data wanted to see

SELECT location, date, total_cases, new_cases, total_deaths, new_deaths, population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2;


-----------------------------------

---- Looking at total cases vs total deaths
---- showing likelihood of dying if you contrac covid in Thailand

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
---WHERE location LIKE '%Thailand%'
---	AND continent is not null
WHERE continent is not null
ORDER BY 1,2;


-----------------------------------

---- Looking at total cases vs poppulation
---- Showing percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfacted
FROM CovidDeaths
---WHERE location LIKE '%Thailand%'
---	AND continent is not null
WHERE continent is not null
ORDER BY 1,2;


-----------------------------------

---- Looking at country with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
	PercentPopulationInfacted
FROM CovidDeaths
---WHERE location LIKE '%Thailand%'
---	AND continent is not null
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfacted desc;


------------------------------------

---- Looking as country with highest death count compared per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
---WHERE location LIKE '%Thailand%'
---	AND continent is not null
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

---- Let's break thing down by Continent
---- Looking as continent with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
---WHERE location LIKE '%Thailand%'
---	AND continent is not null
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;


--------------------------------------

---- GLOBAL NUMBERS
---- Looking for new deaths per new cases

SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
---WHERE location LIKE '%Thailand%'
---	AND continent is not null
WHERE continent is not null
ORDER BY 1,2;


---------------------------------------

---- Looking as total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


---- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
---ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
From PopvsVac


---- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(225),
Location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
	as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
---WHERE dea.continent is not null
---ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated