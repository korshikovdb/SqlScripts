/*
    SPID with high priority
    (DANGER!! May kills many processes)
*/

DECLARE @SPID NVARCHAR(20) = '1730'
--Super SPID
SET NOCOUNT ON;
WHILE (1 = 1)
BEGIN
    DROP TABLE IF EXISTS #Table
    CREATE TABLE #Table
    (
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
    INSERT INTO #Table
    EXEC sp_who2
    DECLARE @LockedSPID NVARCHAR(20) = '  .';
    SELECT @LockedSPID = BlkBy
    FROM #Table
    WHERE SPID = @SPID
        AND BlkBy != '  .'
    IF (@LockedSPID != '  .' OR @LockedSPID IS NULL)
       BEGIN
        BEGIN TRY
                     DECLARE @Sql NVARCHAR(MAX) = '';
                     SET @Sql = 'KILL ' + @LockedSPID
                     EXEC sp_executesql @Sql
                     DECLARE @Message NVARCHAR(MAX) = '';
                     SET @Message = 'Killed ' + @LockedSPID + ' process';
                     SET @LockedSPID = '  .';
                     RAISERROR(@Message, 10, 1) WITH NOWAIT;                
              END TRY
              BEGIN CATCH
                     DECLARE @eMessage NVARCHAR(MAX) = @LockedSPID + ' ';
                     SET @LockedSPID = '  .';
                     SET @eMessage = @eMessage + ERROR_MESSAGE();
                     RAISERROR(@eMessage, 10, 1) WITH NOWAIT;
              END CATCH
    END
    SET @LockedSPID = '  .';
END