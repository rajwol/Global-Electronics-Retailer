```sql
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
```
![Best selling products GER](https://github.com/user-attachments/assets/063c11d6-c622-42a9-bef7-28fd9de3ced0)
