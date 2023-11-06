create table temporadas
(
	codigo			varchar2(9),
	Nombre			varchar2(35),
	fecha_inicio	date,
	fecha_fin		date,
	constraint pk_temporadas primary key (codigo)
);	

create table regimenes
(
	codigo			varchar2(9),
	Nombre			varchar2(35),
	constraint pk_regimenes primary key (codigo),
	constraint contenido_codigo check( codigo in ('AD','MP','PC','TI'))
);	

create table tipos_de_habitacion
(
	codigo			varchar2(9),
	nombre			varchar2(35),
	constraint pk_tipohabit primary key (codigo)
);	

create table habitaciones
(
	numero			varchar2(4),
	codigotipo		varchar2(9),
	constraint pk_habitaciones primary key (numero),
	constraint fk_habitaciones foreign key (codigotipo) references tipos_de_habitacion(codigo)
);	

create table personas
(
	nif			varchar2(9),
	nombre			varchar2(35) constraint nombre_obligatorio not null,
	apellidos		varchar2(35) constraint apellidos_obligatorio not null,
	direccion		varchar2(150) constraint direccion_obligatorio not null,
	localidad		varchar2(35) constraint localidad_obligatorio not null,
	constraint pk_personas primary key (nif),
	constraint nif_valido check (regexp_like (nif,'[0-9]{8}[A-Z]{1}') or regexp_like (nif, '[K,L,M,X,Y,Z]{1}[0-9]{7}[A-Z]{1}')),
  	constraint localidades check(localidad like '%(Salamanca)' or localidad like '%(Ávila)' or localidad like '%(Madrid)')
);	

create table estancias
(
	codigo			varchar2(9),
	fecha_inicio		date,
	fecha_fin		date,
	numerohabitacion	varchar2(9),
	nifresponsable		varchar2(9),
	nifcliente		varchar2(9),
	codigoregimen		varchar2(9),
	constraint pk_estancias primary key (codigo),
	constraint unica_estancia unique (nifresponsable),
	constraint fk_estanciasnumhab foreign key (numerohabitacion) references habitaciones(numero),
	constraint fk_estanciasnifresp foreign key (nifresponsable) references personas(nif),
	constraint fk_estanciasnifcli foreign key (nifcliente) references personas(nif),
	constraint fk_estanciasregim foreign key (codigoregimen) references regimenes(codigo),
	constraint fecha_salida check( to_char(fecha_fin,'hh24:mi')<='21:00')
);	

create table tarifas
(
	codigo			varchar2(9),
	codigotipohabitacion	varchar2(9),
	codigotemporada		varchar2(9),
	codigoregimen		varchar2(9),
	preciopordia		number(6,2),
	constraint pk_tarifas primary key (codigo),
	constraint fk_tarifastipo foreign key (codigotipohabitacion) references tipos_de_habitacion(codigo),
	constraint fk_tarifasregimenes foreign key (codigoregimen) references regimenes(codigo),
	constraint fk_tarifastempor foreign key (codigotemporada) references temporadas(codigo)
);	

create table facturas
(
	numero			varchar2(9),
	codigoestancia		varchar2(9),
	fecha			date,
	constraint pk_facturas primary key (numero),
	constraint fk_facturas foreign key (codigoestancia) references estancias (codigo)
);

create table gastos_extra
(
	codigogasto		varchar2(9),
	codigoestancia		varchar2(9),
	fecha			date,
	concepto		varchar(120),
	cuantia			number(6,2),
	constraint pk_gastext primary key (codigogasto),
	constraint fk_gastext foreign key (codigoestancia) references estancias(codigo)
);


create table actividades
(
	codigo			varchar2(9),
	nombre			varchar2(35),
	descripcion		varchar2(140),
	precioporpersona	number(6,2),
	comisionhotel		number(6,2),
	costepersonaparahotel	number(6,2),
	constraint pk_actividades primary key (codigo),
	constraint codigo_valido check( regexp_like( codigo, '[A-Z]{1}[0-9]{3}.*')),
	constraint comisionhotel_inferior check(comisionhotel <= precioporpersona*0.25)
);


create table actividadesrealizadas
(
	codigoestancia		varchar2(9),
	codigoactividad		varchar2(9),
	fecha			date,
	numpersonas		number(6,2) default 1,
	abonado			number(6,2),
	constraint pk_actrealizadas primary key (codigoestancia, codigoactividad, fecha),
	constraint fk_actrealestan foreign key (codigoestancia) references estancias(codigo),
	constraint fk_actrealact foreign key (codigoactividad) references actividades(codigo),
  	constraint descanso_activs check(to_char(fecha, 'DAY') not like '%MON%' and to_char(fecha,'hh24:mi') not between '23:00' and '05:00')
);



/// INTRODUCCI�N DE DATOS

-//Temporadas	

insert into temporadas
values ('01','Baja', to_date('01-11-2023','DD-MM-YYYY'), to_date('31-03-2024'.'DD-MM-YYYY'));
insert into temporadas
values ('02','Alta', to_date('01-04-2023','DD-MM-YYYY'), to_date('31-10-2023'.'DD-MM-YYYY'));
insert into temporadas
values ('03','Especial', to_date('24-14-2023','DD-MM-YYYY'), to_date('06-01-2023'.'DD-MM-YYYY'));


-//Regimenes	
insert into regimenes
values ('AD','Alojamiento y Desayuno');
insert into regimenes
values ('MP','Media pension');
insert into regimenes
values ('PC','Pension completa');
insert into regimenes
values ('TI','Todo incluido');


-//Tipos de habitacion	
insert into tipos_de_habitacion
values ('01','Habitacion individual');
insert into tipos_de_habitacion
values ('02','Habitacion doble');
insert into tipos_de_habitacion
values ('03','Habitacion triple');


-//Tarifas -- codigo, codigotipohabitacion, codigotemporada, codigoregimen, preciopordia
insert into tarifas
values ('00','01','01','AD',50);
insert into tarifas
values ('01','01','02','AD',70);
insert into tarifas
values ('02','01','03','AD',60);

insert into tarifas
values ('03','02','01','AD',60);
insert into tarifas
values ('04','02','02','AD',84);
insert into tarifas
values ('05','02','03','AD',72);

insert into tarifas
values ('06','03','01','AD',81);
insert into tarifas
values ('07','03','02','AD',115);
insert into tarifas
values ('08','03','03','AD',100);

insert into tarifas
values ('09','01','01','MP',35);
insert into tarifas
values ('10','01','02','MP',50);
insert into tarifas
values ('11','01','03','MP',40);

insert into tarifas
values ('12','02','01','MP',79);
insert into tarifas
values ('13','02','02','MP',119);
insert into tarifas
values ('14','02','03','MP',70);

insert into tarifas
values ('15','03','01','MP',43);
insert into tarifas
values ('16','03','02','MP',65);
insert into tarifas
values ('17','03','03','MP',52.5);

insert into tarifas
values ('18','01','01','PC',85);
insert into tarifas
values ('19','01','02','PC',102);
insert into tarifas
values ('20','01','03','PC',92.9);

insert into tarifas
values ('21','02','01','PC',80.5);
insert into tarifas
values ('22','02','02','PC',105.6);
insert into tarifas
values ('23','02','03','PC',93.5);

insert into tarifas
values ('24','03','01','PC',61.6);
insert into tarifas
values ('25','03','02','PC',110);
insert into tarifas
values ('26','03','03','PC',94.1);

insert into tarifas
values ('27','01','01','TI',79);
insert into tarifas
values ('28','01','02','TI',99);
insert into tarifas
values ('29','01','03','TI',86);

insert into tarifas
values ('30','02','01','TI',60);
insert into tarifas
values ('31','02','02','TI',95);
insert into tarifas
values ('32','02','03','TI',80);

insert into tarifas
values ('33','03','01','TI',60);
insert into tarifas
values ('34','03','02','TI',87);
insert into tarifas
values ('35','03','03','TI',70);


-//Habitaciones -- numero, codigotipo
insert into habitaciones
values ('00','01');
insert into habitaciones
values ('01','02');
insert into habitaciones
values ('02','03');
insert into habitaciones
values ('03','01');
insert into habitaciones
values ('04','02');
insert into habitaciones
values ('05','02');
insert into habitaciones
values ('06','02');
insert into habitaciones
values ('07','02');
insert into habitaciones
values ('08','03');
insert into habitaciones
values ('09','02');
insert into habitaciones
values ('10','01');
insert into habitaciones
values ('11','03');


-//Personas -- nif, nombre, apellidos, direccion, localidad
insert into personas
values ('54890865P','Alvaro','Rodriguez Marquez','C\ Alemania n�19','Madrid (Madrid)');
insert into personas
values ('40687067K','Aitor','Leon Delgado','Ciudad Blanca Blq 16 1�-D','Adanero (�vila)');
insert into personas
values ('77399071T','Virginia','Leon Delgado','Ciudad Blanca Blq 16 1�-D','Mu�opepe (�vila)');
insert into personas
values ('69191424H','Antonio Agustin','Fernandez Melendez','C\Armero n� 19','Mu�ico (�vila)');
insert into personas
values ('36059752F','Antonio','Melendez Delgado','C\Armero n� 18','Navadijos (�vila)');
insert into personas
values ('10402498N','Carlos','Mejias Calatrava','C\ Francisco de Rioja n� 9','Abusejo (Salamanca)');
insert into personas
values ('10950967T','Ana','Gutierrez Bando','C\ Burgos n� 3','Alaraz (Salamanca)');
insert into personas
values ('88095695Z','Adrian','Garcia Guerra','C\ Nueva n� 14','Moz�rbez (Salamanca)');
insert into personas
values ('95327640T','Juan Carlos','Romero Diaz','C\ San Lorenzo n� 22','Ajalvir (Madrid)');
insert into personas
values ('06852683V','Francisco','Franco Giraldez','AAVV Rosales n� 1','Legan�s (Madrid)');

-//Estancias -- codigo, fecha inicio, fecha fin, numerohabitacion, nifresponsable, nifcliente, codigoregimen
insert into estancias
values ('00',to_date('11-03-2016 12:00','DD-MM-YYYY hh24:mi'),to_date('13-03-2016 12:00','DD-MM-YYYY hh24:mi'),'00','54890865P','54890865P','AD');
insert into estancias
values ('01',to_date('19-05-2015 17:00','DD-MM-YYYY hh24:mi'),to_date('25-05-2015 17:00','DD-MM-YYYY hh24:mi'),'10','10950967T','10950967T','MP');
insert into estancias
values ('02',to_date('20-09-2015 13:30','DD-MM-YYYY hh24:mi'),to_date('21-09-2015 13:30','DD-MM-YYYY hh24:mi'),'03','10402498N','10402498N','AD');
insert into estancias 
values ('03',to_date('14-03-2015 11:15','DD-MM-YYYY hh24:mi'),to_date('16-03-2015 11:15','DD-MM-YYYY hh24:mi'),'02','95327640T','95327640T','MP');
insert into estancias
values ('04',to_date('30-07-2015 18:00','DD-MM-YYYY hh24:mi'),to_date('11-08-2015 18:00','DD-MM-YYYY hh24:mi'),'09','06852683V','06852683V','TI');
insert into estancias
values ('05',to_date('09-01-2016 16:35','DD-MM-YYYY hh24:mi'),to_date('12-01-2015 16:35','DD-MM-YYYY hh24:mi'),'05','40687067K','40687067K','MP');
insert into estancias
values ('06',to_date('26-12-2015 19:50','DD-MM-YYYY hh24:mi'),to_date('01-01-2016 19:50','DD-MM-YYYY hh24:mi'),'07','77399071T','77399071T','PC');
insert into estancias
values ('07',to_date('22-02-2016 20:20','DD-MM-YYYY hh24:mi'),to_date('29-02-2016 20:20','DD-MM-YYYY hh24:mi'),'04','69191424H','69191424H','PC');

-//Facturas -- numero, codigoestancia, fecha
insert into facturas
values ('00','00',to_date('13-03-2016 12:00','DD-MM-YYYY hh24:mi'));
insert into facturas
values ('01','02',to_date('21-09-2015 13:30','DD-MM-YYYY hh24:mi'));
insert into facturas
values ('02','04',to_date('11-08-2015 18:00','DD-MM-YYYY hh24:mi'));
insert into facturas
values ('03','07',to_date('29-02-2016 20:20','DD-MM-YYYY hh24:mi'));
insert into facturas
values ('04','05',to_date('12-01-2015 16:35','DD-MM-YYYY hh24:mi'));
insert into facturas
values ('05','01',to_date('25-05-2015 17:00','DD-MM-YYYY hh24:mi'));


-//Gastos Extras -- codigogasto, codigoestancia, fecha, concepto, cuantia
insert into gastos_extra
values ('00','03',to_date('15-03-2015 18:23','DD-MM-YYYY hh24:mi'),'Bolos',7);
insert into gastos_extra
values ('01','02',to_date('20-09-2015 19:15','DD-MM-YYYY hh24:mi'),'Centro de pasatiempo de mascotas',12);
insert into gastos_extra
values ('02','01',to_date('23-05-2015 12:40','DD-MM-YYYY hh24:mi'),'Piscina privada',2);
insert into gastos_extra
values ('03','01',to_date('23-05-2015 17:50','DD-MM-YYYY hh24:mi'),'Wifi',2);
insert into gastos_extra
values ('04','03',to_date('15-03-2015 20:00','DD-MM-YYYY hh24:mi'),'Masajes',8);
insert into gastos_extra
values ('05','05',to_date('11-01-2016 16:00','DD-MM-YYYY hh24:mi'),'Spa',8);
insert into gastos_extra
values ('06','07',to_date('24-02-2016 16:45','DD-MM-YYYY hh24:mi'),'Alquiler de bicicletas',5);
insert into gastos_extra
values ('07','02',to_date('20-09-2015 16:00','DD-MM-YYYY hh24:mi'),'Television',2);
insert into gastos_extra
values ('08','04',to_date('02-08-2015 13:30','DD-MM-YYYY hh24:mi'),'Rellenar minibar', 15);
insert into gastos_extra
values ('09','00',to_date('12-03-2016 18:15','DD-MM-YYYY hh24:mi'),'Aire acondicionado', 6);
insert into gastos_extra
values ('10','06',to_date('28-12-2015 19:23','DD-MM-YYYY hh24:mi'),'Telefono',3);
insert into gastos_extra
values ('11','02',to_date('21-09-2015 10:00','DD-MM-YYYY hh24:mi'),'Alquiler de pistas',2);


-//Actividades -- codigo, nombre, descripcion, precioporpersona, comisionhotel, costepersonaparahotel
insert into actividades
values ('A001','Aventura','Red de cuevas naturales visitables-Barrancos',15,3.74,0);
insert into actividades
values ('C093','Curso','Espeleologia- iniciacion',75,13,10);
insert into actividades
values ('B302','Hipica','Montar a caballo durante 2 horas',22,4,5);
insert into actividades
values ('A032','Tiro con Arco','4�u desperfecto de flecha',12,2,4);


-//Actividadesrealizadas -- codigoestancia, codigoactividad, fecha, numpersonas, abonado
insert into actividadesrealizadas
values ('01','A001',to_date('20-05-2015 17:30','DD-MM-YYYY hh24:mi'),2,30);
insert into actividadesrealizadas
values ('07','C093',to_date('25-02-2016 18:00','DD-MM-YYYY hh24:mi'),5,375);
insert into actividadesrealizadas
values ('06','B302',to_date('29-12-2015 12:00','DD-MM-YYYY hh24:mi'),1,22);
insert into actividadesrealizadas
values ('04','A032',to_date('04-08-2015 11:30','DD-MM-YYYY hh24:mi'),2,24);
insert into actividadesrealizadas
values ('01','C093',to_date('21-05-2015 17:00','DD-MM-YYYY hh24:mi'),2,150);
insert into actividadesrealizadas
values ('05','A001',to_date('10-01-2016 16:15','DD-MM-YYYY hh24:mi'),4,60);
insert into actividadesrealizadas
values ('07','B302',to_date('28-02-2016 17:45','DD-MM-YYYY hh24:mi'),3,66);
insert into actividadesrealizadas
values ('04','A032',to_date('07-08-2015 12:15','DD-MM-YYYY hh24:mi'),6,72);

