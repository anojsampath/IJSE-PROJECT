package lk.ijse.moviebooking.exception;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.ConstraintViolationException;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.PessimisticLockingFailureException;
import org.springframework.http.*;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.web.ErrorResponse;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.method.annotation.HandlerMethodValidationException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

@RestControllerAdvice
@Slf4j
public class GlobalExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ApiError> validation(
            MethodArgumentNotValidException ex, HttpServletRequest request) {
        Map<String, String> fields = new LinkedHashMap<>();
        ex.getBindingResult()
                .getFieldErrors()
                .forEach(e -> fields.putIfAbsent(e.getField(), e.getDefaultMessage()));
        return response(HttpStatus.BAD_REQUEST, "Request validation failed", request, fields);
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<ApiError> handle(Exception ex, HttpServletRequest request) {
        if (ex instanceof ApiException api)
            return response(api.status(), api.getMessage(), request, Map.of());
        if (ex instanceof AuthenticationException)
            return response(HttpStatus.UNAUTHORIZED, "Invalid credentials", request, Map.of());
        if (ex instanceof AccessDeniedException)
            return response(HttpStatus.FORBIDDEN, "Access denied", request, Map.of());
        if (ex instanceof HttpMessageNotReadableException
                || ex instanceof MethodArgumentTypeMismatchException
                || ex instanceof ConstraintViolationException
                || ex instanceof HandlerMethodValidationException)
            return response(
                    HttpStatus.BAD_REQUEST, "Malformed or invalid request", request, Map.of());
        if (ex instanceof DataIntegrityViolationException
                || ex instanceof PessimisticLockingFailureException)
            return response(
                    HttpStatus.CONFLICT,
                    "Operation conflicts with existing data; refresh and retry",
                    request,
                    Map.of());
        if (ex instanceof ErrorResponse error)
            return response(
                    HttpStatus.valueOf(error.getStatusCode().value()),
                    "Request could not be handled",
                    request,
                    Map.of());
        log.error("Unexpected request failure at {}", request.getRequestURI(), ex);
        return response(
                HttpStatus.INTERNAL_SERVER_ERROR,
                "An unexpected error occurred",
                request,
                Map.of());
    }

    private ResponseEntity<ApiError> response(
            HttpStatus status,
            String message,
            HttpServletRequest request,
            Map<String, String> fields) {
        return ResponseEntity.status(status)
                .body(
                        new ApiError(
                                Instant.now(),
                                status.value(),
                                status.name(),
                                message,
                                request.getRequestURI(),
                                fields));
    }
}
