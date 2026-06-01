if not exists (
select name from sys.databases where name = 'ComprasVentasInventarioDB'
)
begin
create database comprasventasinventariodb
end
go

use comprasventasinventariodb
go

if not exists (select 1 from sys.schemas where name = 'seguridad')
exec('create schema seguridad authorization dbo')
go

if not exists (select 1 from sys.schemas where name = 'datos')
exec('create schema datos authorization dbo')
go

if not exists (select 1 from sys.schemas where name = 'reportes')
exec('create schema reportes authorization dbo')
go

grant select, insert, update, delete on schema::datos to public;
go

grant select, insert, update, delete on schema::seguridad to public;
go

grant select on schema::reportes to public;
go

deny delete on schema::reportes to public;
go

drop table if exists seguridad.permiso_rol;
drop table if exists seguridad.rol_usuario;
drop table if exists seguridad.permiso;
drop table if exists seguridad.rol;
drop table if exists seguridad.usuario;
drop table if exists datos.detallecompra;
drop table if exists datos.detalleventa;
drop table if exists datos.movimientoinventario;
drop table if exists datos.inventario;
drop table if exists datos.compra;
drop table if exists datos.venta;
drop table if exists datos.producto;
drop table if exists datos.proveedor;
drop table if exists datos.cliente;
drop table if exists datos.unidadmedida;
drop table if exists datos.marca;
drop table if exists datos.categoria;
drop table if exists datos.bodega;
drop table if exists datos.ciudad;
drop table if exists datos.departamento;
go

create table seguridad.usuario (
id_usuario int primary key identity(1,1),
nombre_usuario nvarchar(100) not null constraint uq_usuario_nombre unique,
correo nvarchar(150) not null constraint uq_usuario_correo unique,
contrasena_hash nvarchar(256) not null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null
)
go

create table seguridad.rol (
id_rol int primary key identity(1,1),
nombre_rol nvarchar(100) not null constraint uq_rol_nombre unique,
descripcion nvarchar(255) null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null
)
go

create table seguridad.permiso (
id_permiso int primary key identity(1,1),
nombre_permiso nvarchar(100) not null constraint uq_permiso_nombre unique,
descripcion nvarchar(255) null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null
)
go

create table seguridad.rol_usuario (
id_rol_usuario int primary key identity(1,1),
id_usuario int not null,
id_rol int not null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint uq_rol_usuario unique (id_usuario, id_rol),
constraint fk_rol_usuario_usuario foreign key (id_usuario) references seguridad.usuario(id_usuario),
constraint fk_rol_usuario_rol foreign key (id_rol) references seguridad.rol(id_rol)
)
go

create table seguridad.permiso_rol (
id_permiso_rol int primary key identity(1,1),
id_rol int not null,
id_permiso int not null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint uq_permiso_rol unique (id_rol, id_permiso),
constraint fk_permiso_rol_rol foreign key (id_rol) references seguridad.rol(id_rol),
constraint fk_permiso_rol_permiso foreign key (id_permiso) references seguridad.permiso(id_permiso)
)
go

create table datos.departamento (
id_departamento int primary key identity(1,1),
nombre_departamento nvarchar(100) not null constraint uq_departamento_nombre unique,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null
)
go

create table datos.ciudad (
id_ciudad int primary key identity(1,1),
nombre_ciudad nvarchar(100) not null,
id_departamento int not null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint fk_ciudad_departamento foreign key (id_departamento) references datos.departamento(id_departamento)
)
go

create table datos.proveedor (
id_proveedor int primary key identity(1,1),
nombre_proveedor nvarchar(100) not null,
telefono nvarchar(20) null,
id_ciudad int null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint fk_proveedor_ciudad foreign key (id_ciudad) references datos.ciudad(id_ciudad)
)
go

create table datos.cliente (
id_cliente int primary key identity(1,1),
nombre_cliente nvarchar(100) not null,
id_ciudad int not null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint fk_cliente_ciudad foreign key (id_ciudad) references datos.ciudad(id_ciudad)
)
go

create table datos.categoria (
id_categoria int primary key identity(1,1),
nombre_categoria nvarchar(100) not null constraint uq_categoria_nombre unique,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null
)
go

create table datos.marca (
id_marca int primary key identity(1,1),
nombre_marca nvarchar(100) not null constraint uq_marca_nombre unique,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null
)
go

create table datos.unidadmedida (
id_unidad_medida int primary key identity(1,1),
nombre_unidad nvarchar(50) not null constraint uq_unidad_nombre unique,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null
)
go

create table datos.bodega (
id_bodega int primary key identity(1,1),
nombre_bodega nvarchar(100) not null,
id_ciudad int null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint fk_bodega_ciudad foreign key (id_ciudad) references datos.ciudad(id_ciudad)
)
go

create table datos.producto (
id_producto int primary key identity(1,1),
nombre_producto nvarchar(100) not null,
precio_venta decimal(10,2) not null,
id_categoria int not null,
id_marca int not null,
id_unidad_medida int not null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint chk_producto_precio check (precio_venta > 0),
constraint fk_producto_categoria foreign key (id_categoria) references datos.categoria(id_categoria),
constraint fk_producto_marca foreign key (id_marca) references datos.marca(id_marca),
constraint fk_producto_unidad foreign key (id_unidad_medida) references datos.unidadmedida(id_unidad_medida)
)
go

create table datos.inventario (
id_producto int not null,
id_bodega int not null,
stock int not null default 0,
stock_minimo int not null default 0,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint pk_inventario primary key (id_producto, id_bodega),
constraint chk_inventario_stock check (stock >= 0),
constraint chk_inventario_stockmin check (stock_minimo >= 0),
constraint fk_inventario_producto foreign key (id_producto) references datos.producto(id_producto),
constraint fk_inventario_bodega foreign key (id_bodega) references datos.bodega(id_bodega)
)
go

create table datos.movimientoinventario (
id_movimiento int primary key identity(1,1),
id_producto int not null,
id_bodega int not null,
tipo_movimiento nvarchar(20) not null,
cantidad int not null,
fecha_movimiento datetime not null default getdate(),
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint chk_movimiento_tipo check (tipo_movimiento in ('ENTRADA', 'SALIDA')),
constraint chk_movimiento_cantidad check (cantidad > 0),
constraint fk_movimiento_producto foreign key (id_producto) references datos.producto(id_producto),
constraint fk_movimiento_bodega foreign key (id_bodega) references datos.bodega(id_bodega)
)
go

create table datos.venta (
id_venta int primary key identity(1,1),
fecha_venta date not null default cast(getdate() as date),
total_venta decimal(10,2) not null default 0.00,
id_cliente int not null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint chk_venta_total check (total_venta >= 0),
constraint fk_venta_cliente foreign key (id_cliente) references datos.cliente(id_cliente)
)
go

create table datos.detalleventa (
id_detalle_venta int primary key identity(1,1),
id_venta int not null,
id_producto int not null,
cantidad_venta int not null,
precio_unitario decimal(10,2) not null,
subtotal decimal(10,2) not null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint chk_detalle_venta_cantidad check (cantidad_venta > 0),
constraint chk_detalle_venta_precio check (precio_unitario > 0),
constraint chk_detalle_venta_subtotal check (subtotal >= 0),
constraint fk_detalle_venta_venta foreign key (id_venta) references datos.venta(id_venta),
constraint fk_detalle_venta_producto foreign key (id_producto) references datos.producto(id_producto)
)
go

create table datos.compra (
id_compra int primary key identity(1,1),
fecha_compra date not null default cast(getdate() as date),
total_compra decimal(10,2) not null default 0.00,
id_proveedor int not null,
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint chk_compra_total check (total_compra >= 0),
constraint fk_compra_proveedor foreign key (id_proveedor) references datos.proveedor(id_proveedor)
)
go

create table datos.detallecompra (
id_detalle_compra int primary key identity(1,1),
id_compra int not null,
id_producto int not null,
cantidad_compra int not null,
precio_compra decimal(10,2) not null,
subtotal_compra as cast(cantidad_compra * precio_compra as decimal(10,2)),
is_active bit not null default 1,
created_at datetime not null default getdate(),
updated_at datetime null,
deleted_at datetime null,
constraint chk_detalle_compra_cantidad check (cantidad_compra > 0),
constraint chk_detalle_compra_precio check (precio_compra > 0),
constraint fk_detalle_compra_compra foreign key (id_compra) references datos.compra(id_compra),
constraint fk_detalle_compra_producto foreign key (id_producto) references datos.producto(id_producto)
)
go

insert into datos.departamento (nombre_departamento) values
('Managua'),
('Granada'),
('León'),
('Masaya'),
('Matagalpa'),
('Chinandega'),
('Estelí'),
('Rivas'),
('Carazo'),
('Nueva Segovia')
go

insert into datos.ciudad (nombre_ciudad, id_departamento) values
('Managua', 1),
('Granada', 2),
('León', 3),
('Masaya', 4),
('Matagalpa', 5),
('Chinandega', 6),
('Estelí', 7),
('Rivas', 8),
('Jinotepe', 9),
('Ocotal', 10),
('Tipitapa', 1),
('Diriamba', 9)
go

insert into datos.bodega (nombre_bodega, id_ciudad) values
('Bodega Central Managua', 1),
('Bodega Norte Managua', 1),
('Bodega Sur Managua', 1),
('Bodega Granada', 2),
('Bodega León', 3),
('Bodega Matagalpa', 5),
('Bodega Estelí', 7),
('Bodega Masaya', 4),
('Bodega Chinandega', 6),
('Bodega Rivas', 8)
go

insert into datos.categoria (nombre_categoria) values
('Bebidas'),
('Lácteos'),
('Panadería'),
('Carnes y Embutidos'),
('Granos y Cereales'),
('Limpieza'),
('Higiene Personal'),
('Confitería'),
('Electrónica'),
('Papelería')
go

insert into datos.marca (nombre_marca) values
('Coca-Cola'),
('Nestlé'),
('La Perfecta'),
('Tip Top'),
('Bimbo'),
('Colgate'),
('Lala'),
('Diana'),
('Toña'),
('Saltica')
go

insert into datos.unidadmedida (nombre_unidad) values
('Unidad'),
('Caja'),
('Litro'),
('Kilogramo'),
('Gramo'),
('Docena'),
('Par'),
('Bolsa'),
('Paquete'),
('Metro')
go

insert into datos.proveedor (nombre_proveedor, telefono, id_ciudad) values
('Distribuidora El Sol S.A.', '2255-1234', 1),
('Comercial del Norte S.A.', '2268-5678', 1),
('Importaciones La Paz S.A.', '2270-9012', 1),
('Carnes y Más Nicaragua', '8765-3344', 1),
('Distribuidora Nacional S.A.', '2266-7890', 1),
('Lácteos del Campo S.A.', '8891-2233', 5),
('Bebidas Centroamericanas S.A.', '2255-4455', 1),
('Limpieza Total Nicaragua', '8774-6677', 1),
('Granos del Pacífico S.A.', '2244-8899', 3),
('Higiene y Salud S.A.', '8763-5511', 1)
go

insert into datos.cliente (nombre_cliente, id_ciudad) values
('Carlos Pérez Hernández', 1),
('María López Torres', 2),
('Juan Martínez Silva', 3),
('Ana García Ruiz', 1),
('Luis Sánchez Morales', 4),
('Rosa Mendoza Flores', 5),
('Jorge Castillo Reyes', 6),
('Patricia Vega Jiménez', 7),
('Roberto Núñez Espinoza', 8),
('Carmen Ríos Gutiérrez', 9),
('Fernando Alvarado Bonilla', 11),
('Silvia Centeno Obando', 12)
go

insert into datos.producto (nombre_producto, precio_venta, id_categoria, id_marca, id_unidad_medida) values
('Coca-Cola 600 ml', 25.00, 1, 1, 1),
('Leche Entera La Perfecta 1L', 40.00, 2, 3, 3),
('Pan Blanco Bimbo 350g', 30.00, 3, 5, 1),
('Jugo de Naranja Nestlé 500ml', 35.00, 1, 2, 1),
('Queso Fresco 500g', 80.00, 2, 3, 9),
('Arroz Diana 5lb', 75.00, 5, 8, 9),
('Jabón Colgate Protección 90g', 25.00, 7, 6, 1),
('Pollo Entero Tip Top 1kg', 120.00, 4, 4, 4),
('Cerveza Toña 355ml', 30.00, 1, 9, 1),
('Crema Lala 200ml', 45.00, 2, 7, 1),
('Aceite Diana 1L', 85.00, 5, 8, 3),
('Frijoles Negros Diana 1lb', 40.00, 5, 8, 9)
go

insert into datos.inventario (id_producto, id_bodega, stock, stock_minimo) values
(1, 1, 120, 20),
(2, 1, 65, 15),
(3, 1, 90, 25),
(4, 1, 80, 20),
(5, 1, 45, 10),
(6, 1, 55, 15),
(7, 1, 180, 30),
(8, 1, 35, 10),
(9, 1, 95, 20),
(10, 1, 60, 15),
(11, 1, 40, 10),
(12, 1, 70, 20),
(1, 2, 50, 10)
go

insert into datos.movimientoinventario (id_producto, id_bodega, tipo_movimiento, cantidad, fecha_movimiento) values
(1, 1, 'ENTRADA', 100, '2026-01-02 08:00:00'),
(9, 1, 'ENTRADA', 50, '2026-01-02 08:30:00'),
(2, 1, 'ENTRADA', 60, '2026-01-08 09:00:00'),
(5, 1, 'ENTRADA', 30, '2026-01-08 09:30:00'),
(1, 1, 'SALIDA', 3, '2026-01-05 10:00:00'),
(2, 1, 'SALIDA', 2, '2026-01-05 10:05:00'),
(3, 1, 'ENTRADA', 80, '2026-01-15 08:00:00'),
(6, 1, 'ENTRADA', 40, '2026-01-15 08:30:00'),
(3, 1, 'SALIDA', 5, '2026-01-12 11:00:00'),
(6, 1, 'SALIDA', 1, '2026-01-12 11:10:00'),
(4, 1, 'ENTRADA', 70, '2026-01-22 08:00:00'),
(10, 1, 'ENTRADA', 50, '2026-01-22 08:30:00')
go

insert into datos.venta (fecha_venta, id_cliente, total_venta) values
('2026-01-05', 1, 155.00),
('2026-01-12', 2, 225.00),
('2026-01-18', 3, 270.00),
('2026-01-25', 4, 315.00),
('2026-02-03', 5, 200.00),
('2026-02-10', 6, 230.00),
('2026-02-17', 7, 290.00),
('2026-02-24', 8, 430.00),
('2026-03-05', 9, 395.00),
('2026-03-12', 10, 520.00)
go

insert into datos.detalleventa (id_venta, id_producto, cantidad_venta, precio_unitario, subtotal) values
(1, 1, 3, 25.00, 75.00),
(1, 2, 2, 40.00, 80.00),
(2, 3, 5, 30.00, 150.00),
(2, 5, 1, 75.00, 75.00),
(3, 1, 6, 25.00, 150.00),
(3, 9, 4, 30.00, 120.00),
(4, 7, 3, 25.00, 75.00),
(4, 8, 2, 120.00, 240.00),
(5, 2, 3, 40.00, 120.00),
(5, 5, 1, 80.00, 80.00),
(6, 4, 4, 35.00, 140.00),
(6, 10, 2, 45.00, 90.00),
(7, 11, 2, 85.00, 170.00),
(7, 12, 3, 40.00, 120.00),
(8, 1, 10, 25.00, 250.00),
(8, 9, 6, 30.00, 180.00),
(9, 3, 4, 30.00, 120.00),
(9, 6, 2, 75.00, 150.00),
(9, 7, 5, 25.00, 125.00),
(10, 8, 3, 120.00, 360.00),
(10, 2, 4, 40.00, 160.00)
go

insert into datos.compra (fecha_compra, id_proveedor, total_compra) values
('2026-01-02', 1, 2900.00),
('2026-01-08', 6, 3330.00),
('2026-01-15', 3, 3800.00),
('2026-01-22', 7, 3250.00),
('2026-02-05', 4, 5200.00),
('2026-02-12', 9, 5240.00),
('2026-02-20', 6, 4440.00),
('2026-03-05', 3, 3950.00),
('2026-03-12', 1, 5800.00),
('2026-03-20', 5, 5490.00)
go

insert into datos.detallecompra (id_compra, id_producto, cantidad_compra, precio_compra) values
(1, 1, 100, 18.00),
(1, 9, 50, 22.00),
(2, 2, 60, 28.00),
(2, 5, 30, 55.00),
(3, 3, 80, 20.00),
(3, 6, 40, 55.00),
(4, 4, 70, 25.00),
(4, 10, 50, 30.00),
(5, 8, 40, 85.00),
(5, 7, 100, 18.00),
(6, 11, 50, 60.00),
(6, 12, 80, 28.00),
(7, 2, 80, 28.00),
(7, 5, 40, 55.00),
(8, 3, 60, 20.00),
(8, 6, 50, 55.00),
(9, 1, 200, 18.00),
(9, 9, 100, 22.00),
(10, 4, 90, 25.00),
(10, 10, 60, 30.00),
(10, 7, 80, 18.00)
go

insert into seguridad.rol (nombre_rol, descripcion) values
('administrador', 'acceso total al sistema'),
('supervisor', 'acceso a reportes y consultas de todas las areas'),
('vendedor', 'registro y consulta de ventas'),
('comprador', 'registro y consulta de compras'),
('bodeguero', 'gestion de inventario y movimientos'),
('consultor', 'solo lectura en todas las tablas')
go

insert into seguridad.permiso (nombre_permiso, descripcion) values
('ventas.crear', 'crear nuevas ventas'),
('ventas.leer', 'consultar ventas'),
('ventas.actualizar', 'modificar ventas existentes'),
('ventas.eliminar', 'eliminar ventas'),
('compras.crear', 'crear nuevas compras'),
('compras.leer', 'consultar compras'),
('compras.actualizar', 'modificar compras existentes'),
('compras.eliminar', 'eliminar compras'),
('inventario.crear', 'registrar entradas y salidas'),
('inventario.leer', 'consultar inventario'),
('inventario.actualizar', 'ajustar stock'),
('inventario.eliminar', 'eliminar registros de inventario'),
('catalogos.crear', 'crear productos, categorias, marcas'),
('catalogos.leer', 'consultar catalogos'),
('catalogos.actualizar', 'editar catalogos'),
('catalogos.eliminar', 'eliminar catalogos'),
('seguridad.gestionar', 'administrar usuarios y roles')
go

insert into seguridad.usuario (nombre_usuario, correo, contrasena_hash) values
('admin', 'admin@sinorges.com', 'hash_admin_placeholder'),
('vendedor01', 'vendedor01@sinorges.com', 'hash_v01_placeholder'),
('comprador01', 'comprador01@sinorges.com', 'hash_c01_placeholder'),
('bodeguero01', 'bodeguero01@sinorges.com', 'hash_b01_placeholder'),
('consultor01', 'consultor01@sinorges.com', 'hash_cons01_placeholder')
go

insert into seguridad.rol_usuario (id_usuario, id_rol) values
(1, 1),
(2, 3),
(3, 4),
(4, 5),
(5, 6)
go

insert into seguridad.permiso_rol (id_rol, id_permiso) values
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,8),(1,9),(1,10),(1,11),(1,12),(1,13),(1,14),(1,15),(1,16),(1,17),
(2,2),(2,6),(2,10),(2,14),
(3,1),(3,2),(3,3),
(4,5),(4,6),(4,7),
(5,9),(5,10),(5,11),
(6,2),(6,6),(6,10),(6,14)
go

alter table datos.cliente
add correo nvarchar(150) null;
go

create unique index uq_cliente_correo on datos.cliente (correo) where correo is not null;
go

alter table datos.proveedor
add correo nvarchar(150) null;
go

alter table datos.proveedor
add direccion nvarchar(255) null;
go

alter table datos.producto
add descripcion nvarchar(255) null;
go

alter table datos.producto
add codigo_barra nvarchar(50) null;
go

create unique index uq_producto_codigo on datos.producto (codigo_barra) where codigo_barra is not null;
go

alter table datos.venta
add observacion nvarchar(255) null;
go

alter table datos.compra
add observacion nvarchar(255) null;
go

alter table datos.compra
add numero_factura nvarchar(50) null;
go

create unique index uq_compra_factura on datos.compra (numero_factura) where numero_factura is not null;
go

alter table datos.bodega
add responsable nvarchar(100) null;
go

alter table datos.bodega
add telefono nvarchar(20) null;
go

alter table seguridad.usuario
add ultimo_acceso datetime null;
go

alter table seguridad.usuario
add intentos_fallidos int not null default 0;
go

alter table seguridad.usuario
add constraint chk_usuario_intentos check (intentos_fallidos >= 0);
go
