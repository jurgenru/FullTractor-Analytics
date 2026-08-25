SELECT customer_id, full_name, count(customer_id) as total_orders, sum(order_total_amount) as total_spent, max(ordered_at) last_order, min(ordered_at) first_order
FROM {{ref('int_dim_customer')}}
GROUP BY 1, 2