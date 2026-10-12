package lk.ijse.moviebooking;

import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;

@ActiveProfiles("mysqltest")
@ContextConfiguration(initializers = MySqlWorkflowIT.TestDatabaseGuard.class)
class MySqlWorkflowIT extends WorkflowContract {
    static class TestDatabaseGuard
            implements ApplicationContextInitializer<ConfigurableApplicationContext> {
        @Override
        public void initialize(ConfigurableApplicationContext context) {
            var env = context.getEnvironment();
            String url = env.getRequiredProperty("DB_TEST_URL");
            String username = env.getRequiredProperty("DB_TEST_USERNAME");
            if (!url.matches("jdbc:mysql://[^/]+/movie_booking_test(\\?.*)?")
                    || !username.equals("movie_booking_test")
                    || url.equals(env.getProperty("DB_URL"))
                    || username.equals(env.getProperty("DB_USERNAME"))) {
                throw new IllegalStateException(
                        "Integration tests require the isolated movie_booking_test database and user");
            }
            env.getRequiredProperty("DB_TEST_PASSWORD");
        }
    }
}
