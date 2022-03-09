select * 
from SQLPortefolio..coviddeaths
order by 3, 4

--select * 
--from SQLPortefolio..covidvaccinations
--order by 3, 4

select location, date, population, total_cases, new_cases, total_deaths
from SQLPortefolio..coviddeaths
order by 1, 2

-- Total Cases vs Total Deaths
select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as deaths_pourcentage
from SQLPortefolio..coviddeaths
where location like 'France'
order by 1, 2

-- Total Cases in Population
select location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 as contamination_pourcentage
from SQLPortefolio..coviddeaths
--where location = 'France'
order by 1, 2

--Contries with highest contamination compared to population
select location, population, max(total_cases) as highest_contamination, max((cast(total_cases as float)/population)*100) as percentage_contamination
from SQLPortefolio..coviddeaths
group by location, population
order by percentage_contamination desc

-- Highest deaths per countries
select location, max(cast(total_deaths as float)) as highest_deaths
from SQLPortefolio..coviddeaths
where continent is not NULL
group by location
order by highest_deaths desc

-- Highest deahts by continents
select continent, max(cast(total_deaths as float)) as highest_deaths
from SQLPortefolio..coviddeaths
where continent is not NULL
group by continent
order by highest_deaths desc

-- European figures
select date, sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, (sum(cast(new_deaths as float))/sum(nullif(cast(new_cases as float),0)))*100 as deaths_pourcentage
from SQLPortefolio..coviddeaths
where continent = 'Europe' or location = 'Europe'
group by date
order by 1, 2 desc

select sum(cast(new_cases as float)) as total_case, sum(cast(new_deaths as float)) as total_deaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as death_percentage
from SQLPortefolio..coviddeaths
where continent = 'Europe' 

--deaths by european country
select location, population, max(cast(total_cases as float)) as total_cases, max(cast(total_deaths as float)) as total_deaths, (sum(cast(new_deaths as float))/sum(cast(new_cases as float)))*100 as death_percentage
from SQLPortefolio..coviddeaths
where continent = 'Europe' 
group by location, population
order by 1, 2 desc


--Vacination

--CTE
with popvsvac (continent, location, date, population, new_vaccinations, cumulative_count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cumulative_count
from SQLPortefolio..coviddeaths dea
join SQLPortefolio..covidvaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location	
)
select*, (cumulative_count/population)*100 as percent_vacc
from popvsvac

--TEMP TABLE
drop table if exists #percentvaccinated
create table #percentvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
cumulative_count numeric
)
insert into #percentvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cumulative_count
from SQLPortefolio..coviddeaths dea
join SQLPortefolio..covidvaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location	
select*, (cumulative_count/population)*100 as percent_vacc
from #percentvaccinated

-- create View
create view francevaccination as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(float, new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as cumulative_count
from SQLPortefolio..coviddeaths dea
join SQLPortefolio..covidvaccinations vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.location = 'France'

select *
from francevaccination