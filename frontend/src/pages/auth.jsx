import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../auth';
import { ErrorNote, describeError } from '../components';

export default function Login() {
  const { login, signup } = useAuth();
  const nav = useNavigate();
  const [mode, setMode] = useState('signin');
  const [form, setForm] = useState({ name: '', email: '', password: '' });
  const [err, setErr] = useState('');
  const [busy, setBusy] = useState(false);

  const field = (key) => (e) => setForm({ ...form, [key]: e.target.value });

  async function submit(e) {
    e.preventDefault();
    setErr('');
    setBusy(true);
    try {
      const user =
        mode === 'signup'
          ? await signup(form.name, form.email, form.password)
          : await login(form.email, form.password);
      nav(user.role === 'ADMIN' ? '/admin/movies' : '/');
    } catch (ex) {
      setErr(describeError(ex));
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="auth-wrap">
      <div className="card">
        <h1>Movie Ticket Booking</h1>
        <div className="tabs">
          <button className={mode === 'signin' ? 'active' : ''} onClick={() => setMode('signin')} type="button">
            Sign in
          </button>
          <button className={mode === 'signup' ? 'active' : ''} onClick={() => setMode('signup')} type="button">
            Register
          </button>
        </div>
        <ErrorNote msg={err} />
        <form onSubmit={submit}>
          {mode === 'signup' && (
            <>
              <label>Full name</label>
              <input value={form.name} onChange={field('name')} required maxLength={100} />
            </>
          )}
          <label>Email</label>
          <input type="email" value={form.email} onChange={field('email')} required maxLength={254} />
          <label>Password</label>
          <input
            type="password"
            value={form.password}
            onChange={field('password')}
            required
            minLength={mode === 'signup' ? 8 : undefined}
            maxLength={72}
          />
          <div className="actions">
            <button className="primary" disabled={busy} type="submit">
              {busy ? 'Please wait…' : mode === 'signup' ? 'Create account' : 'Sign in'}
            </button>
          </div>
        </form>
        <p className="muted" style={{ marginTop: 14 }}>
          {mode === 'signup'
            ? 'Registration creates a customer account. Sign in afterwards to get a token.'
            : 'Use an administrator account to manage the catalogue, or a customer account to book seats.'}
        </p>
      </div>
    </div>
  );
}
