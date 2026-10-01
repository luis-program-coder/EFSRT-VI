package com.technova.service;
import com.technova.model.*; 
import com.technova.repo.*;
import org.springframework.stereotype.Service; 
import org.springframework.transaction.annotation.Transactional;
import java.math.*;
import java.time.*; 
import java.time.format.DateTimeFormatter; 
import java.util.*;
@Service public class TiendaService {public final ProductoRepository pr;
public final CategoriaRepository cr;
public final MarcaRepository mr;
public final PedidoRepository per;
public final DetallePedidoRepository dr;
private final ClienteRepository clr;
private final PagoRepository par;
private final ComprobanteRepository cor;
private final MovimientoStockRepository msr;
public TiendaService(ProductoRepository p,CategoriaRepository c,MarcaRepository m,PedidoRepository pe,DetallePedidoRepository d,ClienteRepository cl,PagoRepository pa,ComprobanteRepository co,MovimientoStockRepository ms){pr=p;cr=c;mr=m;per=pe;dr=d;clr=cl;par=pa;cor=co;msr=ms;}
public List<Producto> buscar(String t,Long cat){return (t!=null&&!t.isBlank()?pr.findByNombreContainingIgnoreCase(t):pr.findAll()).stream().filter(p->Boolean.TRUE.equals(p.getEstado())&&p.getStock()!=null&&p.getStock()>0).filter(p->cat==null||(p.getCategoria()!=null&&cat.equals(p.getCategoria().getId()))).toList();}

@Transactional
public Pedido vender(List<Map<String,Object>> cart, String nombre, String documento, 
        String email, String telefono, String direccion, 
        String metodo, String tipo) {
if (cart.isEmpty()) throw new IllegalArgumentException("El carrito está vacío");

BigDecimal sub = BigDecimal.ZERO;
List<DetallePedido> ds = new ArrayList<>();

// Procesar carrito
for (Map<String,Object> i : cart) {
Long id = Long.valueOf(i.get("id").toString());
int q = Integer.parseInt(i.get("cantidad").toString());
Producto p = pr.findById(id).orElseThrow();

if (p.getStock() < q) throw new IllegalArgumentException("Stock insuficiente: " + p.getNombre());

int before = p.getStock(), after = before - q;
p.setStock(after);
p.setEstado(after > 0);
pr.save(p);

BigDecimal price = p.getPrecioFinal();
BigDecimal imp = price.multiply(BigDecimal.valueOf(q)).setScale(2, RoundingMode.HALF_UP);
sub = sub.add(imp);

DetallePedido d = new DetallePedido();
d.setProductoId(id);
d.setProductoNombre(p.getNombre());
d.setCantidad(q);
d.setPrecioUnitario(price);
d.setDescuento(BigDecimal.ZERO);
d.setImporte(imp);
ds.add(d);

msr.save(new MovimientoStock(id, "SALIDA", q, before, after, "Venta", null));
}

// Cliente
Cliente c = (documento == null || documento.isBlank()) ? null : clr.findByDocumento(documento).orElse(null);
if (c == null) {
c = new Cliente();
c.setNombres(nombre);
c.setApellidos("");
c.setTipoDocumento("DNI");
c.setDocumento((documento == null || documento.isBlank()) ? "TEMP-" + System.currentTimeMillis() : documento);
c.setEmail(email);
c.setTelefono(telefono);
c.setDireccion(direccion);
c.setCiudad("Trujillo");
c.setEstado(1);
c = clr.save(c);
}

// Pedido
BigDecimal igv = sub.multiply(new BigDecimal("0.18")).setScale(2, RoundingMode.HALF_UP);
BigDecimal total = sub.add(igv);
LocalDateTime now = LocalDateTime.now();

Pedido p = new Pedido();
p.setNumero("PED-" + now.format(DateTimeFormatter.ofPattern("yyyyMMddHHmmssSSS")));
p.setFecha(now);
p.setClienteId(c.getId());
p.setTipoComprobante(tipo);
p.setMetodoPago(metodo);
p.setEstadoPago("PAGADO"); // simulado
p.setEstadoPedido("CONFIRMADO");
p.setDireccion(direccion);
p.setSubtotal(sub);
p.setIgv(igv);
p.setDescuento(BigDecimal.ZERO);
p.setTotal(total);
p = per.save(p);

for (DetallePedido d : ds) {
d.setPedidoId(p.getId());
dr.save(d);
}

// Pago ficticio
Pago pay = new Pago();
pay.setPedidoId(p.getId());
pay.setFechaPago(now);
pay.setMetodo(metodo);
pay.setMonto(total);
pay.setEstado("APROBADO"); // simulado
par.save(pay);

// Comprobante ficticio
Comprobante co = new Comprobante();
co.setPedidoId(p.getId());
co.setSerie("BOLETA".equals(tipo) ? "B001" : "F001");
co.setNumero(Math.toIntExact(1000 + p.getId()));
co.setTipo(tipo);
co.setFechaEmision(now);
co.setClienteNombre(c.getNombres() + " " + c.getApellidos());
co.setDocumento(c.getDocumento());
co.setSubtotal(sub);
co.setIgv(igv);
co.setTotal(total);
cor.save(co);

return p;
}}
