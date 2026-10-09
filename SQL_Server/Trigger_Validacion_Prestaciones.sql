USE DIRESA_PERU;
GO

CREATE OR ALTER TRIGGER dbo.TRG_VALIDAR_PRESTACIONES
ON dbo.PRESTACIONES
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;


    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE EDAD_DIAS < 0
    )
    BEGIN
        RAISERROR(
            'Error: EDAD_DIAS no puede contener valores negativos.',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE DIAS_HOSP < 0
    )
    BEGIN
        RAISERROR(
            'Error: DIAS_HOSP no puede contener valores negativos.',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;
    END;


    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE PESO IS NOT NULL
          AND PESO <= 0
    )
    BEGIN
        RAISERROR(
            'Error: PESO debe ser mayor que cero cuando se encuentre registrado.',
            16,
            1
        );

        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO


----
UPDATE dbo.PRESTACIONES
SET EDAD_DIAS = -5
WHERE ID_REGISTRO_REL = 999999998;

----
SELECT 
    ID_REGISTRO_REL,
    EDAD_DIAS
FROM dbo.PRESTACIONES
WHERE ID_REGISTRO_REL = 999999998;

EXEC sp_help 'dbo.LOG_AUDITORIA';