/*
Covid 19 Data Exploration (as of 07/12/21)

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Germany

Select Location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 3) as DeathPercentage
From PortfolioProjectSQL..CovidDeaths
Where location = 'Germany'
order by DeathPercentage DESC

-- # We see that in terms of ratio (total deaths vs total cases), the deadliest day in Germany was on 2020-06-11 with 4.69%
----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Total Cases vs Population
-- Shows what percentage of population in Germany infected with Covid

Select Location, date, Population, total_cases,  ROUND((total_cases/population)*100, 3) as PercentPopulationInfected
From PortfolioProjectSQL..CovidDeaths
Where location = 'Germany'
order by PercentPopulationInfected DESC

-- # We see that the highest % of population infected with Covid in Germany was in fact on 2021-12-06 (Basically at the timeframe of writing this Project)
----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Countries with the Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  ROUND(Max((total_cases/population))*100, 2) as PercentPopulationInfected
From PortfolioProjectSQL..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected DESC

-- # We see that the highest Infection Rate was observed in Montenegro with 25.26% of population being infected at some point in time.
----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Countries with the Highest Death Count

Select Location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProjectSQL..CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount DESC

-- # We see that the highest count of total deaths from covid was observed in USA with 789745 deaths.
----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Showing GLOBAL deaths count

Select location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
From PortfolioProjectSQL..CovidDeaths
Where continent is null 
Group by location
order by TotalDeathCount desc

-- # We see that there are so far slightly more than 5m deaths from covid worldwide with almost 1.5m deaths in Europe alone.
----------------------------------------------------------------------------------------------------------------------------------------------------------

-- GLOBAL Numbers Overview

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, ROUND(SUM(cast(new_deaths as bigint))/SUM(New_Cases)*100, 2) as DeathPercentage
From PortfolioProjectSQL..CovidDeaths
where continent is not null 

-- # We see that worldwide there are 265m observed COVID cases and the death % is at almost 2.
----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine by Day and Country

-- Using CTE to perform Calculation on Partition By

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProjectSQL..CovidDeaths dea
Join PortfolioProjectSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null 
)

Select *, Round((RollingPeopleVaccinated/Population)*100,2) as RPV_Percentage -- % by countries only.
From PopvsVac

----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProjectSQL..CovidDeaths dea
Join PortfolioProjectSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, Round((RollingPeopleVaccinated/Population)*100,2) as RPV_Percentage
From #PercentPopulationVaccinated

----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From PortfolioProjectSQL..CovidDeaths dea
Join PortfolioProjectSQL..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

where dea.continent is not null 

-----
Select *
From PercentPopulationVaccinated

----------------------------------------------------------------------------------------------------------------------------------------------------------