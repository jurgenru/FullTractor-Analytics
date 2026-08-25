select
    id                        as customer_id,
    name                      as first_name,
    last_name                 as last_name,
    name || ' ' || last_name  as full_name
from {{ source('raw', 'users') }}