{{
    config(
        materialized='incremental',
        unique_key='invoice_no'
    )
}}

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

{% if is_incremental() %}
    -- Only process records newer than the max date in the existing table
    where cast(invoice_date as date) > (select max(order_date) from {{ this }})
{% endif %}
