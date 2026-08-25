select
    id                          as order_item_id,
    order_id                    as order_id,
    product_id                  as product_id,
    historical_price            as unit_price,
    quantity                    as quantity,
    historical_price * quantity as line_amount
from {{ source('raw', 'order_items') }}