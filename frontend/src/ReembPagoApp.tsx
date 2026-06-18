// ReembPagoApp — shell principal de la pantalla reemb_pago
// Remy (Producer orchestration) | Sprint 6
// Demo: Paso 1 Buscar Afiliado activo, pasos 2-5 scaffolded

import { useState } from "react";
import { BusquedaAfiliado } from "./components/reemb-pago/BusquedaAfiliado";
import { StepIndicator } from "./components/reemb-pago/StepIndicator";
import type { AfiliadoItem, ReembPasoId } from "./types-reemb-pago";
import { REEMB_STEPS } from "./types-reemb-pago";

export default function ReembPagoApp() {
  const [currentStep, setCurrentStep] = useState<ReembPasoId>("busqueda");
  const [completedSteps, setCompletedSteps] = useState<Set<ReembPasoId>>(new Set());
  const [afiliadoSeleccionado, setAfiliadoSeleccionado] = useState<AfiliadoItem | null>(null);

  function handleAfiliadoSeleccionado(afiliado: AfiliadoItem) {
    setAfiliadoSeleccionado(afiliado);
    setCompletedSteps((prev) => new Set(prev).add("busqueda"));
    setCurrentStep("datos-reembolso");
  }

  function handleVolverBusqueda() {
    setCurrentStep("busqueda");
    setCompletedSteps(new Set());
    setAfiliadoSeleccionado(null);
  }

  return (
    <div className="app-shell">
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="brand-block">
          <div className="brand-mark">IP</div>
          <div>
            <h1 className="brand-title">Infoplan</h1>
            <p className="brand-subtitle">Sistema de Gestión</p>
          </div>
        </div>

        <nav className="side-nav">
          <button className="side-link active">
            💊 Reembolso de Pago
          </button>
          <button className="side-link">📋 Rep. Aprobaciones</button>
          <button className="side-link">📊 Consultas</button>
        </nav>

        <button className="side-logout">⬅ Salir</button>
      </aside>

      {/* Content shell */}
      <div className="content-shell">
        {/* Topbar */}
        <header className="topbar">
          <h2 className="topbar-title">Reembolso de Pago — PBI 203844</h2>
          <div className="topbar-user">
            <div>
              <p className="topbar-name">César R.</p>
              <p className="topbar-mail">cesar@infoplan.com</p>
            </div>
            <div className="topbar-avatar">CR</div>
          </div>
        </header>

        {/* Page content */}
        <main className="page">
          {/* Hero */}
          <div className="hero-card">
            <div>
              <h1>Registro de Reembolso</h1>
              <p>Complete los 5 pasos para registrar la solicitud de reembolso</p>
            </div>
            <div className="hero-chip">
              Sprint 6 · MVP · Demo
            </div>
          </div>

          {/* Step indicator */}
          <StepIndicator
            steps={REEMB_STEPS}
            currentStep={currentStep}
            completedSteps={completedSteps}
          />

          {/* Afiliado seleccionado banner */}
          {afiliadoSeleccionado && (
            <div
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                padding: "12px 16px",
                background: "rgba(140,233,154,0.1)",
                border: "1px solid rgba(140,233,154,0.35)",
                borderRadius: 10,
                gap: 12,
              }}
            >
              <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                <span style={{ fontSize: "1.4rem" }}>✅</span>
                <div>
                  <p style={{ margin: 0, fontWeight: 700, color: "#8ce99a" }}>
                    Afiliado seleccionado
                  </p>
                  <p style={{ margin: "2px 0 0", fontSize: "0.9rem", color: "var(--ink-soft)" }}>
                    {afiliadoSeleccionado.nombreCompleto} ·{" "}
                    <code style={{ color: "var(--accent)" }}>
                      {afiliadoSeleccionado.idAfiliado}
                    </code>{" "}
                    · Carnet {afiliadoSeleccionado.numeroCarnet}
                  </p>
                </div>
              </div>
              <button
                style={{ fontSize: "0.8rem", padding: "6px 12px" }}
                onClick={handleVolverBusqueda}
              >
                Cambiar afiliado
              </button>
            </div>
          )}

          {/* Paso 1: Búsqueda de Afiliado */}
          {currentStep === "busqueda" && (
            <BusquedaAfiliado onSeleccionar={handleAfiliadoSeleccionado} />
          )}

          {/* Pasos 2-5: Scaffolded (Sprint 7) */}
          {currentStep !== "busqueda" && (
            <section className="panel">
              <h2>
                {REEMB_STEPS.find((s) => s.id === currentStep)?.label} — En
                construcción
              </h2>
              <div className="status-panel">
                <p style={{ color: "var(--ink-soft)" }}>
                  Este paso será implementado en el siguiente incremento (Sprint 6
                  T-02/T-03). Afiliado base confirmado:{" "}
                  <strong style={{ color: "var(--ink)" }}>
                    {afiliadoSeleccionado?.nombreCompleto}
                  </strong>
                </p>
              </div>
              <div className="actions-row">
                <button onClick={handleVolverBusqueda}>
                  ← Volver a Búsqueda
                </button>
              </div>
            </section>
          )}
        </main>
      </div>
    </div>
  );
}
