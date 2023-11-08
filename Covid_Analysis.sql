select*
from Covid_Analysis..CovidDeaths$

--select*
--from Covid_Analysis..CovidVaccinations$


select location, date, total_cases, new_cases, total_deaths, population
from Covid_Analysis..CovidDeaths$
order by 1,2

--Total cases vs percentage of death cases

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid_Analysis..CovidDeaths$
order by 1,2

--looking at Total cases vs percentage of death cases in the United states
--hence it shows the probability of deaths if infected with covid in this location

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid_Analysis..CovidDeaths$
where continent is not null
order by 1,2

--Total population vs total cases
-- This reveals the percentage of the population with covid

select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
from Covid_Analysis..CovidDeaths$
where location like '%states%'
and continent is not null
order by 1,2

--Countries with the highest infection rate compared to their population

select location, population, Max(total_cases) as MaxTotalcase, Max((total_cases/population))*100 as MAxPercentagePopulationinfected
from Covid_Analysis..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location, population
order by MAxPercentagePopulationinfected desc


--Countries with the highest death count per population

select location,population ,Max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Analysis..CovidDeaths$
--where location like '%states%'
where continent is not null
group by location,population 
order by TotalDeathCount desc

--Continents with the highest death count 

select location,Max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Analysis..CovidDeaths$
--where location like '%states%'
where continent is null
group by location
order by TotalDeathCount desc

select continent,Max(cast(total_deaths as int)) as TotalDeathCount
from Covid_Analysis..CovidDeaths$
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers

select  date, SUM(new_cases) as daily_cases,SUM(cast(new_deaths as int)) as daily_deaths--, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from Covid_Analysis..CovidDeaths$
where continent is not null
group by date
order by 1,2

select  SUM(new_cases) as daily_cases,SUM(cast(new_deaths as int)) as daily_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from Covid_Analysis..CovidDeaths$
where continent is  null
--group by date
order by 1,2

--Looking at Total population vs Total vanccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from Covid_Analysis..CovidDeaths$ dea
join Covid_Analysis..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
   where dea.continent is not  null
   order by 1,2,3

--Ceate Temp table in order to view percentage vaccinated populace
create table #percentagevaccinatedpopulace
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
Vacinnatedpopulace numeric
)
insert into #percentagevaccinatedpopulace
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as Vacinnatedpopulace
from Covid_Analysis..CovidDeaths$ dea
join Covid_Analysis..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
   where dea.continent is not  null
   order by 1,2,3

select*, (Vacinnatedpopulace/population)*100 as percentage_vacinated_populace
from #percentagevaccinatedpopulace 

--creating views to store data for later visualisation

create view percentagevaccinatedpopulace as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as Vacinnatedpopulace
from Covid_Analysis..CovidDeaths$ dea
join Covid_Analysis..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
   where dea.continent is not  null
   
