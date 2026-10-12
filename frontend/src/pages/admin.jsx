import { useCallback, useEffect, useState } from 'react';
import { api } from '../api';
import { Pill, money, ErrorNote, OkNote, Loading, describeError } from '../components';

const MOVIE_STATUS = ['UPCOMING', 'NOW_SHOWING', 'ENDED'];
const THEATRE_STATUS = ['ACTIVE', 'INACTIVE'];
const SHOW_STATUS = ['SCHEDULED', 'COMPLETED', 'CANCELLED'];

function useList(path) {
  const [items, setItems] = useState([]);
  const [err, setErr] = useState('');
  const [loading, setLoading] = useState(true);
  const reload = useCallback(() => {
    setLoading(true);
    api
      .get(path)
      .then(setItems)
      .catch((e) => setErr(describeError(e)))
      .finally(() => setLoading(false));
  }, [path]);
  useEffect(reload, [reload]);
  return { items, err, setErr, loading, reload };
}

function numberOr(value, cast) {
  return value === '' ? null : cast(value);
}

/* ------------------------------- Movies -------------------------------- */

export function AdminMovies() {
  const { items, err, setErr, loading, reload } = useList('/movies');
  const blank = { title: '', description: '', duration: 120, language: '', genre: '', releaseDate: '', status: 'UPCOMING' };
  const [form, setForm] = useState(blank);
  const [editing, setEditing] = useState(null);
  const [ok, setOk] = useState('');

  const set = (k) => (e) => setForm({ ...form, [k]: e.target.value });

  function startEdit(m) {
    setEditing(m.id);
    setOk('');
    setForm({ ...m, releaseDate: m.releaseDate || '' });
  }
  function reset() {
    setEditing(null);
    setForm(blank);
    setOk('');
  }

  async function save(e) {
    e.preventDefault();
    setErr(''); setOk('');
    const body = {
      title: form.title,
      description: form.description,
      duration: numberOr(form.duration, Number),
      language: form.language,
      genre: form.genre,
      releaseDate: form.releaseDate,
      status: form.status,
    };
    try {
      const msg = editing ? 'Movie updated.' : 'Movie created.';
      if (editing) {
        await api.put(`/movies/${editing}`, body);
      } else {
        await api.post('/movies', body);
      }
      reset();
      setOk(msg);
      reload();
    } catch (ex) {
      setErr(describeError(ex));
    }
  }

  async function remove(id) {
    if (!window.confirm('Delete this movie?')) return;
    setErr('');
    try {
      await api.del(`/movies/${id}`);
      reload();
    } catch (ex) {
      setErr(describeError(ex));
    }
  }

  return (
    <div>
      <h1>Manage Movies</h1>
      <ErrorNote msg={err} />
      <div className="card">
        <h2 style={{ marginTop: 0 }}>{editing ? `Edit movie #${editing}` : 'New movie'}</h2>
        <OkNote msg={ok} />
        <form onSubmit={save}>
          <label>Title</label>
          <input value={form.title} onChange={set('title')} required maxLength={200} />
          <label>Description</label>
          <textarea value={form.description} onChange={set('description')} required maxLength={4000} />
          <div className="row">
            <div style={{ flex: 1 }}>
              <label>Duration (min)</label>
              <input type="number" min={1} max={1440} value={form.duration} onChange={set('duration')} required />
            </div>
            <div style={{ flex: 1 }}>
              <label>Language</label>
              <input value={form.language} onChange={set('language')} required maxLength={50} />
            </div>
            <div style={{ flex: 1 }}>
              <label>Genre</label>
              <input value={form.genre} onChange={set('genre')} required maxLength={80} />
            </div>
            <div style={{ flex: 1 }}>
              <label>Release date</label>
              <input type="date" value={form.releaseDate} onChange={set('releaseDate')} required />
            </div>
            <div style={{ flex: 1 }}>
              <label>Status</label>
              <select value={form.status} onChange={set('status')}>
                {MOVIE_STATUS.map((s) => <option key={s} value={s}>{s}</option>)}
              </select>
            </div>
          </div>
          <div className="actions">
            <button className="primary" type="submit">{editing ? 'Save changes' : 'Create movie'}</button>
            {editing && <button type="button" onClick={reset}>Cancel edit</button>}
          </div>
        </form>
      </div>
      <Loading loading={loading} />
      <table>
        <thead><tr><th>ID</th><th>Title</th><th>Duration</th><th>Language</th><th>Genre</th><th>Release</th><th>Status</th><th></th></tr></thead>
        <tbody>
          {items.map((m) => (
            <tr key={m.id}>
              <td>{m.id}</td><td>{m.title}</td><td>{m.duration}</td><td>{m.language}</td><td>{m.genre}</td>
              <td>{m.releaseDate}</td><td><Pill value={m.status} /></td>
              <td className="right">
                <div className="row" style={{ justifyContent: 'flex-end' }}>
                  <button onClick={() => startEdit(m)}>Edit</button>
                  <button className="danger" onClick={() => remove(m.id)}>Delete</button>
                </div>
              </td>
            </tr>
          ))}
          {items.length === 0 && <tr><td colSpan={8} className="muted">No movies.</td></tr>}
        </tbody>
      </table>
    </div>
  );
}

/* ------------------------------ Theatres ------------------------------- */

export function AdminTheatres() {
  const { items, err, setErr, loading, reload } = useList('/theatres');
  const blank = { name: '', location: '', capacity: 50, status: 'ACTIVE' };
  const [form, setForm] = useState(blank);
  const [editing, setEditing] = useState(null);
  const [ok, setOk] = useState('');
  const set = (k) => (e) => setForm({ ...form, [k]: e.target.value });

  function startEdit(t) { setEditing(t.id); setOk(''); setForm(t); }
  function reset() { setEditing(null); setForm(blank); setOk(''); }

  async function save(e) {
    e.preventDefault();
    setErr(''); setOk('');
    const body = { name: form.name, location: form.location, capacity: numberOr(form.capacity, Number), status: form.status };
    try {
      const msg = editing ? 'Theatre updated.' : 'Theatre created.';
      if (editing) { await api.put(`/theatres/${editing}`, body); }
      else { await api.post('/theatres', body); }
      reset(); setOk(msg); reload();
    } catch (ex) { setErr(describeError(ex)); }
  }
  async function remove(id) {
    if (!window.confirm('Delete this theatre?')) return;
    setErr('');
    try { await api.del(`/theatres/${id}`); reload(); } catch (ex) { setErr(describeError(ex)); }
  }

  return (
    <div>
      <h1>Manage Theatres</h1>
      <ErrorNote msg={err} />
      <div className="card">
        <h2 style={{ marginTop: 0 }}>{editing ? `Edit theatre #${editing}` : 'New theatre'}</h2>
        <OkNote msg={ok} />
        <form onSubmit={save}>
          <div className="row">
            <div style={{ flex: 2 }}><label>Name</label><input value={form.name} onChange={set('name')} required maxLength={150} /></div>
            <div style={{ flex: 2 }}><label>Location</label><input value={form.location} onChange={set('location')} required maxLength={250} /></div>
            <div style={{ flex: 1 }}><label>Capacity</label><input type="number" min={1} max={10000} value={form.capacity} onChange={set('capacity')} required /></div>
            <div style={{ flex: 1 }}>
              <label>Status</label>
              <select value={form.status} onChange={set('status')}>{THEATRE_STATUS.map((s) => <option key={s} value={s}>{s}</option>)}</select>
            </div>
          </div>
          <div className="actions">
            <button className="primary" type="submit">{editing ? 'Save changes' : 'Create theatre'}</button>
            {editing && <button type="button" onClick={reset}>Cancel edit</button>}
          </div>
        </form>
      </div>
      <Loading loading={loading} />
      <table>
        <thead><tr><th>ID</th><th>Name</th><th>Location</th><th>Capacity</th><th>Status</th><th></th></tr></thead>
        <tbody>
          {items.map((t) => (
            <tr key={t.id}>
              <td>{t.id}</td><td>{t.name}</td><td>{t.location}</td><td>{t.capacity}</td><td><Pill value={t.status} /></td>
              <td className="right">
                <div className="row" style={{ justifyContent: 'flex-end' }}>
                  <button onClick={() => startEdit(t)}>Edit</button>
                  <button className="danger" onClick={() => remove(t.id)}>Delete</button>
                </div>
              </td>
            </tr>
          ))}
          {items.length === 0 && <tr><td colSpan={6} className="muted">No theatres.</td></tr>}
        </tbody>
      </table>
    </div>
  );
}

/* -------------------------------- Shows -------------------------------- */

export function AdminShows() {
  const { items, err, setErr, loading, reload } = useList('/shows');
  const [movies, setMovies] = useState([]);
  const [theatres, setTheatres] = useState([]);
  const blank = { movieId: '', theatreId: '', showDate: '', showTime: '19:00:00', ticketPrice: 1000, status: 'SCHEDULED' };
  const [form, setForm] = useState(blank);
  const [editing, setEditing] = useState(null);
  const [ok, setOk] = useState('');
  const set = (k) => (e) => setForm({ ...form, [k]: e.target.value });

  useEffect(() => {
    api.get('/movies').then(setMovies).catch(() => {});
    api.get('/theatres').then(setTheatres).catch(() => {});
  }, []);

  function startEdit(s) { setEditing(s.id); setOk(''); setForm({ ...s, showTime: (s.showTime || '').slice(0, 8) }); }
  function reset() { setEditing(null); setForm(blank); setOk(''); }

  async function save(e) {
    e.preventDefault();
    setErr(''); setOk('');
    const body = {
      movieId: Number(form.movieId),
      theatreId: Number(form.theatreId),
      showDate: form.showDate,
      showTime: form.showTime.length === 5 ? form.showTime + ':00' : form.showTime,
      ticketPrice: numberOr(form.ticketPrice, Number),
      status: form.status,
    };
    try {
      const msg = editing ? 'Show updated.' : 'Show created.';
      if (editing) { await api.put(`/shows/${editing}`, body); }
      else { await api.post('/shows', body); }
      reset(); setOk(msg); reload();
    } catch (ex) { setErr(describeError(ex)); }
  }

  async function setStatus(s, status) {
    setErr('');
    const body = {
      movieId: s.movieId, theatreId: s.theatreId, showDate: s.showDate,
      showTime: (s.showTime || '').slice(0, 8), ticketPrice: Number(s.ticketPrice), status,
    };
    try { await api.put(`/shows/${s.id}`, body); reload(); } catch (ex) { setErr(describeError(ex)); }
  }

  async function remove(id) {
    if (!window.confirm('Delete this show?')) return;
    setErr('');
    try { await api.del(`/shows/${id}`); reload(); } catch (ex) { setErr(describeError(ex)); }
  }

  return (
    <div>
      <h1>Manage Shows</h1>
      <ErrorNote msg={err} />
      <div className="card">
        <h2 style={{ marginTop: 0 }}>{editing ? `Edit show #${editing}` : 'New show'}</h2>
        <OkNote msg={ok} />
        <p className="muted">New shows must be SCHEDULED and in the future. A theatre cannot host overlapping shows.</p>
        <form onSubmit={save}>
          <div className="row">
            <div style={{ flex: 1 }}>
              <label>Movie</label>
              <select value={form.movieId} onChange={set('movieId')} required>
                <option value="">Select…</option>
                {movies.map((m) => <option key={m.id} value={m.id}>{m.title}</option>)}
              </select>
            </div>
            <div style={{ flex: 1 }}>
              <label>Theatre</label>
              <select value={form.theatreId} onChange={set('theatreId')} required>
                <option value="">Select…</option>
                {theatres.map((t) => <option key={t.id} value={t.id}>{t.name} ({t.capacity})</option>)}
              </select>
            </div>
            <div style={{ flex: 1 }}><label>Date</label><input type="date" value={form.showDate} onChange={set('showDate')} required /></div>
            <div style={{ flex: 1 }}><label>Time</label><input type="time" value={(form.showTime || '').slice(0, 5)} onChange={(e) => setForm({ ...form, showTime: e.target.value + ':00' })} required /></div>
            <div style={{ flex: 1 }}><label>Ticket price</label><input type="number" min="0.01" step="0.01" max="999999.99" value={form.ticketPrice} onChange={set('ticketPrice')} required /></div>
            <div style={{ flex: 1 }}>
              <label>Status</label>
              <select value={form.status} onChange={set('status')}>{SHOW_STATUS.map((s) => <option key={s} value={s}>{s}</option>)}</select>
            </div>
          </div>
          <div className="actions">
            <button className="primary" type="submit">{editing ? 'Save changes' : 'Create show'}</button>
            {editing && <button type="button" onClick={reset}>Cancel edit</button>}
          </div>
        </form>
      </div>
      <Loading loading={loading} />
      <table>
        <thead><tr><th>ID</th><th>Movie</th><th>Theatre</th><th>When</th><th>Ticket</th><th>Status</th><th></th></tr></thead>
        <tbody>
          {items.map((s) => (
            <tr key={s.id}>
              <td>{s.id}</td>
              <td>{(movies.find((m) => m.id === s.movieId) || {}).title || `#${s.movieId}`}</td>
              <td>{(theatres.find((t) => t.id === s.theatreId) || {}).name || `#${s.theatreId}`}</td>
              <td>{s.showDate} {(s.showTime || '').slice(0, 5)}</td>
              <td className="money">{money(s.ticketPrice)}</td>
              <td>
                <div className="row">
                  <Pill value={s.status} />
                  <select value={s.status} onChange={(e) => setStatus(s, e.target.value)} style={{ width: 'auto' }}>
                    {SHOW_STATUS.map((st) => <option key={st} value={st}>{st}</option>)}
                  </select>
                </div>
              </td>
              <td className="right">
                <div className="row" style={{ justifyContent: 'flex-end' }}>
                  <button onClick={() => startEdit(s)}>Edit</button>
                  <button className="danger" onClick={() => remove(s.id)}>Delete</button>
                </div>
              </td>
            </tr>
          ))}
          {items.length === 0 && <tr><td colSpan={7} className="muted">No shows.</td></tr>}
        </tbody>
      </table>
    </div>
  );
}

/* ------------------------------ Bookings ------------------------------- */

export function AdminBookings() {
  const { items, err, setErr, loading, reload } = useList('/bookings');
  const [busy, setBusy] = useState(false);

  async function updateStatus(id, status) {
    setBusy(true); setErr('');
    try { await api.put(`/bookings/${id}/status`, { status }); reload(); }
    catch (ex) { setErr(describeError(ex)); }
    finally { setBusy(false); }
  }

  return (
    <div>
      <h1>All Bookings</h1>
      <ErrorNote msg={err} />
      <Loading loading={loading} />
      <p className="muted">Confirming requires a completed payment; cancelling releases seats and refunds a completed payment.</p>
      <table>
        <thead><tr><th>ID</th><th>User</th><th>Show</th><th>Seats</th><th>Tickets</th><th>Total</th><th>Status</th><th>Action</th></tr></thead>
        <tbody>
          {items.map((b) => (
            <tr key={b.id}>
              <td>{b.id}</td><td>#{b.userId}</td><td>#{b.showId}</td>
              <td>{b.seatNumbers.join(', ')}</td><td>{b.numberOfTickets}</td>
              <td className="money">{money(b.totalAmount)}</td><td><Pill value={b.status} /></td>
              <td>
                <div className="row">
                  <select defaultValue="" disabled={busy} style={{ width: 'auto' }} onChange={(e) => { if (e.target.value) { updateStatus(b.id, e.target.value); e.target.value = ''; } }}>
                    <option value="">Set status…</option>
                    {['PENDING', 'CONFIRMED', 'CANCELLED'].map((s) => <option key={s} value={s}>{s}</option>)}
                  </select>
                </div>
              </td>
            </tr>
          ))}
          {items.length === 0 && <tr><td colSpan={8} className="muted">No bookings.</td></tr>}
        </tbody>
      </table>
    </div>
  );
}

/* ------------------------------ Payments ------------------------------- */

export function AdminPayments() {
  const { items, err, loading } = useList('/payments');
  return (
    <div>
      <h1>All Payments</h1>
      <ErrorNote msg={err} />
      <Loading loading={loading} />
      <table>
        <thead><tr><th>ID</th><th>Booking</th><th>Amount</th><th>Method</th><th>Status</th><th>Processed</th></tr></thead>
        <tbody>
          {items.map((p) => (
            <tr key={p.id}>
              <td>{p.id}</td><td>#{p.bookingId}</td><td className="money">{money(p.amount)}</td>
              <td>{p.paymentMethod}</td><td><Pill value={p.status} /></td>
              <td className="muted">{p.paymentDate ? new Date(p.paymentDate).toLocaleString() : '—'}</td>
            </tr>
          ))}
          {items.length === 0 && <tr><td colSpan={6} className="muted">No payments.</td></tr>}
        </tbody>
      </table>
    </div>
  );
}
