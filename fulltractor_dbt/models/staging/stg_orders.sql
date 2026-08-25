select
    id          as order_id,
    user_id     as customer_id,
    total_price as order_total_amount,
    order_date  as ordered_at
from {{ source('raw', 'orders') }}