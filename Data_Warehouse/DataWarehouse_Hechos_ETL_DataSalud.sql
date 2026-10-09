USE DW_DataSalud;
GO

CREATE TABLE dbo.FactPrestacionesRN (
    IdFactPrestacion BIGINT IDENTITY(1,1) PRIMARY KEY,

    IdRegistroRel INT NOT NULL,

    IdTiempo INT NOT NULL,
    IdUbicacion INT NOT NULL,
    IdServicio INT NOT NULL,
    IdRecienNacido INT NOT NULL,

    EdadDias INT NOT NULL,
    Peso DECIMAL(10,2) NULL,
    DiasHospitalizacion INT NOT NULL,
    NivelEESS VARCHAR(20) NOT NULL,
    AteCapita VARCHAR(20) NOT NULL,

    CONSTRAINT FK_FactPrestacionesRN_Tiempo
        FOREIGN KEY (IdTiempo)
        REFERENCES dbo.DimTiempo(IdTiempo),

    CONSTRAINT FK_FactPrestacionesRN_Ubicacion
        FOREIGN KEY (IdUbicacion)
        REFERENCES dbo.DimUbicacion(IdUbicacion),

    CONSTRAINT FK_FactPrestacionesRN_Servicio
        FOREIGN KEY (IdServicio)
        REFERENCES dbo.DimServicio(IdServicio),

    CONSTRAINT FK_FactPrestacionesRN_RecienNacido
        FOREIGN KEY (IdRecienNacido)
        REFERENCES dbo.DimRecienNacido(IdRecienNacido)
);
GO

---
SELECT COUNT(*) AS TotalHechos
FROM dbo.FactPrestacionesRN;

-----


INSERT INTO dbo.FactPrestacionesRN
(
    IdRegistroRel,
    IdTiempo,
    IdUbicacion,
    IdServicio,
    IdRecienNacido,
    EdadDias,
    Peso,
    DiasHospitalizacion,
    NivelEESS,
    AteCapita
)
SELECT
    P.ID_REGISTRO_REL,
    T.IdTiempo,
    U.IdUbicacion,
    S.IdServicio,
    RN.IdRecienNacido,
    P.EDAD_DIAS,
    P.PESO,
    P.DIAS_HOSP,
    P.NIVEL_EESS,
    P.ATE_CAPITA
FROM DIRESA_PERU.dbo.PRESTACIONES P
INNER JOIN dbo.DimTiempo T
    ON T.Fecha = P.FECHA_ATENCION
INNER JOIN dbo.DimUbicacion U
    ON U.Ubigeo = P.UBIGEO
INNER JOIN dbo.DimServicio S
    ON S.CodigoServicio = P.CODIGO_SERV_PRESTACIONAL
INNER JOIN dbo.DimRecienNacido RN
    ON RN.CodigoAnonimizado = P.CODIGO_ANONIMIZADO
WHERE P.CODIGO_SERV_PRESTACIONAL <> '001';
GO


----
SELECT
    COUNT(*) AS TotalHechos,
    COUNT(DISTINCT IdRegistroRel) AS RegistrosDistintos,
    MIN(EdadDias) AS EdadMinima,
    MAX(EdadDias) AS EdadMaxima

FROM dbo.FactPrestacionesRN;


----


SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE
FROM DIRESA_PERU.INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('AFILIADOS', 'ATENCIONES_DIABETES')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

----
SELECT
    COUNT(*) AS TotalAtenciones,
    COUNT(DISTINCT ID_AFILIADO) AS AfiliadosDistintos
FROM DIRESA_PERU.dbo.ATENCIONES_DIABETES;

SELECT TOP 10
    ID_AFILIADO,
    COUNT(*) AS CantidadRegistros
FROM DIRESA_PERU.dbo.ATENCIONES_DIABETES
GROUP BY ID_AFILIADO
HAVING COUNT(*) > 1
ORDER BY CantidadRegistros DESC;


---

CREATE TABLE dbo.DimAfiliadoDiabetes
(
    IdAfiliadoDiabetes INT IDENTITY(1,1) PRIMARY KEY,
    IdAfiliadoOrigen INT NOT NULL UNIQUE,
    CodigoAnonimizado VARCHAR(100) NOT NULL,
    Edad TINYINT NOT NULL,
    Sexo VARCHAR(20) NOT NULL
);
GO


INSERT INTO dbo.DimAfiliadoDiabetes
(
    IdAfiliadoOrigen,
    CodigoAnonimizado,
    Edad,
    Sexo
)
SELECT
    ID,
    CODIGO_ANONIMIZADO,
    EDAD,
    SEXO
FROM DIRESA_PERU.dbo.AFILIADOS;
GO

---
SELECT COUNT(*) AS TotalAfiliados
FROM dbo.DimAfiliadoDiabetes;

SELECT TOP 5 *
FROM dbo.DimAfiliadoDiabetes;

----

SELECT
    CODIGO_ANONIMIZADO,
    COUNT(*) AS Cantidad
FROM DIRESA_PERU.dbo.AFILIADOS
GROUP BY CODIGO_ANONIMIZADO
HAVING COUNT(*) > 1
ORDER BY Cantidad DESC;

---

SELECT
    ID,
    CODIGO_ANONIMIZADO,
    EDAD,
    SEXO,
    UBIGEO,
    FECHA_AFILIADOS_SIS
FROM DIRESA_PERU.dbo.AFILIADOS
WHERE CODIGO_ANONIMIZADO LIKE 'PRUEBA%';

---


DELETE FROM dbo.DimAfiliadoDiabetes
WHERE CodigoAnonimizado LIKE 'PRUEBA%';
GO

SELECT COUNT(*) AS TotalAfiliados
FROM dbo.DimAfiliadoDiabetes;
GO


---

CREATE TABLE dbo.FactAtencionDiabetes
(
    IdFactAtencion BIGINT IDENTITY(1,1) PRIMARY KEY,

    IdAfiliadoDiabetes INT NOT NULL,
    IdTiempo INT NOT NULL,
    IdUbicacion INT NOT NULL,

    FechaPrimerDx DATE NOT NULL,
    TipoDiabetes NVARCHAR(100) NOT NULL,

    ConDxObesidad VARCHAR(10) NOT NULL,
    ConDxHipertension VARCHAR(10) NOT NULL,
    ConDxSaludMental VARCHAR(10) NOT NULL,

    CantAtenciones INT NOT NULL,
    ValorNeto DECIMAL(18,2) NOT NULL,
    CantAtencionesHosp INT NOT NULL,
    ValorNetoHosp DECIMAL(18,2) NOT NULL,
    DiasHosp INT NOT NULL,

    CONSTRAINT FK_FactAtencionDiabetes_Afiliado
        FOREIGN KEY (IdAfiliadoDiabetes)
        REFERENCES dbo.DimAfiliadoDiabetes(IdAfiliadoDiabetes),

    CONSTRAINT FK_FactAtencionDiabetes_Tiempo
        FOREIGN KEY (IdTiempo)
        REFERENCES dbo.DimTiempo(IdTiempo),

    CONSTRAINT FK_FactAtencionDiabetes_Ubicacion
        FOREIGN KEY (IdUbicacion)
        REFERENCES dbo.DimUbicacion(IdUbicacion)
);
GO


----
SELECT
    COUNT(*) AS TotalOrigen,

    SUM(CASE WHEN D.IdAfiliadoDiabetes IS NULL
        THEN 1 ELSE 0 END) AS SinAfiliado,

    SUM(CASE WHEN T.IdTiempo IS NULL
        THEN 1 ELSE 0 END) AS SinTiempo,

    SUM(CASE WHEN U.IdUbicacion IS NULL
        THEN 1 ELSE 0 END) AS SinUbicacion

FROM DIRESA_PERU.dbo.ATENCIONES_DIABETES A

INNER JOIN DIRESA_PERU.dbo.AFILIADOS AF
    ON AF.ID = A.ID_AFILIADO

LEFT JOIN dbo.DimAfiliadoDiabetes D
    ON D.IdAfiliadoOrigen = AF.ID

LEFT JOIN dbo.DimTiempo T
    ON T.Fecha = A.FECHA_PRIMER_DX

LEFT JOIN dbo.DimUbicacion U
    ON U.Ubigeo = AF.UBIGEO

WHERE AF.CODIGO_ANONIMIZADO NOT LIKE 'PRUEBA%';


---

INSERT INTO dbo.FactAtencionDiabetes
(
    IdAfiliadoDiabetes,
    IdTiempo,
    IdUbicacion,
    FechaPrimerDx,
    TipoDiabetes,
    ConDxObesidad,
    ConDxHipertension,
    ConDxSaludMental,
    CantAtenciones,
    ValorNeto,
    CantAtencionesHosp,
    ValorNetoHosp,
    DiasHosp
)
SELECT
    D.IdAfiliadoDiabetes,
    T.IdTiempo,
    U.IdUbicacion,
    A.FECHA_PRIMER_DX,
    A.TIPO_DIABETES,
    A.CON_DX_OBESIDAD,
    A.CON_DX_HIPERTENSION,
    A.CON_DX_SALUDMENTAL,
    A.CANT_ATENCIONES,
    A.VALOR_NETO,
    A.CANT_ATENCIONES_HOSP,
    A.VALOR_NETO_HOSP,
    A.DIAS_HOSP
FROM DIRESA_PERU.dbo.ATENCIONES_DIABETES A
INNER JOIN DIRESA_PERU.dbo.AFILIADOS AF
    ON AF.ID = A.ID_AFILIADO
INNER JOIN dbo.DimAfiliadoDiabetes D
    ON D.IdAfiliadoOrigen = AF.ID
INNER JOIN dbo.DimTiempo T
    ON T.Fecha = A.FECHA_PRIMER_DX
INNER JOIN dbo.DimUbicacion U
    ON U.Ubigeo = AF.UBIGEO
WHERE AF.CODIGO_ANONIMIZADO NOT LIKE 'PRUEBA%';
GO


---
SELECT
    (SELECT COUNT(*) FROM dbo.FactPrestacionesRN) 
        AS TotalPrestacionesRN,

    (SELECT COUNT(*) FROM dbo.FactAtencionDiabetes) 
        AS TotalAtencionesDiabetes;
GO

---
CREATE TABLE dbo.LogETL
(
    IdLog INT IDENTITY(1,1) PRIMARY KEY,
    Proceso VARCHAR(100) NOT NULL,
    FechaInicio DATETIME2 NOT NULL,
    FechaFin DATETIME2 NULL,
    RegistrosProcesados INT NULL,
    Estado VARCHAR(20) NOT NULL,
    Mensaje VARCHAR(500) NULL
);
GO


INSERT INTO dbo.LogETL
(
    Proceso,
    FechaInicio,
    FechaFin,
    RegistrosProcesados,
    Estado,
    Mensaje
)
VALUES
(
    'Carga FactPrestacionesRN',
    SYSDATETIME(),
    SYSDATETIME(),
    290469,
    'EXITOSO',
    'Carga inicial validada desde DIRESA_PERU'
),
(
    'Carga FactAtencionDiabetes',
    SYSDATETIME(),
    SYSDATETIME(),
    850366,
    'EXITOSO',
    'Carga inicial validada desde DIRESA_PERU'
);
GO

SELECT *
FROM dbo.LogETL
ORDER BY IdLog;


---
GO
CREATE OR ALTER PROCEDURE dbo.SP_VALIDAR_ETL_DATASALUD
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Inicio DATETIME2 = SYSDATETIME();
    DECLARE @TotalRN INT;
    DECLARE @TotalDiabetes INT;

    BEGIN TRY

        SELECT @TotalRN = COUNT(*)
        FROM dbo.FactPrestacionesRN;

        SELECT @TotalDiabetes = COUNT(*)
        FROM dbo.FactAtencionDiabetes;

        INSERT INTO dbo.LogETL
        (
            Proceso,
            FechaInicio,
            FechaFin,
            RegistrosProcesados,
            Estado,
            Mensaje
        )
        VALUES
        (
            'Validacion ETL DataSalud',
            @Inicio,
            SYSDATETIME(),
            @TotalRN + @TotalDiabetes,
            'EXITOSO',
            CONCAT(
                'FactPrestacionesRN: ', @TotalRN,
                ' | FactAtencionDiabetes: ', @TotalDiabetes
            )
        );

    END TRY
    BEGIN CATCH

        INSERT INTO dbo.LogETL
        (
            Proceso,
            FechaInicio,
            FechaFin,
            RegistrosProcesados,
            Estado,
            Mensaje
        )
        VALUES
        (
            'Validacion ETL DataSalud',
            @Inicio,
            SYSDATETIME(),
            0,
            'ERROR',
            ERROR_MESSAGE()
        );

        THROW;
    END CATCH
END;
GO
---
EXEC dbo.SP_VALIDAR_ETL_DATASALUD;
GO

SELECT *
FROM dbo.LogETL
ORDER BY IdLog;
GO