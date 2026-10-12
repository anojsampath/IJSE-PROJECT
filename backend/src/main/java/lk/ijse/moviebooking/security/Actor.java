package lk.ijse.moviebooking.security;

import java.security.Principal;
import lk.ijse.moviebooking.enums.Types.Role;
import org.springframework.security.access.AccessDeniedException;

public record Actor(Long id, Role role) implements Principal {
    @Override
    public String getName() {
        return id.toString();
    }

    public void requireCustomer() {
        if (role != Role.CUSTOMER) throw new AccessDeniedException("Customer access required");
    }

    public void requireOwnerOrAdmin(Long userId) {
        if (role != Role.ADMIN && !id.equals(userId))
            throw new AccessDeniedException("Access denied");
    }
}
