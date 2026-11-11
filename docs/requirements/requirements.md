# Requisitos

### REQ-001: préstamo de equipos a empleados
- **Descripción:** El sistema debe permitir que los empleados soliciten préstamos de laptops y proyectores.
- **Fuente:** Acta de kickoff (inbox/2026-11-12-example-kickoff.md)
- **Estado:** propuesto
- **Supuestos:** Se asume que el usuario será un empleado de la organización y que el préstamo se gestionará dentro de un entorno interno.

### REQ-002: uso de datos ficticios en pruebas
- **Descripción:** Durante la fase inicial, la solución no debe depender de la lista real de empleados ni de datos sensibles de producción.
- **Fuente:** Acta de kickoff (inbox/2026-11-12-example-kickoff.md)
- **Estado:** propuesto
- **Supuestos:** Se asume que la validación inicial se realizará con datos inventados para evitar riesgos de privacidad.

### REQ-003: trazabilidad de cada préstamo
- **Descripción:** Cada préstamo debe registrar quién lo solicita, cuándo ocurre y el motivo o finalidad del préstamo.
- **Fuente:** Acta de kickoff (inbox/2026-11-12-example-kickoff.md)
- **Estado:** propuesto
- **Supuestos:** Se asume que la trazabilidad es necesaria para auditoría, soporte y seguimiento.

### REQ-004: idempotencia en la operación de préstamo
- **Descripción:** Si se repite la misma operación de préstamo por error, el sistema debe evitar duplicados o estados inconsistentes.
- **Fuente:** Acta de kickoff (inbox/2026-11-12-example-kickoff.md)
- **Estado:** propuesto
- **Supuestos:** Se asume que la operación puede reintentarse por error o por desconexión temporal.
