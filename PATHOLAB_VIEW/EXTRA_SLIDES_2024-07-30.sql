SQL> -- שליפת ההגדרה של הVIEW
SQL> SELECT dbms_metadata.get_ddl('VIEW', '&VIEW_NAME', 'LIMS') FROM dual;
old:SELECT dbms_metadata.get_ddl('VIEW', '&VIEW_NAME', 'LIMS') FROM dual
new:SELECT dbms_metadata.get_ddl('VIEW', 'EXTRA_SLIDES', 'LIMS') FROM dual

DBMS_METADATA.GET_DDL('VIEW','EXTRA_SLIDES','LIMS')                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "LIMS"."EXTRA_SLIDES" ("SDG_ID", "REQ_ID", "CONTAINERRECEIVEDON", "SDG_PATHOLAB_NUMBER", "SAMPLE_PATHOLAB_NUMBER", "ALIQUOT_PATHOLAB_NUMBER", "PRIORITY_NUM", "PRIORITY", "SLIDE_NUMBER", "PATHOLOG_NAME", "PATHOLOG_MACRO", "PATHOLOG_MACRO_TIME", "REQUEST_DETAILS", "REQUEST_NAME", "REQUEST_STATUS", "REQUEST_ENTITY_TYPE", "REQUEST_REMARKS", "CUTTING_LABORANT", "SEDIMENTATION_LABORANT", "BLOCK_NUMBER", "REQUEST_CREATED_ON", "REQUEST_TYPE") AS 
  SELECT 
  d.sdg_id AS sdg_id,
  erdu.u_extra_request_data_id AS req_id,
  cu.u_received_on AS containerReceivedOn,
  du.u_patholab_number AS sdg_patholab_number,
  sampU.u_patholab_sample_name AS sample_patholab_number,
  aliqU.u_patholab_aliquot_name AS aliquot_patholab_number,
  du.u_priority AS priority_num,
  LIMS.phrase_lookup('Priority', du.u_priority) AS priority,
  erdu.u_slide_name AS slide_number,
  PathologOper.FULL_NAME AS patholog_name,
  MacroPathologOper.u_hebrew_name AS patholog_macro,
  res.completed_on AS patholog_macro_time,
  erdu.u_request_details AS request_details,
  er.name AS request_name,
  LIMS.phrase_lookup('Extra Request Status', erdu.u_status) AS request_status,
  erdu.u_entity_type AS request_Entity_Type,
  erdu.u_remarks AS request_remarks,
  TestOper.FULL_NAME AS cutting_laborant,
  ResultOper.FULL_NAME AS Sedimentation_laborant,
  SUBSTR(erd.name, 1, 14) AS block_number,
  eru.u_created_on AS request_created_on,
  erdu.u_req_type AS request_type
FROM sdg d
INNER JOIN sdg_user du ON d.sdg_id = du.sdg_id
INNER JOIN u_container_user cu ON cu.u_container_id = du.u_container_id
INNER JOIN sample samp ON d.sdg_id = samp.sdg_id AND samp.status <> 'X'
INNER JOIN sample_user sampU ON sampU.sample_id = samp.sample_id
INNER JOIN aliquot aliq ON samp.sample_id = aliq.sample_id AND aliq.status <> 'X'
INNER JOIN aliquot_user aliqU ON aliq.aliquot_id = aliqU.aliquot_id
LEFT JOIN test t ON t.aliquot_id = aliq.aliquot_id AND t.name LIKE '%Macro%'
LEFT JOIN result res ON res.test_id = t.test_id AND res.status = 'C' AND res.name = 'Histology Macro text'
LEFT JOIN test tem ON tem.aliquot_id = aliq.aliquot_id AND tem.name LIKE '%Embedding%' AND tem.completed_by IS NOT NULL
LEFT JOIN result er ON er.test_id = tem.test_id AND er.name LIKE '%Embedding%' AND er.completed_by IS NOT NULL
LEFT JOIN operator TestOper ON TestOper.operator_id = tem.completed_by
LEFT JOIN operator ResultOper ON ResultOper.operator_id = er.completed_by
LEFT JOIN operator PathologOper ON PathologOper.operator_id = du.u_patholog
LEFT JOIN operator_user MacroPathologOper ON MacroPathologOper.operator_id = sampU.u_patholog_macro
INNER JOIN u_extra_request_data_user erdu ON erdu.u_slide_name = aliq.name
INNER JOIN u_extra_request er ON erdu.u_extra_request_id = er.u_extra_request_id
INNER JOIN u_extra_request_user eru ON eru.u_extra_request_id = er.u_extra_request_id
INNER JOIN u_extra_request_data erd ON erdu.u_extra_request_data_id = erd.u_extra_request_data_id
WHERE erdu.u_status IN ('V', 'I') 
and erdu.U_REQ_TYPE IN ('H', 'I', 'O')

SQL> SPOOL OFF
