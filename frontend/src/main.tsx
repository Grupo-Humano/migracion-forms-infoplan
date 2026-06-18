import React from "react";
import ReactDOM from "react-dom/client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import App from "./App";
import ReembPagoApp from "./ReembPagoApp";
import "./styles.css";

const queryClient = new QueryClient();

// DEMO Sprint 6: muestra reemb_pago. Cambiar a <App /> para volver a rep_aprobarechazo.
const DEMO_SCREEN: "reemb_pago" | "rep_aprobarechazo" = "reemb_pago";

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      {DEMO_SCREEN === "reemb_pago" ? <ReembPagoApp /> : <App />}
    </QueryClientProvider>
  </React.StrictMode>
);
