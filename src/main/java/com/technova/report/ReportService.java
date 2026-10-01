package com.technova.report;
import com.technova.model.*;
import com.technova.repo.*; 
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook; 
import org.springframework.stereotype.Service;
import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfWriter;
import java.io.*; 
import java.math.BigDecimal;
import java.util.*;
@Service public class ReportService { private final ProductoRepository pr; 
private final PedidoRepository per;
private final ClienteRepository clr; 
public ReportService(ProductoRepository p,PedidoRepository pe,ClienteRepository cl){pr=p;per=pe;clr=cl;}
public byte[] ventasCsv(){StringBuilder s=new StringBuilder("numero,fecha,cliente,comprobante,pago,estado,total\n");
for(Pedido p:per.findAll()){String cliente=p.getClienteNombre();
if((cliente==null||cliente.isBlank())&&p.getClienteId()!=null) cliente=clr.findById(p.getClienteId()).map(c->c.getNombres()+" "+c.getApellidos()).orElse(""); s.append(csv(p.getNumero())).append(',').append(csv(String.valueOf(p.getFecha()))).append(',').append(csv(cliente)).append(',').append(p.getTipoComprobante()).append(',').append(p.getMetodoPago()).append(',').append(p.getEstadoPedido()).append(',').append(p.getTotal()).append('\n');}return s.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8);}
public byte[] productosExcel() throws IOException {try(Workbook wb=new XSSFWorkbook();
		ByteArrayOutputStream out=new ByteArrayOutputStream()){Sheet sh=wb.createSheet("Productos");org.apache.poi.ss.usermodel.Row h = sh.createRow(0);;String[] hs={"Código","Producto","Categoría","Marca","Precio","Stock","Stock mínimo","Estado"};for(int i=0;i<hs.length;i++)h.createCell(i).setCellValue(hs[i]);int r=1;for(Producto p:pr.findAll()){org.apache.poi.ss.usermodel.Row x = sh.createRow(r++);;x.createCell(0).setCellValue(p.getCodigo());x.createCell(1).setCellValue(p.getNombre());x.createCell(2).setCellValue(p.getCategoria()==null?"":p.getCategoria().getNombre());x.createCell(3).setCellValue(p.getMarca()==null?"":p.getMarca().getNombre());x.createCell(4).setCellValue(p.getPrecioFinal().doubleValue());x.createCell(5).setCellValue(p.getStock()==null?0:p.getStock());x.createCell(6).setCellValue(p.getStockMinimo()==null?0:p.getStockMinimo());x.createCell(7).setCellValue(String.valueOf(p.getEstado()));}for(int i=0;i<8;i++)sh.autoSizeColumn(i);wb.write(out);return out.toByteArray();}}
public byte[] ventasPdf(){try(ByteArrayOutputStream out=new ByteArrayOutputStream()){Document d=new Document();PdfWriter.getInstance(d,out);d.open();d.add(new Paragraph("TECHNOVA - REPORTE DE VENTAS"));d.add(new Paragraph("Generado: "+new Date()));d.add(new Paragraph(" "));for(Pedido p:per.findAll())d.add(new Paragraph(p.getNumero()+" | "+p.getFecha()+" | "+p.getTipoComprobante()+" | S/ "+p.getTotal()));d.close();return out.toByteArray();}catch(Exception e){throw new RuntimeException(e);}}
private String csv(String x){if(x==null)return "";return '"'+x.replace("\"","\"\"")+'"';}}
