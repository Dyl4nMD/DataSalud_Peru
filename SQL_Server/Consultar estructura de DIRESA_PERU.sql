USE DIRESA_PERU
SELECT 
    s.name AS Esquema,
    t.name AS Tabla
FROM sys.tables t
INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
ORDER BY s.name, t.name;



SELECT
    t.name AS Tabla,
    c.column_id AS Orden,
    c.name AS Columna,
    ty.name AS TipoDato,
    CASE
        WHEN ty.name IN ('varchar','char','nvarchar','nchar')
        THEN CAST(c.max_length AS VARCHAR(10))
        ELSE '-'
    END AS Longitud,
    CASE 
        WHEN c.is_nullable = 1 THEN 'SI'
        ELSE 'NO'
    END AS PermiteNULL
FROM sys.tables t
INNER JOIN sys.columns c
    ON t.object_id = c.object_id
INNER JOIN sys.types ty
    ON c.user_type_id = ty.user_type_id
WHERE t.name <> 'sysdiagrams'
ORDER BY t.name, c.column_id;

USE DIRESA_PERU;
GO


SELECT
    t.name AS Tabla,
    kc.name AS Nombre_PK,
    c.name AS Columna
FROM sys.key_constraints kc
INNER JOIN sys.tables t
    ON kc.parent_object_id = t.object_id
INNER JOIN sys.index_columns ic
    ON kc.parent_object_id = ic.object_id
    AND kc.unique_index_id = ic.index_id
INNER JOIN sys.columns c
    ON ic.object_id = c.object_id
    AND ic.column_id = c.column_id
WHERE kc.type = 'PK'
ORDER BY t.name, ic.key_ordinal;


SELECT
    fk.name AS Nombre_FK,
    OBJECT_NAME(fk.parent_object_id) AS TablaOrigen,
    COL_NAME(
        fkc.parent_object_id,
        fkc.parent_column_id
    ) AS ColumnaOrigen,
    OBJECT_NAME(fk.referenced_object_id) AS TablaDestino,
    COL_NAME(
        fkc.referenced_object_id,
        fkc.referenced_column_id
    ) AS ColumnaDestino
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc
    ON fk.object_id = fkc.constraint_object_id
ORDER BY TablaOrigen;


SELECT
    OBJECT_NAME(parent_object_id) AS Tabla,
    name AS Restriccion,
    definition AS Regla
FROM sys.check_constraints
ORDER BY Tabla;


SELECT
    t.name AS Tabla,
    i.name AS Indice,
    i.type_desc AS Tipo,
    i.is_unique AS EsUnico
FROM sys.indexes i
INNER JOIN sys.tables t
    ON i.object_id = t.object_id
WHERE
    i.name IS NOT NULL
    AND t.name <> 'sysdiagrams'
ORDER BY t.name, i.name;