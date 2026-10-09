USE master;
GO

---Respaldo completo de la base de datos

BACKUP DATABASE DIRESA_PERU
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\Backup\DIRESA_PERU_FULL.bak'
WITH
    INIT,
    FORMAT,
    NAME = 'Backup FULL - DIRESA_PERU',
    STATS = 10;
GO


---Respaldo diferencial de la base

BACKUP DATABASE DIRESA_PERU
TO DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\Backup\DIRESA_PERU_DIFF.bak'
WITH
    DIFFERENTIAL,
    INIT,
    NAME = 'Backup DIFFERENTIAL - DIRESA_PERU',
    STATS = 10;
GO


--- Verificación de los archivos contenidos en el respaldo completo

RESTORE FILELISTONLY
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\Backup\DIRESA_PERU_FULL.bak';
GO



--- Restauración del respaldo completo

RESTORE DATABASE DIRESA_PERU_RESTORE_TEST
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\Backup\DIRESA_PERU_FULL.bak'
WITH
    MOVE 'DIRESA_PERU'
        TO 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\DIRESA_PERU_RESTORE_TEST.mdf',
    MOVE 'DIRESA_PERU_log'
        TO 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\DATA\DIRESA_PERU_RESTORE_TEST_log.ldf',
    NORECOVERY,
    REPLACE,
    STATS = 10;
GO


--- Aplicación del respaldo diferencial y recuperación de la base de datos

RESTORE DATABASE DIRESA_PERU_RESTORE_TEST
FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL17.MSSQLSERVER\MSSQL\Backup\DIRESA_PERU_DIFF.bak'
WITH
    RECOVERY,
    STATS = 10;
GO


---Verificamos que esté correctamente restaurado


USE DIRESA_PERU_RESTORE_TEST;
GO

SELECT
    DB_NAME() AS BASE_RESTAURADA,
    COUNT(*) AS TOTAL_PRESTACIONES
FROM dbo.PRESTACIONES;
GO