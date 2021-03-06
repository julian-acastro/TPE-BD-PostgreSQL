-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2021-07-05 13:09:33.147

-- Vistas
DROP VIEW v_prof_exclusivo CASCADE;
DROP VIEW v_prof_simple CASCADE;
DROP VIEW v_asignaturas_simple CASCADE;

-- Functions
DROP FUNCTION fn_gr01_actualizar_v_prof_exclusivo() CASCADE;
DROP FUNCTION fn_gr01_actualizar_v_prof_simple() CASCADE;
DROP FUNCTION fn_gr01_control_prof() CASCADE;
DROP FUNCTION fn_gr01_control_prof_simple() CASCADE;
DROP FUNCTION fn_gr01_control_prof_exclusivo() CASCADE;


-- foreign keys
ALTER TABLE G01_ASIGNATURA_PROFESOR
    DROP CONSTRAINT FK_G01_ASIGNATURA_PROFESOR_ASIGNATURA;

ALTER TABLE G01_ASIGNATURA_PROFESOR
    DROP CONSTRAINT FK_G01_ASIGNATURA_PROFESOR_PROFESOR;

ALTER TABLE G01_PROF_EXCLUSIVO
    DROP CONSTRAINT FK_G01_PROF_EXCLUSIVO_PROFESOR;

ALTER TABLE G01_PROF_SIMPLE
    DROP CONSTRAINT FK_G01_PROF_SIMPLE_PROFESOR;

-- tables
DROP TABLE G01_ASIGNATURA;

DROP TABLE G01_ASIGNATURA_PROFESOR;

DROP TABLE G01_PROFESOR;

DROP TABLE G01_PROF_EXCLUSIVO;

DROP TABLE G01_PROF_SIMPLE;

-- End of file.

