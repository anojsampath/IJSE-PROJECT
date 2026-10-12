package lk.ijse.moviebooking;

import static org.assertj.core.api.Assertions.*;

import java.util.Map;
import org.junit.jupiter.api.Test;
import org.springframework.context.support.GenericApplicationContext;
import org.springframework.core.env.MapPropertySource;

class TestDatabaseGuardTest {
    @Test
    void rejectsProductionDatabaseBeforeAnyConnection() {
        try (var context =
                context("jdbc:mysql://localhost:3306/movie_booking", "movie_booking_test")) {
            assertThatThrownBy(() -> new MySqlWorkflowIT.TestDatabaseGuard().initialize(context))
                    .isInstanceOf(IllegalStateException.class);
        }
    }

    @Test
    void rejectsSharedUserAndAllowsDedicatedTestDatabase() {
        try (var context = context("jdbc:mysql://localhost:3306/movie_booking_test", "root")) {
            assertThatThrownBy(() -> new MySqlWorkflowIT.TestDatabaseGuard().initialize(context))
                    .isInstanceOf(IllegalStateException.class);
        }
        try (var context =
                context("jdbc:mysql://localhost:3306/movie_booking_test", "movie_booking_test")) {
            assertThatCode(() -> new MySqlWorkflowIT.TestDatabaseGuard().initialize(context))
                    .doesNotThrowAnyException();
        }
    }

    private GenericApplicationContext context(String url, String user) {
        var context = new GenericApplicationContext();
        context.getEnvironment()
                .getPropertySources()
                .addFirst(
                        new MapPropertySource(
                                "test",
                                Map.of(
                                        "DB_TEST_URL",
                                        url,
                                        "DB_TEST_USERNAME",
                                        user,
                                        "DB_TEST_PASSWORD",
                                        "test-only",
                                        "DB_URL",
                                        "jdbc:mysql://localhost:3306/movie_booking",
                                        "DB_USERNAME",
                                        "movie_booking")));
        return context;
    }
}
