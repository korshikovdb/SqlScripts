SET NOCOUNT ON;
DECLARE @Cnt INT = 0 -- count all records
              , @I INT = 0 -- current iterration
              , @AvgTime INT = 0 -- average time of executions of one batch
              , @BatchSize INT = 1000 --one batch size;
DECLARE @Iterrations TABLE
(
       ExecutionTime INT
)

--EDIT. select count of records to be updated or inserted.
--SELECT @Cnt = COUNT(*)

--SELECT @Cnt

WHILE ((@I * @BatchSize) < @Cnt)
BEGIN
       DECLARE @From DATETIME;
       SET @From = GETDATE();

       --main query here

       --end main query

       SET @I = @I + 1;
       DECLARE @To DATETIME;
       SET @To = GETDATE();

       INSERT INTO @Iterrations
       VALUES
       (DATEDIFF(MILLISECOND, @From, @To));

       DECLARE @Avg INT;
       SELECT @Avg = AVG(ExecutionTime) FROM @Iterrations;

       DECLARE @Message NVARCHAR(MAX);
       SET @Message = CAST(@BatchSize AS NVARCHAR) + ' done for ' +  CAST(DATEDIFF(SECOND, @From, @To) AS NVARCHAR) + ' seconds. Estimated end over ' +  REPLACE(REPLACE(CONVERT(VARCHAR, CONVERT(MONEY, CAST((@Avg * 1.0 / 1000 * ((@Cnt /  @BatchSize) - @I)) AS INT)), 1), '.00', ''), ',', ' ') + ' seconds'
       RAISERROR(@Message, 10, 1) WITH NOWAIT;
END