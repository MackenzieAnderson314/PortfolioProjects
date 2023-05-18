use portfolioProjectCovid;

select * 
from 
coviddeaths
where continent != " ";

SELECT 
	continent,
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    CovidDeaths
where continent is not null;

-- looking at total cases vs. total deaths.
-- Shows likelihood of dying if you contract Covid in the United States

SELECT 
	continent,
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 AS DeathPercentage
FROM
    CovidDeaths
where continent != " " and location = "United States";

-- Looking at total cases vs population
-- Shows what percentage of US population has gotten Covid

SELECT 
	continent,
    location,
    date,
    total_cases,
	population,
    (total_cases/population)*100 AS PopPercentage
FROM
    CovidDeaths
where continent != " " and location = "United States";


-- Looking at countries with highest infection rate compared to population

SELECT 
	continent,
    location,
    population,
    max(total_cases) as HighestInfectionCount,
	max(total_cases/population)*100 as PercentPopulationInfected
FROM
    CovidDeaths
where continent != " "
group by location, population
order by PercentPopulationInfected desc;

-- Let's break things down by continent.
-- showing the continents with the highest death count per population

SELECT 
    continent,
    max(cast(total_deaths AS double)) as TotalDeathCount
FROM
    CovidDeaths
where continent != " "
Group by continent
order by TotalDeathCount desc;


-- Showing countries with the highest death count per population

SELECT 
	continent,
    location,
    max(cast(total_deaths AS double)) as TotalDeathCount
FROM
    CovidDeaths
where continent != " "
group by continent, location
order by TotalDeathCount desc;

-- Global numbers by date

SELECT 
    sum(new_cases) as totalCases,
    sum(cast(new_deaths as double)) as totalDeaths,
   (sum(cast(new_deaths as double))/sum(new_cases))*100 AS DeathPercentage
FROM
    CovidDeaths
where continent != " "
group by date
order by totalCases;


-- Global number totals

SELECT 
    sum(new_cases) as totalCases,
    sum(cast(new_deaths as double)) as totalDeaths,
   (sum(cast(new_deaths as double))/sum(new_cases))*100 AS DeathPercentage
FROM
    CovidDeaths
where continent != " "
order by totalCases;

-- starting to look at CovidVaccinations table as well
-- looking at total population vs vaccinations

select 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
sum(cast(new_vaccinations as double)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated,
(sum(cast(new_vaccinations as double)) over (partition by d.location order by d.location, d.date)/d.population)*100 as PercentPopVaccinated
from coviddeaths d join covidvaccinations v on d.location= v.location
where d.continent != " "
order by d.location, d.date
limit 1000;

-- Use CTE

with PopVsVac (continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated) as 
(select 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
sum(cast(new_vaccinations as double)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from coviddeaths d join covidvaccinations v on d.location= v.location and d.date = v.date
where d.continent != " "
)
select * , (rollingPeopleVaccinated/Population)*100 as PercentVaccinated
from PopVsVac
order by location, date;


-- Temp Table 

DROP Table if exists PercentPopulationVaccinated ;

Create Temporary Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date nvarchar(255),
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into PercentPopulationVaccinated 
Select d.continent, 
d.location, 
d.date, 
d.population, 
(Cast(v.new_vaccinations as real)),
SUM(Cast(v.new_vaccinations as real)) OVER (Partition by d.Location Order by d.location, d.Date) as RollingPeopleVaccinated
From coviddeaths d 
Join CovidVaccinations v
	On d.location = v.location
	and d.date = v.date
where d.continent != " ";

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;


-- Creating view to store data for later visualizations: Rolling People Vaccinated

create view RollingPeopleVaccinated AS
Select 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
sum(cast(new_vaccinations as double)) over (partition by d.location order by d.location, d.date) as RollingPeopleVaccinated
from coviddeaths d join covidvaccinations v on d.location= v.location and d.date = v.date
where d.continent != " ";

select * from RollingPeopleVaccinated;

-- Creating view to store data for later visualizations: Rolling People Vaccinated: Global Numbers by date

create view GlobalNumbersByDate AS
SELECT 
    sum(new_cases) as totalCases,
    sum(cast(new_deaths as double)) as totalDeaths,
   (sum(cast(new_deaths as double))/sum(new_cases))*100 AS DeathPercentage
FROM
    CovidDeaths
where continent != " "
group by date
order by totalCases;

-- view: Countries with the highest death count per population

create view CountriesHighestDeaths AS
SELECT 
	continent,
    location,
    max(cast(total_deaths AS double)) as TotalDeathCount
FROM
    CovidDeaths
where continent != " "
group by continent, location
order by TotalDeathCount desc;

-- View: Looking at countries with highest infection rate compared to population

create view CountriesInfectionRatePerPop AS
SELECT 
	continent,
    location,
    population,
    max(total_cases) as HighestInfectionCount,
	max(total_cases/population)*100 as PercentPopulationInfected
FROM
    CovidDeaths
where continent != " "
group by location, population
order by PercentPopulationInfected desc;

-- View: Shows likelihood of dying if you contract Covid 
create view LikelihoodDeathIfContracted AS
SELECT 
	continent,
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 AS DeathPercentage
FROM
    CovidDeaths
where continent != " ";

select * from LikelihoodDeathIfContracted;


-- View: Shows what percentage of US population has gotten Covid
create view PercentOfUSContractedByDate AS
SELECT 
	continent,
    location,
    date,
    total_cases,
	population,
    (total_cases/population)*100 AS PopPercentage
FROM
    CovidDeaths
where continent != " " and location = "United States";

select * from PercentOfUSContractedByDate;
