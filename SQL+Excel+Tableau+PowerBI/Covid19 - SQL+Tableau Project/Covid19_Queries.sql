select * from Covid19..CovidDeaths 
-- where continent is not null 
order by 2,3,4;

select * from Covid19..CovidVaccinations
-- where continent is not null 
order by 2,3,4;



-- Total Cases vs Total Deaths (Shows likelihood of dying if you contract covid in your country)
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from Covid19..CovidDeaths
where continent is not null
order by location;

-- Total Cases vs Population (Shows what percentage of population infected with Covid)
select location, date, population, total_cases, (total_cases/population)*100 as infection_percentage
from Covid19..CovidDeaths
where continent is not null and total_cases > 1000
order by 1,2;


-- Countries with Highest Infection Rate compared to Population
select location, population, max(cast(total_cases as int)) as total_cases , max((cast(total_cases as int)/population)*100) as infection_percentage
from Covid19..CovidDeaths
where continent is not null
group by location, population
order by infection_percentage desc;


-- Countries with Highest Death Count per Population
select location, population, max(cast(total_deaths as int)) as total_deaths , max((cast(total_deaths as int)/population)*100) as death_percentage
from Covid19..CovidDeaths
where continent is not null
group by location, population
order by total_deaths desc;


-- continents with the highest death count per population
select location, population, max(cast(total_deaths as int)) as total_deaths , max((cast(total_deaths as int)/population)*100) as death_percentage
from Covid19..CovidDeaths
where continent is null and location not in ('world','international', 'European Union')
group by location, population
order by total_deaths desc;


-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as death_percentage
From Covid19..CovidDeaths
where continent is not null


-- Total Population vs Vaccinations (Shows Percentage of Population that has received at least one Covid Vaccine)
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
From Covid19..CovidDeaths dea
Join Covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
with PopVsVac as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
From Covid19..CovidDeaths dea
Join Covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select * , RollingPeopleVaccinated/population *100 as Percantage_Vaccinated
from PopVsVac order by 2,3


-- Using a Temp Table to perform Calculation on Partition By in previous query
drop table if exists Percantage_Vaccinated
create table Percantage_Vaccinated
(
continent text,
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into Percantage_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Date) as RollingPeopleVaccinated
From Covid19..CovidDeaths dea
Join Covid19..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * , RollingPeopleVaccinated/population *100 as Percantage_Vaccinated
from Percantage_Vaccinated order by 2,3

