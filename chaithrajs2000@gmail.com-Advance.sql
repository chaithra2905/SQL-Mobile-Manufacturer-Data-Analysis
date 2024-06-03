--SQL Advance Case Study
use db_SQLCaseStudies

--Q1--BEGIN 
--1. List all the states in which we have customers who have bought cellphones 
--from 2005 till today.
Select State,d.YEAR from [dbo].[DIM_LOCATION] as l
inner join [dbo].[FACT_TRANSACTIONS] as ft
on l.[IDLocation]=ft.[IDLocation]
inner join [dbo].[DIM_DATE] as d
on ft.[Date]=d.[DATE]
where d.Year>=2005




--Q1--END

--Q2--BEGIN
--2. What state in the US is buying the most 'Samsung' cell phones?	

Select top 1 State,Country,[Manufacturer_Name],count(*) as cnt
from  [dbo].[DIM_LOCATION] as l
inner join [dbo].[FACT_TRANSACTIONS] as ft
on l.[IDLocation]=ft.[IDLocation]
inner join [dbo].[DIM_MODEL] as mo
on ft.[IDModel]=mo.[IDModel]
inner join [dbo].[DIM_MANUFACTURER] as ma
on mo.[IDManufacturer]=ma.[IDManufacturer]
Where Country='US' and [Manufacturer_Name]='Samsung'
group by State,Country,[Manufacturer_Name]
order by cnt desc

--Q2--END

--Q3--BEGIN      
--3. Show the number of transactions for each model per zip code per state.
Select IDModel,[ZipCode],[State],count(*) as total_transactions from [dbo].[DIM_LOCATION] as l
inner join [dbo].[FACT_TRANSACTIONS] as ft
on l.[IDLocation]=ft.[IDLocation]
group by IDModel,[ZipCode],[State]









--Q3--END

--Q4--BEGIN
--4. Show the cheapest cellphone (Output should contain the price also)
Select top 1 mo.IDModel,Model_Name,MIN(Unit_price) as Cheapest_Price from [dbo].[DIM_Model] as mo
inner join [dbo].[FACT_TRANSACTIONS] as ft
on mo.[IDModel]=ft.[IDModel]
group by mo.IDModel,Model_Name
order by Cheapest_Price




--Q4--END

--Q5--BEGIN
--5. Find out the average price for each model in the top5 manufacturers in 
--terms of sales quantity and order by average price.

Select Manufacturer_Name, mo.[IDModel],avg(TotalPrice) as avg_price,sum(quantity) as tot_qty
from FACT_TRANSACTIONS as ft join DIM_MODEL as mo
							on mo.[IDModel]=ft.[IDModel]
							inner join [dbo].[DIM_MANUFACTURER] as ma
							on mo.[IDManufacturer]=ma.[IDManufacturer]
where Manufacturer_Name in( Select top 5 Manufacturer_Name
							from FACT_TRANSACTIONS as ft
							inner join  DIM_MODEL as mo
							on mo.[IDModel]=ft.[IDModel]
							inner join [dbo].[DIM_MANUFACTURER] as ma
							on mo.[IDManufacturer]=ma.[IDManufacturer]
							group by Manufacturer_Name
							order by sum(TotalPrice) desc)
group by Manufacturer_Name, mo.[IDModel]
order by avg_price desc



--Q5--END

--Q6--BEGIN
--6. List the names of the customers and the average amount spent in 2009, 
--where the average is higher than 500

Select Customer_Name, avg(TotalPrice) as Avg_amount, d.Year from [dbo].[DIM_CUSTOMER] as c
inner join [dbo].[FACT_TRANSACTIONS] as ft
on c.[IDCustomer]=ft.[IDCustomer]
inner join [dbo].[DIM_DATE] as d
on ft.[Date]=d.[Date]
where Year='2009'
group by Customer_Name, d.Year
having avg(TotalPrice)>500







--Q6--END
	
--Q7--BEGIN  
--7. List if there is any model that was in the top 5 in terms of quantity, 
--simultaneously in 2008, 2009 and 2010	

Select * from(
Select top 5 IDModel from FACT_TRANSACTIONS ft
inner join [dbo].[DIM_DATE] d
on ft.DATE=d.Date
where Year IN('2008')
group by IDModel,Year
order by sum(Quantity) desc
) as A

INTERSECT

Select * from(
Select top 5 IDModel from FACT_TRANSACTIONS ft
inner join [dbo].[DIM_DATE] d
on ft.DATE=d.Date
where Year IN('2009')
group by IDModel,Year
order by sum(Quantity) desc
) as B

INTERSECT

Select * from
(
Select top 5 IDModel from FACT_TRANSACTIONS ft
inner join [dbo].[DIM_DATE] d
on ft.DATE=d.Date
where Year IN('2010')
group by IDModel,Year
order by sum(Quantity) desc
) as C







--Q7--END	
--Q8--BEGIN
--8. Show the manufacturer with the 2nd top sales in the year of 2009 and the 
--manufacturer with the 2nd top sales in the year of 2010.
Select * from
(
Select top 1 * 
from
(
	Select top 2 Manufacturer_Name,year(Date) as year, sum([TotalPrice]) as Sales
	from [dbo].[FACT_TRANSACTIONS] as  ft
	inner join [dbo].[DIM_MODEL] as mo
	on ft.IDModel=mo.IDModel
	inner join DIM_MANUFACTURER as ma
	on mo.IDManufacturer=ma.IDManufacturer
	where year(Date) =2009
	group by Manufacturer_Name,year(Date)
	order by Sales desc
)as A
order by Sales asc
) as C

UNION

Select * from
(
Select top 1 * 
from
(
	Select top 2 Manufacturer_Name,year(Date) as year, sum([TotalPrice]) as Sales
	from [dbo].[FACT_TRANSACTIONS] as  ft
	inner join [dbo].[DIM_MODEL] as mo
	on ft.IDModel=mo.IDModel
	inner join DIM_MANUFACTURER as ma
	on mo.IDManufacturer=ma.IDManufacturer
	where year(Date) =2010
	group by Manufacturer_Name,year(Date)
	order by Sales desc
)as A
order by Sales asc
) as D


--Q8--END
--Q9--BEGIN
--9. Show the manufacturers that sold cellphones in 2010 but did not in 2009.	

Select [Manufacturer_Name] from [dbo].[FACT_TRANSACTIONS] ft
inner join [dbo].[DIM_MODEL] mo
on ft.[IDModel]=mo.[IDModel]
inner join DIM_MANUFACTURER ma
on mo.IDManufacturer=ma.IDManufacturer
where Year(date) = 2010
except
Select [Manufacturer_Name] from [dbo].[FACT_TRANSACTIONS] ft
inner join [dbo].[DIM_MODEL] mo
on ft.[IDModel]=mo.[IDModel]
inner join DIM_MANUFACTURER ma
on  mo.IDManufacturer=ma.IDManufacturer
where Year(date) = 2009
group by [Manufacturer_Name]





--Q9--END

--Q10--BEGIN
--10. Find top 100 customers and their average spend, average quantity by each 
--year. Also find the percentage of change in their spend.	

Select * , ((avg_price-lag_price)/lag_price) as percentage_change from(

Select * , lag(avg_price,1) over (partition by IDCustomer order by year) as lag_price from
(

Select IDCustomer,year(date) as year,avg(totalprice) as avg_price,
sum(quantity) as qty from FACT_TRANSACTIONS
where IDCustomer in (Select top 10 IDCustomer from FACT_TRANSACTIONS
					 group by IDCustomer
					order by sum(totalprice) desc)
group by IDCustomer,year(date)
) as A
) as B











--Q10--END
	