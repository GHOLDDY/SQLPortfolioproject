Select *
from PortfolioProject..CovidDeath
where continent is not null
Order by 3, 4

Select *
from PortfolioProject..CovidVaccination
order by 3, 4

Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
order by 1, 2


--looking at Total cases vs Total Deaths 
Select location, date, total_cases,  total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location = 'Nigeria'
order by 1, 2

--shows the  percentage of population got Covid
Select location, date, total_cases, Population,  total_deaths, (Total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeath
--where location = 'United States'
order by 1, 2


--look at countries with the highest infection rate compared to population

Select location, Population,  MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeath
Group by location, Population
order by PercentPopulationInfected desc


--showing countries with the highest Death count per location

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
where continent is not null
Group by location
order by TotalDeathCount desc

--BREAKING IT DOWN BY location 
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
where continent is null
Group by location
order by TotalDeathCount desc

--Break it down by continent
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
where continent is not null
Group by continent
order by TotalDeathCount desc


-- looking at the African continent 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeath
where continent = 'Africa'
Group by continent
order by TotalDeathCount desc

--showing continent with the highest death count per population
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global covid numbers
Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where continent is not null
--group by date
order by 1,2

-- total_cases and total death by date 
Select date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where continent is not null
group by date
order by 1,2

--looking at total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated-- we use partition by the location to break off the query, when 
-- a new location, so the aggregate function doesnt run all the time in a loop
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




--USE CTE
With PopvsVac(Continent, location, Date, Population, new_vaccinations, PeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated-- we use partition by the location to break off the query, when 
-- a new location, the aggregate function doesnt run all the time
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (PeopleVaccinated/Population) *100 as PercentageValueVaccinated
From PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #PercentageValueVaccinated
Create table #PercentageValueVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
PeopleVaccinated numeric
)

Insert into #PercentageValueVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated-- we use partition by the location to break off the query, when 
-- a new location, the aggregate function doesnt run all the time
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select * , (PeopleVaccinated/Population) *100 
From #PercentageValueVaccinated


--Creating view to store data for visualizations
Create view PercentagePopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as PeopleVaccinated-- we use partition by the location to break off the query, when 
-- a new location, the aggregate function doesnt run all the time
from PortfolioProject..CovidDeath dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

--Another view
Create view GlobalNumbers as
Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where continent is not null
--group by date
--order by 1,2

--Another view 
Create view AfricanContinentCovidNumbers as
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath
where continent = 'Africa'
Group by continent
--order by TotalDeathCount desc
