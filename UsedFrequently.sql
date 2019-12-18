---------------------------------------------
----Get command text by SPID
DBCC INPUTBUFFER(@SPID)

---------------------------------------------
----Raise error in sql server transaction
DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

SELECT
    @ErrorMessage = ERROR_MESSAGE(),
    @ErrorSeverity = ERROR_SEVERITY(),
    @ErrorState = ERROR_STATE();

RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

---------------------------------------------
----The last date of month by month and year
SELECT CAST(EOMONTH(DATEFROMPARTS(@Year, @Month, 1)) AS datetime)

--for old versions
SELECT
    DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0) AS StartOfYear,
    DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1) AS EndOfYear

---------------------------------------------
----Drop table if exists

IF OBJECT_ID('dbo.tmpPersonTable', 'U') IS NOT NULL
    DROP TABLE dbo.tmpPersonTable;

--Sql Server 2016
DROP TABLE IF EXISTS dbo.Product

--Temporary table
IF OBJECT_ID ( 'tempdb..#tmp') IS NOT NULL
    DROP TABLE dbo. #tmp;

---------------------------------------------
----Command sp_who2 with output filtering
DECLARE @Table TABLE(
    SPID INT ,
    Status NVARCHAR ( MAX),
    LOGIN NVARCHAR ( MAX),
    HostName NVARCHAR ( MAX),
    BlkBy NVARCHAR ( MAX),
    DBName NVARCHAR ( MAX),
    Command NVARCHAR ( MAX),
    CPUTime NVARCHAR ( MAX),
    DiskIO NVARCHAR ( MAX),
    LastBatch NVARCHAR ( MAX),
    ProgramName NVARCHAR ( MAX),
    SPID_1 NVARCHAR ( MAX),
    REQUESTID NVARCHAR ( MAX)
)
INSERT INTO @Table
EXEC sp_who2
SELECT *
FROM @Table
WHERE BlkBy != '  .'
--OR ProgramName LIKE N'%az%' --for specified program
--DBCC INPUTBUFFER(123) --command text
--KILL 123 --:)

---------------------------------------------
----No wait print
RAISERROR ('Foo', 10, 1) WITH NOWAIT

---------------------------------------------
----Update statistics on specified table
UPDATE STATISTICS dbo.MedicalRecordsPatient

---------------------------------------------
----Execute on all databases by pattern
EXEC sp_MSforeachdb 'IF ''?''  LIKE ''DMEDSC%''
BEGIN
          USE ?
       SELECT ''?'', COUNT(*) FROM UnloadReports
END'

--If table exists in other databases
EXEC sp_MSforeachdb 'IF ''?''  LIKE ''DMEDSC%''
BEGIN
        DECLARE @cmd1 VARCHAR(500)
        IF (''?'' LIKE ''DMEDSC%'') EXECUTE (''USE ? SELECT DB_NAME(), ID, ShortNameRU, IsPMSP, IsKDP, IsHospital FROM KMIS_OrgHealthCare WHERE IsUseMedReg = 1'')
END'

---------------------------------------------
----Create index with progress monitoring

--Create index with statistics profile
SET STATISTICS PROFILE ON
CREATE NONCLUSTERED INDEX IX_Patients_timestamp ON Patients
(
        timestamp ASC
)
SET STATISTICS PROFILE OFF

--Query for monitoring
SELECT session_id, request_id , physical_operator_name , node_id ,
    thread_id , row_count , estimate_row_count
FROM sys .dm_exec_query_profiles
ORDER BY node_id DESC , thread_id

--Details by spid multi threads (with percents)
SELECT
    node_id,
    physical_operator_name,
    SUM(row_count) row_count,
    SUM(estimate_row_count) AS estimate_row_count,
    CAST(SUM(row_count)*100 AS float)/SUM(estimate_row_count) as estimate_percent_complete
FROM sys.dm_exec_query_profiles
WHERE session_id=@SPID
GROUP BY node_id,physical_operator_name
ORDER BY node_id desc;

---------------------------------------------
----Disable jobs by name pattern (code generation)
SELECT 'EXEC msdb.dbo.sp_update_job @job_name=''' + name + ''',@enabled = 0' , job_id, [name], *
FROM msdb. dbo. sysjobs
WHERE name LIKE N'%test%'
    AND enabled = 1

---------------------------------------------
----Create one synonym

--Creating synonym on specified table or view
--Code generation and execution
DECLARE @DatabaseName NVARCHAR(100) = 'Authentications' -- Source database without postfix
    , @TargetDatabaseName NVARCHAR(010) = 'DMEDSC' --Destination database without postfix
    , @TableName NVARCHAR(30) = 'UsersView' --Table or view or something name
    , @SQL NVARCHAR(MAX) = '';

SET @SQL = @SQL + (
SELECT REPLACE(
(SELECT 'USE ' + @TargetDatabaseName + REPLACE(name, @DatabaseName, '') + N'
GO
CREATE SYNONYM ' + @DatabaseName + '_' + @TableName + ' FOR ' + name + '.dbo.' + @TableName + N'
'
    FROM sys.databases
    WHERE name LIKE N'%' + @DatabaseName + '___%'
    FOR XML PATH('')
), '&#x0D;', '')
)

EXEC sp_executesql @SQL

---------------------------------------------

---------------------------------------------