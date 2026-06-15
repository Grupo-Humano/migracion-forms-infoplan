-- ============================================================================
-- ORDS HANDLER DEPLOYMENT SCRIPT #1: Create ORDS Module
-- ============================================================================
-- Purpose: Register new ORDS module for rep_aprobarechazo form handlers
-- Target: Oracle ORDS (any version)
-- Execution: SQLcl or APEX SQL Workshop
-- Time: ~5 minutes
-- ============================================================================

BEGIN
  -- Create new ORDS module
  ORDS.create_module(
    p_module_name   => 'facturacion-aprobaciones-rechazos-v1',
    p_base_path     => '/aprobaciones-rechazos',
    p_items_per_page=> 25,
    p_enabled       => TRUE
  );
  
  COMMIT;
  
  DBMS_OUTPUT.put_line('✅ Module created: facturacion-aprobaciones-rechazos-v1');
  DBMS_OUTPUT.put_line('   Base Path: /aprobaciones-rechazos');
  DBMS_OUTPUT.put_line('   Full URL: https://infoplan-web-dev.humano.local/ords/infoplan/facturacion/api/v1/aprobaciones-rechazos');
  
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('❌ Error: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/

-- Verify module creation
SELECT 
  name,
  base_path,
  enabled,
  created,
  last_updated
FROM user_ords_modules
WHERE name = 'facturacion-aprobaciones-rechazos-v1';

-- ============================================================================
-- END: Create ORDS Module
-- ============================================================================
