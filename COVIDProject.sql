Select continent, location, date, total_cases, new_cases, total_deaths, population
From portfolio.coviddeaths3
Order by 1,2;

# looking at total cases vs total deaths
# and likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
From portfolio.coviddeaths3
Where location like '%swi%'
Order by 1,2 and date;	


# looking at total cases vs population (ex US)
# percentage of population got Covid
Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
From portfolio.coviddeaths3
Where location like '%state%' AND date = '22.04.21' and  continent != 'A'
Order by 1,2 and date;	

#looking at countries with Highest infection rate compared to population
Select location, population, MAX(total_cases), MAX((total_cases/population)*100) as CasesPercentage
From portfolio.coviddeaths3
where continent != 'A'
Group by location, population
Order by CasesPercentage desc;

#looking at countries with Highest infection rate compared to population
Select location, population, MAX(total_deaths), MAX((total_deaths/population)*100) as DeathsPercentage
From portfolio.coviddeaths3
where continent != 'A'
Group by location, population
Order by DeathsPercentage desc;

#Countries with highst died count per population

Select location, max(total_deaths) as TotalDeathPerCountry
From portfolio.coviddeaths3
where continent != 'A'
Group by location
Order by TotalDeathPerCountry desc;

#Continent with highst died count per population
Select continent, max(total_deaths) as TotalDeathPerCountry
From portfolio.coviddeaths3
where continent != 'A'
Group by continent
Order by TotalDeathPerCountry desc;

#Global new cases
Select date, sum(new_cases) as NewCases, sum(new_deaths) as NewDeaths, (sum(new_deaths)/sum(new_cases))*100 as PercentageDeathinNewCases
From portfolio.coviddeaths3
Where continent !='A'
Group by date
Order by date desc;

# Population vs Vaccination
Select d.continent, d.location, d.date, d.population, v.new_vaccinations
From portfolio.coviddeaths3 as d JOIN portfolio.covidvaccinations3 as v
	on d.location = v.location and d.date = v.date
Where d.continent !='A'
Order by 2,3;

# Sum of new vaccination per day per location (aggregation)
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
		SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
From portfolio.coviddeaths3 as d JOIN portfolio.covidvaccinations3 as v
	on d.location = v.location and d.date = v.date
Where d.continent !='A'
Order by 2,3;

# use of CTE

WITH PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
AS
(Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
		SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
From portfolio.coviddeaths3 as d JOIN portfolio.covidvaccinations3 as v
	on d.location = v.location and d.date = v.date
Where d.continent !='A'
)
Select *, (RollingPeopleVaccinated/population)*100 as CumulativePercentageOfVaccinated
From PopvsVac;

# creating view to store data for later visualization in Tableau

CREATE VIEW portfolio.PopvsVac AS
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
		SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) as RollingPeopleVaccinated
From portfolio.coviddeaths3 as d JOIN portfolio.covidvaccinations3 as v
	on d.location = v.location and d.date = v.date
Where d.continent !='A';

CREATE VIEW portfolio.GlobalNewCases AS
Select date, sum(new_cases) as NewCases, sum(new_deaths) as NewDeaths, (sum(new_deaths)/sum(new_cases))*100 as PercentageDeathinNewCases
From portfolio.coviddeaths3
Where continent !='A'
Group by date
Order by date desc;