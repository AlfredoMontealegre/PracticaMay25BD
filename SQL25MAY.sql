/* =============================================
SCRIPT: bd_universidad
Motor: SQL Server
Autor: AlfredoMontealegre
============================================= */

------------------------------------------------
-- SECCIÓN DOWN (limpiar todo)
------------------------------------------------
USE master;
GO

-- Desconectar sesiones activas (bonus)
ALTER DATABASE bd_universidad SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO

DROP DATABASE IF EXISTS bd_universidad;
GO

------------------------------------------------
-- SECCIÓN UP (crear todo)
------------------------------------------------
CREATE DATABASE bd_universidad;
GO

USE bd_universidad;
GO

------------------------------------------------
-- 1. TABLAS INDEPENDIENTES
------------------------------------------------

CREATE TABLE CARRERA (
    id_carrera INT IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(100) NOT NULL,
    duracion_anios INT NOT NULL,
    modalidad NVARCHAR(20) NOT NULL,
    CONSTRAINT ck_modalidad_carrera 
        CHECK (modalidad IN (N'Presencial', N'Virtual', N'Semipresencial')),
    CONSTRAINT ck_duracion_carrera 
        CHECK (duracion_anios BETWEEN 3 AND 6)
);
GO

CREATE TABLE MATERIA (
    id_materia INT IDENTITY(1,1),
    codigo NVARCHAR(10) NOT NULL UNIQUE,
    nombre NVARCHAR(100) NOT NULL,
    creditos TINYINT NOT NULL,
    semestre TINYINT NOT NULL,
    CONSTRAINT pk_materia PRIMARY KEY (id_materia),
    CONSTRAINT ck_creditos_positivos CHECK (creditos > 0),
    CONSTRAINT ck_semestre_valido CHECK (semestre BETWEEN 1 AND 10)
);
GO

------------------------------------------------
-- 2. TABLA ESTUDIANTE (FK)
------------------------------------------------

CREATE TABLE ESTUDIANTE (
    id_estudiante INT IDENTITY(1,1) PRIMARY KEY,
    carnet NVARCHAR(10) NOT NULL UNIQUE,
    nombre_completo NVARCHAR(150) NOT NULL,
    fecha_nacimiento DATE NULL,
    email NVARCHAR(100) NOT NULL UNIQUE,
    id_carrera INT NOT NULL,
    CONSTRAINT fk_estudiante_carrera 
        FOREIGN KEY (id_carrera)
        REFERENCES CARRERA(id_carrera)
        ON DELETE NO ACTION
        ON UPDATE CASCADE
);
GO

------------------------------------------------
-- 3. TABLA INSCRIPCION (N:M)
------------------------------------------------

CREATE TABLE INSCRIPCION (
    id_inscripcion INT IDENTITY(1,1) PRIMARY KEY,
    id_estudiante INT NOT NULL,
    id_materia INT NOT NULL,
    anio SMALLINT NOT NULL,
    periodo NVARCHAR(3) NOT NULL,
    nota_final DECIMAL(4,2) NULL,

    CONSTRAINT fk_inscripcion_estudiante 
        FOREIGN KEY (id_estudiante) REFERENCES ESTUDIANTE(id_estudiante),

    CONSTRAINT fk_inscripcion_materia 
        FOREIGN KEY (id_materia) REFERENCES MATERIA(id_materia),

    CONSTRAINT ck_periodo_valido 
        CHECK (periodo IN (N'I', N'II', N'III')),

    CONSTRAINT ck_anio_valido 
        CHECK (anio BETWEEN 2000 AND 2099),

    CONSTRAINT uq_inscripcion 
        UNIQUE (id_estudiante, id_materia, anio, periodo)
);
GO

------------------------------------------------
-- 4. ALTER TABLE (AGREGAR COLUMNAS)
------------------------------------------------

ALTER TABLE ESTUDIANTE
ADD telefono NVARCHAR(25) NULL;
GO

ALTER TABLE ESTUDIANTE
ADD estado NVARCHAR(10) NOT NULL DEFAULT N'Activo',
    CONSTRAINT ck_estado_valido CHECK (estado IN (N'Activo', N'Inactivo'));
GO

ALTER TABLE MATERIA
ADD descripcion NVARCHAR(MAX) NULL;
GO

------------------------------------------------
-- 5. MODIFICACIONES
------------------------------------------------

-- Cambiar tamaño teléfono
ALTER TABLE ESTUDIANTE
ALTER COLUMN telefono NVARCHAR(25) NULL;
GO

-- Renombrar columna
EXEC sp_rename 
    'CARRERA.duracion_anios',
    'duracion',
    'COLUMN';
GO

-- Cambiar nota_final
ALTER TABLE INSCRIPCION
ALTER COLUMN nota_final DECIMAL(5,2);
GO

------------------------------------------------
-- 6. ÍNDICES
------------------------------------------------

CREATE NONCLUSTERED INDEX ix_estudiante_email
ON ESTUDIANTE(email);
GO

------------------------------------------------
-- 7. ELIMINAR COLUMNA (con dependencia)
------------------------------------------------

-- Primero eliminar DEFAULT si existe
DECLARE @constraint_name NVARCHAR(200);

SELECT @constraint_name = dc.name
FROM sys.default_constraints dc
JOIN sys.columns c 
    ON dc.parent_object_id = c.object_id 
    AND dc.parent_column_id = c.column_id
WHERE c.name = 'descripcion'
AND OBJECT_NAME(dc.parent_object_id) = 'MATERIA';

IF @constraint_name IS NOT NULL
BEGIN
    EXEC('ALTER TABLE MATERIA DROP CONSTRAINT ' + @constraint_name);
END
GO

ALTER TABLE MATERIA
DROP COLUMN descripcion;
GO

------------------------------------------------
-- 8. PRUEBA DROP EN ORDEN CORRECTO
------------------------------------------------

-- Orden correcto por FK
DROP TABLE IF EXISTS INSCRIPCION;
DROP TABLE IF EXISTS ESTUDIANTE;
DROP TABLE IF EXISTS MATERIA;
DROP TABLE IF EXISTS CARRERA;
GO

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'ESTUDIANTE';
