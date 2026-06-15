-- Sprint 1 - Mock schema for rep_aprobarechazo
-- Safe re-runnable script for local/dev environments.

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE mock_transacciones PURGE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE mock_oficiales PURGE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE mock_gerentes PURGE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE mock_intermediarios PURGE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE != -942 THEN
      RAISE;
    END IF;
END;
/

CREATE TABLE mock_oficiales (
  codigo NUMBER PRIMARY KEY,
  nombre VARCHAR2(100) NOT NULL
);

CREATE TABLE mock_gerentes (
  codigo_compania VARCHAR2(10) NOT NULL,
  codigo NUMBER NOT NULL,
  nombre VARCHAR2(100) NOT NULL,
  CONSTRAINT pk_mock_gerentes PRIMARY KEY (codigo_compania, codigo)
);

CREATE TABLE mock_intermediarios (
  codigo_compania VARCHAR2(10) NOT NULL,
  codigo NUMBER NOT NULL,
  nombre VARCHAR2(100) NOT NULL,
  CONSTRAINT pk_mock_intermediarios PRIMARY KEY (codigo_compania, codigo)
);

CREATE TABLE mock_transacciones (
  id_transaccion NUMBER PRIMARY KEY,
  fec_tra DATE NOT NULL,
  cliente NUMBER,
  compania NUMBER,
  ramo NUMBER,
  secuencial NUMBER,
  monto NUMBER(14,2),
  estado VARCHAR2(10),
  codigo_rechazo VARCHAR2(20),
  descripcion_rechazo VARCHAR2(500),
  respuesta_banco VARCHAR2(500),
  oficial NUMBER,
  gerente NUMBER,
  intermediario NUMBER,
  nombre_oficial VARCHAR2(100),
  nombre_gerente VARCHAR2(100),
  nombre_intermediario VARCHAR2(100),
  seleccion CHAR(1) DEFAULT 'N' CHECK (seleccion IN ('S','N')),
  user_crea VARCHAR2(30),
  fecha_crea DATE,
  user_actualiza VARCHAR2(30),
  fecha_actualiza DATE
);

CREATE INDEX idx_mock_trans_fec_tra ON mock_transacciones (fec_tra);
CREATE INDEX idx_mock_trans_filtros ON mock_transacciones (oficial, gerente, intermediario, cliente);

INSERT INTO mock_oficiales (codigo, nombre) VALUES (101, 'Ana Perez');
INSERT INTO mock_oficiales (codigo, nombre) VALUES (102, 'Carlos Diaz');

INSERT INTO mock_gerentes (codigo_compania, codigo, nombre) VALUES ('1', 201, 'Laura Medina');
INSERT INTO mock_gerentes (codigo_compania, codigo, nombre) VALUES ('1', 202, 'Ramon Ortiz');

INSERT INTO mock_intermediarios (codigo_compania, codigo, nombre) VALUES ('1', 301, 'Intermed Uno');
INSERT INTO mock_intermediarios (codigo_compania, codigo, nombre) VALUES ('1', 302, 'Intermed Dos');

INSERT INTO mock_transacciones (
  id_transaccion, fec_tra, cliente, compania, ramo, secuencial, monto,
  estado, codigo_rechazo, descripcion_rechazo, respuesta_banco,
  oficial, gerente, intermediario, nombre_oficial, nombre_gerente, nombre_intermediario,
  seleccion, user_crea, fecha_crea, user_actualiza, fecha_actualiza
) VALUES (
  900001, TRUNC(SYSDATE) - 2, 50001, 1, 10, 100001, 2450.75,
  'APR', NULL, NULL, 'APROBADA',
  101, 201, 301, 'Ana Perez', 'Laura Medina', 'Intermed Uno',
  'N', 'MIGRACION', SYSDATE - 2, 'MIGRACION', SYSDATE - 1
);

INSERT INTO mock_transacciones (
  id_transaccion, fec_tra, cliente, compania, ramo, secuencial, monto,
  estado, codigo_rechazo, descripcion_rechazo, respuesta_banco,
  oficial, gerente, intermediario, nombre_oficial, nombre_gerente, nombre_intermediario,
  seleccion, user_crea, fecha_crea, user_actualiza, fecha_actualiza
) VALUES (
  900002, TRUNC(SYSDATE) - 1, 50002, 1, 10, 100002, 1800.00,
  'RECH', 'R01', 'FONDOS INSUFICIENTES', 'DECLINADA POR BANCO',
  102, 202, 302, 'Carlos Diaz', 'Ramon Ortiz', 'Intermed Dos',
  'N', 'MIGRACION', SYSDATE - 1, 'MIGRACION', SYSDATE
);

COMMIT;
