# Propuesta: equipo de agentes de IA para acelerar el desarrollo de proyectos de software

Nov 10, 2026 · @Samuel

## Resumen ejecutivo

Se propone implementar un equipo de cuatro agentes de inteligencia artificial (IA) que asista a las personas del proyecto en la fase de definición y diseño. Los agentes ordenan lo acordado en reuniones, lo convierten en decisiones documentadas, lo cuestionan desde la seguridad y el riesgo, y explican la terminología a quienes se incorporan.

La solución se construye con GitHub Copilot en Visual Studio Code, utiliza scripts para las tareas deterministas y reserva la IA para las tareas que requieren interpretación. La decisión final corresponde siempre a una persona.

## Antecedentes y problema

En los proyectos de gran tamaño, las decisiones se dispersan entre reuniones, correos y notas, y la documentación se desactualiza con rapidez. Un error de definición tiene un costo bajo si se detecta al inicio y un costo alto cuando ya existe código construido sobre él. Además, las personas con menos experiencia dependen de la disponibilidad de los expertos para comprender la terminología y las decisiones.

La propuesta busca atender los siguientes problemas:

- Decisiones y supuestos que no quedan registrados.
- Documentos que se desactualizan entre reuniones.
- Riesgos de seguridad y de diseño que se detectan tarde.
- Una curva de aprendizaje lenta para el personal que se incorpora.

## Objetivos

El objetivo general es reducir el tiempo y el riesgo de la fase de definición de un proyecto, manteniendo a las personas como responsables de las decisiones. Los objetivos específicos son:

1. Convertir el contenido de reuniones y documentos en actas, requisitos y decisiones trazables.
2. Detectar huecos, contradicciones y riesgos de seguridad antes de construir.
3. Reducir la dependencia de los expertos para explicar la terminología al personal nuevo.
4. Mantener una memoria documental del proyecto que se actualice con cada reunión.
5. Usar IA solo donde aporta valor y scripts en las tareas deterministas.

## Solución propuesta

La solución consiste en cuatro agentes de IA con roles definidos. Un agente de IA, en este contexto, es un asistente configurado con instrucciones y herramientas propias para un rol concreto, y no un chat de uso general.

Tres agentes forman una cadena de definición y diseño (Analista, Arquitecto y Revisor) y un cuarto (Mentor) apoya el aprendizaje. Todos leen y escriben sobre un repositorio de documentos que funciona como memoria del proyecto.

La separación de roles es una decisión deliberada: quien propone un diseño no debe evaluarlo, porque tiende a justificarlo. Por ello, el Revisor es un agente distinto, con la instrucción de cuestionar las propuestas.

## Arquitectura del flujo

&#91;embedded content: flujo de agentes · 4 agentes y la persona que decide\]

La persona revisa el resultado entre cada agente. Si el Revisor identifica riesgos, el trabajo regresa al Arquitecto y, al final, la persona aprueba, ajusta o devuelve. El Mentor trabaja sobre las mismas notas y comparte el glosario con el Analista.

## Agentes y responsabilidades

Tres agentes trabajan en cadena (Analista, Arquitecto y Revisor): la salida de uno es la entrada del siguiente. El Mentor opera en paralelo sobre las mismas notas.

| Agente | Responsabilidad | Entrada | Salida |
| --- | --- | --- | --- |
| Analista | Ordenar lo acordado y detectar huecos y contradicciones | Notas, transcripciones, documentos | Acta, requisitos, preguntas abiertas, glosario técnico |
| Arquitecto | Convertir los requisitos en decisiones de diseño | Salidas del Analista | Registros de decisión (ADR), modelo común, diseño propuesto |
| Revisor | Cuestionar el diseño en seguridad, riesgos y escalabilidad | Decisiones y propuestas del Arquitecto | Informe de riesgos |
| Mentor | Traducir la terminología técnica para quien aprende | Notas, transcripciones, glosario | Glosario explicado, resumen en palabras simples, dudas por aclarar |

Un ADR (registro de decisión de arquitectura) es un documento breve que indica qué se decidió, por qué y qué alternativas se descartaron. El Analista y el Mentor comparten el archivo de glosario, de modo que este crece con cada reunión.

## Agente Mentor: apoyo al aprendizaje

El Mentor toma la transcripción o las notas de una reunión en la que una persona con experiencia explica un tema y las traduce al nivel de quien aprende. Entrega cuatro resultados:

1. **Glosario de la reunión:** cada término técnico, explicado en lenguaje sencillo.
2. **Resumen en palabras simples** de lo que se explicó.
3. **Dudas por aclarar,** listas para llevar al experto en la siguiente reunión.
4. **Mapa de conceptos:** qué término depende de cuál, para saber por dónde empezar a estudiar.

Por ejemplo, si el experto afirma que "se requiere linaje de datos y procesos idempotentes", el Mentor entrega:

- **Linaje de datos (data lineage):** el recorrido de un dato desde su origen hasta donde se utiliza. Permite saber de dónde proviene un valor y qué se ve afectado si cambia la fuente.
- **Idempotente:** propiedad de un proceso que, ejecutado varias veces, deja el mismo resultado que si se hubiera ejecutado una sola vez. Evita duplicados cuando un proceso falla y se reintenta.

Una explicación errónea expresada con seguridad es difícil de detectar para quien aprende. Por ello, el Mentor aplica tres controles:

- Diferencia la definición general de un término de lo que dijo el experto en la reunión.
- Marca como "no verificado" lo que no puede afirmar con certeza.
- Entrega el glosario para su validación por una persona con experiencia antes de considerarlo definitivo.

## Principios de operación

Los cuatro agentes comparten seis principios, definidos en sus instrucciones:

1. **No inventar.** Lo que falta se marca como supuesto o pregunta abierta.
2. **Trazabilidad.** Cada requisito y cada decisión indica de qué reunión o documento proviene.
3. **Seguridad por defecto.** No solicitan ni utilizan datos reales o sensibles; trabajan con ejemplos ficticios.
4. **Consulta ante la ambigüedad.** Preguntan antes de asumir.
5. **Formato fijo** por tipo de documento, para que los scripts puedan validarlo.
6. **Decisión humana.** Los agentes preparan y cuestionan; no aprueban.

## Ejemplo de operación

A continuación se describe el recorrido de una reunión de planificación que termina con notas desordenadas:

1. La persona guarda las notas de la reunión en una carpeta de entrada, tal como se registraron.
2. El **Analista** genera el acta, los requisitos con su origen, las preguntas abiertas (por ejemplo, "¿quién aprueba el acceso?") y el glosario técnico.
3. En paralelo, el **Mentor** produce el glosario explicado y las dudas por aclarar para quien se está incorporando.
4. La persona revisa y corrige la salida del Analista y activa el traspaso al Arquitecto.
5. El **Arquitecto** redacta un ADR con contexto, alternativas, ventajas, desventajas y una recomendación marcada como propuesta.
6. El **Revisor** evalúa el ADR en cuanto a seguridad, dependencias entre proyectos y comportamiento ante un mayor volumen de uso, y entrega un informe de riesgos.
7. La persona decide, ajusta y aprueba. Las preguntas respondidas se cierran.
8. En la siguiente reunión, los agentes leen primero la documentación existente, por lo que el proyecto conserva memoria entre sesiones.

## Reparto entre IA y scripts

El criterio de reparto es el siguiente: si el resultado debe ser siempre idéntico, corresponde a un script; si requiere interpretación, corresponde a la IA.

| Tarea | Responsable | Motivo |
| --- | --- | --- |
| Entender notas desordenadas | IA | Requiere interpretar |
| Detectar contradicciones y huecos | IA | Requiere comparar y razonar |
| Proponer alternativas y redactar decisiones | IA | Requiere juicio y redacción |
| Evaluar riesgos de un diseño | IA | Requiere cuestionar supuestos |
| Explicar terminología según el nivel del lector | IA | Requiere adaptar el lenguaje |
| Transcribir audio (fase futura) | Script o herramienta | Tarea mecánica |
| Numerar documentos | Script | Mismo resultado siempre |
| Validar que cada documento tenga sus secciones | Script | Regla fija |
| Generar índices y mover archivos procesados | Script | Regla fija |

## Implementación técnica

Cada agente se define como un archivo de texto con extensión `.agent.md`, almacenado en la carpeta `.github/agents` del repositorio y creado en Visual Studio Code con el comando Chat: New Custom Agent. El encabezado del archivo (frontmatter, un bloque de configuración al inicio) define el nombre, la descripción, las herramientas permitidas y los traspasos (handoffs), que aparecen como botones al terminar la respuesta del agente. El cuerpo contiene las instrucciones en lenguaje natural. Los nombres exactos de los campos pueden variar entre versiones, por lo que deben verificarse en la documentación vigente.

Estructura propuesta del repositorio:

```text
proyecto-docs/
├── .github/
│   ├── copilot-instructions.md   (contexto general)
│   ├── agents/                   (Analista, Arquitecto, Revisor, Mentor)
│   └── prompts/                  (tareas repetibles)
├── inbox/                        (notas sin procesar)
├── docs/
│   ├── actas/
│   ├── requisitos/
│   ├── adr/
│   ├── riesgos/
│   ├── glosario.md
│   └── preguntas-abiertas.md
└── scripts/                      (numerar, validar, indexar)
```

Los documentos del repositorio funcionan como la memoria del proyecto: los agentes los leen antes de responder.

## Riesgos y mitigaciones

| Riesgo | Mitigación |
| --- | --- |
| Requisitos o explicaciones incorrectos expresados con seguridad | Etiquetar supuestos y lo no verificado; validación por una persona con experiencia antes de aprobar |
| Exposición de información sensible de las reuniones | Confirmar las herramientas aprobadas por la organización antes de procesar contenido sensible; no utilizar datos reales |
| Confianza excesiva en la salida de los agentes | La decisión final es siempre de una persona; el Revisor cuestiona cada propuesta |
| Documentación desactualizada | Los agentes actualizan los documentos afectados en cada reunión; los scripts validan el formato |
| Cambios en las funciones de GitHub Copilot | Verificar la documentación vigente antes de implementar; mantener las instrucciones en archivos de texto portables |
| Transcripción de audio sin herramienta aprobada | Iniciar solo con texto y documentos; incorporar el audio en una fase posterior |

## Plan de implementación por fases

| Fase | Alcance |
| --- | --- |
| 1. Base | Instrucciones generales del repositorio, estructura de carpetas y agente Analista probado con notas reales |
| 2. Cadena de diseño | Agentes Arquitecto y Revisor, con sus traspasos |
| 3. Aprendizaje | Agente Mentor y glosario compartido, validado por una persona con experiencia |
| 4. Automatización | Scripts de numeración, validación de formato e indexación |
| 5. Ampliación | Transcripción de audio, sujeta a la disponibilidad de una herramienta aprobada |

La fase 1 puede ejecutarse de forma independiente y ya aporta valor por sí sola. El orden de las fases siguientes puede ajustarse según la prioridad del proyecto.

## Fuentes

- [Custom agents in VS Code](https://code.visualstudio.com/docs/agent-customization/custom-agents)
- [Handoffs en VS Code](https://code.visualstudio.com/docs/copilot/customization/custom-chat-modes)
