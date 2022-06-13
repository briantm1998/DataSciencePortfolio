--Select *
--00From PortfolioProject..CovidDeaths
--order by 3, 4

--Select *
--From PortfolioProject.. CovidVaccinations
--order by 3,4

--Select data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.. CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.. CovidDeaths
where location like '%zimbabwe%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what % of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentOfPopInfected
From PortfolioProject.. CovidDeaths
where location like '%zimbabwe%'
order by 1,2

-- Looking at Countries with highest Infection Rate Compared to population in African Countries

Select Location, population, MAX(total_cases) as HighestInfectionCountries, Max(total_cases/population)*100 as PercentOfPopInfected
From PortfolioProject.. CovidDeaths
where continent like '%africa%'
Group by location, population
order by 4 desc

--Looking at Countries with Highest Death Count per Population in Africa
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.. CovidDeaths
where continent like '%africa%'
Group by location, population
order by 2 desc

--Show highest Death Count by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject.. CovidDeaths
where continent is null
Group by location
order by 2 desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage

From PortfolioProject.. CovidDeaths
where continent is not null
--Group by date
order by 1,2

--AFRICA GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage

From PortfolioProject.. CovidDeaths
where continent like '%africa%'
--Group by date
order by 1,2

--LOOKING AT TOTAL POPULATIONS VS VACCINATIONS

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinatedPeople,

From PortfolioProject..CovidDeaths	dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, location, date,Population,new_vaccinations, RollingVaccinatedPeople)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingVaccinatedPeople

From PortfolioProject..CovidDeaths	dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--order by 2,3)
)
Select *, (RollingVaccinatedPeople/Population)*100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaccinatedPeople numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) 
as RollingVaccinatedPeople

From PortfolioProject..CovidDeaths	dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3)

Select *, (RollingVaccinatedPeople/Population)*100
From #PercentPopulationVaccinated




