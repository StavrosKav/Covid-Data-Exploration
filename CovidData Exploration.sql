select *
from CovidDeaths
where continent is not null
order by 1,2

-- Select Data that we are going to be starting with

select location,date,total_cases,new_cases,total_deaths,population
from PortofolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercenatage
from PortofolioProject..CovidDeaths
where location like '%Greece%' and  continent is not null
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortofolioProject..CovidDeaths
where location like '%Greece%' and  continent is not null
order by 1,2

-- Countries with Highest Infection Rate compared to Population

select location,population,max(total_cases) as HighestInfectionCount,max(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where continent is not null
group by location,population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

select location,max(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is  not null
group by location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

select continent,max(cast(Total_Deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--------

select date,sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths,sum(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- GLOBAL NUMBERS

select sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths,sum(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
from PortofolioProject..CovidDeaths
where continent is not null


select*
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
	order by 2,3


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
order by 2,3




-- Using CTE to perform Calculation on Partition By in previous query

with PopvsVac(Continent,location,date,population,New_Vaccinations,RollingPeapleVaccinated)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeapleVaccinated/population)*100
from PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query
drop table if exists #PercentPoplulationVaccinated
create table #PercentPoplulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPoplulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null

select *,(RollingPeopleVaccinated/population)*100
from #PercentPoplulationVaccinated

-- Creating View to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location 
	and dea.date=vac.date
where dea.continent is not null


select *,(RollingPeopleVaccinated/population)*100 as VaccinationPercent
from PercentPopulationVaccinated
where location like '%Greece%'