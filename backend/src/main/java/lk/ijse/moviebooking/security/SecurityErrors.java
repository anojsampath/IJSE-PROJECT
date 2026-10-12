package lk.ijse.moviebooking.security;

import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.Instant;
import java.util.Map;
import lk.ijse.moviebooking.exception.ApiError;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import tools.jackson.databind.ObjectMapper;

@Component
@RequiredArgsConstructor
public class SecurityErrors {
    private final ObjectMapper mapper;

    public void write(HttpServletRequest request, HttpServletResponse response, HttpStatus status)
            throws IOException {
        response.setStatus(status.value());
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        if (status == HttpStatus.UNAUTHORIZED) response.setHeader("WWW-Authenticate", "Bearer");
        mapper.writeValue(
                response.getWriter(),
                new ApiError(
                        Instant.now(),
                        status.value(),
                        status.name(),
                        status == HttpStatus.UNAUTHORIZED
                                ? "Authentication required or invalid token"
                                : "Access denied",
                        request.getRequestURI(),
                        Map.of()));
    }
}
