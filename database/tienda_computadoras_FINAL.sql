-- ============================================================
-- TIENDA DE COMPUTADORAS - BASE DE DATOS COMPLETA
-- MySQL 8.x / MySQL Workbench
-- Ejecutar TODO este archivo desde el inicio.
-- ============================================================

DROP DATABASE IF EXISTS tienda_computadoras;
CREATE DATABASE tienda_computadoras CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tienda_computadoras;

SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE categoria (
  id_categoria BIGINT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion VARCHAR(255),
  estado TINYINT(1) NOT NULL DEFAULT 1,
  fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE marca (
  id_marca BIGINT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  descripcion VARCHAR(255),
  estado TINYINT(1) NOT NULL DEFAULT 1,
  fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE proveedor (
  id_proveedor BIGINT AUTO_INCREMENT PRIMARY KEY,
  razon_social VARCHAR(180) NOT NULL,
  ruc VARCHAR(11) UNIQUE,
  contacto VARCHAR(120),
  telefono VARCHAR(30),
  email VARCHAR(150),
  direccion VARCHAR(255),
  estado TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE usuario (
  id_usuario BIGINT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  username VARCHAR(60) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  rol ENUM('ADMIN','VENDEDOR') NOT NULL DEFAULT 'VENDEDOR',
  estado TINYINT(1) NOT NULL DEFAULT 1,
  fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cliente (
  id_cliente BIGINT AUTO_INCREMENT PRIMARY KEY,
  nombres VARCHAR(100) NOT NULL,
  apellidos VARCHAR(100) NOT NULL,
  tipo_documento ENUM('DNI','RUC','CE','PASAPORTE') NOT NULL DEFAULT 'DNI',
  documento VARCHAR(20) NOT NULL UNIQUE,
  email VARCHAR(150),
  telefono VARCHAR(30),
  direccion VARCHAR(255),
  ciudad VARCHAR(100),
  estado TINYINT(1) NOT NULL DEFAULT 1,
  fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE producto (
  id_producto BIGINT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(30) NOT NULL UNIQUE,
  nombre VARCHAR(150) NOT NULL,
  descripcion TEXT,
  precio DECIMAL(10,2) NOT NULL,
  precio_oferta DECIMAL(10,2) NULL,
  stock INT NOT NULL DEFAULT 0,
  stock_minimo INT NOT NULL DEFAULT 5,
  imagen VARCHAR(600),
  estado TINYINT(1) NOT NULL DEFAULT 1,
  id_categoria BIGINT,
  id_marca BIGINT,
  fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria) ON DELETE SET NULL,
  FOREIGN KEY (id_marca) REFERENCES marca(id_marca) ON DELETE SET NULL
);

CREATE TABLE compra (
  id_compra BIGINT AUTO_INCREMENT PRIMARY KEY,
  numero_compra VARCHAR(30) NOT NULL UNIQUE,
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_proveedor BIGINT NOT NULL,
  id_usuario BIGINT,
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  igv DECIMAL(10,2) NOT NULL DEFAULT 0,
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  estado ENUM('REGISTRADA','RECIBIDA','ANULADA') NOT NULL DEFAULT 'RECIBIDA',
  observacion VARCHAR(255),
  FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor),
  FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE SET NULL
);

CREATE TABLE detalle_compra (
  id_detalle_compra BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_compra BIGINT NOT NULL,
  id_producto BIGINT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  importe DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (id_compra) REFERENCES compra(id_compra) ON DELETE CASCADE,
  FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

CREATE TABLE pedido (
  id_pedido BIGINT AUTO_INCREMENT PRIMARY KEY,
  numero_pedido VARCHAR(30) NOT NULL UNIQUE,
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_cliente BIGINT,
  id_usuario BIGINT,
  tipo_comprobante ENUM('BOLETA','FACTURA','NOTA_VENTA') NOT NULL DEFAULT 'BOLETA',
  metodo_pago ENUM('EFECTIVO','YAPE','PLIN','TARJETA','TRANSFERENCIA') NOT NULL,
  estado_pago ENUM('PENDIENTE','PAGADO','ANULADO') NOT NULL DEFAULT 'PENDIENTE',
  estado_pedido ENUM('PENDIENTE','CONFIRMADO','PREPARANDO','ENVIADO','ENTREGADO','CANCELADO') NOT NULL DEFAULT 'PENDIENTE',
  direccion_entrega VARCHAR(255),
  referencia VARCHAR(255),
  subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
  igv DECIMAL(10,2) NOT NULL DEFAULT 0,
  descuento DECIMAL(10,2) NOT NULL DEFAULT 0,
  total DECIMAL(10,2) NOT NULL DEFAULT 0,
  observacion VARCHAR(500),
  FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE SET NULL,
  FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE SET NULL
);

CREATE TABLE detalle_pedido (
  id_detalle_pedido BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_pedido BIGINT NOT NULL,
  id_producto BIGINT NOT NULL,
  producto_nombre VARCHAR(150) NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  descuento DECIMAL(10,2) NOT NULL DEFAULT 0,
  importe DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE,
  FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

CREATE TABLE pago (
  id_pago BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_pedido BIGINT NOT NULL,
  fecha_pago DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  metodo ENUM('EFECTIVO','YAPE','PLIN','TARJETA','TRANSFERENCIA') NOT NULL,
  monto DECIMAL(10,2) NOT NULL,
  referencia VARCHAR(100),
  estado ENUM('PENDIENTE','APROBADO','RECHAZADO','ANULADO') NOT NULL DEFAULT 'PENDIENTE',
  FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE
);

CREATE TABLE comprobante (
  id_comprobante BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_pedido BIGINT NOT NULL UNIQUE,
  serie VARCHAR(10) NOT NULL,
  numero INT NOT NULL,
  tipo ENUM('BOLETA','FACTURA','NOTA_VENTA') NOT NULL,
  fecha_emision DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  cliente_nombre VARCHAR(200) NOT NULL,
  documento VARCHAR(20),
  subtotal DECIMAL(10,2) NOT NULL,
  igv DECIMAL(10,2) NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE
);

CREATE TABLE movimiento_stock (
  id_movimiento BIGINT AUTO_INCREMENT PRIMARY KEY,
  id_producto BIGINT NOT NULL,
  tipo ENUM('ENTRADA','SALIDA','AJUSTE') NOT NULL,
  cantidad INT NOT NULL,
  stock_anterior INT NOT NULL,
  stock_nuevo INT NOT NULL,
  motivo VARCHAR(255),
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  id_usuario BIGINT,
  FOREIGN KEY (id_producto) REFERENCES producto(id_producto),
  FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE SET NULL
);

CREATE TABLE contacto (
  id_contacto BIGINT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(150) NOT NULL,
  email VARCHAR(150),
  telefono VARCHAR(30),
  asunto VARCHAR(200),
  mensaje TEXT NOT NULL,
  estado ENUM('PENDIENTE','ATENDIDO') NOT NULL DEFAULT 'PENDIENTE',
  fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE configuracion_tienda (
  id_configuracion BIGINT AUTO_INCREMENT PRIMARY KEY,
  nombre_tienda VARCHAR(150) NOT NULL,
  ruc VARCHAR(11),
  telefono VARCHAR(30),
  whatsapp VARCHAR(30),
  email VARCHAR(150),
  direccion VARCHAR(255),
  horario VARCHAR(255),
  yape_numero VARCHAR(30),
  plin_numero VARCHAR(30),
  mensaje_footer VARCHAR(500)
);

-- ============================================================
-- DATOS DE PRUEBA
-- ============================================================

INSERT INTO categoria (id_categoria,nombre,descripcion) VALUES
(1,'Laptops','Laptops para estudio, trabajo y gaming'),
(2,'PC Gaming','Computadoras de escritorio para gaming y edición'),
(3,'Monitores','Monitores Full HD, QHD y gaming'),
(4,'Componentes','Procesadores, memoria RAM, SSD, tarjetas gráficas y más'),
(5,'Accesorios','Teclados, mouse, audífonos, webcams y periféricos'),
(6,'Impresoras','Impresoras para hogar, oficina y negocio'),
(7,'Redes','Routers, switches, adaptadores y conectividad');

INSERT INTO marca (id_marca,nombre,descripcion) VALUES
(1,'Lenovo','Equipos portátiles y computación'),
(2,'ASUS','Laptops, placas, monitores y gaming'),
(3,'Acer','Laptops y monitores'),
(4,'Kingston','Memoria y almacenamiento'),
(5,'Logitech','Periféricos'),
(6,'HP','Computadoras e impresoras'),
(7,'Dell','Computación y monitores'),
(8,'MSI','Gaming y componentes'),
(9,'Intel','Procesadores'),
(10,'AMD','Procesadores y tarjetas gráficas'),
(11,'NVIDIA','Tarjetas gráficas');

INSERT INTO proveedor (id_proveedor,razon_social,ruc,contacto,telefono,email,direccion) VALUES
(1,'Importaciones Tech Perú S.A.C.','20601234567','Luis Torres','987654321','ventas@techperu.com','Av. Wilson 1234, Lima'),
(2,'Distribuidora Computec S.A.C.','20598765432','María Flores','986543210','contacto@computec.com','Av. Argentina 850, Lima'),
(3,'Periféricos del Norte E.I.R.L.','20456789123','Carlos Medina','985432109','ventas@perinorte.com','Av. España 450, Trujillo'),
(4,'Soluciones Digitales Perú S.R.L.','20345678912','Ana Ruiz','984321098','ventas@solucionesdigitales.pe','Jr. Grau 720, Trujillo');

INSERT INTO usuario (id_usuario,nombre,username,password,rol) VALUES
(1,'Administrador General','admin','admin123','ADMIN'),
(2,'Vendedor Principal','vendedor','vendedor123','VENDEDOR'),
(3,'Vendedor 2','ventas02','ventas123','VENDEDOR');

INSERT INTO cliente (id_cliente,nombres,apellidos,tipo_documento,documento,email,telefono,direccion,ciudad) VALUES
(1,'Carlos','Ramírez','DNI','12345678','carlos@ejemplo.com','999111222','Av. España 100','Trujillo'),
(2,'María','Gómez','DNI','87654321','maria@ejemplo.com','988222333','Jr. Independencia 250','Trujillo'),
(3,'Juan','Pérez','DNI','45678912','juan@ejemplo.com','977333444','Av. América 520','Trujillo'),
(4,'Empresa Soluciones Norte','S.A.C.','RUC','20609876543','compras@solucionesnorte.com','966444555','Av. Mansiche 850','Trujillo'),
(5,'Lucía','Torres','DNI','74125896','lucia@ejemplo.com','955555666','Jr. Grau 410','Trujillo'),
(6,'Diego','Vargas','DNI','36985214','diego@ejemplo.com','944666777','Av. Larco 900','Trujillo');

INSERT INTO producto (id_producto,codigo,nombre,descripcion,precio,precio_oferta,stock,stock_minimo,imagen,estado,id_categoria,id_marca) VALUES
(1,'LAP-001','Lenovo IdeaPad 3','Laptop de 15.6 pulgadas para estudio, oficina y trabajo.',1899.00,1749.00,15,5,'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=900',1,1,1),
(2,'LAP-002','ASUS TUF Gaming','Laptop gaming de alto rendimiento para videojuegos y edición.',3299.00,3099.00,8,3,'https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=900',1,1,2),
(3,'PCG-001','PC Gaming RTX','PC de escritorio para gaming, streaming y edición.',4599.00,4299.00,5,2,'https://images.unsplash.com/photo-1587202372775-e229f172b9d7?w=900',1,2,8),
(4,'MON-001','Monitor 24 pulgadas','Monitor Full HD para oficina, estudio y entretenimiento.',699.00,649.00,20,5,'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=900',1,3,3),
(5,'TEC-001','Teclado mecánico RGB','Teclado mecánico retroiluminado para gaming y oficina.',249.00,NULL,30,8,'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=900',1,5,5),
(6,'SSD-001','SSD Kingston 1TB NVMe','Unidad SSD NVMe de 1 TB para mejorar velocidad y almacenamiento.',399.00,359.00,18,5,'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=900',1,4,4),
(7,'LAP-003','Acer Aspire 5','Laptop versátil para estudio y trabajo.',2299.00,2149.00,10,4,'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=900',1,1,3),
(8,'MON-002','ASUS TUF 27 Gaming','Monitor 27 pulgadas de alta frecuencia para gaming.',1199.00,1099.00,7,3,'https://images.unsplash.com/photo-1616763355548-1b606f439f86?w=900',1,3,2),
(9,'RAM-001','Kingston Fury 16GB DDR4','Memoria RAM DDR4 de 16 GB para PC.',299.00,269.00,25,8,'https://images.unsplash.com/photo-1562976540-1502c2145186?w=900',1,4,4),
(10,'MOU-001','Logitech G502 Gaming','Mouse gaming ergonómico con botones programables.',279.00,249.00,22,6,'https://images.unsplash.com/photo-1527814050087-3793815479db?w=900',1,5,5),
(11,'AUD-001','Audífonos Gaming Logitech','Audífonos con micrófono para juegos y reuniones.',349.00,319.00,14,5,'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=900',1,5,5),
(12,'IMP-001','HP DeskJet Multifunción','Impresora multifunción para hogar y oficina.',549.00,499.00,9,3,'https://images.unsplash.com/photo-1612815154858-60aa4c59eaa6?w=900',1,6,2),
(13,'CPU-001','Intel Core i5','Procesador Intel Core i5 para equipos de escritorio.',899.00,849.00,11,4,'https://images.unsplash.com/photo-1591799264318-7e6ef8ddb7ea?w=900',1,4,9),
(14,'GPU-001','ASUS GeForce RTX','Tarjeta gráfica para gaming y creación de contenido.',2499.00,2299.00,4,2,'https://images.unsplash.com/photo-1591488320449-011701bb6704?w=900',1,4,11),
(15,'ROU-001','Router WiFi 6','Router de alta velocidad para hogar y oficina.',399.00,349.00,16,5,'https://images.unsplash.com/photo-1606904825846-647eb07f5be2?w=900',1,7,2),
(16,'WEB-001','Webcam Full HD','Cámara web Full HD para videollamadas y clases.',189.00,169.00,19,5,'https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?w=900',1,5,5),
(17,'LAP-004','Dell Inspiron 15','Laptop de 15 pulgadas para trabajo y productividad.',2799.00,2599.00,6,3,'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=900',1,1,7),
(18,'MON-003','Acer Nitro 27','Monitor gaming de 27 pulgadas.',1399.00,1299.00,3,2,'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?w=900',1,3,3),
(19,'SSD-002','Kingston NV2 500GB','SSD NVMe de 500 GB.',249.00,219.00,24,7,'https://images.unsplash.com/photo-1597872200969-2b65d56bd16b?w=900',1,4,4),
(20,'KIT-001','Kit teclado y mouse inalámbrico','Kit inalámbrico para oficina y estudio.',129.00,109.00,35,10,'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=900',1,5,5);

INSERT INTO compra (id_compra,numero_compra,fecha,id_proveedor,id_usuario,subtotal,igv,total,estado,observacion) VALUES
(1,'C-00001','2026-09-01 09:30:00',1,1,10000.00,1800.00,11800.00,'RECIBIDA','Compra inicial de laptops y componentes'),
(2,'C-00002','2026-09-05 11:15:00',2,1,6500.00,1170.00,7670.00,'RECIBIDA','Reposición de monitores y periféricos'),
(3,'C-00003','2026-09-10 15:40:00',3,2,3200.00,576.00,3776.00,'RECIBIDA','Accesorios y periféricos'),
(4,'C-00004','2026-09-14 10:20:00',4,1,4800.00,864.00,5664.00,'REGISTRADA','Nueva compra de componentes');

INSERT INTO detalle_compra (id_detalle_compra,id_compra,id_producto,cantidad,precio_unitario,importe) VALUES
(1,1,1,5,1500.00,7500.00),
(2,1,6,5,500.00,2500.00),
(3,2,4,5,500.00,2500.00),
(4,2,8,2,1000.00,2000.00),
(5,2,12,4,500.00,2000.00),
(6,3,5,8,200.00,1600.00),
(7,3,10,4,250.00,1000.00),
(8,3,11,2,300.00,600.00),
(9,4,9,8,400.00,3200.00),
(10,4,13,2,800.00,1600.00);

INSERT INTO pedido (id_pedido,numero_pedido,fecha,id_cliente,id_usuario,tipo_comprobante,metodo_pago,estado_pago,estado_pedido,direccion_entrega,referencia,subtotal,igv,descuento,total,observacion) VALUES
(1,'PED-00001','2026-09-05 10:15:00',1,2,'BOLETA','YAPE','PAGADO','ENTREGADO','Av. España 100','Frente al parque',1749.00,314.82,0,2063.82,'Entrega realizada'),
(2,'PED-00002','2026-09-07 16:20:00',2,2,'FACTURA','TARJETA','PAGADO','ENTREGADO','Jr. Independencia 250','Oficina 302',3099.00,557.82,100,3556.82,'Cliente solicita factura'),
(3,'PED-00003','2026-09-12 12:05:00',3,1,'BOLETA','PLIN','PAGADO','ENVIADO','Av. América 520','Casa azul',1298.00,233.64,0,1531.64,'En ruta'),
(4,'PED-00004','2026-09-15 18:40:00',4,1,'FACTURA','TRANSFERENCIA','PAGADO','PREPARANDO','Av. Mansiche 850','Recepción',2299.00,413.82,0,2712.82,'Pedido corporativo'),
(5,'PED-00005','2026-09-16 09:10:00',5,NULL,'BOLETA','EFECTIVO','PENDIENTE','CONFIRMADO','Jr. Grau 410','Portón negro',498.00,89.64,0,587.64,'Pago contra entrega'),
(6,'PED-00006','2026-09-16 15:25:00',6,2,'BOLETA','YAPE','PAGADO','ENTREGADO','Av. Larco 900','Departamento 201',578.00,104.04,0,682.04,'Compra web');

INSERT INTO detalle_pedido (id_detalle_pedido,id_pedido,id_producto,producto_nombre,cantidad,precio_unitario,descuento,importe) VALUES
(1,1,1,'Lenovo IdeaPad 3',1,1749.00,0,1749.00),
(2,2,2,'ASUS TUF Gaming',1,3099.00,100,2999.00),
(3,3,4,'Monitor 24 pulgadas',1,649.00,0,649.00),
(4,3,5,'Teclado mecánico RGB',1,249.00,0,249.00),
(5,3,10,'Logitech G502 Gaming',1,249.00,0,249.00),
(6,3,16,'Webcam Full HD',1,169.00,0,169.00),
(7,4,7,'Acer Aspire 5',1,2149.00,0,2149.00),
(8,4,6,'SSD Kingston 1TB NVMe',1,359.00,0,359.00),
(9,5,5,'Teclado mecánico RGB',2,249.00,0,498.00),
(10,6,10,'Logitech G502 Gaming',1,249.00,0,249.00),
(11,6,11,'Audífonos Gaming Logitech',1,319.00,0,319.00);

INSERT INTO pago (id_pago,id_pedido,fecha_pago,metodo,monto,referencia,estado) VALUES
(1,1,'2026-09-05 10:20:00','YAPE',2063.82,'YAPE-784512','APROBADO'),
(2,2,'2026-09-07 16:25:00','TARJETA',3556.82,'POS-458721','APROBADO'),
(3,3,'2026-09-12 12:10:00','PLIN',1531.64,'PLIN-963214','APROBADO'),
(4,4,'2026-09-15 18:45:00','TRANSFERENCIA',2712.82,'TRX-741258','APROBADO'),
(5,5,NULL,'EFECTIVO',587.64,NULL,'PENDIENTE'),
(6,6,'2026-09-16 15:30:00','YAPE',682.04,'YAPE-852369','APROBADO');

INSERT INTO comprobante (id_comprobante,id_pedido,serie,numero,tipo,fecha_emision,cliente_nombre,documento,subtotal,igv,total) VALUES
(1,1,'B001',1001,'BOLETA','2026-09-05 10:21:00','Carlos Ramírez','12345678',1749.00,314.82,2063.82),
(2,2,'F001',5001,'FACTURA','2026-09-07 16:26:00','María Gómez','87654321',2999.00,557.82,3556.82),
(3,3,'B001',1002,'BOLETA','2026-09-12 12:11:00','Juan Pérez','45678912',1298.00,233.64,1531.64),
(4,4,'F001',5002,'FACTURA','2026-09-15 18:46:00','Empresa Soluciones Norte S.A.C.','20609876543',2299.00,413.82,2712.82),
(5,6,'B001',1003,'BOLETA','2026-09-16 15:31:00','Diego Vargas','36985214',578.00,104.04,682.04);

INSERT INTO movimiento_stock (id_movimiento,id_producto,tipo,cantidad,stock_anterior,stock_nuevo,motivo,fecha,id_usuario) VALUES
(1,1,'ENTRADA',20,0,20,'Compra C-00001','2026-09-01 09:40:00',1),
(2,1,'SALIDA',1,20,19,'Venta PED-00001','2026-09-05 10:30:00',2),
(3,1,'SALIDA',4,19,15,'Ajuste por ventas registradas','2026-09-05 18:00:00',1),
(4,6,'ENTRADA',5,0,5,'Compra C-00001','2026-09-01 09:40:00',1),
(5,4,'ENTRADA',5,15,20,'Compra C-00002','2026-09-05 11:30:00',1),
(6,4,'SALIDA',1,20,19,'Venta PED-00003','2026-09-12 12:20:00',1),
(7,5,'SALIDA',2,32,30,'Venta PED-00005','2026-09-16 09:20:00',1),
(8,10,'SALIDA',2,24,22,'Ventas PED-00003 y PED-00006','2026-09-16 15:35:00',2),
(9,11,'SALIDA',1,15,14,'Venta PED-00006','2026-09-16 15:35:00',2);

INSERT INTO contacto (id_contacto,nombre,email,telefono,asunto,mensaje,estado,fecha) VALUES
(1,'Pedro Sánchez','pedro@email.com','933111222','Consulta por laptop','Deseo conocer disponibilidad de laptops gaming.','ATENDIDO','2026-09-10 09:15:00'),
(2,'Ana López','ana@email.com','922333444','Cotización','Solicito cotización para 10 computadoras.','PENDIENTE','2026-09-15 14:30:00'),
(3,'Roberto Díaz','roberto@email.com','911555666','Garantía','Quiero consultar sobre la garantía de mi producto.','PENDIENTE','2026-09-16 11:20:00');

INSERT INTO configuracion_tienda (id_configuracion,nombre_tienda,ruc,telefono,whatsapp,email,direccion,horario,yape_numero,plin_numero,mensaje_footer) VALUES
(1,'TechNova','20601234567','044-123456','999888777','contacto@technova.pe','Av. España 123, Trujillo - La Libertad','Lun-Sáb 9:00 AM - 8:00 PM','999888777','999888777','Gracias por comprar en TechNova.');

SET FOREIGN_KEY_CHECKS=1;

-- ============================================================
-- VISTAS ÚTILES PARA EL PROYECTO
-- ============================================================

CREATE OR REPLACE VIEW vw_catalogo_productos AS
SELECT p.id_producto,p.codigo,p.nombre,p.descripcion,
       p.precio,p.precio_oferta,p.stock,p.stock_minimo,p.imagen,p.estado,
       c.nombre AS categoria,m.nombre AS marca
FROM producto p
LEFT JOIN categoria c ON c.id_categoria=p.id_categoria
LEFT JOIN marca m ON m.id_marca=p.id_marca;

CREATE OR REPLACE VIEW vw_ventas AS
SELECT pe.id_pedido,pe.numero_pedido,pe.fecha,
       CONCAT(COALESCE(cl.nombres,''),' ',COALESCE(cl.apellidos,'')) AS cliente,
       pe.tipo_comprobante,pe.metodo_pago,pe.estado_pago,pe.estado_pedido,
       pe.subtotal,pe.igv,pe.descuento,pe.total
FROM pedido pe
LEFT JOIN cliente cl ON cl.id_cliente=pe.id_cliente;

CREATE OR REPLACE VIEW vw_stock_bajo AS
SELECT p.id_producto,p.codigo,p.nombre,p.stock,p.stock_minimo,
       c.nombre AS categoria,m.nombre AS marca
FROM producto p
LEFT JOIN categoria c ON c.id_categoria=p.id_categoria
LEFT JOIN marca m ON m.id_marca=p.id_marca
WHERE p.stock <= p.stock_minimo AND p.estado = 1;

CREATE OR REPLACE VIEW vw_productos_mas_vendidos AS
SELECT p.id_producto,p.codigo,p.nombre,
       SUM(dp.cantidad) AS unidades_vendidas,
       SUM(dp.importe) AS importe_vendido
FROM detalle_pedido dp
JOIN producto p ON p.id_producto=dp.id_producto
JOIN pedido pe ON pe.id_pedido=dp.id_pedido
WHERE pe.estado_pedido <> 'CANCELADO'
GROUP BY p.id_producto,p.codigo,p.nombre;

-- ============================================================
-- CONSULTAS DE PRUEBA
-- ============================================================
SELECT 'BASE DE DATOS CREADA CORRECTAMENTE' AS mensaje;
SHOW TABLES;
SELECT COUNT(*) AS total_categorias FROM categoria;
SELECT COUNT(*) AS total_marcas FROM marca;
SELECT COUNT(*) AS total_productos FROM producto;
SELECT COUNT(*) AS total_clientes FROM cliente;
SELECT COUNT(*) AS total_pedidos FROM pedido;
SELECT COUNT(*) AS total_usuarios FROM usuario;
SELECT * FROM vw_catalogo_productos;
