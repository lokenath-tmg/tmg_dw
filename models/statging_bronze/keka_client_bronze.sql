select client_name,
billing_name,
client_code,
est_billing_amount
from {{source("keka_client_source","dim_client_billing_bronze")}}
