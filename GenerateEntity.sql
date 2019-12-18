/*
    Generate entity class by table name
    IMPORTANT: Execute with "Result to Text" (Ctrl+T in Sql Server Management Studio)
    Author: Korshikov Denis
    Create date: 12.04.2019
	Params: 
		@TableName - name of table for entity
		@ExcludeID - if 1, than ID excludes from entioy code
*/

DECLARE @TableName NVARCHAR(100) = 'MedicationsChainStage'
		, @ExcludeID BIT = 1

SELECT N'/// <summary>' + N'
/// ' + CAST(sep.value AS NVARCHAR(250))
       + N'
/// </summary>
'
+ N'public ' + CASE system_type_id
  WHEN 127 THEN 'long' + IIF(sc.is_nullable = 1, '?', '')
  WHEN 56 THEN 'int' + IIF(sc.is_nullable = 1, '?', '')
  WHEN 48 THEN 'int' + IIF(sc.is_nullable = 1, '?', '')
  WHEN 52 THEN 'int' + IIF(sc.is_nullable = 1, '?', '')
  WHEN 62 THEN 'float' + IIF(sc.is_nullable = 1, '?', '')
  WHEN 61 THEN 'DateTime' + IIF(sc.is_nullable = 1, '?', '')
  WHEN 104 THEN 'bool'
  WHEN 35 THEN 'string'
  WHEN 99 THEN 'string'
  WHEN 167 THEN 'string'
  WHEN 175 THEN 'string'
  WHEN 231 THEN 'string'
  WHEN 239 THEN 'string'
  WHEN 106 THEN 'decimal'
  ELSE 'TYPE NOT IDENTIFIED'
  END
+ ' ' + sc.name + ' { get; set; } ' + CHAR(13) [Description]
FROM sys.tables st
       INNER JOIN sys.columns sc ON st.object_id = sc.object_id
       LEFT JOIN sys.extended_properties sep ON st.object_id = sep.major_id
              AND sc.column_id = sep.minor_id
              AND sep.name = 'MS_Description'
WHERE st.name = @TableName
       AND (sc.name != 'id' OR @ExcludeID = 0)