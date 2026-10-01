# TechNova - Tienda de Computadoras Pro (versión corregida)

Proyecto académico web desarrollado con **Spring Boot 3.5.5, Java 17, Thymeleaf, Spring Data JPA, Spring Security y MySQL 8**.

## 1. Requisitos
- Java 17 o superior
- MySQL 8.x
- Maven 3.9+ (Spring Tools Suite/Eclipse también puede ejecutar Maven)

## 2. Base de datos
1. Abre MySQL Workbench.
2. Ejecuta completo: `database/tienda_computadoras_FINAL.sql`
3. El script crea la base `tienda_computadoras`, las **15 tablas**, datos de prueba y vistas.

## 3. Configuración
En `src/main/resources/application.properties` verifica usuario y contraseña de MySQL. Por defecto el proyecto usa:
- Base: `tienda_computadoras`
- Puerto web: `8081`
- Usuario MySQL: `root`

Si tu contraseña de MySQL es diferente, cambia `spring.datasource.password`.

## 4. Ejecutar en Spring Tools
1. Importa la carpeta del proyecto.
2. Espera a que Maven descargue las dependencias.
3. Ejecuta `TiendaComputadorasApplication.java` con **Run As > Spring Boot App**.
4. Abre `http://localhost:8081`

También puedes usar: `mvn spring-boot:run`

## 5. Usuario administrador
- Usuario: `admin`
- Contraseña: `admin123`

El sistema convierte automáticamente la contraseña demo a BCrypt al primer inicio de sesión.

## 6. Funciones corregidas
- Productos visibles en la página de inicio con imagen, nombre, descripción, precio y oferta.
- Catálogo con búsqueda y filtro por categoría.
- Carrito funcional.
- Checkout con boleta/factura y métodos YAPE, PLIN, tarjeta y efectivo (registro de método; no procesa dinero real).
- Actualización automática de stock al vender.
- Comprobante imprimible.
- Login y protección de administración.
- CRUD de productos: nuevo, editar, guardar y desactivar.
- Imágenes visibles también en administración con imagen de respaldo si una URL externa falla.
- Dashboard con productos activos, pedidos y stock bajo.
- Reportes PDF, Excel y CSV.

## 7. Reportes
- Dashboard: `/admin/dashboard`
- PDF: `/api/admin/reportes/ventas.pdf`
- Excel: `/api/admin/reportes/productos.xlsx`
- CSV: `/api/admin/reportes/ventas.csv`

## 8. Importante
El pago YAPE/PLIN/tarjeta del proyecto es **simulado/registrado para fines académicos**. Para cobrar dinero real se requiere una integración oficial con el proveedor de pagos.
