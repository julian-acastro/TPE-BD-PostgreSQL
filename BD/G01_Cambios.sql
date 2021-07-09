/*
 Ejercicio A 1.	Se le agregar la columna cantidad_prof_simples (cantidad de profesores simples)
 y cantidad_prof_exclusivos (cantidad de profesores exclusivos) a la tabla ASIGNATURA y la columna activo
 a la tabla ASIGNATURA_PROFESOR.  Es necesario mantener actualizada las columnas cantidad_prof_simples
 y cantidad_prof_exclusivos con la cantidad de profesores simples y excluivos activos que tiene cada asignatura
 (es decir que el campo activo está en true). Se debe realizar con triggers FOR STATEMENT.
 */



CREATE OR REPLACE FUNCTION fn_g01_actualizacion_profes_asig()
    RETURNS TRIGGER AS
$$
BEGIN
    --Actualización columna cantidad_prof_simple
    UPDATE g01_asignatura a
    SET cantidad_prof_simple = c.cant
    FROM (SELECT ap.cod_asig, ap.tipo_asig, COUNT(ap.dni) AS cant
          FROM g01_asignatura_profesor ap
                   JOIN g01_asignatura a
                        ON a.tipo_asig = ap.tipo_asig
                            AND a.cod_asig = ap.cod_asig
          WHERE (ap.activo = TRUE)
            AND (ap.dni IN (SELECT p.dni
                            FROM g01_profesor p
                            WHERE p.tipo_prof = 1))
          GROUP BY ap.cod_asig, ap.tipo_asig) AS c
    WHERE c.cod_asig = a.cod_asig
      AND c.tipo_asig = a.tipo_asig;
    --Actualización columna cantidad_prof_exclusivo
    UPDATE g01_asignatura a
    SET cantidad_prof_exclusivo = c.cant
    FROM (SELECT ap.cod_asig, ap.tipo_asig, COUNT(ap.dni) AS cant
          FROM g01_asignatura_profesor ap
                   JOIN g01_asignatura a
                        ON a.tipo_asig = ap.tipo_asig
                            AND a.cod_asig = ap.cod_asig
          WHERE (ap.activo = TRUE)
            AND (ap.dni IN (SELECT p.dni
                            FROM g01_profesor p
                            WHERE p.tipo_prof = 2))
          GROUP BY ap.cod_asig, ap.tipo_asig) AS c
    WHERE c.cod_asig = a.cod_asig
      AND c.tipo_asig = a.tipo_asig;
   RETURN NULL;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER tr_g01_actualizacion_profes_asig
    AFTER INSERT OR DELETE OR UPDATE
    ON g01_asignatura_profesor
    FOR EACH STATEMENT
EXECUTE PROCEDURE fn_g01_actualizacion_profes_asig();

--Ejercicio A 2.Utilizando 2 vistas V_PROF_SIMPLE y V_PROF_EXCLUSIVO que contienen todos los datos
--de los profesores simples o exclusivos respectivamente, construir los triggers INSTEAD OF necesarios
--para mantener actualizadas las tablas de PROFESOR, PROF_SIMPLE y PROF_EXCLUSIVO de manera de respetar
--el diseño de datos de la jerarquía.

--Vista prof_simple
/*
 Esta vista no es actualizable automáticamente porque contiene un JOIN en el FROM.
 Es actualizable mediante el uso de triggers individuales para las declaraciones INSERT, UPDATE,
 DELETE y una función.
 */

CREATE VIEW v_prof_simple AS
SELECT *
FROM g01_profesor
         NATURAL JOIN g01_prof_simple;

--Actualización Vista prof_simple

CREATE OR REPLACE FUNCTION fn_gr01_actualizar_v_prof_simple()
    RETURNS TRIGGER AS
$$
BEGIN
    IF (tg_op = 'INSERT') THEN
        INSERT INTO g01_profesor
        VALUES (new.dni, new.apellido, new.nombre, new.titulo, new.departamento, new.tipo_prof);

        INSERT INTO g01_prof_simple
        VALUES (new.dni, new.perfil);
        RETURN new;
    ELSE
        IF (tg_op = 'DELETE') THEN
            DELETE FROM g01_profesor WHERE old.dni = dni;
            DELETE FROM g01_prof_simple WHERE old.dni = dni;
            RETURN old;
        ELSE
            IF (tg_op = 'UPDATE') THEN
                UPDATE g01_profesor
                SET (dni, apellido, nombre, titulo, departamento, tipo_prof) =
                        (new.dni, new.apellido, new.nombre, new.titulo, new.departamento, new.tipo_prof)
                WHERE old.dni = new.dni;
                UPDATE g01_prof_simple
                SET (dni, perfil) =
                        (new.dni, new.perfil)
                WHERE old.dni = new.dni;
                RETURN new;
            END IF;
        END IF;
    END IF;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER tr_gr01_v_prof_simple_actualizar_in
    INSTEAD OF INSERT
    ON v_prof_simple
    FOR EACH ROW
EXECUTE PROCEDURE fn_gr01_actualizar_v_prof_simple();

CREATE TRIGGER tr_gr01_v_prof_simple_actualizar_del
    INSTEAD OF DELETE
    ON v_prof_simple
    FOR EACH ROW
EXECUTE PROCEDURE fn_gr01_actualizar_v_prof_simple();

CREATE TRIGGER tr_gr01_v_prof_simple_actualizar_up
    INSTEAD OF UPDATE
    ON v_prof_simple
    FOR EACH ROW
EXECUTE PROCEDURE fn_gr01_actualizar_v_prof_simple();

--Vista prof_exclusivo
/*
 Esta vista no es actualizable automáticamente porque contiene un JOIN en el FROM.
 Es actualizable mediante el uso de triggers individuales para las declaraciones INSERT, UPDATE,
 DELETE y una función.
 */

CREATE VIEW v_prof_exclusivo AS
SELECT *
FROM g01_profesor
         NATURAL JOIN g01_prof_exclusivo;

--Actualización Vista prof_exclusivo

CREATE OR REPLACE FUNCTION fn_gr01_actualizar_v_prof_exclusivo()
    RETURNS TRIGGER AS
$$
BEGIN
    IF (tg_op = 'INSERT') THEN
        INSERT INTO g01_profesor
        VALUES (new.dni, new.apellido, new.nombre, new.titulo, new.departamento, new.tipo_prof);

        INSERT INTO g01_prof_exclusivo
        VALUES (new.dni, new.proy_investig);
        RETURN new;
    ELSE
        IF (tg_op = 'DELETE') THEN
            DELETE FROM g01_profesor WHERE old.dni = dni;
            DELETE FROM g01_prof_exclusivo WHERE old.dni = dni;
            RETURN old;
        ELSE
            IF (tg_op = 'UPDATE') THEN
                UPDATE g01_profesor
                SET (dni, apellido, nombre, titulo, departamento, tipo_prof) =
                        (new.dni, new.apellido, new.nombre, new.titulo, new.departamento, new.tipo_prof)
                WHERE old.dni = new.dni;
                UPDATE g01_prof_exclusivo
                SET (dni, proy_investig) =
                        (new.dni, new.proy_investig)
                WHERE old.dni = new.dni;
                RETURN new;
            END IF;
        END IF;
    END IF;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER tr_gr01_v_prof_exclusivo_actualizar_in
    INSTEAD OF INSERT
    ON v_prof_exclusivo
    FOR EACH ROW
EXECUTE PROCEDURE fn_gr01_actualizar_v_prof_exclusivo();

CREATE TRIGGER tr_gr01_v_prof_exclusivo_actualizar_del
    INSTEAD OF DELETE
    ON v_prof_exclusivo
    FOR EACH ROW
EXECUTE PROCEDURE fn_gr01_actualizar_v_prof_exclusivo();

CREATE TRIGGER tr_gr01_v_prof_exclusivo_actualizar_up
    INSTEAD OF UPDATE
    ON v_prof_exclusivo
    FOR EACH ROW
EXECUTE PROCEDURE fn_gr01_actualizar_v_prof_exclusivo();

--Los siguientes triggers son controles de integridad, para evitar tipo_prof en tablas prof_exclusivo y prof_simple

CREATE OR REPLACE FUNCTION fn_gr01_control_prof_simple()
    RETURNS TRIGGER AS
$$
BEGIN
    IF (new.dni NOT IN (SELECT p.dni
                        FROM g01_profesor p
                        WHERE tipo_prof = 1)) THEN
        RAISE EXCEPTION 'Error, este profesor no es tipo_prof = 1';
    END IF;
    RETURN new;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER tr_gr01_prof_simple
    BEFORE INSERT
    ON g01_prof_simple
    FOR EACH ROW
EXECUTE PROCEDURE fn_gr01_control_prof_simple();

CREATE OR REPLACE FUNCTION fn_gr01_control_prof_exclusivo()
    RETURNS TRIGGER AS
$$
BEGIN
    IF (new.dni NOT IN (SELECT p.dni
                        FROM g01_profesor p
                        WHERE tipo_prof = 2)) THEN
        RAISE EXCEPTION 'Error, este profesor no es tipo_prof = 2';
    END IF;
    RETURN new;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER tr_gr01_prof_exclusivo
    BEFORE INSERT
    ON g01_prof_exclusivo
    FOR EACH ROW
EXECUTE PROCEDURE fn_gr01_control_prof_exclusivo();

CREATE OR REPLACE FUNCTION fn_gr01_control_prof()
    RETURNS TRIGGER AS
$$
BEGIN
    IF (new.tipo_prof <> 1 AND new.dni IN (SELECT dni
                                           FROM g01_prof_simple)) THEN
        RAISE EXCEPTION 'Error: no puede cambiar el tipo_prof porque se encuentra en prof_simple.';
    ELSE
        IF (new.tipo_prof <> 2 AND new.dni IN (SELECT dni
                                               FROM g01_prof_exclusivo)) THEN
            RAISE EXCEPTION 'Error: no puede cambiar el tipo_prof porque se encuentra en prof_exclusivo.';
        END IF;
    END IF;
    RETURN new;
END;
$$
    LANGUAGE 'plpgsql';

CREATE TRIGGER tr_gr01_control_prof
    BEFORE UPDATE OF tipo_prof
    ON g01_profesor
    FOR EACH ROW
EXECUTE PROCEDURE fn_gr01_control_prof();

/*
 Ejercicio B 1.	Construya una vista V_ASIGNATURAS_SIMPLE que contenga las asignaturas
 formadas sólo por profesores simples.
 */
/*
 Esta vista es actualizable automáticamente.
 */

CREATE VIEW v_asignaturas_simple AS
SELECT *
FROM g01_asignatura
WHERE (cod_asig, tipo_asig) IN (SELECT cod_asig, tipo_asig
                                FROM g01_asignatura_profesor
                                WHERE dni IN (SELECT dni
                                              FROM g01_profesor
                                              WHERE tipo_prof = 1));

/*
 Ejercicio B 2.	Construya una vista V_PROFESORES_ASG que liste para cada profesor la lista de materias a las que
 está asignado y el total de horas por cuatrimestre.
 */
/*
 Esta vista no es actualizable automáticamente porque contiene una función "window"(subconsulta)
 en el SELECT.
 */

CREATE VIEW v_profesores_asg AS
SELECT ap.dni,
       ap.cod_asig,
       ap.tipo_asig,
       ap.cuatrimestre,
       SUM(ap.cantidad_horas) OVER (PARTITION BY ap.dni, ap.cuatrimestre)
FROM g01_asignatura_profesor ap;
-----------------------------------------------------------------------------------------
