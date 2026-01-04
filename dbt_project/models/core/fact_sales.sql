select
    invoice_no,
    customer_id,
    stock_code,
    description,
    quantity,
    unit_price,
    quantity * unit_price as total_value,
    cast(invoice_date as date) as order_date
from {{ ref('stg_online_retail') }}
