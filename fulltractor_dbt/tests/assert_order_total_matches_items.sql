select
    o.order_id,
    o.order_total_amount,
    sum(oi.line_amount) as items_total
from {{ ref('stg_orders') }} o
join {{ ref('stg_order_items') }} oi on oi.order_id = o.order_id
group by 1, 2
having abs(o.order_total_amount - sum(oi.line_amount)) > 0.01