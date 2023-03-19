select *
from [portfolio project]..CovidDeaths$
where continent is not null
order by 3,4

select *
from [portfolio project]..CovidVaccinations$
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From [portfolio project]..CovidDeaths$
order by 1,2


-- looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [portfolio project]..CovidDeaths$
where location like '%states%'
where continent is not null
order by 1,2

-- looking at Total cases vs Population
-- shows what percentage of population got covid
Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From [portfolio project]..CovidDeaths$
Where location like '%states%'
where continent is not null
order by 1,2

-- looking at Countries with Highest Infection

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From [portfolio project]..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [portfolio project]..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc


-- LETS'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [portfolio project]..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- showing continents with the Highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [portfolio project]..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [portfolio project]..CovidDeaths$
--where location like '%states%'
where continent is not null
--Group By date
order by 1,2

-- Looking at Total Population vs Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [portfolio project]..CovidDeaths$ dea
Join [portfolio project].. CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [portfolio project]..CovidDeaths$ dea
Join [portfolio project].. CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [portfolio project]..CovidDeaths$ dea
Join [portfolio project].. CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visulizations

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [portfolio project]..CovidDeaths$ dea
Join [portfolio project].. CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated