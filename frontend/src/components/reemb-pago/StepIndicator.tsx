// StepIndicator — indicador visual de progreso del flujo reemb_pago
// Milo (Visual) | Sprint 6

import type { ReembPasoId, ReembStep } from "../../types-reemb-pago";

type Props = {
  steps: ReembStep[];
  currentStep: ReembPasoId;
  completedSteps: Set<ReembPasoId>;
};

export function StepIndicator({ steps, currentStep, completedSteps }: Readonly<Props>) {
  return (
    <div style={styles.wrapper}>
      {steps.map((step, idx) => {
        const isCompleted = completedSteps.has(step.id);
        const isCurrent = step.id === currentStep;
        const isUpcoming = !isCompleted && !isCurrent;

        return (
          <div key={step.id} style={styles.stepRow}>
            <div
              style={{
                ...styles.circle,
                ...(isCompleted ? styles.circleCompleted : {}),
                ...(isCurrent ? styles.circleCurrent : {}),
                ...(isUpcoming ? styles.circleUpcoming : {}),
              }}
            >
              {isCompleted ? "✓" : step.numero}
            </div>

            <span
              style={{
                ...styles.label,
                ...(isCurrent ? styles.labelCurrent : {}),
                ...(isUpcoming ? styles.labelUpcoming : {}),
              }}
            >
              {step.label}
            </span>

            {idx < steps.length - 1 && (
              <div
                style={{
                  ...styles.connector,
                  ...(isCompleted ? styles.connectorDone : {}),
                }}
              />
            )}
          </div>
        );
      })}
    </div>
  );
}

const styles: Record<string, React.CSSProperties> = {
  wrapper: {
    display: "flex",
    alignItems: "center",
    gap: 0,
    padding: "14px 20px",
    background: "var(--bg-panel)",
    borderRadius: 12,
    border: "1px solid var(--line)",
    overflowX: "auto",
  },
  stepRow: {
    display: "flex",
    alignItems: "center",
    gap: 8,
    flexShrink: 0,
  },
  circle: {
    width: 32,
    height: 32,
    borderRadius: "50%",
    display: "grid",
    placeItems: "center",
    fontWeight: 700,
    fontSize: "0.85rem",
    flexShrink: 0,
    transition: "background 0.2s",
  },
  circleCurrent: {
    background: "var(--accent)",
    border: "2px solid #87b6f8",
    color: "#fff",
    boxShadow: "0 0 10px rgba(95,157,237,0.5)",
  },
  circleCompleted: {
    background: "var(--ok)",
    border: "2px solid #a3e6aa",
    color: "#0b2210",
  },
  circleUpcoming: {
    background: "var(--bg-sidebar-deep)",
    border: "2px solid var(--line-soft)",
    color: "var(--ink-soft)",
  },
  label: {
    fontSize: "0.82rem",
    fontWeight: 700,
    whiteSpace: "nowrap",
  },
  labelCurrent: {
    color: "#90c4ff",
  },
  labelUpcoming: {
    color: "var(--ink-soft)",
  },
  connector: {
    width: 32,
    height: 2,
    background: "var(--line-soft)",
    marginLeft: 8,
    marginRight: 8,
    flexShrink: 0,
  },
  connectorDone: {
    background: "var(--ok)",
  },
};
