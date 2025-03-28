use jaspaldb

select * from dbo.GGEnergy

create table GG_Energy(
Country varchar (20),
year int,
EnergySource varchar(20),
EnergyProduction int,
CarbonProduction int,
Investment int,
JobsCreated int
);

insert into GG_Energy(
Country,
Year,
EnergySource,
EnergyProduction,
CarbonProduction,
Investment,
JobsCreated
)

select Country,
year,
EnergySource,
EnergyProduction,
CarbonReduction,
Investment,
JobsCreated
from dbo.GGEnergy

select * 
from GG_Energy

--growth rate of energy production over the years.

with yearlyproduction as(
						select year, sum(cast(EnergyProduction as float)) as TotalProduction
						from GG_Energy
						Group BY year
						),
Growthrate as (
				select year, TotalProduction,
				lag(TotalProduction) over (order by year) as PreviousProduction,
				case
					when lag(TotalProduction) over (order by year) = 0 Then Null
					Else ((TotalProduction - lag(TotalProduction) over (order by year)) / lag(TotalProduction) over (order by year)) * 100
					end as Growthrate
					from yearlyproduction
					)
select year, TotalProduction, Growthrate
from Growthrate

order by Growthrate desc

--countries with the highest increase in investment from one year to the next.

with investmentgrowth as (
							select country, year, investment,
							lag(Investment) over (partition by country order by year) as previuos_year_investment,
							(investment - (lag(Investment) over (partition by country order by year))) as investment_increase
							from GG_Energy
											)
											 select country, year, investment_increase
											 from investmentgrowth
											 where investment_increase = (
																		  select max(investment_increase)
																		  from investmentgrowth);

--top 3 countries with the highest total energy production.

select top 3 Country, sum(cast(EnergyProduction as float)) as total_energy_production
from GG_Energy
group by Country
order by sum(cast(EnergyProduction as float)) desc

--the percentage share of each energy source in total energy production.

select EnergySource,
sum(cast(EnergyProduction as float)) as Total_Energy_Production,
((sum(cast(EnergyProduction as float)) *100) / (select Sum(cast(EnergyProduction as float)))) as percentage_share 
from GG_Energy
group by EnergySource
order by percentage_share desc

--correlation between investment and energy production

-- investment likely doesn’t directly impact energy production as corelation is likely 0

with corelation as(
					select 
					count(*) as N,																		--Total Number of rows, (N)
					sum(cast(Investment as float)) as x,												--Sum of all Investments (x)
					sum(cast(EnergyProduction as float)) as y,											--Sum of all energy production (y)					
					sum((cast(Investment as float)) * cast(EnergyProduction as float)) as xy,			--sum of product of investment and energy production (xy)
					sum((cast(Investment as float)) * cast(Investment as float)) as xx,					--sum of square of investment (xx)
					sum((cast(EnergyProduction as float)) * cast(EnergyProduction as float)) as yy		--sum of square of energy production (xy)
					from GG_Energy
					)
select (N * xy - x * y) /
   (SQRT((N * xx - x * x) * (N * xx - y * y))) as stats
   from corelation
 
--cumulative investment for each country over the years.

 select Country, year, Investment,
 sum(cast(Investment as float)) over ( partition by Country 
										order by year
										rows between unbounded preceding and current row) as cumulative_investment 
from GG_Energy
order by Country, year

--year-over-year percentage change in investment for each country.

select Country , 
	   Investment, 
	   year,
			lag(Investment) over (partition by Investment order by year) as previous_year_investment,
						case 
						 WHEN LAG(Investment) OVER (PARTITION BY country ORDER BY year) IS NOT NULL 
							THEN ROUND( (CAST(Investment AS DECIMAL(18,2)) - CAST(LAG(Investment) OVER (PARTITION BY country ORDER BY year) AS DECIMAL(18,2))) 
									/ CAST(LAG(Investment) OVER (PARTITION BY country ORDER BY year) AS DECIMAL(18,2)) * 100,2)
							else null
							end as YoY_investment_change
from GG_Energy
order by Country, Year

--Ranking countries based on total investment in Renewable energy sources.

select Country,
sum(cast (Investment as float)) as total_investment,
rank() over (order by (sum(cast (Investment as float))) desc) as RANKING
from GG_Energy
group by Country
order by RANKING

--the top 3 years with the highest investment for each country.

with RankedInvestment as (
select Country,
year,
SUM(cast(Investment as float)) as total_investment,
rank() over (partition by Country order by SUM(cast(Investment as float)) asc) as Ranking
from GG_Energy
group by Country, year
)
  select * 
  from RankedInvestment
  where Ranking <=3
  order by Country, Ranking

--the first and last year of recorded investment for each country.

select Country,
max(year) as First_year_of_transaction,
min(year) as Last_year_of_transaction
from GG_Energy
group by Country
order by Country

-- Detect investment trends (e.g., increasing or decreasing) for each country

with investment_record as (
						select Country, year,
							sum(cast(Investment as float)) as total_investment,
							lag(sum(cast(Investment as float))) over (partition by Country order by Year) as previous_year_investment,
							((sum(cast(Investment as float))) - (lag(sum(cast(Investment as float))) over (partition by Country order by Year))) as change_in_investment
						from GG_Energy
						group by Country, year
						)
select Country, 
	   year,
	   total_investment,
	   previous_year_investment,
	   change_in_investment,
	   case 
			when previous_year_investment is null then 'N/A (first investent)'
			when total_investment > previous_year_investment then 'Increasing'
			when total_investment < previous_year_investment then 'Decreasing'
			else 'NO Change'
			end
from investment_record
order by Country, year;

--Find the Energy Source with the Highest Variance in Investment Across Countries

with investmentstats as
(
   select EnergySource,
	 avg(cast(Investment as float)) as Total_investment,
	   count(*) as Total_entries,
		 (sum(cast(Investment as float)) / (count(*))) as mean_investment
		   from GG_Energy
		     group by EnergySource
),
   variance as 
(
   select g.EnergySource,
	SUM(POWER(CAST(g.Investment AS FLOAT) - i.mean_investment, 2)) / COUNT(*) / count(*) as Variance_Investment
	  from GG_Energy g
		join investmentstats i
		  on g.EnergySource = i.EnergySource
		    group by g.EnergySource
)
   select EnergySource, Variance_Investment
	 from variance
	   order by Variance_Investment desc

-- Optimize a query to quickly retrieve the top 10 countries by total investment.

 --CREATE INDEX idx_country_investment ON GG_Energy (Country, Investment);
SELECT TOP 10 
Country, 
SUM(cast(Investment as float)) AS total_investment
FROM GG_Energy
GROUP BY Country
ORDER BY total_investment DESC; -- to check the speed of the execution(ctrl + M)