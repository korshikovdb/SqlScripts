/*
    Drop default constraint on column
    Generate and execute script with sp_executesql
*/

DECLARE @TableName NVARCHAR(500) = N'table'
        , @ColumnName NVARCHAR(500) = N'column'
        
DECLARE @SQL NVARCHAR(MAX) = '';
SET @SQL = @SQL + (
    SELECT 'ALTER TABLE ' + @TableName + N' DROP CONSTRAINT '  + default_constraints.name
    FROM sys.all_columns
        INNER JOIN sys.tables ON all_columns.object_id = tables.object_id
        INNER JOIN sys.schemas ON tables.schema_id = schemas.schema_id
        INNER JOIN sys.default_constraints ON all_columns.default_object_id = default_constraints.object_id
    WHERE schemas.name = 'dbo'
        AND tables.name = @TableName
        AND all_columns.name = @ColumnName
)
EXEC sp_executesql @SQL