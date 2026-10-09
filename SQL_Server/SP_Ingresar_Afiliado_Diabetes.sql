USE DIRESA_PERU;
GO

---Creamos el procedimiento

CREATE OR ALTER PROCEDURE dbo.SP_INGRESAR_AFILIADO_DIABETES
    @CODIGO_ANONIMIZADO VARCHAR(64),
    @EDAD TINYINT,
    @SEXO VARCHAR(10),
    @UBIGEO CHAR(6),
    @FECHA_AFILIADOS_SIS DATE,
    @FECHA_CORTE DATE,
    @FECHA_PRIMER_DX DATE,
    @TIPO_DIABETES NVARCHAR(300),
    @CON_DX_OBESIDAD VARCHAR(2),
    @CON_DX_HIPERTENSION VARCHAR(2),
    @CON_DX_SALUDMENTAL VARCHAR(2),
    @CANT_ATENCIONES INT,
    @VALOR_NETO DECIMAL(18,2),
    @CANT_ATENCIONES_HOSP INT,
    @VALOR_NETO_HOSP DECIMAL(18,2),
    @DIAS_HOSP INT
AS
BEGIN
    SET NOCOUNT ON;



    BEGIN TRY
        BEGIN TRANSACTION;
        IF @CODIGO_ANONIMIZADO IS NULL
           OR LTRIM(RTRIM(@CODIGO_ANONIMIZADO)) = ''
        BEGIN
            ROLLBACK;
            SELECT 'Error: el codigo anonimizado es obligatorio.' AS Mensaje;
            RETURN;
        END;

    
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.UBIGEO
            WHERE UBIGEO = @UBIGEO
        )
        BEGIN
            ROLLBACK;
            SELECT 'Error: el UBIGEO indicado no existe.' AS Mensaje;
            RETURN;
        END;

      
        IF EXISTS (
            SELECT 1
            FROM dbo.AFILIADOS
            WHERE CODIGO_ANONIMIZADO = @CODIGO_ANONIMIZADO
        )
        BEGIN
            ROLLBACK;
            SELECT 'Error: el codigo anonimizado ya esta registrado.' AS Mensaje;
            RETURN;
        END;

       
        IF @CANT_ATENCIONES < 0
           OR @VALOR_NETO < 0
           OR @CANT_ATENCIONES_HOSP < 0
           OR @VALOR_NETO_HOSP < 0
           OR @DIAS_HOSP < 0
        BEGIN
            ROLLBACK;
            SELECT 'Error: las cantidades, valores y dias no pueden ser negativos.' AS Mensaje;
            RETURN;
        END;

        INSERT INTO dbo.AFILIADOS
        (
            CODIGO_ANONIMIZADO,
            EDAD,
            SEXO,
            UBIGEO,
            FECHA_AFILIADOS_SIS
        )
        VALUES
        (
            @CODIGO_ANONIMIZADO,
            @EDAD,
            @SEXO,
            @UBIGEO,
            @FECHA_AFILIADOS_SIS
        );

        DECLARE @ID_AFILIADO INT;
        SET @ID_AFILIADO = SCOPE_IDENTITY();

        INSERT INTO dbo.ATENCIONES_DIABETES
        (
            ID_AFILIADO,
            FECHA_CORTE,
            FECHA_PRIMER_DX,
            TIPO_DIABETES,
            CON_DX_OBESIDAD,
            CON_DX_HIPERTENSION,
            CON_DX_SALUDMENTAL,
            CANT_ATENCIONES,
            VALOR_NETO,
            CANT_ATENCIONES_HOSP,
            VALOR_NETO_HOSP,
            DIAS_HOSP
        )
        VALUES
        (
            @ID_AFILIADO,
            @FECHA_CORTE,
            @FECHA_PRIMER_DX,
            @TIPO_DIABETES,
            @CON_DX_OBESIDAD,
            @CON_DX_HIPERTENSION,
            @CON_DX_SALUDMENTAL,
            @CANT_ATENCIONES,
            @VALOR_NETO,
            @CANT_ATENCIONES_HOSP,
            @VALOR_NETO_HOSP,
            @DIAS_HOSP
        );

        COMMIT;

        SELECT
            'Registro ingresado correctamente.' AS Mensaje,
            @ID_AFILIADO AS ID_AFILIADO;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK;

        SELECT
            ERROR_NUMBER() AS NumeroError,
            ERROR_MESSAGE() AS MensajeError;

    END CATCH;
END;
GO


----Prueba de ejecución con éxito

EXEC dbo.SP_INGRESAR_AFILIADO_DIABETES
    @CODIGO_ANONIMIZADO = 'PRUEBA_SP001',
    @EDAD = 35,
    @SEXO = 'F',
    @UBIGEO = '010101',
    @FECHA_AFILIADOS_SIS = '2025-01-15',
    @FECHA_CORTE = '2025-12-31',
    @FECHA_PRIMER_DX = '2025-03-10',
    @TIPO_DIABETES = 'DM2',
    @CON_DX_OBESIDAD = 'NO',
    @CON_DX_HIPERTENSION = 'SI',
    @CON_DX_SALUDMENTAL = 'NO',
    @CANT_ATENCIONES = 3,
    @VALOR_NETO = 150.00,
    @CANT_ATENCIONES_HOSP = 1,
    @VALOR_NETO_HOSP = 80.00,
    @DIAS_HOSP = 2;


---- Verificamos el registro insertado

SELECT *
FROM dbo.AFILIADOS
WHERE CODIGO_ANONIMIZADO = 'PRUEBA_SP001';

SELECT *
FROM dbo.ATENCIONES_DIABETES
WHERE ID_AFILIADO = 1352753;


--- Validación y Rollback

EXEC dbo.SP_INGRESAR_AFILIADO_DIABETES
    @CODIGO_ANONIMIZADO = 'PRUEBA_ROLLBACK01',
    @EDAD = 40,
    @SEXO = 'F',
    @UBIGEO = '010101',
    @FECHA_AFILIADOS_SIS = '2025-01-15',
    @FECHA_CORTE = '2025-12-31',
    @FECHA_PRIMER_DX = '2025-03-10',
    @TIPO_DIABETES = 'DM2',
    @CON_DX_OBESIDAD = 'NO',
    @CON_DX_HIPERTENSION = 'NO',
    @CON_DX_SALUDMENTAL = 'NO',
    @CANT_ATENCIONES = 3,
    @VALOR_NETO = -100.00,
    @CANT_ATENCIONES_HOSP = 0,
    @VALOR_NETO_HOSP = 0.00,
    @DIAS_HOSP = 0;


SELECT *
FROM dbo.AFILIADOS
WHERE CODIGO_ANONIMIZADO = 'PRUEBA_ROLLBACK01';


---PRUEBA DE EXCEPCIÓN CON TRY...CATCH Y ROLLBACK
DECLARE @TIPO_LARGO NVARCHAR(300);
SET @TIPO_LARGO = REPLICATE(N'X', 200);

EXEC dbo.SP_INGRESAR_AFILIADO_DIABETES
    @CODIGO_ANONIMIZADO = 'PRUEBA_ROLLBACK02',
    @EDAD = 40,
    @SEXO = 'F',
    @UBIGEO = '100101',
    @FECHA_AFILIADOS_SIS = '2025-01-15',
    @FECHA_CORTE = '2025-12-31',
    @FECHA_PRIMER_DX = '2025-03-10',
    @TIPO_DIABETES = @TIPO_LARGO,
    @CON_DX_OBESIDAD = 'NO',
    @CON_DX_HIPERTENSION = 'NO',
    @CON_DX_SALUDMENTAL = 'NO',
    @CANT_ATENCIONES = 3,
    @VALOR_NETO = 100.00,
    @CANT_ATENCIONES_HOSP = 0,
    @VALOR_NETO_HOSP = 0.00,
    @DIAS_HOSP = 0;


SELECT *
FROM dbo.AFILIADOS
WHERE CODIGO_ANONIMIZADO = 'PRUEBA_ROLLBACK02';