
/*
Project: Real Estate Price Analysis
Author: Ashwini Jindam
Tool Used: SQL Server (SSMS)
Dataset: King County Housing Data
Description: Exploratory Data Analysis to identify key factors affecting house prices.
*/


-- View sample data
SELECT top 10* FROM DBO.RE_DATASET;

EXEC sp_help 'DBO.RE_DATASET';


--** DATA MODELING ** --

ALTER TABLE DBO.RE_DATASET
ADD S_DATE date

UPDATE DBO.RE_DATASET
SET S_DATE = convert(date, left(S_date,8)

ALTER TABLE DBO.RE_DATASET
DROP COLUMN date 

ALTER TABLE DBO.RE_DATASET
ALTER COLUMN PRICE bigint

ALTER TABLE DBO.RE_DATASET
ALTER COLUMN lat decimal(10,4)

ALTER TABLE DBO.RE_DATASET
ALTER COLUMN long decimal(10,4)



-- ** DATA CLEANING ** --
-- checking NULL values
Select count(*)
from dbo.RE_DATASET
where id is null

Select SUM(CASE WHEN price is null THEN 1 ELSE 0 end) as Price_null,
		SUM(CASE WHEN bedrooms is null THEN 1 ELSE 0 end) as bedroom_null,
		SUM(CASE WHEN bathrooms is null THEN 1 ELSE 0 end) as Bathroom_null,
		SUM(CASE WHEN sqft_living is null THEN 1 ELSE 0 end) as sqft_living_null,
		SUM(CASE WHEN sqft_lot is null THEN 1 ELSE 0 end) as Sqft_lot_null,
		SUM(CASE WHEN zipcode is null THEN 1 ELSE 0 end) as zipcode_null
from dbo.RE_DATASET

-- Checking DUplicate values
Select id,count(*) as id_count
from dbo.RE_DATASET					--here we can see duplicate id s 
group by id having count(*) >1

select * from dbo.RE_DATASET
where id = 8103000110				--but one house can be sold multiple times so checking by date and price
order by S_DATE

SELECT id, S_DATE, count(*)
FROM dbo.RE_DATASET					-- No duplicates here
group by Id, s_date
having count(*) >1



-- ** EPLORATORY DATA ANALYSIS ** --

-- find the Most Cheapest and most Expensive house price
Select Min(price) as Cheapest_house,
		Max(price) as Expensive_house
from dbo.RE_DATASET

-- Top 10 Most Expensive houses
select Top 10 id,price,bedrooms,
			bathrooms,sqft_living,sqft_lot,
			zipcode
from dbo.RE_DATASET
order by Price desc

-- Top 10 Cheapest houses
select Top 10 id,price,bedrooms,
			bathrooms,sqft_living,sqft_lot,
			zipcode
from dbo.RE_DATASET
order by Price


-- AVG Price of house
select avg(price) from dbo.RE_DATASET

-- Which bedroom count is the most common 
Select bedrooms, count(*) as Total_houses
from dbo.RE_DATASET								-- 3 bedrooms is the most common 
group by bedrooms
order by Total_houses DESC

--Does waterfront increase the price?
select waterfront, avg(price) as AVG_Price 
from dbo.RE_DATASET								-- avg_price of waterfront is higher than avg_price of normal
group by waterfront

-- Aerage price by Zipcode
select zipcode, Avg(price) as AVG_price
from dbo.RE_DATASET
group by zipcode
order by AVG_price desc

-- Does more bedrooms always mean higher price? (price vs Bedrooms relationship)
select bedrooms, avg(Price) as AVG_Price,
		AVG(sqft_living) as avg_sqft_living,		-- Bedroom alone do not determine price other factors also influcing price strongly
		AVG(grade) as avg_grade
from dbo.RE_DATASET
group by bedrooms
order by bedrooms

--Property Grade impact on price
select Grade, avg(price)as avg_price,
		count(*) as total_houses					-- Grade often influences price more than bedrooms because price increasing with grade
from dbo.RE_DATASET
group by  grade
order by Grade

--Price trend by Year
select Year(S_date) as date_yr,
		avg(price) as avg_price
from dbo.RE_DATASET						-- avgprice increasing by year,
group by Year(S_date)
order by avg_price


--How many houses renovated
--Whether renovation increases price
with CTE_RenovationStatus as 
(select Price,
	   case when yr_renovated = 0 then 'Not Renovated'
	        else 'Renovated'
	   End as Renovation_status
from dbo.RE_DATASET)

select  Renovation_status,
		count(*) as Total_houses,
		avg(price) as avg_price
from CTE_RenovationStatus
group by Renovation_status


-- Identitfy top 5 most premium areas
select top 5 zipcode, avg(price)as avg_price,
		count(*)as Total_houses
from dbo.RE_DATASET
group by zipcode
order by avg_price DESC

--Does an increase in living area (sqft) significantly impact house prices?
SELECT 
    sqft_living,    
    price
FROM dbo.RE_DATASET
ORDER BY sqft_living desc


select avg(Price) as avg_price,sqft_category
from
(select price,
	case When sqft_living < 1000 then 'Small'
		When sqft_living between 1000 and 3000 then 'Medium' 
		When sqft_living between 3000 and 5000 then 'Large'
		else 'Luxury'
	end as sqft_category
from dbo.RE_DATASET) as CAT
group by sqft_category
order by avg_price

