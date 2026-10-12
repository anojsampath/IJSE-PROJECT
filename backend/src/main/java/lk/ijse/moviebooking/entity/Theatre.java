package lk.ijse.moviebooking.entity;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;
import lk.ijse.moviebooking.enums.Types.TheatreStatus;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = "theatres")
@Getter
@Setter
@NoArgsConstructor
public class Theatre {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String name;

    @Column(nullable = false, length = 250)
    private String location;

    @Column(nullable = false)
    private int capacity;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private TheatreStatus status;

    @OneToMany(mappedBy = "theatre")
    private List<Show> shows = new ArrayList<>();
}
