{{ config(materialized='incremental', unique_key=['category_name', 'sales_month']) }}

select
    category_name,
    date_trunc('month', ordered_at) as sales_month,
    count(distinct order_item_id)   as line_count,
    sum(line_amount)                as total_sales
from {{ ref('int_sales_lines') }}
group by 1, 2