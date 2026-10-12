export function Pill({ value }) {
  return <span className={'pill ' + (value || '')}>{value}</span>;
}

export function money(v) {
  if (v === null || v === undefined) return '—';
  return 'LKR ' + Number(v).toFixed(2);
}

export function ErrorNote({ msg }) {
  if (!msg) return null;
  return <div className="notice error">{msg}</div>;
}

export function OkNote({ msg }) {
  if (!msg) return null;
  return <div className="notice ok">{msg}</div>;
}

export function Loading({ loading }) {
  if (!loading) return null;
  return <p className="muted">Loading…</p>;
}

// Small helper to describe a field-error object from the backend in one line.
export function describeError(err) {
  if (!err) return '';
  const fields = err.body && err.body.fieldErrors;
  if (fields && Object.keys(fields).length) {
    const parts = Object.entries(fields).map(([k, v]) => `${k}: ${v}`);
    return (err.body.message || 'Validation failed') + ' — ' + parts.join('; ');
  }
  return err.message || String(err);
}
