package lk.ijse.moviebooking.enums;

public final class Types {
    private Types() {}

    public enum Role {
        ADMIN,
        CUSTOMER
    }

    public enum MovieStatus {
        UPCOMING,
        NOW_SHOWING,
        ENDED
    }

    public enum TheatreStatus {
        ACTIVE,
        INACTIVE
    }

    public enum ShowStatus {
        SCHEDULED,
        COMPLETED,
        CANCELLED
    }

    public enum BookingStatus {
        PENDING,
        CONFIRMED,
        CANCELLED
    }

    public enum PaymentStatus {
        PENDING,
        COMPLETED,
        FAILED,
        REFUNDED
    }

    public enum PaymentMethod {
        SIMULATED
    }

    public enum PaymentOutcome {
        COMPLETED,
        FAILED
    }
}
