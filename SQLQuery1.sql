SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
Order by 1,2

-- We will be looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Pakistan%' and continent is not null
Order by 1,2

-- Looking now at the Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date,population, total_cases,(total_cases/population)*100 as PercentPopulation
From PortfolioProject..CovidDeaths
-- Where location like '%Pakistan%'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group By location,population
Order by PercentPopulationInfected desc

-- Showing countries with Highest Death Count per Population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group By location
Order by TotalDeathCount desc

-- LET's BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the Highest Death Count per Population

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
WHERE continent is not NULL
Group By continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2

-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine by using rolling count
-- Using CTE

With PopvsVac (Continent, location, date, population,new_vacinnations, RollingPeopleVaccinated)
as (Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations))
 OVER (Partition by dth.location Order by dth.location, dth.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not NULL
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 as Percentge
FROM PopvsVac

-- Using the above statement using the TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations))
 OVER (Partition by dth.location Order by dth.location, dth.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not NULL
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 as Percentge
FROM #PercentPopulationVaccinated 


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations))
 OVER (Partition by dth.location Order by dth.location, dth.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dth
Join PortfolioProject..CovidVaccinations vac
	On dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not NULL

Select *
FROM PercentPopulationVaccinated
