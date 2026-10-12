package lk.ijse.moviebooking.service;

import static org.assertj.core.api.Assertions.*;

import org.junit.jupiter.api.Test;

class SeatLayoutTest {
    @Test
    void supportsPartialRowsAndRowsBeyondZ() {
        assertThat(SeatLayout.seats(12))
                .containsExactly(
                        "A1", "A2", "A3", "A4", "A5", "A6", "A7", "A8", "A9", "A10", "B1", "B2");
        assertThat(SeatLayout.seats(261).getLast()).isEqualTo("AA1");
        assertThat(SeatLayout.seats(10000)).hasSize(10000).doesNotHaveDuplicates();
    }
}
