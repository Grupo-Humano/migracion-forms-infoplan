// Datos mock para demo Paso 1 - Búsqueda de Afiliado
// PBI-203844 Sprint 6

import type { AfiliadoItem, CriterioBusqueda } from "./types-reemb-pago";

export const mockAfiliados: AfiliadoItem[] = [
  {
    idAfiliado: "AF-00123",
    nombreCompleto: "Carlos Alberto Rodríguez Mora",
    identificacion: "00100234567",
    numeroCarnet: "C-2024-001",
    estadoAfiliado: "ACTIVO",
  },
  {
    idAfiliado: "AF-00456",
    nombreCompleto: "María Elena Sánchez Vargas",
    identificacion: "00200345678",
    numeroCarnet: "C-2024-002",
    estadoAfiliado: "ACTIVO",
  },
  {
    idAfiliado: "AF-00789",
    nombreCompleto: "José Manuel Torres Pérez",
    identificacion: "00300456789",
    numeroCarnet: "C-2023-099",
    estadoAfiliado: "INACTIVO",
  },
  {
    idAfiliado: "AF-01011",
    nombreCompleto: "Ana Lucía Jiménez Castro",
    identificacion: "00400567890",
    numeroCarnet: "C-2024-004",
    estadoAfiliado: "ACTIVO",
  },
  {
    idAfiliado: "AF-01213",
    nombreCompleto: "Roberto Carlos Mendez León",
    identificacion: "00500678901",
    numeroCarnet: "C-2022-055",
    estadoAfiliado: "SUSPENDIDO",
  },
  {
    idAfiliado: "AF-01415",
    nombreCompleto: "Gabriela Fernández Rojas",
    identificacion: "00600789012",
    numeroCarnet: "C-2024-006",
    estadoAfiliado: "ACTIVO",
  },
  {
    idAfiliado: "AF-01617",
    nombreCompleto: "Pedro Antonio Guzmán Herrera",
    identificacion: "00700890123",
    numeroCarnet: "C-2021-033",
    estadoAfiliado: "INACTIVO",
  },
  {
    idAfiliado: "AF-01819",
    nombreCompleto: "Lucia del Carmen Vega Blanco",
    identificacion: "00800901234",
    numeroCarnet: "C-2024-008",
    estadoAfiliado: "ACTIVO",
  },
];

export function buscarAfiliados(
  tipo: CriterioBusqueda,
  valor: string
): AfiliadoItem[] {
  if (!valor.trim()) return [];
  const q = valor.toLowerCase();
  return mockAfiliados.filter((a) => {
    switch (tipo) {
      case "AFILIADO":
        return a.idAfiliado.toLowerCase().includes(q);
      case "CARNET":
        return a.numeroCarnet.toLowerCase().includes(q);
      case "DOCUMENTO":
        return a.identificacion.includes(q);
      case "NOMBRE":
        return a.nombreCompleto.toLowerCase().includes(q);
      default:
        return false;
    }
  });
}
