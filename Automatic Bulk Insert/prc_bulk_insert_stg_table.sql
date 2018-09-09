
/****************************************************************
   Name: prc_bulk_insert_stg_table
   Desc: Stored Procedure to load csv data file from Azure blob storage
   into  staging table
   Author: Karan Dama
   
   Pre-Requisites : Setup externaldatasource_import in database
   
*****************************************************************/


CREATE procedure [dbo].[prc_bulk_insert_stg_table] @SASKey varchar(1000) , @returnvalue VARCHAR(100) Output
AS

BEGIN

DECLARE @row_cnt1 INT ,@row_cnt2 INT ,@msg  VARCHAR(max) ,@stgcmd VARCHAR(MAX),@returnvalue1 int;


EXEC [dbo].[prc_alter_database_scoped_cred] @SASKey ,@returnvalue1

SET @returnvalue='SUCCESS'

SELECT @row_cnt1 = Count(*)
      FROM   dbo.stage_table;


      PRINT N'Number of records in stage table =  '
                + Cast(@row_cnt1 AS VARCHAR)

--------**********Truncate Staging tables******--------

truncate table dbo.stage_table;

PRINT N'Truncate staging table complete'


---------********* Populate Stage Table *********-----------
	
BEGIN TRY
BEGIN TRANSACTION

SET @stgcmd = 
'BULK INSERT dbo.stage_table FROM ''file.csv'' ' +
'WITH ( ' +
'DATA_SOURCE = ''externaldatasource_import'', '+
'firstrow=1,FIELDTERMINATOR = '','', ROWTERMINATOR   = ''0x0a'') '


EXECUTE (@stgcmd) ;

COMMIT TRANSACTION
END TRY


BEGIN CATCH
ROLLBACK TRANSACTION
SET @msg = ( Cast(Getdate() AS VARCHAR(50))
                       + ' Error Number : '
                       + COALESCE(Str(Error_number()), '') + ' '
                       + ' Error Message : '
                       + COALESCE(Error_message(), '') + ' '
                       + 'Line Number : '
                       + COALESCE(Str(Error_line()), '') + ' '
                       + 'Procedure Name : '
                       + COALESCE(Error_procedure(), '') );


PRINT @msg;

SET @returnvalue='FAILURE'

END CATCH


SELECT @row_cnt2 = Count(*)
      FROM   dbo.stage_table;

 PRINT N'Number of records stage table =  '
                + Cast(@row_cnt2 AS VARCHAR)
				

END
