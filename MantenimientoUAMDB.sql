/* Trabajo de Base de Datos, sobre el mantenimiento preventivo y correctivo
de los dispositivos de la uam */

USE master
GO

-- Por si esta base ya existe este comando la borra
-- Busca al igual el nombre y si lo encuentra lo borra
IF DB_ID('MantenimientoUAMDB') IS NOT NULL
BEGIN
    ALTER DATABASE MantenimientoUAMDB 
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE MantenimientoUAMDB;
END
GO

-- Creacion de la base de datos y use para acceder a este
CREATE DATABASE MantenimientoUAMDB;
GO

USE MantenimientoUAMDB;
GO

-- Creacion de los 3 esquemas de nuestro proyecto q actuan practicamente
-- Como categorizaciones de las 8 tablas siguientes.
CREATE SCHEMA Seguridad;
GO

CREATE SCHEMA Catalogo;
GO

CREATE SCHEMA Mantenimiento;
GO

-- Tabla Edificio 
CREATE TABLE Catalogo.Edificio (
    idEdificio INT IDENTITY PRIMARY KEY,
    nombreEdificio VARCHAR(50) NOT NULL UNIQUE,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL -- Ponemos las 2 columnas de edificio, aparte de la auditoria (osea isactive, created, updated y deleted)
);

-- Tabla TipoDispositivo
CREATE TABLE Catalogo.TipoDispositivo (
    idTipoDispositivo INT IDENTITY PRIMARY KEY,
    nombreTipo VARCHAR(30) NOT NULL UNIQUE,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL
);

-- Tabla EstadoDispositivo
CREATE TABLE Catalogo.EstadoDispositivo (
    idEstado INT IDENTITY PRIMARY KEY,
    estado VARCHAR(30) NOT NULL UNIQUE,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL
);

-- Tabla TipoMantenimiento
CREATE TABLE Catalogo.TipoMantenimiento (
    idTipoMantenimiento INT IDENTITY PRIMARY KEY,
    nombreTipoMantenimiento VARCHAR(30) NOT NULL UNIQUE,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL
);
/* Todas estas tablas entran a el esquema de catalogo, por que
hablamos de tipos de cosas, dispositivos o estados y un listado de los mismos en la uam
nos referimos a conecciones que iran proximamente con lo que sera puesto en mantenimiento
*/

-- Tabla Tecnico
CREATE TABLE Seguridad.Tecnico (
    idTecnico INT IDENTITY PRIMARY KEY,
    nombreTecnico VARCHAR(80) NOT NULL,
    telefono VARCHAR(15) NULL,
    correo VARCHAR(100) NULL,
    departamento VARCHAR(50) NULL,
    fechaNacimiento DATE NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL,
    CONSTRAINT chk_correo CHECK (correo LIKE '%@%' OR correo IS NULL) -- El correo se acepta cuando lleva un @ en el.

);
/* Para el tecnico, solo esta seguridad, ya que se nos explica que seguridad es para
quienes acceden o manipulan parte de los datos, como usuarios y demas, en este caso
los tecnicos con los dispositivos */


-- Tabla Salon
CREATE TABLE Mantenimiento.Salon (
    idSalon INT IDENTITY PRIMARY KEY,
    codigoSalon VARCHAR(10) NOT NULL UNIQUE,
    piso TINYINT NOT NULL,
    idEdificio INT NOT NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL,
    CONSTRAINT chk_piso CHECK (piso > 0), -- No pueden haber pisos inexistentes.
    FOREIGN KEY (idEdificio) REFERENCES Catalogo.Edificio(idEdificio)
);


-- Tabla Dispositivo
CREATE TABLE Mantenimiento.Dispositivo (
    idDispositivo INT IDENTITY PRIMARY KEY,
    codigoDispositivo VARCHAR(20) NOT NULL UNIQUE,
    idTipoDispositivo INT NOT NULL,
    idSalon INT NOT NULL,
    idEstado INT NOT NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL,
    FOREIGN KEY (idTipoDispositivo) REFERENCES Catalogo.TipoDispositivo(idTipoDispositivo),
    FOREIGN KEY (idSalon) REFERENCES Mantenimiento.Salon(idSalon),
    FOREIGN KEY (idEstado) REFERENCES Catalogo.EstadoDispositivo(idEstado)
);


-- Tabla Mantenimiento
CREATE TABLE Mantenimiento.Mantenimiento (
    idMantenimiento INT IDENTITY PRIMARY KEY,
    idDispositivo INT NOT NULL,
    idTipoMantenimiento INT NOT NULL,
    fechaMantenimiento DATE NOT NULL,
    idTecnico INT NOT NULL,
    observacion VARCHAR(250) NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL,
    CONSTRAINT chk_fecha CHECK (fechaMantenimiento <= GETDATE()), -- Uno no viene del futuro, eso hace que no hayan fechas fuera de lugar.
    FOREIGN KEY (idDispositivo) REFERENCES Mantenimiento.Dispositivo(idDispositivo),
    FOREIGN KEY (idTipoMantenimiento) REFERENCES Catalogo.TipoMantenimiento(idTipoMantenimiento),
    FOREIGN KEY (idTecnico) REFERENCES Seguridad.Tecnico(idTecnico)
);

/* Las tablas mantenimiento van donde se supone sera los datos mas importantes
sobre el mantenimiento, los dispositivos a los que vamos a darles mantenimiento (bueno, el tecnico)
el donde estan y claramente el mantenimiento a darse */

/* Siempre ponemos el is active en 1 por que es 0 y 1, False y True, ya que es True que 
todas nuestras tablas estan activas, asi no las borramos */