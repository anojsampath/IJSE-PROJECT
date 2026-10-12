package lk.ijse.moviebooking.service;

import java.util.ArrayList;
import java.util.List;

public final class SeatLayout {
    private SeatLayout() {}

    public static List<String> seats(int capacity) {
        List<String> result = new ArrayList<>(capacity);
        for (int index = 0; index < capacity; index++) {
            result.add(row(index / 10) + (index % 10 + 1));
        }
        return List.copyOf(result);
    }

    private static String row(int index) {
        StringBuilder label = new StringBuilder();
        for (int n = index + 1; n > 0; n = (n - 1) / 26) {
            label.append((char) ('A' + (n - 1) % 26));
        }
        return label.reverse().toString();
    }
}
