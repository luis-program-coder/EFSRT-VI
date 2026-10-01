package com.technova.model;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name="producto")
public class Producto {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_producto") private Long id;
 @Column(nullable=false, unique=true, length=30) private String codigo;
 @Column(nullable=false, length=150) private String nombre;
 @Column(columnDefinition="TEXT") private String descripcion;
 @Column(nullable=false) private BigDecimal precio;
 @Column(name="precio_oferta") private BigDecimal precioOferta;
 private Integer stock;
 @Column(name="stock_minimo") private Integer stockMinimo;
 @Column(length=600) private String imagen;
 @Column(name="estado") private Boolean estado;
 @ManyToOne(fetch=FetchType.EAGER) @JoinColumn(name="id_categoria") private Categoria categoria;
 @ManyToOne(fetch=FetchType.EAGER) @JoinColumn(name="id_marca") private Marca marca;
 @Column(name="fecha_registro") private LocalDateTime fechaRegistro;
 public Producto(){}
 @Transient public BigDecimal getPrecioFinal(){return precioOferta!=null?precioOferta:precio;}
 public Long getId(){return id;} public void setId(Long v){id=v;}
 public String getCodigo(){return codigo;} public void setCodigo(String v){codigo=v;}
 public String getNombre(){return nombre;} public void setNombre(String v){nombre=v;}
 public String getDescripcion(){return descripcion;} public void setDescripcion(String v){descripcion=v;}
 public BigDecimal getPrecio(){return precio;} public void setPrecio(BigDecimal v){precio=v;}
 public BigDecimal getPrecioOferta(){return precioOferta;} public void setPrecioOferta(BigDecimal v){precioOferta=v;}
 public Integer getStock(){return stock;} public void setStock(Integer v){stock=v;}
 public Integer getStockMinimo(){return stockMinimo;} public void setStockMinimo(Integer v){stockMinimo=v;}
 public String getImagen(){return imagen;} public void setImagen(String v){imagen=v;}
 public Boolean getEstado(){return estado;} public void setEstado(Boolean v){estado=v;}
 public Categoria getCategoria(){return categoria;} public void setCategoria(Categoria v){categoria=v;}
 public Marca getMarca(){return marca;} public void setMarca(Marca v){marca=v;}
 public LocalDateTime getFechaRegistro(){return fechaRegistro;} public void setFechaRegistro(LocalDateTime v){fechaRegistro=v;}
}
