select
    distinct customer_id,
    country
from {{ ref('stg_online_retail') }}
order by customer_id
