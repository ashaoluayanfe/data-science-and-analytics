select *
from covid_project..CovidDeaths$
order by 3,4

select *
from covid_project..CovidDeaths$
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from covid_project..CovidDeaths$
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_project..CovidDeaths$
where location like '%states%'
order by 1,2

-- Total Cases vs Population
select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
from covid_project..CovidDeaths$
where location like '%states%'
order by 1,2

--Countries with Highest Infection Rate Compared to Population
select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
from covid_project..CovidDeaths$
where location like '%states%'
order by 1,2


--Countries with the highest infection rate in a single day
select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentagePopulationInfected
from covid_project..CovidDeaths$
where continent is not null
group by location, population
order by PercentagePopulationInfected desc

--Countries with highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from covid_project..CovidDeaths$
where continent is not null
group by location
order by TotalDeathCount desc

--Continent with the highest death count
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from covid_project..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Numbers
select date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
from covid_project..CovidDeaths$
where continent is not null
group by date
order by DeathPercentage desc

-- Total death across the world
select sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)* 100 as DeathPercentage
from covid_project..CovidDeaths$
where continent is not null

--  Population and vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from covid_project..CovidDeaths$ dea
join covid_project..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinationPerLocation
from covid_project..CovidDeaths$ dea
join covid_project..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3



with PopvsVac(continent, location, date, population, new_vaccinations, CummulativeVaccinationPerLocation) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinationPerLocation
from covid_project..CovidDeaths$ dea
join covid_project..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
)

select*, (CummulativeVaccinationPerLocation/population) * 100
from PopvsVac

--creating view to store data for visualizations
create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as CummulativeVaccinationPerLocation
from covid_project..CovidDeaths$ dea
join covid_project..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated