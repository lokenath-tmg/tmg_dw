select client_name,
billing_name,
client_code,
est_billing_amount
from {{source("keka_client_source","client_billing_stage")}}
