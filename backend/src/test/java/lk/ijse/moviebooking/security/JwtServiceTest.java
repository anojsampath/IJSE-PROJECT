package lk.ijse.moviebooking.security;

import static org.assertj.core.api.Assertions.*;

import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import java.time.*;
import java.util.Base64;
import org.junit.jupiter.api.Test;

class JwtServiceTest {
    @Test
    void verifiesSubjectAndRejectsExpiredAndWronglySignedTokens() {
        String secret =
                Base64.getEncoder().encodeToString(Jwts.SIG.HS256.key().build().getEncoded());
        Clock clock = Clock.fixed(Instant.parse("2030-01-01T00:00:00Z"), ZoneOffset.UTC);
        var issuer = new JwtService(secret, 3600, clock);
        String token = issuer.issue(42L);
        assertThat(issuer.userId(token)).isEqualTo(42L);
        var later = new JwtService(secret, 3600, Clock.offset(clock, Duration.ofHours(2)));
        assertThatThrownBy(() -> later.userId(token)).isInstanceOf(JwtException.class);
        String otherKey =
                Base64.getEncoder().encodeToString(Jwts.SIG.HS256.key().build().getEncoded());
        assertThatThrownBy(() -> new JwtService(otherKey, 3600, clock).userId(token))
                .isInstanceOf(JwtException.class);
        assertThatThrownBy(() -> issuer.userId("not.a.token")).isInstanceOf(JwtException.class);
    }

    @Test
    void rejectsWeakSecretsAndNonpositiveLifetime() {
        assertThatThrownBy(() -> new JwtService("c2hvcnQ=", 3600, Clock.systemUTC()))
                .isInstanceOf(io.jsonwebtoken.security.WeakKeyException.class);
        String secret =
                Base64.getEncoder().encodeToString(Jwts.SIG.HS256.key().build().getEncoded());
        assertThatThrownBy(() -> new JwtService(secret, 0, Clock.systemUTC()))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
