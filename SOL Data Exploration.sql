SELECT *
from portfolioproject ..CovidDeaths$
order by 3, 4


select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject ..CovidDeaths$
order by 1, 2


select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From PortfolioProject ..CovidDeaths$
where location='India'
order by 1, 2


select Location, date, total_cases, population, (total_cases/population)*100 as percentpopulationinfected
From PortfolioProject ..CovidDeaths$
order by 1, 2


select Location, population, MAX(total_cases) as Highestinfectioncount, MAX(total_cases/population)*100 as percentpopulationinfected
From PortfolioProject ..CovidDeaths$
Group by Location, population
order by percentpopulationinfected desc


select Location, MAX(cast (total_deaths as int)) as TotalDeathcount
From PortfolioProject ..CovidDeaths$
where continent is not null
Group by Location
order by TotalDeathcount desc


--breaking things down by continent

select continent, MAX(cast (total_deaths as int)) as TotalDeathcount
From PortfolioProject ..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathcount desc


--Global data


select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From PortfolioProject ..CovidDeaths$
where continent is not null
group by date
order by 1, 2


select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathpercentage
From PortfolioProject ..CovidDeaths$
where continent is not null


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
JOIN CovidVaccinations$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3


With PopVsVac (continent,location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
JOIN CovidVaccinations$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopVsVac



Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
JOIN CovidVaccinations$ vac
  ON dea.location = vac.location
  AND dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated
