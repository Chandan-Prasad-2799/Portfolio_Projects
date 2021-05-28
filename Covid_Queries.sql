
-- selecting data to use
Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio_Project..Covid_Deaths$
order by 1,2

-- total cases vs total deaths: percentage of deaths

Select location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 as percentage_of_death --finding death percentage
From Portfolio_Project..Covid_Deaths$
where location like '%india%'
order by 1,2

-- total cases vs population
Select location, date, total_cases,population, total_deaths, (total_cases/ population)*100 as percentage_of_positivity --finding positivity percentage
From Portfolio_Project..Covid_Deaths$
where location like '%india%'
order by 1,2

-- countries with highest infection rate
Select location,population, max(total_cases) as Highest_infection_rate, max((total_cases/ population)*100) as percentage_of_infection --finding infection rate percentage
From Portfolio_Project..Covid_Deaths$
group by location, population
order by percentage_of_infection desc

-- continents with highest death counts
Select location, max(cast(total_deaths as int)) as Highest_death_rate --finding high death rate percentage
From Portfolio_Project..Covid_Deaths$
where continent is null
group by location
order by Highest_death_rate desc

-- global numbers
Select --date, 
sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, (sum(cast(new_deaths as int))/sum(new_cases)*100) as percentage_of_death --finding death percentage
From Portfolio_Project..Covid_Deaths$
where continent is not null
--group by date
order by 1,2



Select * 
from Portfolio_Project..Covid_Vaccinations$

-- joining tables
Select * 
From Portfolio_Project..Covid_Deaths$ death
Join Portfolio_Project..Covid_Vaccinations$ vacc
	on death.location= vacc.location
	and death.date= vacc.date

-- percentage of vaccination
-- it will give vacc % by location

Select death.continent,death.location, death.date, death.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) Over (Partition by death.location order by death.location, death. date) as total_vaccinated_till_date -- this creates a view about rolling number of vaccination daily add up counts.  
From Portfolio_Project..Covid_Deaths$ death
Join Portfolio_Project..Covid_Vaccinations$ vacc
	on death.location= vacc.location
	and death.date= vacc.date
where death.continent is not null
order by 2,3

-- creating a temporary table
With pop_vs_vacc (continent, location, date, population, new_vaccinations, total_vaccinated_till_date)
as
(
Select death.continent,death.location, death.date, death.population, vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) Over (Partition by death.location order by death.location, death. date) as total_vaccinated_till_date -- this creates a view about rolling number of vaccination daily add up counts.  
From Portfolio_Project..Covid_Deaths$ death
Join Portfolio_Project..Covid_Vaccinations$ vacc
	on death.location= vacc.location
	and death.date= vacc.date
where death.continent is not null
)

select *, (total_vaccinated_till_date/ population* 100) as total_vacc_percentage
from pop_vs_vacc


-- Temp Table
Drop table if exists #pop_vs_vacc
Create table #pop_vs_vacc
(continent nvarchar(255), 
location nvarchar(255), 
date datetime , 
population numeric, 
total_vaccinated_till_date numeric)

insert into #pop_vs_vacc
Select death.continent,death.location, death.date, death.population,
sum(cast(vacc.new_vaccinations as int)) Over (Partition by death.location order by death.location, death. date) as total_vaccinated_till_date -- this creates a view about rolling number of vaccination daily add up counts.  
From Portfolio_Project..Covid_Deaths$ death
Join Portfolio_Project..Covid_Vaccinations$ vacc
	on death.location= vacc.location
	and death.date= vacc.date
where death.continent is not null

select * 
from #pop_vs_vacc

-- creating view to store data for visualization
drop view if exists people_vaccinated
create view people_vaccinated as
Select death.continent,death.location, death.date, death.population,
sum(convert(int, vacc.new_vaccinations)) Over (Partition by death.location order by death.location, death. date) as total_vaccinated_till_date -- this creates a view about rolling number of vaccination daily add up counts.  
From Portfolio_Project..Covid_Deaths$ death
Join Portfolio_Project..Covid_Vaccinations$ vacc
	on death.location= vacc.location
	and death.date= vacc.date
where death.continent is not null

select * 
from people_vaccinated