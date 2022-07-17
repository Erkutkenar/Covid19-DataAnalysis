select * 
from Covid19Project.dbo.CovidDeaths
order by 3,4;

select * 
from Covid19Project.dbo.CovidDeaths
where continent is not null
order by 3,4;

--select * 
--from Covid19Project.dbo.CovidVaccinations
--order by 3,4;


-- select data that we are going to be using 


select location,date ,total_cases,new_cases, total_deaths,population From Covid19Project.dbo.CovidDeaths
order by 1,2;

-- looking at total cases vs total deaths

--select location,date ,total_cases,new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage From Covid19Project.dbo.CovidDeaths
--order by 1,2;

select location,date ,total_cases,new_cases, total_deaths,round((total_deaths/total_cases)*100,2) as DeathPercentage From Covid19Project.dbo.CovidDeaths
where location like '%states%'
order by 1,2;

-- Looking at total cases ve population
-- shows what percantage of population got covid
select location,date,population ,total_cases, round((total_cases/population)*100,2) as DeathPercentage From Covid19Project.dbo.CovidDeaths
where location like '%states%'
order by 1,2;

select location,date,population ,total_cases, round((total_cases/population)*100,2) as PercentPopulationInfected From Covid19Project.dbo.CovidDeaths
--where location like '%states%'
order by 1,2;


--highest infection rate by countries compared to population

select location,population ,MAX(total_cases) as HighestInfectionCount, round(MAX(total_cases/population)*100,2) as PercentPopulationInfected From Covid19Project.dbo.CovidDeaths
--where location like '%states%'
group by location,population
order by PercentPopulationInfected desc;

-- Lets break things down by continent
Select continent,Max(cast(Total_deaths as int)) as TotalDeathCount
from Covid19Project.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Showing Countries with Highest Death Count per population
Select Location,Max(cast(Total_deaths as int)) as TotalDeathCount
from Covid19Project.dbo.CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount desc

select location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
From Covid19Project.dbo.CovidDeaths 
where continent is not null
group by location
order by TotalDeathCount desc




--showing continents with highest death count per population

Select continent,Max(cast(Total_deaths as int)) as TotalDeathCount
from Covid19Project.dbo.CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers by day 
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage --,total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
from Covid19Project.dbo.CovidDeaths
where continent is not null
group by date
order by 1,2


select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage --,total_deaths,(total_deaths/total_cases) * 100 as DeathPercentage
from Covid19Project.dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2


select * from Covid19Project.dbo.CovidDeaths,Covid19Project.dbo.CovidVaccinations

--Looking at Total population vs vaccinations

select * 
from Covid19Project.dbo.CovidDeaths dea
join Covid19Project.dbo.CovidVaccinations vac
	on  dea.location = vac.location 
	and dea.date=vac.date


select * 
from Covid19Project.dbo.CovidDeaths dea
join Covid19Project.dbo.CovidVaccinations vac
	on  dea.location = vac.location 
	and dea.date=vac.date

--Looking at Total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from Covid19Project.dbo.CovidDeaths dea
join Covid19Project.dbo.CovidVaccinations vac
	on  dea.location = vac.location 
	and dea.date=vac.date
where dea.continent is not null
order by 1,2,3

--Looking at Total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location)
from Covid19Project.dbo.CovidDeaths dea
join Covid19Project.dbo.CovidVaccinations vac
	on  dea.location = vac.location 
	and dea.date=vac.date
where dea.continent is not null
order by 2,3
---or
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) 
	as RollingPeopleVaccinated
from Covid19Project.dbo.CovidDeaths dea
join Covid19Project.dbo.CovidVaccinations vac
	on  dea.location = vac.location 
	and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project.dbo.CovidDeaths dea
Join Covid19Project.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project.dbo.CovidDeaths dea
Join Covid19Project.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid19Project.dbo.CovidDeaths dea
Join Covid19Project.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated