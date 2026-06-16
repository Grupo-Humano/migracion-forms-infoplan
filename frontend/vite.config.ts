import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      "/ords": {
        target: "https://infoplan-web-dev.humano.local",
        changeOrigin: true,
        secure: false
      }
    }
  }
});
