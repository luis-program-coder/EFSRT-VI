package com.technova.repo;
import com.technova.model.Comprobante; import org.springframework.data.jpa.repository.JpaRepository; import java.util.Optional;
public interface ComprobanteRepository extends JpaRepository<Comprobante,Long>{ Optional<Comprobante> findByPedidoId(Long pedidoId); }
