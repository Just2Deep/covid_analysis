select * from Covid..CovidDeaths
where continent is not null
order by 3, 4;

-- Select data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
from Covid..CovidDeaths
where continent is not null
order by 1, 2

-- Looking at Total cases vs Total deaths
-- Shows the likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid..CovidDeaths
--where location like '%India%' and 
where continent is not null
order by 1, 2


-- Looking at Total cases vs Population
-- Shows what percentage of population have got Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from Covid..CovidDeaths
--where location like '%India%'
where continent is not null
order by 1, 2

-- Looking at countries with highest infection rate compared to population

SELECT location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)*100) as PercentPopulationInfected
from Covid..CovidDeaths
where continent is not null
--where location like '%India%'
group by location, population 
order by PercentPopulationInfected desc


-- Showing countries with highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
from Covid..CovidDeaths
where continent is not null
--where location like '%India%'
group by location
order by TotalDeathCount desc

-- Lets break the data by continents

SELECT location as Continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from Covid..CovidDeaths
where continent is null and location not like '%income%'
--where location like '%India%'
group by location
order by TotalDeathCount desc

-- Showing continents with highest death count per population

SELECT Continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
from Covid..CovidDeaths
where continent is not null 
--where location like '%India%'
group by continent
order by TotalDeathCount desc


-- Global Numbers
Select  date, SUM(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths,  (SUM(cast (new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from Covid..CovidDeaths
where continent is not null
group by date 
order by 1, 2

-- Total world cases and deaths 

Select  SUM(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths,  (SUM(cast (new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from Covid..CovidDeaths
where continent is not null
--group by date 
order by 1, 2

-- Looking at Total populations vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from Covid..CovidDeaths as dea
Join Covid..CovidVaccinations as vac
 on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
order by 2 ,3


--using CTE 

with PopvsVac (Continent, Location, Date,Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from Covid..CovidDeaths as dea
Join Covid..CovidVaccinations as vac
 on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
--order by 2 ,3
)
select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage from PopvsVac


-- Using Temporary table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent varchar(255), 
Location varchar(255), 
Date datetime,
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from Covid..CovidDeaths as dea
Join Covid..CovidVaccinations as vac
 on dea.location = vac.location 
    and dea.date = vac.date
--where dea.continent is not null
--order by 2 ,3

select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage 
from #PercentPopulationVaccinated;


-- Creating Views to store data for later visualisations

--DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from Covid..CovidDeaths as dea
Join Covid..CovidVaccinations as vac
 on dea.location = vac.location 
    and dea.date = vac.date
where dea.continent is not null
--order by 2 ,3


-- View for Total world cases and deaths 

CREATE VIEW TotalDeathPercentage as
Select  SUM(new_cases) as TotalCases, SUM(cast (new_deaths as int)) as TotalDeaths,  (SUM(cast (new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from Covid..CovidDeaths
where continent is not null
--group by date 
--order by 1, 2