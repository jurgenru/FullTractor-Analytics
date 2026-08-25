select
    product_name,
    date_trunc('month', ordered_at) as sales_month,
    count(distinct order_item_id)   as line_count
from {{ ref('int_sales_lines') }}
group by 1, 2