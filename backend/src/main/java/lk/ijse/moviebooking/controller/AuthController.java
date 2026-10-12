package lk.ijse.moviebooking.controller;

import jakarta.validation.Valid;
import lk.ijse.moviebooking.dto.Requests.*;
import lk.ijse.moviebooking.dto.Responses.*;
import lk.ijse.moviebooking.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService auth;

    @PostMapping("/signup")
    @ResponseStatus(HttpStatus.CREATED)
    public UserView signup(@Valid @RequestBody Signup request) {
        return auth.signup(request);
    }

    @PostMapping("/signin")
    public TokenView signin(@Valid @RequestBody Signin request) {
        return auth.signin(request);
    }
}
