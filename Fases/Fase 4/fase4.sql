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
-- Debes tener cuidado de facturar bien las estancias que abarcan varias temporadas.3.Realiza un trigger que impida que haga que cuando se inserte la realización de una actividad asociada a una
-- estancia en regimen TI el campo Abonado no pueda valer FALSE.

-- 4.Añade un campo email a los clientes y rellénalo para algunos de ellos. Realiza un trigger que cuando se rellene el
-- campo Fecha de la Factura envíe por correo electrónico un resumen de la factura al cliente, incluyendo los datos
-- fundamentales de la estancia, el importe de cada apartado y el importe total.

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