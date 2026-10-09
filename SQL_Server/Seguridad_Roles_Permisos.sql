USE DIRESA_PERU;
GO

CREATE USER UsuarioAnalista WITHOUT LOGIN;
GO

CREATE ROLE RolAnalista;
GO

ALTER ROLE RolAnalista
ADD MEMBER UsuarioAnalista;
GO


GRANT SELECT ON dbo.AFILIADOS TO RolAnalista;
GRANT SELECT ON dbo.ATENCIONES_DIABETES TO RolAnalista;
GRANT SELECT ON dbo.PRESTACIONES TO RolAnalista;
GRANT SELECT ON dbo.DIAGNOSTICOS TO RolAnalista;
GRANT SELECT ON dbo.MEDICAMENTOS TO RolAnalista;
GO

EXECUTE AS USER = 'UsuarioAnalista';
GO

SELECT TOP 5
    ID_REGISTRO_REL,
    FECHA_ATENCION,
    EDAD_DIAS,
    SEXO,
    PESO
FROM dbo.PRESTACIONES;
GO

REVERT;
GO
---Acceso denegado

EXECUTE AS USER = 'UsuarioAnalista';
GO

DELETE FROM dbo.PRESTACIONES
WHERE ID_REGISTRO_REL = -999999;
GO

REVERT;
GO


---Segundo y tercer rol

CREATE USER UsuarioAdministrador WITHOUT LOGIN;
CREATE USER UsuarioAuditor WITHOUT LOGIN;
GO

CREATE ROLE RolAdministrador;
CREATE ROLE RolAuditor;
GO

ALTER ROLE RolAdministrador
ADD MEMBER UsuarioAdministrador;

ALTER ROLE RolAuditor
ADD MEMBER UsuarioAuditor;
GO

---Permisos admin

GRANT SELECT, INSERT, UPDATE, DELETE
ON SCHEMA::dbo TO RolAdministrador;
GO

EXECUTE AS USER = 'UsuarioAdministrador';
GO

---Probamos los permisos

SELECT TOP 5
    ID_REGISTRO_REL,
    FECHA_ATENCION,
    EDAD_DIAS,
    SEXO,
    PESO
FROM dbo.PRESTACIONES;
GO

REVERT;
GO

---Permisos del auditor


GRANT SELECT
ON dbo.LOG_AUDITORIA TO RolAuditor;
GO

---Probamos los permisos

EXECUTE AS USER = 'UsuarioAuditor';
GO

SELECT TOP 5
    ID_LOG,
    FECHA_HORA,
    USUARIO,
    TABLA_AFECTADA,
    OPERACION,
    ID_REGISTRO,
    DESCRIPCION
FROM dbo.LOG_AUDITORIA
ORDER BY ID_LOG DESC;
GO

REVERT;
GO


---Probamos su acceso a una tarea que solo es válida para el administrador
EXECUTE AS USER = 'UsuarioAuditor';
GO

UPDATE dbo.LOG_AUDITORIA
SET DESCRIPCION = 'MODIFICACION NO AUTORIZADA'
WHERE ID_LOG = 1;
GO

REVERT;
GO