import React from "react";
import ReactDOM from "react-dom/client";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import App from "./App";
import ReembPagoApp from "./ReembPagoApp";
import "./styles.css";

const queryClient = new QueryClient();

type ScreenName = "rep_aprobarechazo" | "reemb_pago";

function resolveScreen(): ScreenName {
  const urlScreen = new URLSearchParams(globalThis.location.search).get("screen");
  if (urlScreen === "rep_aprobarechazo" || urlScreen === "reemb_pago") {
    return urlScreen;
  }

  const envScreen = import.meta.env.VITE_SCREEN as string | undefined;
  if (envScreen === "rep_aprobarechazo" || envScreen === "reemb_pago") {
    return envScreen;
  }

  return "reemb_pago";
}

const screen = resolveScreen();

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <QueryClientProvider client={queryClient}>
      {screen === "rep_aprobarechazo" ? <App /> : <ReembPagoApp />}
    </QueryClientProvider>
  </React.StrictMode>
);
