/* ====================================================================================================================================================

																		Ejercicio B1.3
==================================================================================================================================================== */
/*
--SQL ESTANDAR DECLARATIVO 
ALTER TABLE MOVIMIENTO --Preguntar si el alter table o assertion
ADD CONSTRAINT CK_G13_MOVIMIENTO_ULTIMO_MOV 
	CHECK( NOT EXISTS(SELECT 1
					  FROM G13_MOVIMIENTO m 
					  INNER JOIN  G13_MOVIMIENTO a ON (m.id_mov_ant = a.id_movimiento)
					  WHERE m.fecha < a.fecha  
					  	OR  m.cod_pallet != a.cod_pallet
					  	OR a.id_movimiento <>(SELECT id_movimiento
					  						  FROM G13_MOVIMIENTO
					  						  WHERE cod_pallet = a.cod_pallet
					  						  	AND m.fecha > fecha
					  						  ORDER BY fecha DESC
					  						  LIMIT 1)
					  )
		);
*/
CREATE OR REPLACE FUNCTION TRFN_G13_ULTIMO_MOV() RETURNS trigger AS $$
declare
    max_fecha date;
    max_id int;
    pallet varchar(32);
begin
	SELECT M.fecha, M.id_movimiento, M.cod_pallet INTO max_fecha, max_id, pallet FROM G13_MOVIMIENTO M WHERE id_movimiento = NEW.id_mov_ant;
	IF (NEW.fecha < max_fecha) THEN
		RAISE EXCEPTION 'El movimiento debe ser el ultimo cronoligamente';
	END IF;
	IF (pallet != NEW.cod_pallet) THEN
		RAISE EXCEPTION 'El movimiento anterior y el actual deben ser sobre el mismo pallet';
	END IF;
	IF(max_id <> (SELECT id_movimiento FROM G13_MOVIMIENTO WHERE cod_pallet = NEW.cod_pallet AND fecha < NEW.fecha ORDER BY fecha DESC LIMIT 1)) THEN
		RAISE EXCEPTION 'El movimiento anterior no es el ultimo para dicho pallet';
	END IF;
	RETURN NEW;
END;
$$LANGUAGE 'plpgsql';



CREATE TRIGGER TR_G13_MOVIMIENTO_ULTIMO_MOV
	AFTER INSERT
	ON G13_MOVIMIENTO
		FOR EACH ROW WHEN (NEW.id_mov_ant IS NOT NULL)
		EXECUTE PROCEDURE TRFN_G13_ULTIMO_MOV();

/*
INSERT into g13_movimiento values 
(1,current_timestamp,'e',null,1,'DNI',11111111,1),
(2,current_timestamp,'i',null,3,'DNI',22222222,2), --Deberia fallar porque es interno y id_ant es null pero no nos toca
(3,current_timestamp,'i',1,7,'DNI',33333333,1), 
(4,current_timestamp,'e',null,20,'DNI',44444444,30),
(5,current_timestamp,'s',3,22,'DNI',55555555,1),
--(8,current_timestamp-interval '3 days' ,'i', 4 ,22,'DNI',55555555,30), --Falla por fecha anterior
(10,current_timestamp,'i', 4,22,'DNI',55555555,30);
--(8,current_timestamp,'i', 4,22,'DNI',55555555,30), --Falla porque el id?mov = 4 no es el ultmio para el pallet 30
--(11,current_timestamp,'i', 10,22,'DNI',55555555,2); --Falla por pallets distintos
*/



/* ====================================================================================================================================================

																		Ejercicio B2.2
==================================================================================================================================================== */


CREATE OR REPLACE FUNCTION TRFN_G13_CLIENTE_CANT_POS_ALQ() RETURNS TRIGGER AS 
$$
BEGIN
	IF(TG_OP = 'INSERT') THEN
		NEW.cant_pos_alq = 0;
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TR_CLIENTE_CANT_POS_ALQ 
	BEFORE INSERT
	ON G13_CLIENTE 
		FOR EACH ROW EXECUTE PROCEDURE TRFN_G13_CLIENTE_CANT_POS_ALQ();


CREATE OR REPLACE FUNCTION TRFN_G13_ALQUILER_POSICION_CANT_POS_ALQ() RETURNS TRIGGER AS 
$$
DECLARE 
cuit_cuil_cliente char(11);
tipo_de_alquiler char(10);
cuit_cuil_anterior char(11);
tipo_de_alquiler_ant char(10);
BEGIN
	IF(TG_OP='INSERT') THEN
		SELECT id_cliente, tipo_alquiler INTO cuit_cuil_cliente, tipo_de_alquiler FROM G13_ALQUILER WHERE id_alquiler = NEW.id_alquiler;
		IF(LOWER(tipo_de_alquiler) LIKE '%indefinido') THEN
			UPDATE G13_CLIENTE SET cant_pos_alq = cant_pos_alq+1 WHERE cuit_cuil = cuit_cuil_cliente;
		END IF;
		RETURN NEW;
	ELSIF(TG_OP = 'UPDATE' ) THEN
	--Debo obtener el tipo de alquiler y el cliente del nuevo y anterior alquiler
		SELECT id_cliente, tipo_alquiler INTO cuit_cuil_cliente, tipo_de_alquiler FROM G13_ALQUILER WHERE id_alquiler = NEW.id_alquiler;
		SELECT id_cliente, tipo_alquiler INTO cuit_cuil_anterior, tipo_de_alquiler_ant FROM G13_ALQUILER WHERE id_alquiler = OLD.id_alquiler;
		
		IF(LOWER(tipo_de_alquiler_ant) LIKE '%indefinido') THEN --En caso que el anterior era indefinido, hay que restarle una posicion
			UPDATE G13_CLIENTE SET cant_pos_alq = cant_pos_alq-1 WHERE cuit_cuil = cuit_cuil_anterior;
		END IF;
		IF(LOWER(tipo_de_alquiler) LIKE '%indefinido') THEN --En caso que el alquiler actual es indefinido, hay que sumarle una posicion al cliente
			UPDATE G13_CLIENTE SET cant_pos_alq = cant_pos_alq+1 WHERE cuit_cuil = cuit_cuil_cliente;
		END IF;
		RETURN NEW;
	
	ELSIF (TG_OP = 'DELETE') THEN
		SELECT id_cliente, tipo_alquiler INTO cuit_cuil_anterior, tipo_de_alquiler_ant FROM G13_ALQUILER WHERE id_alquiler = OLD.id_alquiler;
		IF(LOWER(tipo_de_alquiler_ant) LIKE '%indefinido') THEN --En caso que el anterior era indefinido, hay que restarle una posicion
			UPDATE G13_CLIENTE SET cant_pos_alq = cant_pos_alq-1 WHERE cuit_cuil = cuit_cuil_anterior;
		END IF;
		RETURN OLD;
	END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TR_G13_ALQUILER_POSICION_CANT_POS_ALQ
	BEFORE INSERT OR DELETE OR UPDATE OF id_alquiler 
	ON G13_ALQUILER_POSICION
	FOR EACH ROW
		EXECUTE PROCEDURE TRFN_G13_ALQUILER_POSICION_CANT_POS_ALQ();


CREATE OR REPLACE FUNCTION TRFN_G13_ALQUILER_CANT_POS_ALQ() RETURNS TRIGGER AS 
$$
DECLARE
cantidad int;
BEGIN
	IF(TG_OP = 'UPDATE') THEN
		SELECT count(*) INTO  cantidad FROM G13_ALQUILER_POSICION WHERE id_alquiler = NEW.id_alquiler;
		IF(LOWER(NEW.tipo_alquiler) LIKE '%fijo%') THEN
			UPDATE G13_CLIENTE SET cant_pos_alq = cant_pos_alq-cantidad WHERE cuit_cuil = NEW.id_cliente;
		ELSE
			UPDATE G13_CLIENTE SET cant_pos_alq = cant_pos_alq+cantidad WHERE cuit_cuil = NEW.id_cliente;
		END IF;
		RETURN NEW;
	END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER TR_G13_ALQUILER_CANT_POS_ALQ 
	BEFORE UPDATE OF tipo_alquiler
	ON G13_ALQUILER 
	FOR EACH ROW 
		WHEN ((LOWER(OLD.tipo_alquiler) LIKE '%fijo%' AND LOWER(NEW.tipo_alquiler) LIKE '%indefinido%')
			   OR (LOWER(NEW.tipo_alquiler) LIKE '%fijo%' AND LOWER(OLD.tipo_alquiler) LIKE '%indefinido%'))
		EXECUTE PROCEDURE TRFN_G13_ALQUILER_CANT_POS_ALQ();


/*
Estas sentencias son validas siempre y cuando existan las posiciones utilizadas en alquiler_posicion.

INSERT INTO Cliente VALUES 
('1', 'Leonel', 'Benavidez', current_date, 200, 0),
('1', 'Lautaro', 'Osinaga', current_date, 20, 0),
('3', 'Martin','Lorenzo', current_date, 100, 4); -- Esta sentencia omite el cant_pos_alq = 4 y la setea en 0
INSERT INTO Alquiler VALUES 
(1, '1', 'fijo', current_date, current_date+INTERVAL '10 days', 8),
(2, '1', 'indefinido', current_date, current_date+INTERVAL '20 days', 14),
(3, '3', 'indefinido', current_date, current_date+ INTERVAL '5 DAYS', 5);
INSERT INTO Alquiler_posicion VALUES
(1,1), (1,2), (2,3), (2,4), (3, 5), (3,6);--Estas dos sentencias harán que cambie la cantidad de alquileres del cliente '1' a 2 y del '3' a 2.
UPDATE Alquiler SET tipo_alquiler = 'fijo' WHERE id_alquiler = 2; --Esta sentencia dejaría en 0 la cantidad de posiciones alquiladas del cliente '1'.
UPDATE Alquiler_posicion SET id_alquiler = 2 WHERE id_alquiler =3 AND id_pos = 5 --Se reduce la cantidad de posiciones alquiladas del cliente '3' en 1 ya que el alquiler 2 es fijo.
DELETE FROM Alquiler_posicion WHERE id_alquiler = 5 AND id_pos = 6 --Se vuelve a reducir la cantidad de posiciones alquiladas del cliente '2' en 1 ya que se elimina una posición.
*/

/* ====================================================================================================================================================

																		Ejercicio C1.1
==================================================================================================================================================== */

CREATE OR REPLACE FUNCTION FN_G13_ESTANTERIAS_PORCENTAJE_OCUPADA(porcentaje int) RETURNS TABLE (Numero_estanteria int, Nombre_de_estanteria varchar(80)) 
AS $$
BEGIN
	RETURN QUERY
	SELECT nro_estanteria, nombre_estanteria
	FROM G13_ESTANTERIA NATURAL JOIN (SELECT nro_estanteria FROM G13_POSICION
										GROUP BY nro_estanteria, estado
										HAVING COUNT(nro_estanteria)*porcentaje < count(estado)*100 AND LOWER(estado) LIKE '%ocupada%') p; 
END;
$$ LANGUAGE 'plpgsql';

--SELECT * from FN_G13_ESTANTERIAS_PORCENTAJE_OCUPADA(10);


/* ====================================================================================================================================================

																		Ejercicio C2.3
==================================================================================================================================================== */

CREATE OR REPLACE VIEW G13_VW_PROXIMA_FECHA_CON_CANT_ALQUILERES AS
	SELECT a.fecha_hasta, count(*)
	FROM (SELECT id_alquiler, fecha_hasta 
		  FROM G13_ALQUILER 
		  WHERE CURRENT_DATE BETWEEN fecha_desde AND fecha_hasta
		  	AND fecha_hasta = (SELECT MIN(fecha_hasta) FROM G13_ALQUILER WHERE CURRENT_DATE BETWEEN fecha_desde AND fecha_hasta)
		  ) A
	NATURAL JOIN
	G13_ALQUILER_POSICION AP
	GROUP BY A.fecha_hasta
	ORDER BY A.fecha_hasta ASC
	LIMIT 1;

--Select * from G13_VW_PROXIMA_FECHA_CON_CANT_ALQUILERES;
/* ====================================================================================================================================================

																		Ejercicio C3
==================================================================================================================================================== */

CREATE OR REPLACE FUNCTION FN_G13_C3_TPE_MASIVO() RETURNS VOID AS
$$
DECLARE
max_id_liquidacion int;
BEGIN
--Por defecto las funciones en postgre son transacciones
   LOCK TABLE G13_MOVIMIENTO_CC;
   INSERT INTO G13_MOVIMIENTO_CC 
   SELECT nextval('seq_G13_id_mov_cc'),current_date,id_cliente, -sum(importe_dia), NULL,NULL 
   FROM (SELECT id_cliente, importe_dia 
         FROM G13_ALQUILER
         WHERE (current_date BETWEEN fecha_desde AND fecha_hasta) 
            OR (current_date > fecha_desde AND fecha_hasta is NULL)
        ) A  
   NATURAL JOIN G13_ALQUILER_POSICION  
   GROUP BY id_cliente;

   max_id_liquidacion := nextval('seq_G13_id_liquidacion');
   INSERT INTO G13_LINEA_ALQUILER 
   SELECT max_id_liquidacion, id_alquiler, id_pos, importe_dia, (SELECT id_mov_cc 
                                             FROM g13_movimiento_cc
                                             WHERE cuit_cuil= A.id_cliente
                                             ORDER BY fecha DESC, id_mov_cc DESC
                                             LIMIT 1)
   FROM (SELECT id_cliente, id_alquiler, importe_dia 
         FROM G13_ALQUILER
         WHERE (current_date BETWEEN fecha_desde AND fecha_hasta) 
            OR (current_date > fecha_desde AND fecha_hasta is NULL)
        ) A  
   NATURAL JOIN G13_ALQUILER_POSICION ;

END;
$$ LANGUAGE 'plpgsql';

--SELECT FN_G13_C3_TPE_MASIVO();

/* ====================================================================================================================================================

																		Ejercicio D1.1
==================================================================================================================================================== */

CREATE VIEW G13_VW_CLIENTES_MAYOR_IMPORTE AS
SELECT * FROM G13_CLIENTE NATURAL JOIN
	(SELECT *  FROM G13_MOVIMIENTO_CC  
		WHERE fecha >= (current_date-INTERVAL '1 year') ) M
	WHERE id_mov_cc  = (SELECT id_mov_cc 
						FROM g13_MOVIMIENTO_CC mi
						WHERE mi.cuit_cuil = M.cuit_cuil AND fecha >= (current_date-INTERVAL '1 year')
						ORDER BY importe DESC, fecha DESC
						LIMIT 1);

CREATE OR REPLACE FUNCTION FN_G13_UPDATE_VIEW_CLIENTES_MAYOR_IMPORTE() RETURNS TRIGGER AS $$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            INSERT INTO G13_CLIENTE VALUES(NEW.cuit_cuil, NEW.apellido, NEW.nombre, NEW.fecha_alta, NEW.saldo, NEW.cant_pos_alq);

            INSERT INTO g13_MOVIMIENTO_CC VALUES(NEW.id_mov_cc, NEW.fecha, NEW.cuit_cuil, NEW.importe, null, null);
            RETURN NEW;
        END IF;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER TR_G13_UPDATE_VIEW_CLIENTES_MAYOR_IMPORTE
	INSTEAD OF INSERT 
	ON G13_VW_CLIENTES_MAYOR_IMPORTE
	FOR EACH ROW EXECUTE PROCEDURE FN_G13_UPDATE_VIEW_CLIENTES_MAYOR_IMPORTE();

/*
SELECT * FROM G13_VW_CLIENTES_MAYOR_IMPORTE;

INSERT INTO G13_VW_CLIENTES_MAYOR_IMPORTE VALUES ('1','Jose', 'Martinez', current_date, 100, 0, nextval('seq_G13_id_mov_cc') , current_date,,  -10, null, null);

*/
/* ====================================================================================================================================================

																		Ejercicio D2.1
==================================================================================================================================================== */

CREATE VIEW G13_VW_POSICIONES_FILA5_NALQ AS 
SELECT * 
FROM G13_POSICION p
WHERE (p.nro_fila>4) AND (NOT EXISTS (SELECT 1 FROM G13_ALQUILER_POSICION a WHERE p.id_pos=a.id_pos));

--SELECT * FROM G13_VW_POSICIONES_FILA5_NALQ