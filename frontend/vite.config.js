import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

// The SPA talks to the backend through the "/api" path. In development the Vite
// server proxies those requests to the Spring Boot API so the browser stays
// same-origin. Point VITE_PROXY_TARGET at the running API (default port 8081).
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    host: '127.0.0.1',
    proxy: {
      '/api': {
        target: process.env.VITE_PROXY_TARGET || 'http://localhost:8080',
        changeOrigin: true,
      },
    },
  },
});
