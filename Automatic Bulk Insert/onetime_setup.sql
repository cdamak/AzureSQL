--Object Creation:

CREATE DATABASE SCOPED CREDENTIAL dbscopedcredential_import
WITH IDENTITY = 'SHARED ACCESS SIGNATURE',
SECRET = 'YourSasKey'
GO

CREATE EXTERNAL DATA SOURCE externaldatasource_import
WITH (
TYPE = BLOB_STORAGE,
LOCATION = '<<storageaccount/containername>>'
CREDENTIAL = dbscopedcredential_import
)
GO

--Grant Scripts:

ALTER ROLE db_owner ADD MEMBER <<JavaApplicationUser>>  
GO
GRANT EXECUTE ON OBJECT::dbo.prc_alter_database_scoped_cred TO <<JavaApplicationUser>> 
GO
GRANT EXECUTE ON OBJECT::dbo.prc_bulk_insert_stg_table TO <<JavaApplicationUser>> 
GO
GRANT ALTER ON DATABASE SCOPED CREDENTIAL :: dbscopedcredential_import TO <<JavaApplicationUser>> WITH GRANT OPTION 
GO

--Verification

--Checking Database Objects:

select * from sys.database_credentials
GO
select * from sys.external_data_sources
GO

-- Check User Access


SELECT u.name, r.name
FROM sys.database_principals u
LEFT JOIN sys.database_role_members rm
ON rm.member_principal_id = u.principal_id
LEFT JOIN sys.database_principals r
ON r.principal_id = rm.role_principal_id
WHERE u.type != 'R'
AND u.[name] = '<<user>>';
GO

----------------------
SELECT prin.[name] [User], sec.state_desc + ' ' + sec.permission_name [Permission],
sec.class_desc Class, object_name(sec.major_id) [Securable], 
sec.major_id [Securible_Id]
FROM [sys].[database_permissions] sec 
JOIN [sys].[database_principals] prin 
ON sec.[grantee_principal_id] = prin.[principal_id] 
WHERE prin.[name] = '<<user>>'
ORDER BY [User], [Permission];
GO