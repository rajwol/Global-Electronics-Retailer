```sql
Key Performance Indicators (KPIs)

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
```

```sql
--Total items sold
select sum(quantity)
from ger_sales
```

```sql
--Total Orders
select count(distinct order_number) 
from ger_sales
```

```sql
--average delivery time in days
select 
avg(DATEDIFF(day,order_date, delivery_date))
from ger_sales
where Delivery_Date is not null
```
![KPIs](https://github.com/user-attachments/assets/e544f9ad-91c5-480b-92d4-2e68e8461068)

```sql
--Best selling products (revenue)
SELECT TOP 10 
p.product_name AS product,
ROUND(SUM(s.quantity * p.unit_price_usd * ex.exchange_rate),2) AS totalspent
FROM ger_sales s
LEFT JOIN ger_products p 
ON s.product_id = p. product_id
LEFT JOIN ger_exchange_rates ex 
ON s.currency_code = ex.currency_code
AND CAST(s.order_date AS DATE) = CAST(ex.date AS DATE)
GROUP BY p.product_name
ORDER BY totalspent DESC
```
![Best selling products GER](https://github.com/user-attachments/assets/063c11d6-c622-42a9-bef7-28fd9de3ced0)

```sql
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
```
![revenue by year](https://github.com/user-attachments/assets/f55fedae-a502-4a20-91b0-32aa02c72ed9)

```sql
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
```
![Revenue by month](https://github.com/user-attachments/assets/11ed6eec-08cb-4956-a54e-83f1d648a278)

```sql
-- Temp Table creating new Revenue table 
SELECT 
    s.customer_id,
    s.store_id,
    s.product_id,
    s.quantity,
    p.unit_price_usd,
    ex.exchange_rate,
    ROUND((s.quantity * p.unit_price_usd * ex.exchange_rate), 2) AS revenue
INTO #temp_revenue 
FROM
    GER_Sales s
JOIN
    GER_Products p
    ON s.product_id = p.product_id
JOIN
    GER_Exchange_Rates ex
    ON s.currency_code = ex.currency_code
WHERE
    ex.date = s.order_date;
```

```sql
-- Top Customers (Total Amount Spend)
select c.name,
sum(r.quantity) as amountordered,
sum(r.revenue) as amountspent
from #temp_revenue r
left join GER_Customers c 
on r.customer_id = c.Customer_id
group by c.name
order by amountspent desc
```
![Top Customers (Amount Spent)](https://github.com/user-attachments/assets/70a31017-2826-49a3-a13e-39f0b1250012)

