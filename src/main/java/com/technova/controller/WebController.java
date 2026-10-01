package com.technova.controller;

import com.technova.model.*;
import com.technova.repo.*;
import com.technova.service.TiendaService;
import jakarta.servlet.http.HttpSession;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@Controller
public class WebController {
    private final TiendaService service;
    private final ProductoRepository pr;
    private final CategoriaRepository cr;
    private final MarcaRepository mr;
    private final ClienteRepository clr;
    private final DetallePedidoRepository dr;
    private final PedidoRepository per;

    public WebController(TiendaService service, ProductoRepository pr, CategoriaRepository cr, MarcaRepository mr,
                         ClienteRepository clr, DetallePedidoRepository dr, PedidoRepository per) {
        this.service=service; this.pr=pr; this.cr=cr; this.mr=mr; this.clr=clr; this.dr=dr; this.per=per;
    }

    @GetMapping({"/","/inicio"})
    public String home(Model m) {
        m.addAttribute("productos", service.buscar(null,null).stream().limit(8).toList());
        return "index";
    }

    @GetMapping("/catalogo")
    public String catalogo(@RequestParam(required=false) String q, @RequestParam(required=false) Long categoria, Model m) {
        m.addAttribute("productos", service.buscar(q,categoria));
        m.addAttribute("categorias", cr.findAll());
        m.addAttribute("q", q);
        m.addAttribute("categoria", categoria);
        return "catalogo";
    }

    @SuppressWarnings("unchecked")
    private List<Map<String,Object>> cart(HttpSession s) {
        List<Map<String,Object>> c=(List<Map<String,Object>>)s.getAttribute("cart");
        if(c==null){c=new ArrayList<>();s.setAttribute("cart",c);}
        return c;
    }

    @PostMapping("/carrito/agregar/{id}")
    public String add(@PathVariable Long id, HttpSession s) {
        Producto p=pr.findById(id).orElseThrow();
        if(!Boolean.TRUE.equals(p.getEstado()) || p.getStock()==null || p.getStock()<=0) return "redirect:/catalogo";
        List<Map<String,Object>> c=cart(s);
        Optional<Map<String,Object>> ex=c.stream().filter(x->Long.valueOf(x.get("id").toString()).equals(id)).findFirst();
        if(ex.isPresent()){
            int n=Integer.parseInt(ex.get().get("cantidad").toString());
            if(n<p.getStock()) ex.get().put("cantidad",n+1);
        } else {
            Map<String,Object>x=new HashMap<>(); x.put("id",id); x.put("nombre",p.getNombre()); x.put("precio",p.getPrecioFinal());
            x.put("imagen",p.getImagen()); x.put("cantidad",1); c.add(x);
        }
        return "redirect:/carrito";
    }

    @GetMapping("/carrito") public String carrito(HttpSession s,Model m){m.addAttribute("cart",cart(s));return "carrito";}
    @GetMapping("/carrito/eliminar/{id}") public String del(@PathVariable Long id,HttpSession s){cart(s).removeIf(x->Long.valueOf(x.get("id").toString()).equals(id));return "redirect:/carrito";}
    @GetMapping("/carrito/vaciar") public String vaciar(HttpSession s){s.removeAttribute("cart");return "redirect:/carrito";}

    @GetMapping("/checkout") public String checkout(HttpSession s,Model m){
        List<Map<String,Object>> c=cart(s); if(c.isEmpty()) return "redirect:/carrito"; m.addAttribute("cart",c); return "checkout";
    }

    @PostMapping("/checkout")
    public String vender(@RequestParam String nombre,@RequestParam(defaultValue="")String documento,@RequestParam(defaultValue="")String email,
                         @RequestParam(defaultValue="")String telefono,@RequestParam(defaultValue="")String direccion,
                         @RequestParam String metodoPago,@RequestParam String comprobante,HttpSession s,Model m){
        List<Map<String,Object>> c=cart(s); if(c.isEmpty()) return "redirect:/carrito";
        Pedido p=service.vender(c,nombre,documento,email,telefono,direccion,metodoPago,comprobante);
        Cliente cliente = documento.isBlank()?null:clr.findByDocumento(documento).orElse(null);
        p.setClienteNombre(cliente!=null ? cliente.getNombres()+" "+cliente.getApellidos() : nombre);
        p.setDocumento(cliente!=null ? cliente.getDocumento() : documento);
        m.addAttribute("pedido",p); m.addAttribute("detalles",dr.findByPedidoId(p.getId()));
        s.removeAttribute("cart"); return "comprobante";
    }

    @GetMapping("/contacto") public String contacto(){return "contacto";}
    @GetMapping("/ubicacion") public String ubicacion(){return "ubicacion";}

    @GetMapping("/admin/dashboard") public String dashboard(Model m){
        long bajo=pr.findAll().stream().filter(p->Boolean.TRUE.equals(p.getEstado())&&p.getStock()!=null&&p.getStockMinimo()!=null&&p.getStock()<=p.getStockMinimo()).count();
        m.addAttribute("productos",pr.findAll().stream().filter(p->Boolean.TRUE.equals(p.getEstado())).count());
        m.addAttribute("pedidos",per.count()); m.addAttribute("stockBajo",bajo); return "dashboard";
    }

    @GetMapping("/admin/productos") public String admin(Model m){m.addAttribute("productos",pr.findAll());return "admin-productos";}
    @GetMapping("/admin/productos/nuevo") public String nuevo(Model m){m.addAttribute("producto",new Producto());m.addAttribute("categorias",cr.findAll());m.addAttribute("marcas",mr.findAll());return "producto-form";}
    @GetMapping("/admin/productos/editar/{id}") public String editar(@PathVariable Long id,Model m){m.addAttribute("producto",pr.findById(id).orElseThrow());m.addAttribute("categorias",cr.findAll());m.addAttribute("marcas",mr.findAll());return "producto-form";}

    @PostMapping("/admin/productos/guardar")
    public String guardar(@ModelAttribute Producto producto,@RequestParam Long categoriaId,@RequestParam Long marcaId){
        if(producto.getId()!=null){
            Producto actual=pr.findById(producto.getId()).orElseThrow();
            if(producto.getCodigo()==null||producto.getCodigo().isBlank()) producto.setCodigo(actual.getCodigo());
            if(producto.getImagen()==null||producto.getImagen().isBlank()) producto.setImagen(actual.getImagen());
            if(producto.getStockMinimo()==null) producto.setStockMinimo(actual.getStockMinimo());
            if(producto.getFechaRegistro()==null) producto.setFechaRegistro(actual.getFechaRegistro());
        } else if(producto.getCodigo()==null||producto.getCodigo().isBlank()) producto.setCodigo("WEB-"+System.currentTimeMillis());
        producto.setCategoria(cr.findById(categoriaId).orElse(null));
        producto.setMarca(mr.findById(marcaId).orElse(null));
        if(producto.getStock()==null || producto.getStock()<0) producto.setStock(0);
        if(producto.getStockMinimo()==null || producto.getStockMinimo()<0) producto.setStockMinimo(0);
        producto.setEstado(producto.getStock()>0);
        pr.save(producto); return "redirect:/admin/productos";
    }

    @GetMapping("/admin/productos/eliminar/{id}")
    public String eliminar(@PathVariable Long id){
        Producto p=pr.findById(id).orElseThrow(); p.setEstado(false); pr.save(p); return "redirect:/admin/productos";
    }

    @GetMapping("/admin/pedidos") public String pedidos(Model m){
        List<Pedido> pedidos=per.findAll();
        for(Pedido p:pedidos) if(p.getClienteId()!=null) clr.findById(p.getClienteId()).ifPresent(c->p.setClienteNombre(c.getNombres()+" "+c.getApellidos()));
        m.addAttribute("pedidos",pedidos); return "admin-pedidos";
    }
    @GetMapping("/admin/pedidos/{id}") public String pedido(@PathVariable Long id,Model m){
        Pedido p=per.findById(id).orElseThrow();
        if(p.getClienteId()!=null) clr.findById(p.getClienteId()).ifPresent(c->p.setClienteNombre(c.getNombres()+" "+c.getApellidos()));
        m.addAttribute("pedido",p); m.addAttribute("detalles",dr.findByPedidoId(id)); return "pedido-detalle";
    }
}
