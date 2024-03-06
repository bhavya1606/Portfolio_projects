
Select *
From dbo.CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From dbo.CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From dbo.CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From dbo.CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
--Where location like '%states%'
Where continent is null 
Group by location
order by TotalDeathCount desc


-- Global Numbers

Select  date, SUM(new_cases) , SUM(cast(new_deaths as int)) , (SUM(cast(new_deaths as int))/  SUM(new_cases) ) * 100 AS Percentage
From dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
group by date
order by 1,2


Select  SUM(new_cases) , SUM(cast(new_deaths as int)) , (SUM(cast(new_deaths as int))/  SUM(new_cases) ) * 100 AS Percentage
From dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
--group by date
order by 1,2




-- JOIN the 2 tables together
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--using CTEs
with PopvsVac (continent, location, date, population , new_vaccinations, RollingPeopleVaccinated )
as
(

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
Select * , (RollingPeopleVaccinated/ population)*100
from PopvsVac

--TEMP TABLE

DROP TABLE if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 1,2,3

SELECT *,( RollingPeopleVaccinated / Population ) *100
from #PercentagePopulationVaccinated

--creating veiw to store data for later visualizations

Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population) *100
from dbo.CovidDeaths dea
JOIN dbo.CovidVaccinations vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

SELECT *
FROM PercentPopulationVaccinated