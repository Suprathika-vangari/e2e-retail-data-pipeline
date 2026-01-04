select
    InvoiceNo as invoice_no,
    StockCode as stock_code,
    Description as description,
    Quantity as quantity,
    InvoiceDate as invoice_date,
    UnitPrice as unit_price,
    CustomerID as customer_id,
    Country as country
from "retail_db"."raw"."online_retail_II"
where CustomerID is not null