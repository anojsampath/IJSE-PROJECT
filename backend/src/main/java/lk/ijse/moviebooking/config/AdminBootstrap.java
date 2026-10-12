package lk.ijse.moviebooking.config;

import jakarta.validation.Validator;
import lk.ijse.moviebooking.dto.Requests.Signup;
import lk.ijse.moviebooking.entity.User;
import lk.ijse.moviebooking.enums.Types.Role;
import lk.ijse.moviebooking.repository.UserRepository;
import lk.ijse.moviebooking.service.AuthService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.*;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@ConditionalOnProperty(name = "app.admin.enabled", havingValue = "true")
@Slf4j
public class AdminBootstrap implements ApplicationRunner {
    private final UserRepository users;
    private final PasswordEncoder encoder;
    private final Validator validator;
    private final Signup credentials;

    public AdminBootstrap(
            UserRepository users,
            PasswordEncoder encoder,
            Validator validator,
            @Value("${app.admin.name}") String name,
            @Value("${app.admin.email}") String email,
            @Value("${app.admin.password}") String password) {
        this.users = users;
        this.encoder = encoder;
        this.validator = validator;
        this.credentials = new Signup(name, email, password);
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        if (users.existsByRole(Role.ADMIN)) return;
        if (!validator.validate(credentials).isEmpty())
            throw new IllegalStateException(
                    "Valid ADMIN_NAME, ADMIN_EMAIL and ADMIN_PASSWORD are required for bootstrap");
        AuthService.validatePassword(credentials.password());
        String email = AuthService.normalizeEmail(credentials.email());
        if (users.existsByEmail(email))
            throw new IllegalStateException("Bootstrap email already belongs to an account");
        User admin = new User();
        admin.setName(credentials.name().trim());
        admin.setEmail(email);
        admin.setPasswordHash(encoder.encode(credentials.password()));
        admin.setRole(Role.ADMIN);
        users.saveAndFlush(admin);
        log.info(
                "Administrator bootstrapped userId={}; disable bootstrap after first startup",
                admin.getId());
    }
}
