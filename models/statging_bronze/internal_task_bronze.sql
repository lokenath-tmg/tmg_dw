SELECT
  tsk.id AS task_id,
  tsk.name,
  tsk.client,
  tsk.task,
  TRY_TO_DATE(tsk.planned, 'dd/MM/yyyy') AS planned,
  TRY_TO_DATE(tsk.actual, 'dd/MM/yyyy') AS actual,
  tsk.source_sheet,
  tsk.actual_status,
  tsk.mdo,
  tsk.project_id,
  tsk.completion_attachment,
  concat_ws("-", "W", weekofyear(TRY_TO_DATE(tsk.planned, 'dd/MM/yyyy')), year(TRY_TO_DATE(tsk.planned, 'dd/MM/yyyy'))) as week_year,
  concat_ws("-", MONTHNAME(TRY_TO_DATE(tsk.planned, 'dd/MM/yyyy')), year(TRY_TO_DATE(tsk.planned, 'dd/MM/yyyy'))) as month_year,
  concat_ws("-", "Q", QUARTER(TRY_TO_DATE(tsk.planned, 'dd/MM/yyyy')), year(TRY_TO_DATE(tsk.planned, 'dd/MM/yyyy'))) as quarter_year
from {{source('internal_task_source','dim_task_int')}}  as tsk