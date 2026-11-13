# project_docs

Un equipo de cuatro agentes de inteligencia artificial (IA) que ayuda a las personas a definir y diseñar proyectos de software: ordena lo acordado en las reuniones, lo convierte en decisiones documentadas, las cuestiona desde la seguridad y el riesgo, y explica la terminología a quien se está incorporando.

**La decisión final siempre es de una persona.** Los agentes preparan, cuestionan y documentan; no aprueban.

Este repositorio es una **plantilla** (template): se crea un repositorio por proyecto a partir de ella. Contiene solo documentación y decisiones, nunca código del proyecto. Los agentes son *custom agents* de GitHub Copilot (asistentes configurados con instrucciones y herramientas propias para un rol concreto). La justificación del diseño está en la carpeta `__context/`.

## El problema que resuelve

En proyectos grandes, las decisiones se dispersan entre reuniones, correos y notas, y la documentación se desactualiza rápido. Un error de definición cuesta poco si se detecta al inicio y mucho cuando ya hay código construido encima. Además, quien tiene menos experiencia depende de los expertos para entender la terminología.

## Cómo funciona

Guardas las notas de una reunión tal como las tomaste. Los agentes las convierten en documentos ordenados y tú revisas el resultado entre un paso y el siguiente.

```text
notas en inbox/ ──► Analyst ──► tú revisas ──► Architect ──► tú revisas ──► Reviewer ──► tú decides
                       │                            ▲                           │
                       │                            └───── riesgos a corregir ──┘
                       └── Mentor (en paralelo, mismas notas, glosario compartido)
```

| Agente | Qué hace | Comando | Qué escribe |
| --- | --- | --- | --- |
| **Analyst** (analista) | Ordena las notas; encuentra huecos y contradicciones | `/process-meeting inbox/<archivo>` | `docs/meeting-notes/`, `docs/requirements/requirements.md`, `docs/glossary.md`, `docs/open-questions.md` |
| **Architect** (arquitecto) | Convierte los requisitos en decisiones propuestas (ADR: registro breve de qué se decidió, por qué y qué alternativas se descartaron) | `/draft-adr REQ-001` | un archivo nuevo en `docs/adr/` y preguntas nuevas en `docs/open-questions.md` |
| **Reviewer** (revisor) | Ataca la propuesta: seguridad, datos personales, control de acceso, dependencias entre proyectos y escalabilidad. Nunca la defiende | `/review-adr docs/adr/<archivo>` | solo un archivo nuevo en `docs/risks/` |
| **Mentor** | Explica los términos en palabras simples, lista dudas para el experto y arma un mapa de conceptos | `/explain-meeting inbox/<archivo>` | `docs/learning/` y `docs/glossary.md` |

Cuando un agente termina, aparecen botones para pasar el trabajo al siguiente (Analyst → Architect → Reviewer → Architect). Nada se envía solo: una persona revisa cada paso.

## Reglas que cumplen todos los agentes

1. **No inventar.** Lo que falta se marca como supuesto o pregunta abierta.
2. **Trazabilidad.** Cada requisito y decisión indica de qué reunión o documento proviene.
3. **Seguridad por defecto.** No usan datos reales ni sensibles; los ejemplos son ficticios. Si encuentran datos personales en las notas (aunque digan que son de ejemplo) no los copian: los reemplazan por `[DATO SENSIBLE]` y avisan del tipo de dato.
4. **Preguntar antes de asumir.**
5. **Formato fijo** por tipo de documento, para poder validarlo.
6. **Nunca aprobar.** Decide una persona.

## Cómo usarlo

No necesitas usar la terminal: los agentes ejecutan solos los scripts de apoyo (ver más abajo).

**Requisitos:** Visual Studio Code con la extensión GitHub Copilot Chat y un plan de Copilot que admita agentes personalizados (o un Codespace de GitHub, que ya lo trae). En el chat, la primera vez que un agente quiera ejecutar un script, VS Code te pedirá confirmación: acéptala solo si el comando empieza con `bash scripts/`.

1. Abre este repositorio en VS Code (o crea un Codespace).
2. Guarda las notas de la reunión en `inbox/` con el nombre `AAAA-MM-DD-tema.md` (por ejemplo `2026-11-12-kickoff.md`). No uses datos reales ni sensibles. Ya hay un ejemplo: `inbox/2026-11-12-example-kickoff.md`.
3. Abre Copilot Chat y escribe un comando, por ejemplo: `/process-meeting inbox/2026-11-12-example-kickoff.md`. También puedes elegir un agente en el menú de agentes del chat y escribirle.
4. Lee lo que produjo y el resumen que deja en el chat: archivos creados, huecos o contradicciones, avisos de seguridad y preguntas. Corrige lo que no esté bien.
5. Pasa al siguiente agente con el botón o el comando. En cada reunión nueva, los agentes leen primero lo que ya existe, así el proyecto conserva su memoria.
6. Las decisiones las tomas tú: cambias un ADR a `aceptado`, validas las entradas del glosario y cierras las preguntas respondidas.

Los documentos que generan los agentes son tu resultado: actas, requisitos, decisiones, informes de riesgo y explicaciones.

¿Quieres probar los agentes sin escribir notas propias? En [samples/](samples/README.md) hay reuniones ficticias para descargar, qué esperar de cada una y un mapa de dónde queda cada resultado.

## Estructura del repositorio

```text
.github/copilot-instructions.md   reglas generales para todos los agentes
.github/agents/                   los cuatro agentes
.github/prompts/                  los comandos (/process-meeting, /draft-adr, ...)
inbox/                            notas sin procesar (los agentes nunca las modifican)
samples/                          notas de ejemplo para probar; los agentes no entran aquí (ver samples/README.md)
docs/meeting-notes/               actas
docs/requirements/                requisitos, cada uno con su fuente
docs/adr/                         decisiones de arquitectura
docs/risks/                       informes de riesgos
docs/learning/                    explicaciones en palabras simples
docs/glossary.md                  glosario compartido
docs/open-questions.md            decisiones pendientes
scripts/                          scripts de apoyo
__context/                        justificación del diseño (solo referencia)
```

## Scripts de apoyo

Hacen las tareas que deben dar siempre el mismo resultado. Los agentes los ejecutan por ti; también puedes correrlos a mano con `bash scripts/<nombre>.sh`.

| Script | Qué hace | Quién lo usa |
| --- | --- | --- |
| `scripts/scan-inbox.sh [archivo]` | Busca patrones de datos sensibles (correos, números largos, credenciales, montos). Muestra solo el tipo y la línea, nunca el dato. No detecta nombres de personas | Analyst y Mentor antes de procesar; todos los agentes sobre lo que escriben |
| `scripts/number-adr.sh [título]` | Indica el siguiente número de ADR o el nombre de archivo para un título | Architect |
| `scripts/validate-docs.sh` | Revisa nombres, secciones obligatorias e IDs de todos los documentos de `docs/` | Todos los agentes al terminar |
| `scripts/reset-generated-docs.sh` | **Solo para pruebas.** Borra los documentos generados, pidiendo escribir RESET. Ningún agente puede ejecutarlo | Solo una persona |

## Idioma

El código, los scripts, las instrucciones de los agentes y los nombres de archivos están en inglés. Los documentos que generan los agentes están en español. Los agentes responden en español y explican los términos técnicos en inglés.
