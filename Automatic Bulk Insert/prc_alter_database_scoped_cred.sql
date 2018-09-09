
/****************************************************************
   Name: prc_alter_database_scoped_cred
   Desc: Stored Procedure to alter database scoped credential
   Author: Karan Dama
   
   Pre-Requisites : Setup dbscopedcredential_import in database
*****************************************************************/

CREATE procedure [dbo].[prc_alter_database_scoped_cred]
(
@SASKey varchar(1000),
@returnvalue11 int output
)

AS

BEGIN

set @returnvalue1 = 0


DECLARE @cmd1 varchar(1000), @msg varchar(1000),



BEGIN TRY
BEGIN TRANSACTION

 set @cmd1 = 'ALTER DATABASE SCOPED CREDENTIAL dbscopedcredential_import WITH IDENTITY = ''SHARED ACCESS SIGNATURE'', SECRET = ''' + @SASKey + ''''
 exec (@cmd1)



COMMIT TRANSACTION
END TRY



BEGIN CATCH
ROLLBACK TRANSACTION
SET @msg = ( 
				'Error Number:'+ COALESCE(Str(Error_number()), '') + ' '
				+ 'Error Message:'
				+ COALESCE(Error_message(), '') + ' '
				+ 'Line Number:'
				+ COALESCE(Str(Error_line()), '') + ' '
				+ 'Procedure Name:'
				+ COALESCE(Error_procedure(), '') 

			);


PRINT @msg;
set @returnvalue1 = 1

END CATCH


END

