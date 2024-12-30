--Best selling products (revenue)
select top 10 
p.product_name as product,
round(sum(s.quantity * p.unit_price_usd * ex.exchange_rate),2) as totalspent
from ger_sales s
left join ger_products p 
on s.product_id = p. product_id
left join ger_exchange_rates ex 
on s.currency_code = ex.currency_code
and cast(s.order_date as date) = cast(ex.date as date)
group by p.product_name
order by totalspent desc

(https://github.com/user-attachments/assets/d91e6116-2f22-4be5-8745-ce65f6989d6c)

--Best selling products (Amount Sold)
select top 10 
p.product_name as product,
sum(quantity) as amountsold
from ger_sales s
left join ger_products p 
on s.product_id = p. product_id
left join ger_exchange_rates ex 
on s.currency_code = ex.currency_code
and cast(s.order_date as date) = cast(ex.date as date)
group by p.product_name
order by amountsold desc

--Yearly Analysis
select 
datepart(year, order_date) as year,
sum(s.quantity) as amountsold,
round(sum(s.quantity * p.unit_price_usd * ex.exchange_rate),2) as revenue
from ger_sales s
left join ger_products p 
on s.product_id = p. product_id
left join ger_exchange_rates ex 
on s.currency_code = ex.currency_code
and cast(s.order_date as date) = cast(ex.date as date)
group by datepart(year, order_date)
order by year

--Monthly Analysis
select 
datepart(month, order_date) as month,
sum(s.quantity) as amountsold,
round(sum(s.quantity * p.unit_price_usd * ex.exchange_rate),2) as revenue
from ger_sales s
left join ger_products p 
on s.product_id = p. product_id
left join ger_exchange_rates ex 
on s.currency_code = ex.currency_code
and cast(s.order_date as date) = cast(ex.date as date)
group by datepart(month, order_date)
order by month

--average delivery time in days
select 
avg(DATEDIFF(day,order_date, delivery_date))
from ger_sales
where Delivery_Date is not null

--By Year
select 
datepart(year, order_date) as year,
avg(DATEDIFF(day,order_date, delivery_date) * 1.0)
from ger_sales
where Delivery_Date is not null
group by datepart(year, order_date)
order by year

--online vs in-store
with sales_withlocation_CTE as (select *,
case when store_id = 0 then 'Online' else 'In-Store' end as location
from ger_sales
),
revenue_by_location_cte as (
Select 
swl.location,
(swl.quantity * p.unit_price_usd * ex.exchange_rate) as total_revenue
from sales_withlocation_CTE swl
left join ger_products p 
on swl.product_id = p. product_id
left join ger_exchange_rates ex 
on swl.currency_code = ex.currency_code
and cast(swl.order_date as date) = cast(ex.date as date))
select 
location,
avg(total_revenue) as average_order_amount,
sum(total_revenue) as total_revenue
from revenue_by_location_cte
group by location

-- Temp Table creating new Revenue table 
SELECT 
    s.customer_id,
    s.store_id,
    s.product_id,
    s.quantity,
    p.unit_price_usd,
    ex.exchange_rate,
    ROUND((s.quantity * p.unit_price_usd * ex.exchange_rate), 2) AS revenue
INTO #temp_revenue -- Create a temporary table
FROM
    GER_Sales s
JOIN
    GER_Products p
    ON s.product_id = p.product_id
JOIN
    GER_Exchange_Rates ex
    ON s.currency_code = ex.currency_code
WHERE
    ex.date = s.order_date; -- Assuming exchange rate matches sales order date

-- Top Customers
select c.name,
sum(r.quantity) as amountordered,
sum(r.revenue) as amountspent
from #temp_revenue r
left join GER_Customers c 
on r.customer_id = c.Customer_id
group by c.name
order by amountspent desc

--Gross Profit
SELECT 
    SUM((s.Quantity * p.Unit_Price_USD * ROUND(ex.Exchange_Rate, 2)) - 
        (s.Quantity * p.Unit_Cost_USD * ROUND(ex.Exchange_Rate, 2))) AS GrossProfit
FROM 
    GER_Sales s
LEFT JOIN 
    GER_Products p ON s.Product_id = p.Product_id
LEFT JOIN 
    GER_Exchange_Rates ex ON s.Currency_Code = ex.Currency_Code
    AND CAST(s.Order_Date AS DATE) = CAST(ex.Date AS DATE)
WHERE 
    s.Order_Number IS NOT NULL;

