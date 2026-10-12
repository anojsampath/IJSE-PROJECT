import { Routes, Route, Navigate, NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from './auth';
import Login from './pages/auth';
import Movies, { MovieShows, ShowDetail, MyBookings } from './pages/customer';
import { AdminMovies, AdminTheatres, AdminShows, AdminBookings, AdminPayments } from './pages/admin';

function Guard({ role, children }) {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" replace />;
  if (role && user.role !== role) {
    return <div className="notice error">You do not have access to this area.</div>;
  }
  return children;
}

function Header() {
  const { user, isAdmin, logout } = useAuth();
  const nav = useNavigate();
  if (!user) return null;
  function signOut() {
    logout();
    nav('/login');
  }
  return (
    <header className="app-header">
      <div className="brand">🎬 Movie Booking</div>
      <nav>
        <NavLink to="/">Movies</NavLink>
        {isAdmin && <NavLink to="/admin/movies">Manage Movies</NavLink>}
        {isAdmin && <NavLink to="/admin/theatres">Manage Theatres</NavLink>}
        {isAdmin && <NavLink to="/admin/shows">Manage Shows</NavLink>}
        {isAdmin && <NavLink to="/admin/bookings">All Bookings</NavLink>}
        {isAdmin && <NavLink to="/admin/payments">All Payments</NavLink>}
        <NavLink to="/my-bookings">My Bookings</NavLink>
      </nav>
      <div className="spacer" />
      <span className="who">
        {user.name} · {user.role}
      </span>
      <button onClick={signOut}>Sign out</button>
    </header>
  );
}

export default function App() {
  return (
    <div>
      <Header />
      <main>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/" element={<Guard><Movies /></Guard>} />
          <Route path="/movies/:movieId" element={<Guard><MovieShows /></Guard>} />
          <Route path="/shows/:showId" element={<Guard><ShowDetail /></Guard>} />
          <Route path="/my-bookings" element={<Guard><MyBookings /></Guard>} />
          <Route path="/admin/movies" element={<Guard role="ADMIN"><AdminMovies /></Guard>} />
          <Route path="/admin/theatres" element={<Guard role="ADMIN"><AdminTheatres /></Guard>} />
          <Route path="/admin/shows" element={<Guard role="ADMIN"><AdminShows /></Guard>} />
          <Route path="/admin/bookings" element={<Guard role="ADMIN"><AdminBookings /></Guard>} />
          <Route path="/admin/payments" element={<Guard role="ADMIN"><AdminPayments /></Guard>} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </main>
    </div>
  );
}
