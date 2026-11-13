sesion con el experto Pedro sobre como guardar el historial de prestamos - 26 nov
asistieron: Ana, Carla, Pedro (experto)

- Pedro dice que para que el historial sirva de auditoria se necesita linaje de datos: saber de donde sale cada dato del reporte
- tambien dijo que los procesos tienen que ser idempotentes, que si se reintenta no pase nada raro
- menciono el "patron outbox" para no perder eventos. no explico que es, solo dijo que "es lo normal ahora"
- hablo de la "capa ACME" que ya existe en la empresa y que hay que respetarla. nadie sabia a que se refiere
- dijo que CDC resuelve lo del historial. Carla pregunto si es lo de captura de cambios y Pedro dijo "mas o menos"
- Pedro: "el historial no se borra nunca". mas tarde dijo: "a los 2 anos se puede eliminar lo viejo"
- como ejemplo de un registro dijo: Sofia Ruiz, sofia.ruiz@empresa-ejemplo.com, prestamo #9001
- Pedro dijo que ACID es obligatorio para la tabla de prestamos pero que para el historial da lo mismo
- Ana pregunto por la diferencia entre ACID y la consistencia eventual. quedo para la proxima
