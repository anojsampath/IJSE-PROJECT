import { useCallback, useEffect, useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { api } from '../api';
import { useAuth } from '../auth';
import { Pill, money, ErrorNote, OkNote, Loading, describeError } from '../components';

function useFetch(path) {
  const [data, setData] = useState(null);
  const [err, setErr] = useState('');
  const [loading, setLoading] = useState(true);
  const [nonce, setNonce] = useState(0);
  const reload = useCallback(() => setNonce((n) => n + 1), []);
  useEffect(() => {
    let alive = true;
    setLoading(true);
    api
      .get(path)
      .then((d) => alive && setData(d))
      .catch((e) => alive && setErr(describeError(e)))
      .finally(() => alive && setLoading(false));
    return () => {
      alive = false;
    };
  }, [path, nonce]);
  return { data, err, loading, reload, setErr };
}

export default function Movies() {
  const { data, err, loading } = useFetch('/movies');
  return (
    <div>
      <h1>Movies</h1>
      <ErrorNote msg={err} />
      <Loading loading={loading} />
      {data && (
        <div className="grid cols">
          {data.map((m) => (
            <div className="card" key={m.id}>
              <h2 style={{ marginTop: 0 }}>{m.title}</h2>
              <div className="row">
                <Pill value={m.status} />
                <span className="muted">{m.genre} · {m.language} · {m.duration} min</span>
              </div>
              <p className="muted">{m.description}</p>
              <p className="muted">Released {m.releaseDate}</p>
              <div className="actions">
                <Link className="primary" to={`/movies/${m.id}`}>
                  <button className="primary">View shows</button>
                </Link>
              </div>
            </div>
          ))}
          {data.length === 0 && <p className="muted">No movies yet. An administrator can add some.</p>}
        </div>
      )}
    </div>
  );
}

export function MovieShows() {
  const { movieId } = useParams();
  const movie = useFetch(`/movies/${movieId}`);
  const shows = useFetch(`/movies/${movieId}/shows`);
  return (
    <div>
      <p><Link to="/">← All movies</Link></p>
      <h1>{movie.data ? movie.data.title : 'Movie'}</h1>
      <ErrorNote msg={movie.err || shows.err} />
      <Loading loading={shows.loading} />
      {shows.data && (
        <table>
          <thead>
            <tr>
              <th>Date</th><th>Time</th><th>Ticket</th><th>Status</th><th></th>
            </tr>
          </thead>
          <tbody>
            {shows.data.map((s) => (
              <tr key={s.id}>
                <td>{s.showDate}</td>
                <td>{(s.showTime || '').slice(0, 5)}</td>
                <td className="money">{money(s.ticketPrice)}</td>
                <td><Pill value={s.status} /></td>
                <td className="right">
                  {s.status === 'SCHEDULED' && <Link to={`/shows/${s.id}`}><button>Select seats</button></Link>}
                </td>
              </tr>
            ))}
            {shows.data.length === 0 && (
              <tr><td colSpan={5} className="muted">No scheduled shows for this movie.</td></tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}

function rowOf(seat) {
  const m = /^([A-Z]+)(\d+)$/.exec(seat);
  return m ? m[1] : '#';
}

export function ShowDetail() {
  const { showId } = useParams();
  const { isCustomer } = useAuth();
  const show = useFetch(`/shows/${showId}`);
  const seats = useFetch(`/shows/${showId}/seats`);
  const [selected, setSelected] = useState([]);
  const [booking, setBooking] = useState(null);
  const [payment, setPayment] = useState(null);
  const [err, setErr] = useState('');
  const [ok, setOk] = useState('');
  const [busy, setBusy] = useState(false);

  const reserved = useMemo(() => new Set(seats.data ? seats.data.reservedSeats : []), [seats.data]);

  function toggle(seat) {
    if (reserved.has(seat)) return;
    setSelected((cur) => (cur.includes(seat) ? cur.filter((s) => s !== seat) : [...cur, seat]));
  }

  async function reserve() {
    setErr(''); setOk(''); setBusy(true);
    try {
      const b = await api.post('/bookings', {
        showId: Number(showId),
        seatNumbers: selected,
        numberOfTickets: selected.length,
      });
      setBooking(b);
      setSelected([]);
      seats.reload();
      setOk(`Reserved ${b.seatNumbers.join(', ')} — total ${money(b.totalAmount)}. Complete payment to confirm.`);
    } catch (e) {
      setErr(describeError(e));
      if (e.status === 409) seats.reload();
    } finally {
      setBusy(false);
    }
  }

  async function createPayment() {
    setErr(''); setBusy(true);
    try {
      const p = await api.post('/payments', { bookingId: booking.id, paymentMethod: 'SIMULATED' });
      setPayment(p);
      setOk('Payment created (PENDING). Choose a simulated outcome.');
    } catch (e) {
      setErr(describeError(e));
    } finally {
      setBusy(false);
    }
  }

  async function process(outcome) {
    setErr(''); setBusy(true);
    try {
      const p = await api.post(`/payments/${payment.id}/process`, { outcome });
      setPayment(p);
      const fresh = await api.get(`/bookings/${booking.id}`);
      setBooking(fresh);
      setOk(
        outcome === 'COMPLETED'
          ? `Payment ${p.status}. Booking is ${fresh.status}.`
          : `Payment ${p.status} — booking remains ${fresh.status}. Retry the same payment to succeed.`,
      );
    } catch (e) {
      setErr(describeError(e));
    } finally {
      setBusy(false);
    }
  }

  const rows = seats.data
    ? seats.data.totalSeats.reduce((acc, s) => {
        const r = rowOf(s);
        (acc[r] = acc[r] || []).push(s);
        return acc;
      }, {})
    : {};

  return (
    <div>
      <p><Link to={show.data ? `/movies/${show.data.movieId}` : '/'}>← Back</Link></p>
      <h1>Show #{showId}</h1>
      <ErrorNote msg={err || show.err || seats.err} />
      <OkNote msg={ok} />
      {show.data && (
        <div className="card">
          <div className="row">
            <Pill value={show.data.status} />
            <span className="muted">{show.data.showDate} at {(show.data.showTime || '').slice(0, 5)}</span>
            <span className="money">Ticket {money(show.data.ticketPrice)}</span>
          </div>
        </div>
      )}
      <Loading loading={seats.loading} />
      {seats.data && (
        <div className="card">
          <h2 style={{ marginTop: 0 }}>Seat selection</h2>
          {!seats.data.bookable && <div className="notice error">This show is not open for bookings.</div>}
          {booking ? (
            <p className="muted">Seats locked by your booking: {booking.seatNumbers.join(', ')}. Reload to book more.</p>
          ) : (
            <div className="seatmap">
              {Object.entries(rows).map(([r, list]) => (
                <div key={r} style={{ width: '100%' }}>
                  <div className="row-label">Row {r}</div>
                  <div className="seatmap">
                    {list.map((s) => {
                      const cls = reserved.has(s) ? 'seat reserved' : selected.includes(s) ? 'seat selected' : 'seat available';
                      return (
                        <div
                          key={s}
                          className={cls}
                          role="button"
                          aria-disabled={reserved.has(s)}
                          onClick={() => !reserved.has(s) && !booking && toggle(s)}
                        >
                          {s}
                        </div>
                      );
                    })}
                  </div>
                </div>
              ))}
            </div>
          )}
          <div className="legend">
            <span><span className="dot" style={{ background: 'var(--panel-2)', border: '1px solid var(--border)' }} />Available</span>
            <span><span className="dot" style={{ background: 'var(--accent)' }} />Selected ({selected.length})</span>
            <span><span className="dot" style={{ background: 'rgba(239,90,90,.4)' }} />Reserved</span>
          </div>

          {isCustomer && !booking && (
            <div className="actions">
              <button className="primary" disabled={!selected.length || !seats.data.bookable || busy} onClick={reserve}>
                Reserve {selected.length} seat{selected.length === 1 ? '' : 's'}
              </button>
            </div>
          )}
        </div>
      )}

      {booking && (
        <div className="card">
          <h2 style={{ marginTop: 0 }}>Booking #{booking.id}</h2>
          <div className="row">
            <Pill value={booking.status} />
            <span>Seats: {booking.seatNumbers.join(', ')}</span>
            <span>Tickets: {booking.numberOfTickets}</span>
            <span className="money">Total: {money(booking.totalAmount)}</span>
          </div>

          {booking.status === 'PENDING' && (
            <div className="actions">
              {!payment && <button className="primary" disabled={busy} onClick={createPayment}>Create payment</button>}
              {payment && payment.status !== 'COMPLETED' && (
                <>
                  <span className="muted">Payment #{payment.id} ({payment.status}):</span>
                  <button className="success" disabled={busy} onClick={() => process('COMPLETED')}>Pay success</button>
                  <button className="danger" disabled={busy} onClick={() => process('FAILED')}>Pay fail</button>
                </>
              )}
            </div>
          )}

          {payment && (
            <p className="muted">
              Payment #{payment.id}: <Pill value={payment.status} /> {money(payment.amount)}
              {payment.paymentDate ? ` · ${new Date(payment.paymentDate).toLocaleString()}` : ''}
            </p>
          )}
          {booking.status === 'CONFIRMED' && <OkNote msg="Booking confirmed — enjoy the show!" />}
        </div>
      )}
    </div>
  );
}

export function MyBookings() {
  const { data, err, loading, reload } = useFetch('/bookings/my-bookings');
  const [busy, setBusy] = useState(false);

  async function cancel(id) {
    if (!window.confirm('Cancel this booking? Seats will be released and any completed payment refunded.')) return;
    setBusy(true);
    try {
      await api.put(`/bookings/${id}/cancel`, {});
      reload();
    } catch (e) {
      window.alert(describeError(e));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div>
      <h1>My Bookings</h1>
      <ErrorNote msg={err} />
      <Loading loading={loading} />
      {data && (
        <table>
          <thead>
            <tr><th>ID</th><th>Show</th><th>Seats</th><th>Tickets</th><th>Total</th><th>Status</th><th>Booked</th><th></th></tr>
          </thead>
          <tbody>
            {data.map((b) => (
              <tr key={b.id}>
                <td>{b.id}</td>
                <td><Link to={`/shows/${b.showId}`}>#{b.showId}</Link></td>
                <td>{b.seatNumbers.join(', ')}</td>
                <td>{b.numberOfTickets}</td>
                <td className="money">{money(b.totalAmount)}</td>
                <td><Pill value={b.status} /></td>
                <td className="muted">{new Date(b.bookingDate).toLocaleString()}</td>
                <td className="right">
                  {b.status !== 'CANCELLED' && (
                    <button className="danger" disabled={busy} onClick={() => cancel(b.id)}>Cancel</button>
                  )}
                </td>
              </tr>
            ))}
            {data.length === 0 && <tr><td colSpan={8} className="muted">No bookings yet.</td></tr>}
          </tbody>
        </table>
      )}
    </div>
  );
}
