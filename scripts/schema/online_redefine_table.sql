1. execute dbms_redefinition.can_redef_table('&schema','&table_name',dbms_redefinition.cons_use_pk);
2. create interim table
    create table FB.form_submission_tmp(
         ID  NUMBER,
         FORM NUMBER,
         USER_NAME    VARCHAR2(64),
         SUBMISSION_DATE   DATE,
         COMPLETED  NUMBER(1),
         SUBMISSION_TOKEN VARCHAR2(500),
         WARWICK_ID VARCHAR2(100),
         USERCODE VARCHAR2(100),
         DELETED_DATE DATE,
         USER_EMAIL VARCHAR2(500)
         );
 3.
   begin 
    dbms_redefinition.start_redef_table('FB','FORM_SUBMISSION','FORM_SUBMISSION_TMP',
               'id id, to_number(form) form, user_name user_name,submission_date submission_date, ' ||
               'completed completed, submission_token submission_token,warwick_id warwick_id,' ||
               'usercode usercode,deleted_date deleted_date,user_email user_email',
               dbms_redefinition.cons_use_pk);
   end;
   
   The process can be aborted using:
     exec dbms_REdefinition.abort_redef_table('FB','form_submission','form_submission_tmp');
     
 4. 
     DECLARE
     num_errors PLS_INTEGER;
     BEGIN
     dbms_redefinition.copy_table_dependents('FB','FORM_SUBMISSION','FORM_SUBMISSION_TMP', 
           DBMS_REDEFINITION.CONS_ORIG_PARAMS, TRUE, TRUE, TRUE, TRUE, num_errors);
     END;
     copy index,trigger,constraints,privilege and ignore errirs
 5. select object_name, base_table_name, ddl_txt from DBA_REDEFINITION_ERRORS ;
 6 optional,  
    execute DBMS_REDEFINITION.SYNC_INTERIM_TABLE('FB', 'FORM_SUBMISSION', 'FORM_SUBMISSION_TMP');
 7    execute     DBMS_REDEFINITION.FINISH_REDEF_TABLE('FB', 'FORM_SUBMISSION', 'FORM_SUBMISSION_TMP');
 8 drop the interim table
 
 
 ------------------------------------------------------------------------------------------------------

1. execute dbms_redefinition.can_redef_table('&&SCHEMA','FILES',dbms_redefinition.cons_use_pk);

2. create interim table

    create table "&&SCHEMA"."FILES_TMP"(
    ID                                        VARCHAR2(255) NOT NULL,
    NODETYPE                                  VARCHAR2(255) NOT NULL,
    PARENTID                                          VARCHAR2(255),
    NAME                                              NVARCHAR2(2000),
    OWNERID                                            VARCHAR2(255),
    CREATEDDATE                                        TIMESTAMP(6),
    LASTMODIFIEDDATE                                   TIMESTAMP(6),
    ACCOUNTID                                          VARCHAR2(255),
    MIMETYPE                                           VARCHAR2(255),
    FILESIZE                                           NUMBER(19),
    VIRUSCHECKED                                       NUMBER(1),
    HASVIRUS                                           NUMBER(1),
    VIRUSCHECKING                                      NUMBER(1),
    CLIENTLASTMODIFIEDDATE                             TIMESTAMP(6)
   );
 3.
   begin 
   dbms_redefinition.start_redef_table('&&SCHEMA','FILES','FILES_TMP',
               'ID ID, NODETYPE NODETYPE, PARENTID PARENTID,NAME NAME, ' ||
               'OWNERID OWNERID, CREATEDDATE CREATEDDATE,LASTMODIFIEDDATE LASTMODIFIEDDATE,' ||
               'ACCOUNTID ACCOUNTID,MIMETYPE MIMETYPE,FILESIZE FILESIZE, VIRUSCHECKED VIRUSCHECKED, HASVIRUS HASVIRUS, VIRUSCHECKING VIRUSCHECKING, CLIENTLASTMODIFIEDDATE CLIENTLASTMODIFIEDDATE',
               dbms_redefinition.cons_use_pk,
               'PARENTID,NODETYPE');
   end;
   
   The process can be aborted using:
     exec dbms_REdefinition.abort_redef_table('&&SCHEMA','FILES','FILES_TMP');
     
 4. copy index,trigger,constraints,privilege and ignore errors
     
     DECLARE
     num_errors PLS_INTEGER;
     BEGIN
     dbms_redefinition.copy_table_dependents('&&SCHEMA','FILES','FILES_TMP', 
           DBMS_REDEFINITION.CONS_ORIG_PARAMS, TRUE, TRUE, TRUE, TRUE, num_errors);
     END;
     
 5. select object_name, base_table_name, ddl_txt from DBA_REDEFINITION_ERRORS ;
 
 6  Optional,  
    execute DBMS_REDEFINITION.SYNC_INTERIM_TABLE('&&SCHEMA', 'FILES', 'FILES_TMP');
    
 7 execute  DBMS_REDEFINITION.FINISH_REDEF_TABLE('&&SCHEMA', 'FILES', 'FILES_TMP');
 
 8 drop the interim table
   