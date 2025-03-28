select * from GG_Energy

--List all unique energy sources available in the dataset.

select EnergySource
from GG_Energy
Group by EnergySource

--Count the total number of records for each country.

select country, Count(Country) as Total_records
from GG_Energy
group by Country

--Find the average energy production for each energy source.

select EnergySource, avg(cast(EnergyProduction as float)) as Avg_engery_produced
from GG_Energy
group by EnergySource

--Calculate the total carbon reduction for each year.

select year, Sum(cast(CarbonProduction as float)) as Total_carbon_production
from GG_Energy
group by year
order by Year desc

--Retrieve the top 5 countries with the highest energy production.

select top 5 country, sum(cast(EnergyProduction as float)) as Total_energy_Production
from GG_Energy
group by Country
order by Total_energy_Production desc

--Find the country with the lowest carbon reduction in a given year.

select top 1 country, sum(cast(EnergyProduction as float)) as Total_energy_Production
from GG_Energy
group by Country
Order by Total_energy_Production ASC

--Group investments by energy source and calculate the average investment.

select EnergySource, avg(cast(Investment as float)) as Avg_Investment
from GG_Energy
Group by EnergySource

--List the top 10 records based on jobs created.

select top 10 * 
from GG_Energy
order by JobsCreated desc

--Find countries with more than 100000 jobs created.

select Country, JobsCreated
from GG_Energy
where JobsCreated > 100000

--Calculate the total investment made by each country.

select Country, Sum(cast(Investment as Float)) As Total_investment
from GG_Energy
Group by Country

--Find the highest energy production in each year.

select Year, max(EnergyProduction) As Highest_energy_production
from GG_Energy
Group by Year

--Retrieve records where carbon reduction is above 500000.

select *
from GG_Energy
where CarbonProduction > 500000

--Find the average carbon Production for each energy source.

select EnergySource, Avg(cast(CarbonProduction as float)) as Avg_Carbon_Production
from GG_Energy
group by EnergySource

--List countries that invested more than $500 million.

select Country, sum(cast(Investment as float)) as Total_Investment
From GG_Energy
where Investment > 500000000
group by Country 

--Calculate the total energy production per year.

select Year, Sum(Cast(EnergyProduction as float)) as Total_Energy_production
from GG_Energy
Group by year

--Find countries that produced more than 50000 units of solar energy.

select Country, sum(cast(EnergyProduction as float)) as Total_energy_production
from GG_Energy
where EnergySource = 'Solar' 
group by Country
having sum(cast(EnergyProduction as float)) > 50000
 
-- Count the number of records where investment exceeds $1 billion.

select *
from GG_Energy
where Investment > 1000000000

--Find the average number of jobs created per energy source.

select EnergySource, Avg(cast(JobsCreated as float)) as Avg_Job_Created
from GG_Energy
group by EnergySource

--List countries with the maximum and minimum energy production.

select top 1 Country, Max(EnergyProduction) as Max_EProduction 
from GG_Energy
Group BY Country
order by  Max(EnergyProduction) desc 

select top 1 Country, Min(EnergyProduction) as MIn_Eproduction
from GG_Energy
Group BY Country
order by  Min(EnergyProduction) asc

--Retrieve records sorted by carbon Production in descending order.

select *
from GG_Energy
order by CarbonProduction desc

--Calculate the yearly average jobs created.

select year, Avg(cast(JobsCreated as float)) as Avg_Jobs_created
from GG_Energy
Group by Year

--Find the most common energy source for each country.

select country, 
mode() within group (Order by EnergySource) as MostCommonEnergy
from GG_Energy
group by Country

--Retrieve the total carbon production by Country

select Country, Sum(cast(CarbonProduction as Float)) as Total_Carbon_Production
from GG_Energy
Group by Country

--Calculate the difference between maximum and minimum energy production for each country.

select Country, max(EnergyProduction)-min(EnergyProduction) as Production_Difference
from GG_Energy
group by Country

--Identify energy sources with average carbon production above 300000.

Select EnergySource, Avg(cast(carbonProduction as float)) as Avg_Carbon_Production
from GG_Energy
group by EnergySource
having Avg(cast(carbonProduction as float)) > 300000

--Find records where jobs created are below the average for that energy source.

select *
from GG_Energy as g1
where JobsCreated < (
						select  Avg(cast(JobsCreated as float)) as AvgjobCreated
						from GG_Energy as g2
						where g1.EnergySource = g2.EnergySource
						)



--List records where the investment per job created is the highest

select *
from GG_Energy
where (investment /nullif(JobsCreated, 0)) = ( select max(investment / nullif(jobscreated, 0))
												from GG_Energy)

--Retrieve the first and last records for each energy source.

with rank as ( select *,
						rank () over (partition by EnergySource order by year desc) as firstrecord,
						Rank () over (partition by EnergySource order by year asc) as lastrecord
						from GG_Energy
						) 
						  select *
						  from rank
						  where firstrecord = 1 or lastrecord = 1;