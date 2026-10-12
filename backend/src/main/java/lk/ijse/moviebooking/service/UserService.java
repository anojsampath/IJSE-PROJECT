package lk.ijse.moviebooking.service;

import java.util.List;
import lk.ijse.moviebooking.dto.Requests.UserUpdate;
import lk.ijse.moviebooking.dto.Responses;
import lk.ijse.moviebooking.dto.Responses.UserView;
import lk.ijse.moviebooking.entity.User;
import lk.ijse.moviebooking.enums.Types.Role;
import lk.ijse.moviebooking.exception.ApiException;
import lk.ijse.moviebooking.repository.*;
import lk.ijse.moviebooking.security.Actor;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional(readOnly = true)
public class UserService {
    private final UserRepository users;
    private final BookingRepository bookings;

    public List<UserView> all() {
        return users.findAll().stream().map(Responses::user).toList();
    }

    public UserView get(Long id) {
        return Responses.user(find(id));
    }

    @Transactional
    public UserView update(Long id, UserUpdate request, Actor actor) {
        User user = find(id);
        if (id.equals(actor.id()) && request.role() != Role.ADMIN)
            throw ApiException.conflict("Administrators cannot demote their own account");
        String email = AuthService.normalizeEmail(request.email());
        if (!email.equals(user.getEmail()) && users.existsByEmail(email))
            throw ApiException.conflict("Email already registered");
        user.setName(request.name().trim());
        user.setEmail(email);
        user.setRole(request.role());
        users.flush();
        log.info("User updated userId={} actorId={}", id, actor.id());
        return Responses.user(user);
    }

    @Transactional
    public void delete(Long id, Actor actor) {
        User user = find(id);
        if (id.equals(actor.id()))
            throw ApiException.conflict("Administrators cannot delete their own account");
        if (bookings.existsByUserId(id)) throw ApiException.conflict("User has booking history");
        users.delete(user);
        users.flush();
        log.info("User deleted userId={} actorId={}", id, actor.id());
    }

    private User find(Long id) {
        return users.findById(id).orElseThrow(() -> ApiException.missing("User"));
    }
}
