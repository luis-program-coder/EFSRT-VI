package com.technova.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity @Table(name="pedido")
public class Pedido {
 @Transient private String clienteNombre;
 @Transient private String documento;
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_pedido") private Long id;
 @Column(name="numero_pedido") private String numero;
 private LocalDateTime fecha;
 @Column(name="id_cliente") private Long clienteId;
 @Column(name="id_usuario") private Long usuarioId;
 @Column(name="tipo_comprobante") private String tipoComprobante;
 @Column(name="metodo_pago") private String metodoPago;
 @Column(name="estado_pago") private String estadoPago;
 @Column(name="estado_pedido") private String estadoPedido;
 @Column(name="direccion_entrega") private String direccion;
 private String referencia;
 private BigDecimal subtotal;
 private BigDecimal igv;
 private BigDecimal descuento;
 private BigDecimal total;
 private String observacion;
 public Pedido(){}
 public Long getId(){return id;} public void setId(Long v){id=v;}
 public String getNumero(){return numero;} public void setNumero(String v){numero=v;}
 public String getClienteNombre(){return clienteNombre;} public void setClienteNombre(String v){clienteNombre=v;}
 public String getDocumento(){return documento;} public void setDocumento(String v){documento=v;}
 public String getComprobante(){return tipoComprobante;}
 public LocalDateTime getFecha(){return fecha;} public void setFecha(LocalDateTime v){fecha=v;}
 public Long getClienteId(){return clienteId;} public void setClienteId(Long v){clienteId=v;}
 public Long getUsuarioId(){return usuarioId;} public void setUsuarioId(Long v){usuarioId=v;}
 public String getTipoComprobante(){return tipoComprobante;} public void setTipoComprobante(String v){tipoComprobante=v;}
 public String getMetodoPago(){return metodoPago;} public void setMetodoPago(String v){metodoPago=v;}
 public String getEstadoPago(){return estadoPago;} public void setEstadoPago(String v){estadoPago=v;}
 public String getEstadoPedido(){return estadoPedido;} public void setEstadoPedido(String v){estadoPedido=v;}
 public String getDireccion(){return direccion;} public void setDireccion(String v){direccion=v;}
 public String getReferencia(){return referencia;} public void setReferencia(String v){referencia=v;}
 public BigDecimal getSubtotal(){return subtotal;} public void setSubtotal(BigDecimal v){subtotal=v;}
 public BigDecimal getIgv(){return igv;} public void setIgv(BigDecimal v){igv=v;}
 public BigDecimal getDescuento(){return descuento;} public void setDescuento(BigDecimal v){descuento=v;}
 public BigDecimal getTotal(){return total;} public void setTotal(BigDecimal v){total=v;}
 public String getObservacion(){return observacion;} public void setObservacion(String v){observacion=v;}
}
