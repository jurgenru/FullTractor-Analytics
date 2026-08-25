select
    id          as product_id,
    category_id as category_id,
    name        as product_name,
    stock       as stock_quantity,
    price       as current_price
from {{ source('raw', 'products') }}