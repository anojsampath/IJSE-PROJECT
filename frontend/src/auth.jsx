import { createContext, useContext, useState } from 'react';
import { api, setToken } from './api';

const STORAGE_KEY = 'mb.auth';
const AuthContext = createContext(null);

function readStored() {
  const raw = localStorage.getItem(STORAGE_KEY);
  if (!raw) return null;
  try {
    const parsed = JSON.parse(raw);
    if (parsed && parsed.token && parsed.user) {
      setToken(parsed.token);
      return parsed;
    }
  } catch {
    /* ignore corrupt storage */
  }
  return null;
}

export function AuthProvider({ children }) {
  const [auth, setAuth] = useState(readStored);
  const user = auth ? auth.user : null;

  async function login(email, password) {
    const result = await api.post('/auth/signin', { email, password });
    const next = { token: result.token, user: result.user };
    setToken(next.token);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
    setAuth(next);
    return result.user;
  }

  async function signup(name, email, password) {
    await api.post('/auth/signup', { name, email, password });
    return login(email, password);
  }

  function logout() {
    setToken(null);
    localStorage.removeItem(STORAGE_KEY);
    setAuth(null);
  }

  const value = { user, isAdmin: user && user.role === 'ADMIN', isCustomer: user && user.role === 'CUSTOMER', login, signup, logout };
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
