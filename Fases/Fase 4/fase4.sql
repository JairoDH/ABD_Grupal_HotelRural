-- 1.Realiza una función ComprobarPago que reciba como parámetros un código de cliente y un código de actividad y
-- devuelva un TRUE si el cliente ha pagado la última actividad con ese códiggastos_extraso que ha realizado y un FALSE en caso
-- contrario. Debes controlar las siguientes excepciones: Cliente inexistente, Actividad Inexistente, Actividad realizada
-- en régimen de Todo Incluido y El cliente nunca ha realizado esa actividad.

-- 2.Realiza un procedimiento llamado ImprimirFactura que reciba un código de estancia e imprima la factura vinculada
-- a la misma. Debes tener en cuenta que la factura tendrá el siguiente formato:

-- Complejo Rural La Fuente
-- Candelario (Salamanca)
-- Código Estancia: xxxxxxxx
-- Cliente: NombreCliente ApellidosCliente
-- Número Habitación: nnn
-- Fecha Inicio: nn/nn/n.nnn
-- Fecha Salida: nn/nn/nnnn
-- Régimen de Alojamiento: NombreRegimen

-- Alojamiento
-- Temporada1
-- NumDías1Importe1
-- NumDíasNImporteN

-- …

-- TemporadaN
-- Importe Total Alojamiento: n.nnn,nn
-- Gastos Extra

-- Fecha1
-- Concepto1Cuantía1
-- ConceptoNCuantíaN
-- ….

-- FechaN
-- Importe Total Gastos Extra: n.nnn,nn
-- Actividades Realizadas

-- Fecha1
-- NombreActividad1NumPersonas1Importe1
-- NombreActividadNNumPersonasNImporteN

-- …

-- FechaN
-- Importe Total Actividades Realizadas: n.nnn
-- Importe Factura: nn.nnn,nn

-- Notas: Si la estancia se ha hecho en régimen de Todo Incluido no se imprimirán los apartados de Gastos Extra o
-- Actividades Realizadas. Del mismo modo, si en la estancia no se ha efectuado ninguna Actividad o Gasto Extra, no
-- aparecerán en la factura.
-- Si una Actividad ha sido abonada in situ tampoco aparecerá en la factura.
-- Debes tener cuidado de facturar bien las estancias que abarcan varias temporadas.


        -- Función para devolver el nombre del cliente por el código de la estancia
            CREATE OR REPLACE FUNCTION NombreCliente (p_CodEst estancias.codigo%TYPE)
            RETURN VARCHAR2
            IS 
                v_nombre VARCHAR2;
            BEGIN
                SELECT nombre, apellidos INTO v_nombre
                FROM personas
                WHERE nif = (SELECT nifcliente
                             FROM estancias
                             WHERE codigo = p_CodEst);
                RETURN v_nombre;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN 
                    RETURN NULL;
                WHEN TOO_MANY_ROWS THEN
                    RETURN NULL;
            END;
            /

        -- Procedimiento para mostrar la habitación con las fechas de la estancia.
            CREATE OR REPLACE PROCEDURE Habitacion (p_CodEst estancias.codigo%TYPE)
            AS
                CURSOR c_alojamiento IS
                SELECT numerohabitacion, fecha_inicio, fecha_fin
                FROM estancias
                WHERE codigo = p_CodEst;
            BEGIN
                FOR c IN c_alojamiento LOOP
                DBMS_OUTPUT.PUT_LINE('Número Habitación: '||c.numerohabitacion||' Fecha Inicio: '||c.fecha_inicio||' Fecha Fin: '||c.fecha_fin);
                END LOOP;
            END;
            /
    
        -- Procedimiento para mostrar la estancia, cliente y el tipo de régimen.
            CREATE OR REPLACE PROCEDURE Regimen (p_CodEst estancias.codigo%TYPE)
            AS 
                CURSOR c_regimen IS
                SELECT nombre
                FROM regimenes
                WHERE codigo = (SELECT codigoregimen
                                FROM estancias
                                WHERE codigo = p_CodEst);
            BEGIN
                FOR c IN c_regimen LOOP
                    DBMS_OUTPUT.PUT_LINE('Codigo Estancia: '||p_CodEst);
                    DBMS_OUTPUT.PUT_LINE('Cliente: '||NombreCliente);
                    Habitacion(p_CodEst);
                    DBMS_OUTPUT.PUT_LINE('Regimen de Alojamiento: '||c.nombre);
                END LOOP;
            END;
            /

        -- Función para devolver el importe total
            CREATE OR REPLACE FUNCTION ImporteAlojamiento (p_CodEst estancias.codigo%TYPE)
            RETURN NUMBER
            IS
                v_importe
            BEGIN
                SELECT SUM(preciopordia) INTO v_importe
                FROM tarifas
                WHERE codigoregimen = (SELECT codigoregimen
                                       FROM estancias
                                       WHERE codigo = p_CodEst);
                RETURN v_importe;
            END;
            /

        -- Procedimiento para que muestre el importe total por el código de estancia
            CREATE OR REPLACE PROCEDURE Alojamiento (p_CodEst estancias.codigo%TYPE)
            AS
                CURSOR c_alojamiento IS
                SELECT nombre, fecha_fin - fecha_inicio AS dias, preciodia
                FROM temporadas te, tarifas ta
                WHERE te.codigo = codigotemporada AND codigoregimen = (SELECT codigoregimen
                                                                        FROM estancias
                                                                        WHERE codigo = p_CodEst)
                ORDER BY nombre;
            BEGIN
                DBMS_OUTPUT.PUT_LINE('Alojamiento');
                DBMS_OUTPUT.PUT_LINE('-----------');
                FOR c IN c_alojamiento LOOP
                    DBMS_OUTPUT.PUT_LINE(c.nombre||chr(7)||c.dias||chr(7)||c.preciopordia);
                END LOOP;
                DBMS_OUTPUT.PUT_LINE('Importe Total Alojamiento: '||ImporteAlojamiento(p_CodEst));
            END;
            /
        
        -- Función para devolver los gastos extras
            CREATE OR REPLACE FUNCTION ImporteGastosExtras (p_CodEst estancias.codigo%TYPE)
            RETURN NUMBER
            IS
            BEGIN
                SELECT SUM(cuantia) INTO v_gastos
                FROM gastos_extra
                WHERE codigoestancia = (SELECT codigo
                                        FROM estancias
                                        WHERE codigo = p_CodEst);
                RETURN v_gastos;
            END;
            /
        
        -- Función para comprobar regimen de Todo Incluido
            CREATE OR REPLACE FUNCTION TodoIncluido (p_CodEst estancias.codigo%TYPE)
            RETURN VARCHAR2
            IS
                v_codigo regimenes.codigo%TYPE;
            BEGIN
                SELECT codigo INTO v_codigo
                FROM regimenes
                WHERE codigo = (SELECT codigoregimen
                                FROM estancias
                                WHERE codigo = p_CodEst);
                RETURN v_codigo
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                RETURN 'Estancia no encontrada';
            END;
            /

        -- Procedimiento para mostrar los gastos extras por el cliente
            CREATE OR REPLACE PROCEDURE GastosExtras (p_CodEst estancias.codigo%TYPE)
            AS
                CURSOR c_gastoextra IS
                SELECT concepto, fecha, cuantia
                FROM gastos_extras
                WHERE codigoestancia = (SELECT codigo
                                        FROM estancias
                                        WHERE codigo = p_CodEst);
            BEGIN
                IF TodoIncluido(p_CodEst) != 'TI'
                    FOR c IN c_gastoextra LOOP
                        DBMS_OUTPUT.PUT_LINE('Gastos extras');
                        DBMS_OUTPUT.PUT_LINE('-------------');
                        DBMS_OUTPUT.PUT_LINE(c.concepto||chr(7)||c.fecha||chr(7)||c.cuantia);
                    END LOOP;
                        DBMS_OUTPUT.PUT_LINE('Importe Total Gastos Extras: '||ImporteGastosExtras(p_CodEst));
                ELSIF TodoIncluido(p_CodEst) = 'TI'
                    DBMS_OUTPUT.PUT_LINE('');
                END IF;
            END;
            /
        
        -- Función para devolver el importe de las actividades realizadas por persona y numero de personas
            CREATE OR REPLACE FUNCTION ImporteActividades (p_CodEst estancias.codigo%TYPE)
            RETURN NUMBER
            IS
                v_actividades
            BEGIN
                SELECT SUM(precioporpersona * numpersonas) INTO v_actividades
                FROM actividadesrealizadas, actividades
                WHERE codigo = codigoactividad AND codigoestancia = (SELECT codigo
                                                                     FROM estancias
                                                                     WHERE codigo = p_CodEst);
                RETURN v_actividades;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                RETURN 'Actividades no encontrada';
            END;
            /

        -- Procedimiento para mostrar las actividades realizadas
            CREATE OR REPLACE PROCEDURE ActividadesRealizadas (p_CodEst estancias.codigo%TYPE)
            AS 
                CURSOR c_actividadReal IS
                SELECT fecha, nombre, numpersonas, (precioporpersona * numpersonas) AS total
                FROM actividadesrealizadas, actividades
                WHERE codigo = codigoactividad AND codigoestancia = (SELECT codigo
                                                                     FROM estancias
                                                                     WHERE codigo = p_CodEst);
            BEGIN
                 IF TodoIncluido(p_CodEst) != 'TI'
                    FOR c IN c_actividadReal LOOP
                        IF TO_DATE(SYSDATE, 'DD-MM-YYYY hh24:mi') != c.fecha THEN
                            DBMS_OUTPUT.PUT_LINE('Actividades realizadas');
                            DBMS_OUTPUT.PUT_LINE('---------------------');
                            DBMS_OUTPUT.PUT_LINE(c.fecha||chr(7)||c.nombre||chr(7)||c.numpersonas||chr(7)||c.total);
                        END IF;
                    END LOOP;
                    DBMS_OUTPUT.PUT_LINE('Importe Total Actividades Realizadas: '||ImporteActividades(p_CodEst));
                ELSIF TodoIncluido(p_CodEst) = 'TI'
                    DBMS_OUTPUT.PUT_LINE('');
                END IF;
            END;
            /
        
        -- Procedimiento para calcular la factura
            CREATE OR REPLACE PROCEDURE Factura (p_CodEst estancias.codigo%TYPE)
            AS
                v_alojamiento NUMBER;
                v_gastosextras NUMBER;
                v_actividadesReal NUMBER;
                v_TotalGastos NUMBER;
            BEGIN
                v_alojamiento := Alojamiento(p_CodEst);
                v_gastosextras := GastosExtras(p_CodEst);
                v_actividadesReal := ActividadesRealizadas(p_CodEst);
                v_TotalGastos := v_alojamiento + v_gastosextras + v_actividadesReal;
                DBMS_OUTPUT.PUT_LINE('Importe Factura: '||v_TotalGastos);
            END;
            /
        
        -- Procedimiento para mostrar la factura del cliente 
            CREATE OR REPLACE PROCEDURE MostrarFactura (p_CodEst estancias.codigo%TYPE)
            AS
            BEGIN
                DBMS_OUTPUT.PUT_LINE('Complejo Rural La Fuente');
                DBMS_OUTPUT.PUT_LINE('Candelario (Salamanca)');
                DBMS_OUTPUT.PUT_LINE(chr(5));
                Regimen(p_CodEst);
                DBMS_OUTPUT.PUT_LINE(chr(5));
                Alojamiento(p_CodEst);
                DBMS_OUTPUT.PUT_LINE(chr(5));
                GastosExtras(p_CodEst);
                DBMS_OUTPUT.PUT_LINE(chr(5));
                ActividadesRealizadas(p_CodEst);
                DBMS_OUTPUT.PUT_LINE(chr(5));
                Factura(p_CodEst);
            END;
            /

    exec MostrarFactura('');

--3.Realiza un trigger que impida que haga que cuando se inserte la realización de una actividad asociada a una
-- estancia en regimen TI el campo Abonado no pueda valer FALSE.

    CREATE OR REPLACE TRIGGER ActividadenTI
    AFTER INSERT ON actividadesrealizadas
    fOR EACH ROW
    DECLARE
        v_estancia VARCHAR2(2);
    BEGIN
        SELECT codigo INTO v_estancia
        FROM regimenes
        WHERE codigo IN (SELECT codigoregimen
                         FROM estancias
                         WHERE codigo = :new.codigoestancia);

        IF v_estancia = 'TI' AND :new.abonado = 'N' THEN
            RAISE_APPLICATION_ERROR(-21000, 'La actividad en regimen Todo Incluido debe estar abonada.')
        END IF;  
    END;
    /
    -- comprobar trigger --
    INSERT INTO actividadesrealizadas VALUES ('04','B302',TO_DATE('10-08-2022 12:00','DD-MM-YYYY hh24:mi'),4,'N');



-- 4.Añade un campo email a los clientes y rellénalo para algunos de ellos. Realiza un trigger que cuando se rellene el
-- campo Fecha de la Factura envíe por correo electrónico un resumen de la factura al cliente, incluyendo los datos
-- fundamentales de la estancia, el importe de cada apartado y el importe total.

        -- Añadir columna email a la tabla personas
            ALTER TABLE personas ADD email VARCHAR2(50);

        -- Datos

            UPDATE personas
            SET email = 
                CASE 
                    WHEN nif = '36059752F' THEN 'antonio.melandez@gmail.com'
                    WHEN nif = '10402498N' THEN 'carlosm@outlook.com'
                    WHEN nif = '10950967T' THEN 'ana17gutierrez@gmail.com'
                    WHEN nif = '54890865P' THEN 'a.rodriguez@gmail.com'
                    WHEN nif = '40687067K' THEN 'aitor-leon22@gmail.com'
                    WHEN nif = '77399071T' THEN 'virginia.leon@outlook.com'
                    WHEN nif = '69191424H' THEN 'antonio.fernandez@gmail.com'
                    WHEN nif = '88095695Z' THEN 'shu_adrian_garcia@hotmail.com'
                    WHEN nif = '95327640T' THEN 'juan.romero@gmail.com'
                    WHEN nif = '06852683V' THEN 'tito_franco23@hotmail.com'
                    ELSE email
                END;
        -- 

-- 5.Añade a la tabla Actividades una columna llamada BalanceHotel. La columna contendrá la cantidad que debe
-- pagar el hotel a la empresa (en cuyo caso tendrá signo positivo) o la empresa al hotel (en cuyo caso tendrá signo
-- negativo) a causa de las Actividades Realizadas por los clientes. Realiza un procedimiento que rellene dicha
-- columna y un trigger que la mantenga actualizada cada vez que la tabla ActividadesRealizadas sufra cualquier
-- cambio.
-- Te recuerdo que cada vez que un cliente realiza una actividad, hay dos posibilidades: Si el cliente está en TI el
-- hotel paga a la empresa el coste de la actividad. Si no está en TI, el hotel recibe un porcentaje de comisión del
-- importe que paga el cliente por realizar la actividad.

-- 6.Realiza los módulos de programación necesarios para que una actividad no sea realizada en una fecha concreta
-- por más de 10 personas.

-- 7.Realiza los módulos de programación necesarios para que los precios de un mismo tipo de habitación en una
-- misma temporada crezca en función de los servicios ofrecidos de esta forma: Precio TI > Precio PC > Precio MP>
-- Precio AD

-- 8.Realiza los módulos de programación necesarios para que un cliente no pueda realizar dos estancias que se
-- solapen en fechas entre ellas, esto es, un cliente no puede comenzar una estancia hasta que no haya terminado la
-- anterior.