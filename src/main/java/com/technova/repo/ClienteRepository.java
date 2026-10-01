package com.technova.repo;
import com.technova.model.Cliente; import org.springframework.data.jpa.repository.JpaRepository; import java.util.Optional;
public interface ClienteRepository extends JpaRepository<Cliente,Long>{ Optional<Cliente> findByDocumento(String documento); }
