package com.technova.model;
import jakarta.persistence.*; import java.math.BigDecimal;
@Entity @Table(name="detalle_pedido")
public class DetallePedido {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_detalle_pedido") private Long id;
 @Column(name="id_pedido") private Long pedidoId;
 @Column(name="id_producto") private Long productoId;
 @Column(name="producto_nombre") private String productoNombre;
 private Integer cantidad;
 @Column(name="precio_unitario") private BigDecimal precioUnitario;
 private BigDecimal descuento;
 private BigDecimal importe;
 public DetallePedido(){}
 public Long getId(){return id;} public void setId(Long v){id=v;} public Long getPedidoId(){return pedidoId;} public void setPedidoId(Long v){pedidoId=v;} public Long getProductoId(){return productoId;} public void setProductoId(Long v){productoId=v;} public String getProductoNombre(){return productoNombre;} public void setProductoNombre(String v){productoNombre=v;} public Integer getCantidad(){return cantidad;} public void setCantidad(Integer v){cantidad=v;} public BigDecimal getPrecioUnitario(){return precioUnitario;} public void setPrecioUnitario(BigDecimal v){precioUnitario=v;} public BigDecimal getDescuento(){return descuento;} public void setDescuento(BigDecimal v){descuento=v;} public BigDecimal getImporte(){return importe;} public void setImporte(BigDecimal v){importe=v;}
}
