select
    id       as payment_id,
    order_id as order_id,
    method   as payment_method,
    amount   as payment_amount,
    paid_at  as paid_at
from {{ source('raw', 'payments') }}