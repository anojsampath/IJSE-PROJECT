CREATE TABLE users (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(254) NOT NULL UNIQUE,
    password_hash VARCHAR(100) NOT NULL,
    role ENUM('ADMIN','CUSTOMER') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE movies (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description VARCHAR(4000) NOT NULL,
    duration INT NOT NULL,
    language VARCHAR(50) NOT NULL,
    genre VARCHAR(80) NOT NULL,
    release_date DATE NOT NULL,
    status ENUM('UPCOMING','NOW_SHOWING','ENDED') NOT NULL,
    CHECK (duration > 0)
) ENGINE=InnoDB;

CREATE TABLE theatres (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    location VARCHAR(250) NOT NULL,
    capacity INT NOT NULL,
    status ENUM('ACTIVE','INACTIVE') NOT NULL,
    CHECK (capacity > 0)
) ENGINE=InnoDB;

CREATE TABLE movie_shows (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    movie_id BIGINT NOT NULL,
    theatre_id BIGINT NOT NULL,
    show_date DATE NOT NULL,
    show_time TIME(6) NOT NULL,
    ticket_price DECIMAL(12,2) NOT NULL,
    status ENUM('SCHEDULED','COMPLETED','CANCELLED') NOT NULL,
    CONSTRAINT fk_show_movie FOREIGN KEY (movie_id) REFERENCES movies(id),
    CONSTRAINT fk_show_theatre FOREIGN KEY (theatre_id) REFERENCES theatres(id),
    INDEX idx_show_schedule (theatre_id, status, show_date),
    CHECK (ticket_price > 0)
) ENGINE=InnoDB;

CREATE TABLE bookings (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    show_id BIGINT NOT NULL,
    number_of_tickets INT NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    booking_date TIMESTAMP(6) NOT NULL,
    status ENUM('PENDING','CONFIRMED','CANCELLED') NOT NULL,
    CONSTRAINT fk_booking_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_booking_show FOREIGN KEY (show_id) REFERENCES movie_shows(id),
    INDEX idx_booking_show_status (show_id, status),
    CHECK (number_of_tickets > 0),
    CHECK (total_amount > 0)
) ENGINE=InnoDB;

CREATE TABLE booking_seats (
    booking_id BIGINT NOT NULL,
    seat_number VARCHAR(12) NOT NULL,
    PRIMARY KEY (booking_id, seat_number),
    CONSTRAINT fk_seat_booking FOREIGN KEY (booking_id) REFERENCES bookings(id)
) ENGINE=InnoDB;

CREATE TABLE payments (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT NOT NULL UNIQUE,
    amount DECIMAL(12,2) NOT NULL,
    payment_date TIMESTAMP(6) NULL,
    payment_method ENUM('SIMULATED') NOT NULL,
    status ENUM('PENDING','COMPLETED','FAILED','REFUNDED') NOT NULL,
    CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) REFERENCES bookings(id),
    CHECK (amount > 0)
) ENGINE=InnoDB;
