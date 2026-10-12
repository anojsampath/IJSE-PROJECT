package lk.ijse.moviebooking.controller;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import java.util.List;
import lk.ijse.moviebooking.dto.Requests.UserUpdate;
import lk.ijse.moviebooking.dto.Responses.UserView;
import lk.ijse.moviebooking.security.Actor;
import lk.ijse.moviebooking.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class UserController {
    private final UserService users;

    @GetMapping
    public List<UserView> all() {
        return users.all();
    }

    @GetMapping("/{id}")
    public UserView get(@PathVariable @Positive Long id) {
        return users.get(id);
    }

    @PutMapping("/{id}")
    public UserView update(
            @PathVariable @Positive Long id,
            @Valid @RequestBody UserUpdate request,
            @AuthenticationPrincipal Actor actor) {
        return users.update(id, request, actor);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable @Positive Long id, @AuthenticationPrincipal Actor actor) {
        users.delete(id, actor);
    }
}
