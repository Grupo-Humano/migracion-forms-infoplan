-- Sprint 1: Auto-connect to HUMANO_DESA and execute mock setup
-- Usage: sqlcl @backend/ords/connect_and_setup.sql

-- Connect to saved connection (requires password saved in SQL Developer)
CONNECT HUMANO_DESA

-- Show connection info
SHOW user
SELECT * FROM v$version WHERE ROWNUM = 1;

-- Run mock setup scripts in order
@backend/ords/sql/01_mock_schema.sql
@backend/ords/sql/02_pkg_rep_aprobarechazo_mock.sql
@backend/ords/sql/03_ords_rep_aprobarechazo_mock.sql
@backend/ords/sql/04_smoke_tests.sql

-- Verify results
SELECT COUNT(*) mock_tables FROM user_tables WHERE table_name LIKE 'MOCK_%';
SELECT COUNT(*) mock_procedures FROM user_procedures WHERE object_name LIKE 'PKG_%' OR object_name LIKE 'P_%';

EXIT;
