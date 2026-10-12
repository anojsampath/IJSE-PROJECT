package lk.ijse.moviebooking.service;

import java.nio.charset.StandardCharsets;
import java.util.Locale;
import lk.ijse.moviebooking.dto.Requests.*;
import lk.ijse.moviebooking.dto.Responses;
import lk.ijse.moviebooking.dto.Responses.*;
import lk.ijse.moviebooking.entity.User;
import lk.ijse.moviebooking.enums.Types.Role;
import lk.ijse.moviebooking.exception.ApiException;
import lk.ijse.moviebooking.repository.UserRepository;
import lk.ijse.moviebooking.security.JwtService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {
    private final UserRepository users;
    private final PasswordEncoder encoder;
    private final JwtService jwt;
    private final AuthenticationManager authenticationManager;

    @Transactional
    public UserView signup(Signup request) {
        String email = normalizeEmail(request.email());
        if (users.existsByEmail(email)) throw ApiException.conflict("Email already registered");
        validatePassword(request.password());
        User user = new User();
        user.setName(request.name().trim());
        user.setEmail(email);
        user.setPasswordHash(encoder.encode(request.password()));
        user.setRole(Role.CUSTOMER);
        users.saveAndFlush(user);
        log.info("Customer registered userId={}", user.getId());
        return Responses.user(user);
    }

    @Transactional(readOnly = true)
    public TokenView signin(Signin request) {
        String email = normalizeEmail(request.email());
        try {
            if (request.password().getBytes(StandardCharsets.UTF_8).length > 72)
                throw new BadCredentialsException("Invalid credentials");
            authenticationManager.authenticate(
                    UsernamePasswordAuthenticationToken.unauthenticated(email, request.password()));
        } catch (AuthenticationException ex) {
            log.info("Authentication attempt rejected");
            throw new BadCredentialsException("Invalid credentials");
        }
        var user =
                users.findByEmail(email)
                        .orElseThrow(() -> new BadCredentialsException("Invalid credentials"));
        log.info("Authentication succeeded userId={}", user.getId());
        return new TokenView(
                jwt.issue(user.getId()), "Bearer", jwt.expirationSeconds(), Responses.user(user));
    }

    public static String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }

    public static void validatePassword(String password) {
        if (password == null
                || password.isBlank()
                || password.length() < 8
                || password.getBytes(StandardCharsets.UTF_8).length > 72)
            throw ApiException.invalid(
                    "Password must contain at least 8 characters and at most 72 UTF-8 bytes");
    }
}
