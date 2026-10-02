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
  tsk.completion_attachment
from {{source('internal_task_source','dim_task_int')}}  as tsk