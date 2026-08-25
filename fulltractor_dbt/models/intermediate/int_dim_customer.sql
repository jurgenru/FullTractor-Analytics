SELECT o.customer_id, u.full_name, o.ordered_at, o.order_total_amount
FROM {{ref('stg_orders')}} o
JOIN {{ref('stg_users')}} u ON o.customer_id = u.customer_id