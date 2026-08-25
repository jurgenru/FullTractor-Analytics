select
    oi.order_item_id,
    oi.line_amount,
    o.ordered_at,
    o.customer_id,
    p.product_name,
    c.category_name
from {{ ref('stg_order_items') }} oi
join {{ ref('stg_orders') }}      o on o.order_id   = oi.order_id
join {{ ref('stg_products') }}    p on p.product_id = oi.product_id
join {{ ref('stg_categories') }}  c on c.category_id = p.category_id