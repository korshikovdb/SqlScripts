----Row level security testing scripts

--Predicate function
--Conditions: function must be system, returns table value with one row (with value 1, column name `fn_securitypredicate_result`), if no rows returns, then access denied
--Function must returns table without variable @returntable
--Function must be SCHEMABINDING
--Function should not contain subquery to system tables
--Function should not contain query to synonyms

--Example
DROP FUNCTION IF EXISTS Security.fn_gridScheduleRecordsPredicate

CREATE OR ALTER FUNCTION Security.fn_gridScheduleRecordsPredicate(@SecurityLevelID INT)
    RETURNS TABLE
WITH SCHEMABINDING
AS
    RETURN
    SELECT TOP 1
    1 AS fn_securitypredicate_result
FROM dbo.SecurityLevelUsers su
WHERE @SecurityLevelID = 1 OR
    (
        su.UserName = CAST(CONTEXT_INFO() AS VARCHAR(128))
    AND su.SecurityLevelID = @SecurityLevelID
    )

--Security policy
--Security policy cannot accept in parameter: subquery or not-determic functions
--Option WITH(STATE = ON); turns on security policy

--Example
DROP SECURITY POLICY GridScheduleRecordsFilter
CREATE SECURITY POLICY GridScheduleRecordsFilter
ADD FILTER PREDICATE Security.fn_gridScheduleRecordsPredicate(SecurityLevelID)
ON dbo.GridScheduleRecords
WITH (STATE = ON);