# Ficha proyecto: Olist

**Nombre:** Análisis de ventas y desempeño operativo de un marketplace de comercio electrónico (Olist)

**Especialidad:** Data Analytics

**Fuente de datos:** Brazilian E-Commerce Public Dataset by Olist (Kaggle)

**Enlace a la fuente:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

**Enlace al repositorio:** https://github.com/albert777mendoza/olist\_brazilian\_ecommerce\_analysis

## Objetivo del proyecto

Identificar qué categorías de productos, regiones y vendedores impulsan los ingresos y dónde se pierde valor, considerando factores como entregas tardías, reseñas negativas y cancelaciones.

El propósito es generar información útil para apoyar las decisiones de la gerencia comercial sobre dónde invertir, qué procesos mejorar y qué oportunidades de negocio priorizar.

## 3. Plan de trabajo

1. **Exploración inicial:** revisar las tablas, el volumen de datos, el período analizado y los estados de los pedidos.
2. **Preparación de datos:** evaluar valores nulos, duplicados, consistencia y relaciones entre tablas.
3. **Análisis de negocio:** utilizar SQL para investigar ingresos, categorías, vendedores, entregas, reseñas y cancelaciones.
4. **Evaluación y visualización:** validar los indicadores y comunicar los principales hallazgos mediante gráficos o un dashboard.
5. **Conclusiones y publicación:** formular recomendaciones, documentar las limitaciones y publicar el proyecto en GitHub y el portafolio.

## 4. Preguntas clave

- ¿Qué categorías de productos, regiones y vendedores generan mayores ingresos?
- ¿Qué relación existe entre las entregas tardías, las reseñas negativas y la experiencia del cliente?
- ¿Qué limitaciones presentan los datos y cómo podrían afectar las recomendaciones?

## 5. Qué se hizo y cómo

### Etapa 0. Preparación técnica

- Se creó la base de datos `olist` en PostgreSQL.
- Se cargaron nueve tablas del dataset.
- Se prepararon scripts SQL para crear las tablas y validar sus relaciones.
- Se configuró Git para el control de versiones del proyecto.
- Se creó un archivo `.gitignore` para excluir los archivos de datos originales del repositorio.
- Se inició la exploración del volumen de registros mediante SQL.

**Avance registrado:** se verificaron los conteos de las nueve tablas. La tabla `orders` contiene 99.441 registros; `order_items`, 112.650; `order_payments`, 103.886; y `order_reviews`, 99.224.

### Etapa 1. Exploración inicial

**Actividad 1. Conteo de registros por tabla**

Se ejecutaron consultas SQL en PostgreSQL para verificar el volumen de registros de las nueve tablas del dataset. La tabla `orders` contiene 99.441 pedidos.

**Actividad 2. Rango de fechas y completitud**

Se consultaron las fechas mínima y máxima de compra y se verificó la presencia de fechas faltantes en la tabla `orders`.

**Resultados:**

- Primer pedido registrado: 4 de septiembre de 2016.
- Último pedido registrado: 17 de octubre de 2018.
- Total de pedidos: 99.441.
- Pedidos con fecha de compra: 99.441.
- Pedidos sin fecha de compra: 0.

**Interpretación:** el dataset permite estudiar la evolución temporal de los pedidos durante el período observado. No se encontraron fechas de compra faltantes en la tabla `orders`.

**Herramientas utilizadas:** PostgreSQL y SQL. Las consultas están documentadas en `sql/01_exploracion.sql`.

**Actividad 3. Distribución de pedidos por estado**

Se agruparon los pedidos según `order_status` mediante SQL, utilizando `GROUP BY` y `COUNT(*)`.

**Resultados principales:**

- Pedidos entregados (`delivered`): 96.478 (97,02 %).
- Pedidos cancelados (`canceled`): 625 (0,63 %).
- Pedidos no disponibles (`unavailable`): 609 (0,61 %).
- Total de pedidos analizados: 99.441.

**Interpretación:** la gran mayoría de los pedidos figura como entregada. Sin embargo, los estados cancelado y no disponible representan 1.234 registros que conviene examinar con mayor detalle.

**Limitación:** el estado del pedido, por sí solo, no permite determinar la causa de la cancelación ni calcular el impacto económico.

**Herramientas utilizadas:** PostgreSQL y SQL. Consulta documentada en `sql/01_exploracion.sql`.

**Actividad 4. Evolución mensual de los pedidos**

Se utilizó SQL para agrupar los pedidos por mes de compra, contar los registros de cada período y ordenar los resultados cronológicamente.

**Resultados principales:**

- Se identificaron 25 meses distintos con registros.
- Noviembre de 2017 fue el mes con mayor volumen, con 7.544 pedidos.
- Entre enero y agosto de 2018, el volumen mensual se mantuvo aproximadamente entre 6.000 y 7.300 pedidos.
- Se observaron volúmenes muy bajos en algunos meses al inicio y al final del período analizado.

**Interpretación:** el volumen de pedidos aumentó considerablemente durante el período observado. Noviembre de 2017 destaca por su actividad, lo que podría investigarse posteriormente para comprender posibles patrones comerciales o estacionales.

**Precaución:** los pocos pedidos registrados en septiembre de 2016, noviembre y diciembre de 2016, y septiembre y octubre de 2018 requieren revisar la cobertura temporal del dataset antes de interpretar tendencias. La ausencia de un mes en el resultado significa que no hay registros para ese mes en esta tabla; no demuestra por sí sola la causa.

**Herramientas:** PostgreSQL y SQL. Consulta registrada en `sql/01_exploracion.sql`.

**Estado:** exploración inicial completada.

### Etapa 2. Calidad de datos

**Actividad: revisión de valores nulos en `orders`**

Se analizaron 99.441 registros de la tabla `orders`. No se encontraron valores nulos en `order_id`, `customer_id`, `order_status`, `order_purchase_timestamp` ni `order_estimated_delivery_date`.

Se identificaron 2.965 registros sin fecha real de entrega, equivalentes aproximadamente al 2,98 % del total. Este resultado requiere contrastarse con el estado de los pedidos antes de determinar si corresponde a una situación esperada del proceso o a un problema de calidad de datos.

**Actividad: análisis de fechas de entrega faltantes por estado**

Se cruzaron los registros sin fecha real de entrega con el estado de cada pedido. Se encontraron 2.965 pedidos sin fecha de entrega registrada. La mayoría corresponde a estados distintos de `delivered`, lo que puede ser coherente con pedidos no completados o cuya entrega aún no se registra.

Se identificaron 8 pedidos con estado `delivered` sin fecha real de entrega. Estos casos se consideran inconsistencias potenciales y requieren validación adicional antes de calcular indicadores de entrega.

**Conclusión:** no todos los valores nulos representan errores; su interpretación depende del contexto del negocio y del estado del pedido. Decisión: los pedidos sin fecha real de entrega se conservan y se excluyen solo de los cálculos de tiempo de entrega y de entregas tardías.

### Investigación de ocho pedidos entregados sin fecha real

**Consulta 3. Identificación de registros inconsistentes**

Se identificaron ocho pedidos con estado `delivered` que no tenían registrada la fecha real de entrega. Los ocho tenían fecha de compra y fecha estimada de entrega.

**Consulta 4. Verificación de artículos asociados**

Se cruzaron los ocho pedidos con la tabla `order_items` mediante `LEFT JOIN`. Todos tenían un artículo registrado. El valor total de los productos fue de R$ 1.249,18 y el flete sumó R$ 129,74.

**Consulta 5. Verificación de pagos**

Se cruzaron los ocho pedidos con la tabla `order_payments`. Todos tenían un registro de pago. La suma de los pagos registrados fue de R$ 1.378,92, coincidente con el valor combinado de productos y fletes.

**Conclusión**

Los ocho pedidos presentan una inconsistencia entre su estado (`delivered`) y la ausencia de fecha real de entrega. Sin embargo, todos tienen artículos y pagos registrados. Esta evidencia permite caracterizar la anomalía, pero no determinar su causa, que queda sin establecer. No se modificaron ni eliminaron registros. Decisión: se conservan los ocho pedidos y se excluyen solo de los cálculos de tiempo de entrega y de entregas tardías.

**Actividad: búsqueda de líneas de artículos duplicadas**

Se agruparon los registros de `order_items` por la combinación `order_id` y `order_item_id`. La consulta no devolvió resultados, por lo que no se encontraron combinaciones duplicadas según estos dos campos.

**Conclusión:** la tabla `order_items` no presenta duplicados de esta combinación identificadora según la prueba realizada.

**Actividad: búsqueda de identificadores de productos duplicados**

Se agruparon los registros de `products` por `product_id` y se buscaron identificadores con más de una aparición. La consulta no devolvió resultados.

**Conclusión:** no se encontraron identificadores de producto duplicados en la tabla `products` según esta prueba.

**Actividad: búsqueda de identificadores de vendedores duplicados**

Se agruparon los registros de `sellers` por `seller_id` y se buscaron identificadores con más de una aparición. La consulta no devolvió resultados.

**Conclusión:** no se encontraron identificadores de vendedor duplicados en la tabla `sellers` según esta prueba.

**Actividad: búsqueda de posibles duplicados en los registros de pago**

Se agruparon los registros de `order_payments` por `order_id` y `payment_sequential` para identificar combinaciones repetidas. La consulta no devolvió resultados.

**Conclusión:** no se encontraron combinaciones duplicadas de pedido y secuencia de pago según esta prueba.

**Actividad: detección y cuantificación de identificadores de reseña repetidos**

Se agruparon los registros de `order_reviews` por `review_id` y se identificaron 789 identificadores con más de una aparición. Estos corresponden a 1.603 registros, de los cuales 814 son excedentes respecto a una aparición por identificador.

Los registros excedentes representan aproximadamente el 0,82 % de las 99.224 filas de la tabla.

**Conclusión:** se detectaron identificadores de reseña repetidos. Las actividades siguientes analizan si las filas asociadas contienen información idéntica o diferente, antes de clasificarlos como errores o eliminar registros.

**Actividad: investigación de identificadores de reseña repetidos**

Se examinó el identificador `1fb4ddc969e6bea80e38deec00393a6f`, que aparece tres veces en `order_reviews`. Las tres filas comparten puntuación y fechas de creación y respuesta, pero están asociadas a tres `order_id` diferentes.

Mediante un `LEFT JOIN` con `orders`, se verificó que los tres pedidos existen y tienen estado `delivered`, con fechas reales de entrega registradas. Los pedidos se realizaron el 26 de julio de 2017, con pocos segundos de diferencia.

**Conclusión:** el identificador de reseña se asocia a varios pedidos existentes. La causa de esta repetición no está determinada. El análisis posterior evalúa si representa un problema de calidad. No se modificaron registros.

**Actividad: análisis de identificadores de reseña asociados a varios pedidos**

Se analizaron los 789 identificadores de reseña que aparecen más de una vez en la tabla `order_reviews`.

La distribución encontrada fue:

- 764 identificadores asociados a 2 pedidos distintos.
- 25 identificadores asociados a 3 pedidos distintos.

En total, se identificaron 1.603 registros asociados a identificadores repetidos, con 814 registros excedentes respecto a una aparición por identificador.

**Conclusión:** existen identificadores de reseña relacionados con varios pedidos. La consistencia de los demás campos y el efecto sobre los análisis de satisfacción se evalúan en las actividades siguientes. No se eliminaron ni modificaron registros.

**Actividad: comparación detallada de reseñas con identificadores repetidos**

Se inspeccionó el identificador `0ec0f24aa34a9b25fb0f7b32034965ce`, asociado a dos pedidos diferentes. Ambas filas presentan la misma puntuación (5), el mismo comentario (“Entrega muito rápida.”), la misma fecha de creación y la misma fecha de respuesta.

El resultado confirma que, en este caso, un mismo identificador y contenido de reseña están relacionados con dos pedidos distintos.

**Conclusión:** los identificadores repetidos no deben tratarse automáticamente como filas idénticas ni eliminarse sin evaluar su efecto en los resultados. Decisión: la unidad de análisis de la satisfacción es el pedido, con el promedio de sus reseñas. No se modificaron ni eliminaron datos.

**Actividad: comparación del contenido de los identificadores de reseña repetidos**

Se compararon los campos `review_score`, `review_comment_title`, `review_comment_message`, `review_creation_date` y `review_answer_timestamp` para los 789 identificadores de reseña que aparecen más de una vez.

Los 789 identificadores presentaron una sola combinación de valores en los campos analizados; ninguno presentó varias combinaciones. Sin embargo, los identificadores están asociados a pedidos distintos.

**Conclusión:** existe un patrón consistente de reutilización de identificadores de reseña con contenido coincidente entre pedidos diferentes. La causa no está determinada. La actividad siguiente evalúa el efecto de este patrón sobre el conteo de reseñas. No se modificaron ni eliminaron registros.

**Actividad: evaluación del efecto de los identificadores de reseña repetidos**

Se comparó la distribución de puntuaciones de `order_reviews` utilizando todas las filas y contando una sola vez cada `review_id`.

La tabla contiene 99.224 filas y 98.410 identificadores únicos, con una diferencia de 814 registros. Las diferencias por puntuación fueron: 142 para la puntuación 1, 37 para la puntuación 2, 82 para la puntuación 3, 135 para la puntuación 4 y 418 para la puntuación 5.

**Conclusión:** los identificadores repetidos afectan el conteo de reseñas por puntuación. La comparación de porcentajes de la actividad siguiente evalúa si también alteran la interpretación de la satisfacción del cliente. El conteo por `review_id` único es una alternativa de análisis, no una corrección definitiva del conjunto de datos.

**Actividad: comparación de la distribución porcentual de puntuaciones**

Se compararon los porcentajes de las puntuaciones de `order_reviews` contando todas las filas y contando una sola vez cada `review_id`.

La puntuación 5 representó el 57,78 % de las filas y el 57,83 % de los identificadores únicos. La diferencia fue de +0,05 puntos porcentuales. Para la puntuación 1, el porcentaje pasó de 11,51 % a 11,46 %, una variación de −0,05 puntos porcentuales. Las variaciones de las demás puntuaciones también fueron pequeñas.

**Conclusión:** los identificadores repetidos afectan el número de registros, pero su efecto sobre la distribución porcentual general de puntuaciones es reducido. Esto no descarta posibles efectos en otros indicadores. Se conserva la información original y se documenta la diferencia metodológica, sin eliminar registros ni atribuir una causa definitiva a las repeticiones.

**Actividad: validación de calidad en `order_items`**

Se revisaron 112.650 registros de la tabla `order_items`. No se encontraron valores nulos en `order_id`, `product_id`, `seller_id`, `price` ni `freight_value`. Tampoco se identificaron precios iguales o inferiores a cero ni valores negativos en el flete.

**Conclusión:** los campos evaluados no presentan anomalías de nulidad o valores no positivos. Este resultado respalda su uso inicial para los análisis económicos, sin sustituir las validaciones posteriores de consistencia y agregación. No se modificaron registros.

**Actividad: validación de calidad en `order_payments`**

Se revisaron 103.886 registros de pagos. No se encontraron valores nulos en los campos evaluados. Se identificaron nueve registros con `payment_value` igual a cero: seis de tipo `voucher` y tres de tipo `not_defined`. No se encontraron pagos negativos. Dos de los nueve registros pertenecen al mismo pedido.

También se identificaron dos registros de tipo `credit_card` con `payment_installments` igual a cero, por valores de R$ 129,94 y R$ 58,69, respectivamente.

**Conclusión:** los pagos con valor cero y los registros de tarjeta con cero cuotas no se clasifican como errores sin contexto adicional. Decisión: las ventas se calculan desde order\_items y los pagos se agregan por pedido antes de unirlos. Se conservaron los datos originales y no se realizaron modificaciones.

**Actividad: análisis de la distribución de tipos de pago**

Se agruparon los 103.886 registros de `order_payments` por `payment_type`, calculando la cantidad de registros, los pedidos distintos y el valor total.

La tarjeta de crédito fue el método predominante, con 76.795 registros y un valor acumulado de R$ 12.542.084,19. Le siguieron `boleto`, con 19.784 registros y R$ 2.869.361,27; `voucher`, con 5.775 registros y R$ 379.436,87; y `debit_card`, con 1.529 registros y R$ 217.989,79. La categoría `not_defined` presentó tres registros con valor total de R$ 0,00.

**Conclusión:** existen diferencias entre el número de registros de pago y el número de pedidos distintos, especialmente en `voucher` y `credit_card`. Los indicadores económicos deberán calcularse con la granularidad adecuada para evitar el doble conteo. No se modificaron registros.

**Actividad: identificación de pedidos con varios tipos de pago**

Se identificaron 2.246 pedidos que presentan más de un tipo de pago en `order_payments`, mediante la agrupación por `order_id` y el conteo de valores distintos de `payment_type`.

**Conclusión:** un pedido puede estar asociado a varios métodos de pago. Por tanto, los análisis por pedido deben considerar la posibilidad de pagos combinados y evitar contar cada registro de pago como una compra independiente. Este resultado describe la estructura de los datos y no constituye por sí solo una anomalía. No se modificaron registros.

**Actividad: revisión de valores nulos en `products`**

Se revisaron 32.951 productos. No se encontraron valores nulos en `product_id`. Se identificaron 610 registros sin categoría, longitud del nombre, longitud de la descripción ni cantidad de fotografías. Estos valores representan aproximadamente el 1,85 % del catálogo.

También se encontraron dos productos sin peso ni dimensiones físicas registradas (`product_weight_g`, `product_length_cm`, `product_height_cm` y `product_width_cm`).

**Conclusión:** los campos faltantes pueden afectar los análisis de categorías y características físicas. La verificación siguiente comprueba si los valores nulos de cada grupo corresponden a los mismos productos. No se eliminaron ni modificaron registros.

**Verificación de coincidencia de valores nulos**

Se confirmó que los 610 productos sin categoría son exactamente los mismos que presentan valores nulos en la longitud del nombre, la longitud de la descripción y la cantidad de fotografías. Por tanto, los cuatro campos faltantes se concentran en el mismo grupo de registros, equivalente aproximadamente al 1,85 % del catálogo.

**Conclusión:** se trata de un grupo identificable de productos con información descriptiva incompleta. Se conservarán los registros y, para los análisis por categoría, se deberá contemplar una categoría explícita como “Sin categoría” o reportar por separado los productos sin clasificación.

**Actividad: validación de traducciones de categorías**

Se compararon las categorías no nulas de `products` con la tabla `product_category_name_translation` mediante un `LEFT JOIN`. Se identificaron dos categorías sin correspondencia en la tabla de traducciones: `pc_gamer` y `portateis_cozinha_e_preparadores_de_alimentos`.

**Conclusión:** estas categorías no deben interpretarse como categorías inexistentes o inválidas; únicamente carecen de una traducción registrada en la tabla auxiliar. Para los informes en inglés, se deberá decidir cómo presentarlas sin perder su identificación original.

**Actividad: validación de peso y dimensiones de productos**

Se revisaron los campos físicos de los 32.951 productos. Se encontraron cuatro registros con peso igual o inferior a cero y dos productos sin peso ni dimensiones físicas registradas. No se identificaron valores iguales o inferiores a cero en largo, alto o ancho.

**Conclusión:** los registros identificados requieren revisión antes de utilizar estas variables en análisis logísticos. No se modificaron ni eliminaron datos, ya que es necesario inspeccionar los casos específicos antes de determinar su tratamiento.

**Inspección de productos con peso no positivo**

Se identificaron cuatro productos de la categoría `cama_mesa_banho` con un peso registrado de 0 gramos. Los cuatro presentan las mismas dimensiones: 30 cm de largo, 25 cm de alto y 30 cm de ancho.

**Conclusión:** estos registros son candidatos a revisión por posible inconsistencia en el peso. Se conservaron los valores originales y no se imputaron pesos estimados, ya que no se dispone de evidencia suficiente para determinar los valores correctos.

**Inspección de productos con datos físicos faltantes**

Se identificaron dos productos sin peso ni dimensiones físicas registradas. Uno pertenece a la categoría `bebes`; el otro tampoco tiene una categoría registrada.

**Conclusión:** los dos registros presentan información incompleta que limita su uso en análisis logísticos. El segundo también debe considerarse en la revisión de categorías faltantes. Se conservaron los registros originales, sin imputar valores ni eliminar productos.

**Actividad: validación de campos nulos en vendedores**

Se revisaron los 3.095 registros de `sellers`. No se encontraron valores nulos en `seller_id`, `seller_zip_code_prefix`, `seller_city` ni `seller_state`.

**Conclusión:** los campos básicos de identificación y ubicación examinados están completos. Esta comprobación no garantiza por sí sola la validez geográfica de los datos.

**Actividad: validación de identificadores únicos de vendedores**

Se agruparon los registros de `sellers` por `seller_id` y se buscaron identificadores asociados a más de un registro. No se encontraron duplicados.

**Conclusión:** los 3.095 vendedores tienen identificadores únicos y los campos básicos de identificación y ubicación examinados no presentan valores nulos. La validación de esta tabla no requirió modificaciones.

**Actividad: validación de campos nulos en clientes**

Se revisaron los 99.441 registros de `customers`. No se encontraron valores nulos en `customer_id`, `customer_unique_id`, `customer_zip_code_prefix`, `customer_city` ni `customer_state`.

**Conclusión:** los campos básicos de identificación y ubicación examinados están completos. La cantidad de registros no debe interpretarse directamente como cantidad de personas únicas, ya que `customer_unique_id` permite identificar clientes que pueden estar asociados a varios pedidos.

**Actividad: comparación de identificadores de clientes**

Se comparó el total de registros de `customers` con la cantidad de identificadores distintos. Los 99.441 registros tienen valores únicos de `customer_id`, mientras que existen 96.096 valores distintos de `customer_unique_id`.

**Conclusión:** la tabla contiene menos clientes únicos que registros. Esta diferencia sugiere que algunos clientes están representados en varios registros. Para medir la recurrencia de compra correctamente, será necesario relacionar los pedidos con `customer_unique_id` y contar los pedidos por cliente, en lugar de interpretar la diferencia como el número de clientes recurrentes.

**Actividad: identificación de customer\_unique\_id repetidos**

Se agruparon los registros de `customers` por `customer_unique_id` y se identificaron valores presentes en varios registros. En la muestra de los diez identificadores con mayor frecuencia, el máximo fue de 17 registros para un mismo identificador.

**Conclusión:** los registros repetidos pueden corresponder a un mismo cliente asociado a diferentes pedidos. Esta consulta identifica posibles casos de recurrencia, pero no demuestra por sí sola la cantidad de compras realizadas. La recurrencia se validará relacionando `customers` con `orders`.

**Actividad: validación de recurrencia de compra**

Se relacionó `customers` con `orders` mediante `customer_id` y se contó el número de pedidos por `customer_unique_id`. Se encontraron clientes asociados a varios pedidos; el mayor valor observado en la muestra de diez clientes fue de 17 pedidos.

**Conclusión:** `customer_unique_id` permite analizar la recurrencia entre pedidos, mientras que `customer_id` relaciona cada registro de cliente con sus pedidos. Para cuantificar la recurrencia general, se calculará cuántos clientes realizaron más de un pedido y qué proporción representan del total de clientes únicos.

**Actividad: medición de recurrencia de compra**

Se calcularon los pedidos por `customer_unique_id`, relacionando las tablas `customers` y `orders` mediante `customer_id`. De los 96.096 clientes únicos, 93.099 realizaron un solo pedido y 2.997 realizaron más de uno. La tasa de recurrencia observada fue del 3,12 %.

**Conclusión:** la mayoría de los clientes únicos registrados realizó una sola compra durante el período analizado. Este indicador puede orientar futuras preguntas sobre recompra y fidelización, pero no permite establecer las causas de la recurrencia ni asumir que los clientes no volvieron a comprar después del período disponible.

**Actividad: validación del rango de puntuaciones de reseñas**

Se revisaron las 99.224 filas de `order_reviews`. No se encontraron puntuaciones nulas ni valores inferiores a 1 o superiores a 5. La puntuación mínima fue 1 y la máxima, 5.

**Conclusión:** las puntuaciones respetan la escala esperada de 1 a 5. Sin embargo, antes de calcular indicadores de satisfacción, debe considerarse que existen `review_id` repetidos asociados a distintos pedidos, situación que puede afectar el conteo de reseñas según la unidad de análisis elegida.

**Actividad: validación de fechas de reseñas**

Se revisaron las fechas de creación y respuesta de las 99.224 filas de `order_reviews`. No se encontraron valores nulos en estos campos ni registros en los que la respuesta tuviera una fecha anterior a la creación de la reseña.

**Conclusión:** las fechas examinadas superan los controles de integridad realizados. Podrán utilizarse en análisis temporales, teniendo presente la duplicidad previamente identificada en `review_id` y la necesidad de definir la unidad de análisis.

**Actividad: validación de correspondencia geográfica de clientes**

Se compararon los códigos postales distintos de `customers` con los códigos postales disponibles en `geolocation`. De los 14.994 códigos postales distintos de clientes, 14.837 encontraron coincidencia y 157 no tuvieron correspondencia exacta. La cobertura por código postal fue del 98,95 %.

**Conclusión:** la mayoría de los códigos postales de clientes tiene correspondencia en la tabla geográfica. Los códigos sin coincidencia deben investigarse antes de realizar análisis espaciales; su ausencia no demuestra por sí sola que sean inválidos. La consulta se realizó a nivel de código postal distinto, no a nivel de cliente individual.

**Actividad: validación geográfica por código postal y estado**

Se compararon los códigos postales distintos de `customers` con `geolocation`, exigiendo coincidencia tanto del código postal como del estado. En los resultados visibles, DF presentó la mayor diferencia: 398 de 465 códigos postales encontraron coincidencia, mientras que 67 no coincidieron bajo ambos criterios.

**Conclusión:** la cobertura geográfica varía por estado. Las diferencias requieren investigación antes de atribuirlas a errores en los datos. No se modificaron registros ni se asumió que los códigos sin coincidencia fueran inválidos.

**Resultado detallado de la validación geográfica por estado**

La consulta devolvió 27 estados y unidades federativas. Se identificaron diferencias entre los códigos postales distintos de `customers` y los códigos que encuentran coincidencia en `geolocation` para el mismo estado. La diferencia más destacada corresponde a DF, con 465 códigos postales de clientes, de los cuales 398 encontraron coincidencia y 67 no.

**Conclusión:** la cobertura geográfica no es uniforme en todos los estados. Los códigos sin coincidencia se consideran casos pendientes de validación, no errores confirmados. No se modificaron los datos originales.

**Inspección de pedidos con entrega al transportista anterior a la compra**

Se inspeccionó una muestra de 20 de los 166 pedidos identificados. En los casos observados, la fecha de entrega al transportista era anterior a la compra por intervalos generalmente breves, de minutos o aproximadamente una hora.

**Conclusión:** la muestra sugiere una posible inconsistencia en el registro cronológico de los eventos. No permite determinar la causa ni confirmar que los 166 casos sigan exactamente el mismo patrón. Se conservaron las fechas originales y no se aplicaron correcciones.

**Consulta 49. Inconsistencias entre compra y entrega al transportista**

Se identificaron 166 pedidos cuya fecha de entrega al transportista es anterior a la fecha de compra. La diferencia promedio fue de 1.562,37 minutos (aproximadamente 26 horas), con un mínimo de 24 segundos y un máximo aproximado de 171 días.

**Conclusión:** existen inconsistencias temporales que deben considerarse al analizar los tiempos logísticos. La revisión no permite determinar su causa exacta, por lo que se conservaron los registros sin modificaciones.

### Etapa 3. Análisis de negocio

**Consulta 50. Indicadores generales de ventas**

Se analizaron los registros de `order_items`, que contienen 112.650 artículos asociados a 98.666 pedidos distintos. La suma del valor de los productos (`price`) fue de R$ 13.591.643,70; los fletes (`freight_value`) sumaron R$ 2.251.909,54. El valor combinado fue de R$ 15.843.553,24 y el precio promedio por artículo fue de R$ 120,65.

**Conclusión:** los productos representan la mayor parte del valor registrado y los fletes constituyen un componente relevante del costo de compra para el cliente. Estos importes son indicadores descriptivos, no medidas de utilidad o rentabilidad.

**Consulta 51. Pedidos sin artículos asociados**

Se identificaron 775 pedidos de `orders` que no tienen registros relacionados en `order_items`, equivalentes aproximadamente al 0,78 % de los 99.441 pedidos registrados. La distribución fue: 603 `unavailable`, 164 `canceled`, 5 `created`, 2 `invoiced` y 1 `shipped`.

**Conclusión:** la mayoría corresponde a pedidos no disponibles o cancelados. Los pedidos en estados `created`, `invoiced` y `shipped` requieren una revisión adicional para determinar si representan situaciones particulares o inconsistencias. No se modificaron los datos.

**Consulta 52. Revisión de pedidos sin artículos en estados especiales**

Se inspeccionaron ocho pedidos sin registros asociados en `order_items`: cinco con estado `created`, dos `invoiced` y uno `shipped`. Los cinco pedidos `created` no tienen fecha de aprobación ni fechas reales de entrega. Los dos `invoiced` tienen fecha de aprobación, pero no fechas de entrega. El pedido `shipped` registra una fecha de entrega al transportista, aunque carece de artículos asociados y de fecha de entrega al cliente.

**Conclusión:** estos registros presentan situaciones diferentes y no deben clasificarse automáticamente como errores. El pedido `shipped` merece atención especial. Se requiere más contexto para establecer las causas y no se modificaron los registros.

**Consulta 53. Pagos asociados a pedidos sin artículos**

Se revisaron ocho pedidos sin registros asociados en `order_items`. Los ocho tienen un registro de pago, por un valor conjunto de R$ 915,06: cinco pedidos `created` suman R$ 688,10; dos `invoiced`, R$ 149,23; y uno `shipped`, R$ 77,73.

**Conclusión:** la existencia de pagos registrados junto con la ausencia de artículos constituye una situación que requiere investigación adicional. Los datos examinados no permiten establecer si los pagos fueron liquidados ni explicar la ausencia de artículos. No se modificaron los registros.

**Consulta 54. Valor de artículos y fletes por estado del pedido**

Se agregaron los artículos por pedido antes de relacionarlos con `orders`, para evitar duplicar importes. Los pedidos `delivered` concentran R$ 13.221.498,11 en productos y R$ 2.198.275,64 en fletes. Se identificaron 461 pedidos `canceled` con artículos asociados, por R$ 95.235,27 en productos, y 6 pedidos `unavailable` con artículos asociados, por R$ 2.007,69.

**Conclusión:** el estado del pedido debe considerarse al interpretar los importes. El valor asociado a pedidos cancelados o no disponibles no equivale automáticamente a una pérdida ni a dinero cobrado. Es necesario contrastarlo con los registros de pagos.

**Consulta 55. Pagos asociados a pedidos cancelados**

Los 625 pedidos con estado `canceled` tienen registros asociados en `order_payments`. La suma de los valores de pago registrados para estos pedidos es de R$ 143.255,60.

**Conclusión:** la existencia de pagos asociados a pedidos cancelados justifica investigar el tratamiento de esos pagos. Este importe no puede interpretarse automáticamente como pérdida económica, porque la consulta no identifica reembolsos, reversos ni liquidaciones definitivas.

**Consulta 56. Tipos de pago en pedidos cancelados**

Se analizaron los pagos registrados en los 625 pedidos con estado `canceled`, por un valor total de R$ 143.255,60. La tarjeta de crédito representó R$ 97.375,31; los vouchers, R$ 25.664,92; los boletos, R$ 17.504,10; las tarjetas débito, R$ 2.711,27; y el tipo `not_defined`, R$ 0,00.

**Conclusión:** la tarjeta de crédito concentra el mayor valor de pagos registrados en pedidos cancelados. Estos importes no permiten determinar cuánto dinero fue efectivamente cobrado, reembolsado o perdido. Un pedido puede tener varios registros de pago, por lo que deben distinguirse los registros de pago de los pedidos únicos.

#### Hallazgos de calidad de datos y decisiones tomadas

| Hallazgo | Decisión |
| --- | --- |
| 8 pedidos `delivered` sin fecha real de entrega | Se conservan; se excluyen solo de los cálculos de tiempo de entrega y de entregas tardías |
| 166 pedidos con entrega al transportista anterior a la compra | Se conservan; esa fecha no se usa en los cálculos logísticos |
| 789 `review_id` repetidos en pedidos distintos | Se conservan; la satisfacción se analiza por pedido, promediando las reseñas por `order_id` |
| 547 pedidos con más de una reseña | La puntuación del pedido es el promedio de sus reseñas para evitar duplicar pedidos al unir tablas |
| Pedidos `canceled` y `unavailable` | Se excluyen de las ventas y se analizan por separado |
| 610 productos sin categoría | Se reportan como “Sin categoría” |
| 2 categorías sin traducción | Se muestran con su nombre original |
| Pagos en cero, tarjetas con 0 cuotas y varios pagos por pedido | Las ventas se calculan desde `order_items`; los pagos se agregan por pedido antes de unirlos |
| 157 códigos postales sin geolocalización | Se conservan; el análisis geográfico se realiza por estado |

#### Decisiones metodológicas

- **Ventas del análisis de negocio:** suma de `price` de los artículos asociados a pedidos que no están en estado `canceled` ni `unavailable`, mediante la vista `v_items_validos`. El flete se analiza por separado.
- **Indicadores generales:** la consulta 50 resume los artículos y valores registrados en `order_items` sin filtrar por estado del pedido. Sus cifras deben distinguirse de las ventas calculadas con `v_items_validos`.
- **Entregas:** se consideran los pedidos `delivered` con fecha real de entrega registrada. La consulta de entregas tardías utiliza 96.470 pedidos de los 96.478 que figuran como entregados. Una entrega se considera tardía cuando la fecha real supera la fecha estimada.
- **Satisfacción:** cuando un pedido tiene varias reseñas, se utiliza el promedio de sus puntuaciones para obtener una puntuación por pedido y evitar multiplicar pedidos al unir tablas.
- **Análisis por estado:** se excluyen los estados con menos de 100 pedidos entregados en las comparaciones correspondientes, para reducir el riesgo de conclusiones basadas en muestras pequeñas.
- **Pagos de pedidos cancelados:** los importes corresponden a pagos registrados; no permiten determinar por sí solos cuánto se cobró efectivamente, se reembolsó o se perdió.

**Organización de scripts:**  el script de creación de la vista v_items_validos debe ejecutarse antes de las consultas que la utilizan (consultas 57–60). Las consultas 61–66 no dependen de esa vista, según el SQL revisado. Los scripts SQL del proyecto se organizan en:

00_esquema_y_carga.sql: creación de tablas y carga inicial de datos.
01_exploracion.sql: exploración inicial del dataset.
02_calidad_datos.sql: validaciones de calidad, consistencia e investigación de anomalías.
03_analisis_negocio.sql: consultas de análisis de negocio e indicadores.
04_modelo_bi.sql: creación de las vistas utilizadas en Power BI (bi_items, bi_pedidos, bi_clientes, bi_productos y bi_vendedores).


## 6. Resultados

| Indicador | Cifra | Interpretación para el negocio |
| --- | --- | --- |
| Crecimiento de ventas (ene-ago 2018 vs. 2017) | ≈ +138 % (de R$ 3,08 M a R$ 7,34 M) | Las ventas más que se duplicaron, pero se estancaron desde enero de 2018 (R$ 0,84 a 0,99 M por mes) |
| Mes pico | Nov 2017: R$ 1,00 M en 7.421 pedidos | Posible efecto de temporada; no confirmado con los datos |
| Concentración por categoría | Top 10 ≈ 62 % de las ventas | `watches_gifts` vende unos R$ 214 por pedido frente a R$ 110 de `bed_bath_table` |
| Concentración geográfica | SP 38,3 %; SP, RJ y MG ≈ 63 % | Dependencia del sudeste |
| Peso del flete | 13,8 % de las ventas en SP; 24 a 28 % en RR, MA, RO, AM y PI | El flete encarece la compra en estados lejanos; algunos tienen pocos pedidos |
| Concentración de vendedores | 540 de 3.053 (≈ 18 %) generan el 80 % de las ventas | Pocas cuentas sostienen gran parte de las ventas |
| Entregas tardías | 8,11 % (7.826 de 96.470); entrega media de 12,6 días | Una de cada doce entregas incumple la fecha prometida |
| Entrega y reseñas | Puntuación 4,29 a tiempo vs. 2,57 tardía; reseñas negativas 9,2 % vs. 54,0 % | Asociación fuerte, no prueba de causalidad |
| Tardanza por estado | AL 23,9 %, MA 19,7 %, RJ 13,5 % vs. SP 5,9 % y PR 5,0 % | La tardanza varía por estado; SP y RJ reúnen cerca de la mitad de las entregas tardías |
| Promesa vs. realidad | Margen de ≈ 19 días en AM y RO; de ≈ 8 a 9 días en AL y MA | Diferencias descriptivas entre estados; no demuestran que el margen prometido sea la causa de las tasas de tardanza |
| Cancelaciones | 625 pedidos (0,63 %); R$ 143.255,60 en pagos registrados | No equivale a pérdida: no hay datos de reembolsos |
| Recurrencia (análisis complementario) | 3,12 % de los clientes únicos (2.997 de 96.096) compró más de una vez | Describe recompra dentro del período observado |
| Reseñas negativas y entregas tardías (consulta 66) | 4.136 de 12.236 pedidos con puntuación promedio ≤ 2 llegaron tarde (33,80 %) | Aproximadamente uno de cada tres pedidos con reseña negativa fue entregado tarde; asociación descriptiva, no causalidad |

Los resultados de entregas y satisfacción se calculan por pedido cuando corresponde, promediando las reseñas asociadas a cada `order_id`. Las consultas 50 y 54 describen valores registrados en `order_items` y pueden incluir artículos vinculados a pedidos cancelados o no disponibles; no deben confundirse con las ventas válidas de las consultas que utilizan `v_items_validos`. Los importes de ventas representan el valor de los productos (`price`), sin sumar el flete ni descontar costos.

### 6.1 Preparación y validación del modelo dimensional para BI

Se crearon cinco vistas SQL en PostgreSQL para preparar los datos que alimentan el dashboard en Power BI.

**Diseño del modelo**

Se utiliza un modelo dimensional con dos tablas de hechos de distinta granularidad y tres dimensiones:

| Vista | Granularidad | Propósito |
| --- | --- | --- |
| `bi_items` | Un artículo por pedido | Analizar ventas, precios, fletes, productos y vendedores. |
| `bi_pedidos` | Un pedido | Analizar estados, pagos, tiempos de entrega y puntuaciones. |
| `bi_clientes` | Un cliente registrado | Analizar ubicación geográfica y región. |
| `bi_productos` | Un producto | Analizar categorías de productos. |
| `bi_vendedores` | Un vendedor | Analizar ubicación y desempeño comercial. |

La tabla `Calendario` se creó en Power BI para el análisis temporal.

**Decisiones de modelado**

- `bi_items` excluye los pedidos cancelados y no disponibles, siguiendo los criterios de la vista `v_items_validos`.
- `bi_pedidos` conserva todos los pedidos, incluidos los cancelados, para permitir el análisis por estado y de los pagos registrados.
- Las reseñas y los pagos se agregan por pedido antes de incorporarlos a `bi_pedidos`, evitando multiplicar registros por las relaciones uno a varios.
- Las ventas por artículo y los indicadores logísticos y de satisfacción se mantienen separados para respetar su granularidad.

**Validación inicial**

Se verificaron los conteos de registros y la unicidad de las claves principales de las tablas de hechos.

| Validación | Resultado |
| --- | --: |
| Artículos válidos (`bi_items`) | 112.101 |
| Pedidos (`bi_pedidos`) | 99.441 |
| Clientes (`bi_clientes`) | 99.441 |
| Productos (`bi_productos`) | 32.951 |
| Vendedores (`bi_vendedores`) | 3.095 |
| Claves únicas en `bi_pedidos` | 99.441 |
| Combinaciones únicas pedido-artículo en `bi_items` | 112.101 |

Los resultados coinciden con los conteos de referencia y no se detectaron duplicados en las claves verificadas.

**Validación de integridad referencial**

Se comprobaron las correspondencias entre las claves de las vistas de hechos y sus respectivas vistas relacionadas mediante consultas SQL con `LEFT JOIN`.

| Relación comprobada | Registros sin correspondencia |
| --- | --: |
| `bi_items` → `bi_productos` | 0 |
| `bi_items` → `bi_vendedores` | 0 |
| `bi_pedidos` → `bi_clientes` | 0 |
| `bi_items` → `bi_pedidos` | 0 |

Las cuatro comprobaciones finalizaron sin registros huérfanos en las relaciones evaluadas.

**Ajuste de la vista `bi_items`**

Se incorporaron los campos `customer_id` y `fecha_compra` a la vista `bi_items`. El objetivo es facilitar el análisis de ventas por cliente y período, así como preparar el modelo para las relaciones con las dimensiones correspondientes en Power BI.

Los campos se añadieron al final de la definición de la vista para conservar el orden de las columnas existentes al utilizar `CREATE OR REPLACE VIEW` en PostgreSQL.

| Control posterior al ajuste | Resultado |
| --- | --: |
| Total de registros | 112.101 |
| Registros con cliente | 112.101 |
| Registros con fecha de compra | 112.101 |
| Claves únicas pedido-artículo | 112.101 |

La validación confirmó que los nuevos campos están completos y que se conserva la granularidad de una fila por artículo de pedido.

**Ajuste de la vista `bi_pedidos`**

Para la página de logística y satisfacción del dashboard se agregó a `bi_pedidos` el campo `estado_entrega`, con los valores “A tiempo” y “Tardía”. Los pedidos sin fecha real de entrega no tienen valor en ese campo y se presentan en el dashboard como “Sin entregar”.

**Estado:** vistas BI creadas y validadas (granularidad, claves únicas e integridad referencial). Las cinco vistas se importaron en Power BI, junto con la tabla `Calendario`, y se construyó el dashboard descrito en la sección 6.3.

### 6.2 Criterio de selección de datos para Power BI

Se seleccionaron cinco vistas SQL (`bi_items`, `bi_pedidos`, `bi_clientes`, `bi_productos` y `bi_vendedores`) como fuente del modelo analítico en Power BI. Esta decisión busca separar la preparación de datos, realizada en PostgreSQL, de la visualización y el análisis de indicadores en la herramienta de BI.

La selección responde a los siguientes criterios:

- **Orientación al negocio:** las vistas reúnen los campos necesarios para analizar ventas, pagos, entregas, satisfacción, productos, vendedores y clientes.
- **Control de la granularidad:** `bi_items` conserva una fila por artículo de pedido, mientras que `bi_pedidos` conserva una fila por pedido. Esta separación evita mezclar indicadores calculados a distintos niveles.
- **Prevención de duplicaciones:** los pagos y las reseñas se agregan por pedido antes de incorporarse a `bi_pedidos`, evitando que las relaciones uno a varios multipliquen los registros.
- **Preparación previa en SQL:** las transformaciones y validaciones principales se realizan en PostgreSQL, facilitando la trazabilidad y la revisión de las consultas.
- **Carga selectiva:** no se importan todas las tablas originales, sino únicamente las vistas requeridas para el análisis. Esto reduce la complejidad del modelo y evita incorporar datos que no aportan valor directo al dashboard.

La dimensión `Calendario` se creó en Power BI para facilitar el análisis temporal.

**Estado:** selección de fuentes definida e implementada en Power BI.

### 6.3 Dashboard en Power BI

El dashboard tiene dos páginas, cada una orientada a una de las preguntas clave del proyecto.

**Página 1. Ventas**

- **Tarjetas:** ventas totales (R$ 13,49 millones), pedidos (99 mil), clientes únicos (96 mil) y vendedores activos (3 mil).
- **Evolución de ventas por año (2016-2018):** muestra la tendencia anual del valor de los productos.
- **Top de categorías por ventas:** identifica las categorías que más aportan.
- **Ventas por estado:** muestra la concentración geográfica, con SP en primer lugar.

**Página 2. Logística y Satisfacción**

- **Tarjetas:** puntuación promedio (4,09) y tiempo medio de entrega (12,56 días).
- **Gráfico de barras apiladas al 100 %:** distribución de los pedidos según su estado de entrega (“A tiempo”, “Tardía” y “Sin entregar”) para cada puntuación de reseña, de 1 a 5.

**Hallazgo principal**

La proporción de entregas tardías disminuye a medida que aumenta la puntuación:

| Puntuación | A tiempo | Tardía | Sin entregar |
| --: | --: | --: | --: |
| 1 | 51,07 % | 31,22 % | 17,71 % |
| 2 | 74,08 % | 19,25 % | 6,67 % |
| 3 | 86,55 % | 10,70 % | 2,75 % |
| 4 | 94,22 % | 4,98 % | 0,80 % |
| 5 | 96,56 % | menos de 3,44 % | menos de 3,44 % |

En las puntuaciones 3 y 4, “Sin entregar” se calculó por diferencia a partir de las etiquetas del gráfico. En la puntuación 5, entre “Tardía” y “Sin entregar” suman 3,44 %.

Los pedidos con puntuación 1 tienen una proporción de entregas tardías más de ocho veces mayor que los de puntuación 5. Esta es una asociación descriptiva y no demuestra causalidad.

**Validación de las medidas contra SQL**

| Indicador | Dashboard | Referencia SQL |
| --- | --- | --- |
| Ventas totales | R$ 13,49 M | R$ 13.591.643,70 (consulta 50) − R$ 95.235,27 (cancelados) − R$ 2.007,69 (no disponibles) = R$ 13.494.400,74 |
| Pedidos | 99 mil | 99.441 |
| Clientes únicos | 96 mil | 96.096 |
| Tiempo medio de entrega | 12,56 días | 12,6 días (sección 6) |

Las cifras del dashboard son coherentes con las consultas SQL.

**Decisiones de diseño**

- El color rojo se reserva para las entregas tardías, para que el mensaje principal destaque.
- El título del gráfico enuncia el hallazgo.
- Las puntuaciones se muestran como enteros (1 a 5). Como la puntuación por pedido es el promedio de sus reseñas, la columna se redondea para agrupar, lo que puede reubicar algunos pedidos entre categorías vecinas.

## 7. Conclusiones y limitaciones

### Conclusiones

1. **Las ventas crecieron, pero se estancaron.** De enero a agosto de 2018 las ventas fueron cerca de 138 % superiores al mismo período de 2017. Desde enero de 2018 se mantienen entre R$ 0,84 y 0,99 millones por mes.
2. **Hay concentración en tres frentes.** SP, RJ y MG reúnen cerca del 63 % de las ventas. Las diez primeras categorías suman alrededor del 62 %. Unos 540 de 3.053 vendedores (≈ 18 %) generan el 80 % de las ventas.
3. **El flete pesa más lejos del sudeste.** Representa 13,8 % de las ventas en SP y entre 24 y 28 % en RR, MA, RO, AM y PI, algunos con pocos pedidos.
4. **Las entregas tardías se asocian a peores reseñas.** El 8,11 % de las entregas fue tardío. La puntuación promedio fue de 4,29 en entregas a tiempo y de 2,57 en tardías, y el 33,80 % de los pedidos con reseña negativa llegó tarde. La tardanza varía por estado: AL 23,9 %, MA 19,7 % y RJ 13,5 %, frente a SP 5,9 % y PR 5,0 %.
5. **Las cancelaciones son pocas.** Son 625 pedidos (0,63 %), con R$ 143.255,60 en pagos registrados, que no equivalen a pérdidas confirmadas.

### Recomendaciones para la gerencia comercial

Son líneas de acción para evaluar, no resultados probados por los datos:

- **Logística:** priorizar la revisión del proceso de entrega en los estados con mayor tasa de tardanza (AL, MA y RJ). SP y RJ concentran cerca de la mitad de las entregas tardías, por lo que RJ es un candidato de alto impacto.
- **Expectativas de entrega:** comparar el plazo prometido con el real por estado, porque los márgenes varían bastante entre ellos.
- **Dependencia geográfica:** evaluar acciones comerciales en regiones con baja participación, considerando el efecto del flete.
- **Vendedores:** diseñar seguimiento para el grupo reducido de cuentas que sostiene la mayor parte de las ventas.
- **Categorías:** analizar el ticket por pedido, ya que, por ejemplo, `watches_gifts` supera los R$ 200 por pedido frente a unos R$ 110 de `bed_bath_table`.
- **Cancelaciones:** reunir datos sobre reembolsos y reversos antes de estimar su costo real.

### Limitaciones identificadas

- **Costos:** el dataset contiene precios de artículos y valores de flete, pero no costos operativos ni costos de adquisición. Por tanto, el análisis mide ventas y desempeño operativo, no utilidad ni rentabilidad.
- **Cobertura temporal:** para las tendencias mensuales, el período útil es de enero de 2017 a agosto de 2018. Los meses con pocos registros al inicio y al final del dataset pueden distorsionar las comparaciones.
- **Años parciales en la tendencia anual:** 2016 y 2018 no cubren el año completo. En la gráfica anual del dashboard esto puede parecer un crecimiento o una desaceleración que no son reales.
- **Identificadores de reseña repetidos:** hay 789 `review_id` que aparecen más de una vez y se relacionan con pedidos distintos. La causa no está determinada; las métricas de satisfacción se calculan por pedido para evitar duplicar pedidos en las uniones. Este criterio reduce la duplicación de pedidos en el análisis, pero no resuelve el origen de los identificadores repetidos.
- **Puntuación redondeada en el dashboard:** el gráfico de logística agrupa los pedidos por puntuación entera, mientras que la puntuación del pedido se calcula como promedio de sus reseñas. El redondeo puede reubicar algunos pedidos entre categorías vecinas.
- **“Sin entregar”:** agrupa pedidos sin fecha real de entrega y puede incluir estados distintos (cancelados, no disponibles, en proceso). No debe leerse como un solo tipo de incidencia.
- **Estacionalidad:** el máximo de noviembre de 2017 podría estar relacionado con la temporada comercial de Black Friday, pero el dataset no permite confirmar esa hipótesis.
- **Cancelaciones y pagos:** los R$ 143.255,60 asociados a pedidos cancelados son pagos registrados, no pérdidas confirmadas. No se dispone de información suficiente sobre reembolsos o reversos.
- **Asociación entre entregas y reseñas:** las entregas tardías aparecen con mayor frecuencia entre los pedidos con reseñas negativas, pero el análisis descriptivo no demuestra causalidad.

## 8. Checklist antes de publicar

- [x] README claro y completo.
- [x] Archivos organizados y sin versiones innecesarias.
- [x] Sin credenciales ni datos sensibles.
- [x] Enlace a la fuente original del dataset.
- [x] Nombres y rutas de los scripts SQL comprobados contra los archivos reales de la carpeta `sql/`.
- [x] Consultas SQL documentadas y verificadas.
- [x] Resultados respaldados por consultas reproducibles.
- [x] Visualizaciones o dashboard terminado.
- [x] Proyecto publicado y accesible en GitHub.
- [] Enlace compartido con el coach de TripleTen.
