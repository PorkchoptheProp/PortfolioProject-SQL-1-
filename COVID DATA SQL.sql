SELECT * 
FROM [Portfolio Project]..[COVID Death]
Where continent is not null 
ORDER by 3, 4

SELECT *
FROM [Portfolio Project]..[COVID VACCANATION]
Where continent is not null
ORDER by 3, 4

--select data that we are going to be using 

SELECT Location, date , total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..[COVID Death]
Where continent is not null
order by 1,2

--looking at Total cases vs total deaths
--roughly showes the likelyhood if you contract COVID in your state

SELECT Location, date , total_cases, total_deaths, ( total_deaths/total_cases)* 100 as DeathPercentage 
FROM [Portfolio Project]..[COVID Death]
where location like '%states%'
Where continent is not null
order by 1,2

--looking at Total cases vs  population 
--showes what percentage of population got covid from 1-1-20 to 9-27-23

SELECT Location, date , total_cases, population, ( total_cases/population)* 100 as Percentofpopultaioninfected 
FROM [Portfolio Project]..[COVID Death]
where location like '%states%'
Where continent is not null
order by 1,2


--looking at countries with the highest infection rate compared to the population in it. 

SELECT Location, Population, MAX(total_cases) as Highestinfectioncount , MAX((total_cases/Population))* 100 as Percentofpopulationinfected 
FROM [Portfolio Project]..[COVID Death]
where location like '%states%'
Where continent is not null
Group by location, population 
Order by Percentofpopulationinfected desc


--showing Countries with the highest death count per population 

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM [Portfolio Project]..[COVID Death]
Where continent is not null
Group by location
order by TotalDeathCount desc


--Let's break things down by continent 
--Showing contintents with the highest death count per population 

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM [Portfolio Project]..[COVID Death]
Where continent is not null
Group by continent
order by TotalDeathCount desc



--Global numbers 

SELECT date , SUM(new_cases), Sum(new_deaths), SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage 
FROM [Portfolio Project]..[COVID Death]
where location like '%states%'
Where continent is not null
Group by date 
order by 1,2

--Looking at total Populatin vs Vaccinations 
--Use CTE

With PopvsVac (continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccination) as (

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
FROM [Portfolio Project]..[COVID Death] dea
Join [Portfolio Project]..[COVID VACCANATION] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
SELECT *, (RollingPeopleVaccination/Population)*100
From PopvsVac



--Temp table

Drop Table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccination numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
FROM [Portfolio Project]..[COVID Death] dea
Join [Portfolio Project]..[COVID VACCANATION] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

SELECT *, (RollingPeopleVaccination/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccination
FROM [Portfolio Project]..[COVID Death] dea
Join [Portfolio Project]..[COVID VACCANATION] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
