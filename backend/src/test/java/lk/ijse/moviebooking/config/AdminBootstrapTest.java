package lk.ijse.moviebooking.config;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.Mockito.*;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import lk.ijse.moviebooking.entity.User;
import lk.ijse.moviebooking.enums.Types.Role;
import lk.ijse.moviebooking.repository.UserRepository;
import org.junit.jupiter.api.*;
import org.mockito.ArgumentCaptor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

class AdminBootstrapTest {
    private final UserRepository users = mock(UserRepository.class);
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    @Test
    void createsAnAdminWithHashedPasswordOnlyOnFirstRun() {
        try (var factory = Validation.buildDefaultValidatorFactory()) {
            Validator validator = factory.getValidator();
            var bootstrap =
                    new AdminBootstrap(
                            users,
                            encoder,
                            validator,
                            "Admin",
                            "ADMIN@example.com",
                            "TestOnly123!");
            bootstrap.run(null);
            var saved = ArgumentCaptor.forClass(User.class);
            verify(users).saveAndFlush(saved.capture());
            assertThat(saved.getValue().getRole()).isEqualTo(Role.ADMIN);
            assertThat(saved.getValue().getEmail()).isEqualTo("admin@example.com");
            assertThat(encoder.matches("TestOnly123!", saved.getValue().getPasswordHash()))
                    .isTrue();
            when(users.existsByRole(Role.ADMIN)).thenReturn(true);
            bootstrap.run(null);
            verify(users, times(1)).saveAndFlush(any());
        }
    }

    @Test
    void rejectsInvalidCredentialsAndNeverPromotesAnExistingCustomer() {
        try (var factory = Validation.buildDefaultValidatorFactory()) {
            var validator = factory.getValidator();
            var invalid = new AdminBootstrap(users, encoder, validator, "Admin", "", "short");
            assertThatThrownBy(() -> invalid.run(null)).isInstanceOf(IllegalStateException.class);
            when(users.existsByEmail("taken@example.com")).thenReturn(true);
            var taken =
                    new AdminBootstrap(
                            users,
                            encoder,
                            validator,
                            "Admin",
                            "taken@example.com",
                            "TestOnly123!");
            assertThatThrownBy(() -> taken.run(null)).isInstanceOf(IllegalStateException.class);
            verify(users, never()).saveAndFlush(any());
        }
    }
}
