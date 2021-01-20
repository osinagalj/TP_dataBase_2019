

/* ====================================================================================================================================================

																		Ejercicio B1.3
==================================================================================================================================================== */
DROP FUNCTION IF EXISTS TRFN_G13_ULTIMO_MOV CASCADE ;
--DROP TRIGGER IF EXISTS TR_G13_MOVIMIENTO_ULTIMO_MOV ON G13_MOVIMIENTO  ;

/* ====================================================================================================================================================

																		Ejercicio B2.2
==================================================================================================================================================== */

DROP FUNCTION IF EXISTS TRFN_G13_CLIENTE_CANT_POS_ALQ CASCADE ;
DROP FUNCTION IF EXISTS TRFN_G13_ALQUILER_POSICION_CANT_POS_ALQ CASCADE ;
DROP FUNCTION IF EXISTS TRFN_G13_ALQUILER_CANT_POS_ALQ  CASCADE;
--DROP TRIGGER TR_CLIENTE_CANT_POS_ALQ   ;
--DROP TRIGGER TR_G13_ALQUILER_POSICION_CANT_POS_ALQ   ;
--DROP TRIGGER TR_G13_ALQUILER_CANT_POS_ALQ   ;
/* ====================================================================================================================================================

																		Ejercicio C1.1
==================================================================================================================================================== */
DROP FUNCTION IF EXISTS FN_G13_ESTANTERIAS_PORCENTAJE_OCUPADA CASCADE ;

/* ====================================================================================================================================================

																		Ejercicio C2.3
==================================================================================================================================================== */

DROP VIEW IF EXISTS G13_VW_PROXIMA_FECHA_CON_CANT_ALQUILERES  ;
/* ====================================================================================================================================================

																		Ejercicio C3
==================================================================================================================================================== */
DROP FUNCTION IF EXISTS FN_G13_C3_TPE_MASIVO CASCADE ;

/* ====================================================================================================================================================

																		Ejercicio D1.1
==================================================================================================================================================== */
DROP VIEW IF EXISTS G13_VW_CLIENTES_MAYOR_IMPORTE  ;
DROP FUNCTION IF EXISTS FN_G13_UPDATE_VIEW_CLIENTES_MAYOR_IMPORTE CASCADE ;
--DROP TRIGGER IF EXISTS TR_G13_UPDATE_VIEW_CLIENTES_MAYOR_IMPORTE  ;
/* ====================================================================================================================================================

																		Ejercicio D2.1
==================================================================================================================================================== */
DROP VIEW IF EXISTS G13_VW_POSICIONES_FILA5_NALQ  ;

/* ====================================================================================================================================================

																		BORRADO DE TABLAS
==================================================================================================================================================== */

DROP TABLE G13_MOVIMIENTO  CASCADE;
DROP TABLE G13_MOV_SALIDA  CASCADE;
DROP TABLE G13_MOV_INTERNO CASCADE ;
DROP TABLE G13_MOV_ENTRADA CASCADE ;
DROP TABLE G13_PALLET CASCADE ;
DROP TABLE G13_LINEA_ALQUILER CASCADE ;
DROP TABLE G13_MOVIMIENTO_CC CASCADE ;
DROP TABLE G13_ALQUILER_POSICION CASCADE ;
DROP TABLE G13_ALQUILER  CASCADE ;
DROP TABLE G13_CLIENTE CASCADE  ;
DROP TABLE G13_ZONA_POSICION CASCADE ;
DROP TABLE G13_ZONA CASCADE ;
DROP TABLE G13_POSICION CASCADE ;
DROP TABLE G13_FILA  CASCADE ;
DROP TABLE G13_ESTANTERIA CASCADE  ;
DROP TABLE G13_EMPLEADO  CASCADE ;