# Acta: arranque de la herramienta de préstamo de equipos
- **Fecha:** 2026-11-12
- **Fuente:** inbox/2026-11-12-example-kickoff.md
## Resumen
Se realizó una reunión de arranque para definir la idea inicial de una herramienta para gestionar préstamos de equipos entre empleados. La conversación centró la necesidad de registrar solicitudes, evitar el uso de datos reales durante pruebas y aclarar la operación del flujo de préstamo.
## Temas tratados
- El objetivo del sistema es permitir que los empleados pidan prestados laptops y proyectores.
- Se discutió si la validación inicial debe utilizar la lista real de empleados o datos ficticios.
- Se identificó la necesidad de registrar la trazabilidad de cada préstamo: quién solicita el equipo, cuándo y por qué.
- Se planteó la necesidad de que el sistema sea idempotente al reintentar una operación de préstamo.
- No quedó definido quién aprueba los préstamos ni si existen fechas límite para su devolución.
## Acuerdos
- Se reconoce como necesidad funcional la gestión de préstamos de laptops y proyectores para empleados.
- Se acepta la idea de mantener un registro de cada préstamo con trazabilidad.
- Se registró una recomendación explícita de usar datos ficticios para pruebas, sin descartar aún la posibilidad de usar una lista real en la validación posterior.
## Pendientes
- Definir quién aprueba los préstamos.
- Resolver si la validación debe usar datos reales o ficticios de empleados.
- Definir si los préstamos tienen fecha límite.
- Confirmar el comportamiento de idempotencia al repetir una solicitud de préstamo.
## Supuestos
- Se asume que la herramienta se desarrollará en una fase inicial como prototipo o validación funcional.
- Se asume que cada préstamo debe tener una trazabilidad mínima para auditoría y soporte.
- No se definió aún la autoridad de aprobación ni la política de vencimiento.
