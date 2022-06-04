select *
from portfolioproject..coviddeaths
where continent is not null
order by 3,4

--select *
--from portfolioproject..covidvacinations
--order by 3,4

--select data that we are going to use

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..coviddeaths
order by 1,2

--Looking at total Cases vs Total Deaths
--shows the likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..coviddeaths
where location like '%states%'
order by 1,2


--Data of India.
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..coviddeaths
where location like '%india%'
order by 1,2


--looking at total cases vs population
--shows what percentage of population got covid

select location, date, total_cases, population, (total_cases/population)*100 as casePercentage
from portfolioproject..coviddeaths
where location like '%states%'
order by 1,2


select location, date, total_cases, population, (total_cases/population)*100 as casePercentage
from portfolioproject..coviddeaths
where location like '%india%'
order by 1,2

--looking at countries with infection rate compared to population

select location, population, MAX(total_cases) as highestinfectioncount, max(total_cases/population)*100 as percentpopulationinfected
from portfolioproject..coviddeaths
--where location like '%states%'
group by location, population
order by percentpopulationinfected desc

--showing countries with highest death count per population



select location, MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc

--lets break down by cotinents

select location, MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is null
group by location
order by totaldeathcount desc

--but we do this instead of that

select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by totaldeathcount desc

--showing the continents with the highest death count per population

select location, MAX(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is null
group by location
order by totaldeathcount desc


--GLOBAL NUMBERS

select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
order by 1,2

select date,SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--totalcases
select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
from portfolioproject..coviddeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2



--joining both the deaths and vaccination table
select *
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date

	--looking at total population vs vacinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3



--USE CTE

with popvsvac(continent, loaction, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(rollingpeoplevaccinated/population)*100
from popvsvac



--Temp table
DROP Table if exists #percentpopulationvaccinated
Create table #percentpopulationvaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from portfolioproject..coviddeaths dea
join portfolioproject..covidvaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(Rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated



