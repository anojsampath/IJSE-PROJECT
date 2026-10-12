package lk.ijse.moviebooking.service;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

import lk.ijse.moviebooking.dto.Requests.Signup;
import lk.ijse.moviebooking.entity.User;
import lk.ijse.moviebooking.enums.Types.Role;
import lk.ijse.moviebooking.exception.ApiException;
import lk.ijse.moviebooking.repository.UserRepository;
import lk.ijse.moviebooking.security.JwtService;
import org.junit.jupiter.api.Test;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.crypto.password.PasswordEncoder;

class AuthServiceTest {
    @Test
    void normalizesEmailAndStoresOnlyAnEncodedCustomerPassword() {
        var users = mock(UserRepository.class);
        var encoder = mock(PasswordEncoder.class);
        var service =
                new AuthService(
                        users, encoder, mock(JwtService.class), mock(AuthenticationManager.class));
        when(encoder.encode("TestOnly123!")).thenReturn("encoded-password");
        when(users.saveAndFlush(any(User.class)))
                .thenAnswer(
                        invocation -> {
                            User user = invocation.getArgument(0);
                            assertThat(user.getRole()).isEqualTo(Role.CUSTOMER);
                            assertThat(user.getPasswordHash()).isEqualTo("encoded-password");
                            user.setId(1L);
                            return user;
                        });
        var result =
                service.signup(new Signup(" Customer ", " CUSTOMER@example.com ", "TestOnly123!"));
        assertThat(result.name()).isEqualTo("Customer");
        assertThat(result.email()).isEqualTo("customer@example.com");
        verify(users).existsByEmail("customer@example.com");
    }

    @Test
    void checksTheBcryptByteLimitAndMinimumLength() {
        assertThatThrownBy(() -> AuthService.validatePassword("é".repeat(37)))
                .isInstanceOf(ApiException.class);
        assertThatThrownBy(() -> AuthService.validatePassword("short"))
                .isInstanceOf(ApiException.class);
        assertThatCode(() -> AuthService.validatePassword("é".repeat(36)))
                .doesNotThrowAnyException();
    }
}
