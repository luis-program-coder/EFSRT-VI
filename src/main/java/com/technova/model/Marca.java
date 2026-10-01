package com.technova.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name="marca")
public class Marca {
 @Id @GeneratedValue(strategy=GenerationType.IDENTITY) @Column(name="id_marca") private Long id;
 @Column(nullable=false, unique=true) private String nombre;
 private String descripcion;
 private Boolean estado;
 @Column(name="fecha_registro") private LocalDateTime fechaRegistro;
 public Marca(){}
 public Long getId(){return id;} public void setId(Long v){id=v;}
 public String getNombre(){return nombre;} public void setNombre(String v){nombre=v;}
 public String getDescripcion(){return descripcion;} public void setDescripcion(String v){descripcion=v;}
 public Boolean getEstado(){return estado;} public void setEstado(Boolean v){estado=v;}
 public LocalDateTime getFechaRegistro(){return fechaRegistro;} public void setFechaRegistro(LocalDateTime v){fechaRegistro=v;}
}
