package lk.ijse.moviebooking.security;

import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import java.time.Clock;
import java.util.Date;
import javax.crypto.SecretKey;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class JwtService {
    private static final String ISSUER = "movie-booking";
    private final SecretKey key;
    private final Clock clock;
    private final long expirationSeconds;

    public JwtService(
            @Value("${app.jwt.secret}") String secret,
            @Value("${app.jwt.expiration-seconds}") long expirationSeconds,
            Clock clock) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(java.nio.charset.StandardCharsets.UTF_8));
        if (expirationSeconds <= 0)
            throw new IllegalArgumentException("JWT lifetime must be positive");
        this.expirationSeconds = expirationSeconds;
        this.clock = clock;
    }

    public String issue(Long userId) {
        var now = clock.instant();
        return Jwts.builder()
                .issuer(ISSUER)
                .subject(userId.toString())
                .issuedAt(Date.from(now))
                .expiration(Date.from(now.plusSeconds(expirationSeconds)))
                .signWith(key)
                .compact();
    }

    public Long userId(String token) {
        var claims =
                Jwts.parser()
                        .verifyWith(key)
                        .requireIssuer(ISSUER)
                        .clock(() -> Date.from(clock.instant()))
                        .build()
                        .parseSignedClaims(token)
                        .getPayload();
        if (claims.getExpiration() == null)
            throw new IllegalArgumentException("Missing expiration");
        return Long.valueOf(claims.getSubject());
    }

    public long expirationSeconds() {
        return expirationSeconds;
    }
}
