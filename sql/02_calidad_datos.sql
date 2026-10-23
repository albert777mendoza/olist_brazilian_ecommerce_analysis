
-- Olist Brazilian E-commerce
-- FASE 02 - Calidad de datos


-- 1. Revisar valores nulos en columnas clave de orders
SELECT
    COUNT(*) AS total_pedidos,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulos,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_id_nulos,
    COUNT(*) FILTER (WHERE order_status IS NULL) AS order_status_nulos,
    COUNT(*) FILTER (WHERE order_purchase_timestamp IS NULL) AS fecha_compra_nula,
    COUNT(*) FILTER (WHERE order_delivered_customer_date IS NULL) AS fecha_entrega_real_nula,
    COUNT(*) FILTER (WHERE order_estimated_delivery_date IS NULL) AS fecha_entrega_estimada_nula
FROM orders;


-- 2. Revisar fechas de entrega faltantes por estado del pedido
SELECT
    order_status,
    COUNT(*) AS total_pedidos,
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date IS NULL
    ) AS sin_fecha_entrega_real
FROM orders
GROUP BY order_status
ORDER BY sin_fecha_entrega_real DESC;


-- 3. Investigar pedidos entregados sin fecha real de entrega
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NULL
ORDER BY order_purchase_timestamp;


-- 4. Comprobar si los pedidos inconsistentes tienen artículos registrados
SELECT
    o.order_id,
    COUNT(oi.order_id) AS cantidad_registros_articulos,
    SUM(oi.price) AS valor_productos,
    SUM(oi.freight_value) AS valor_flete
FROM orders AS o
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NULL
GROUP BY o.order_id
ORDER BY cantidad_registros_articulos DESC;


-- 5. Comprobar pagos de los pedidos inconsistentes
SELECT
    o.order_id,
    COUNT(op.order_id) AS registros_pago,
    SUM(op.payment_value) AS valor_total_pagado
FROM orders AS o
LEFT JOIN order_payments AS op
    ON o.order_id = op.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NULL
GROUP BY o.order_id
ORDER BY registros_pago DESC;


-- 6. Buscar identificadores de pedido duplicados
SELECT
    order_id,
    COUNT(*) AS cantidad
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY cantidad DESC;

   -- 7. Buscar líneas de artículos duplicadas
   SELECT order_id, order_item_id, COUNT(*) AS cantidad
   FROM order_items
   GROUP BY order_id, order_item_id
   HAVING COUNT(*) > 1;


-- 8. Buscar identificadores de productos duplicados
SELECT
    product_id,
    COUNT(*) AS cantidad
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY cantidad DESC;


-- 9. Buscar identificadores de vendedores duplicados
SELECT
    seller_id,
    COUNT(*) AS cantidad
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1
ORDER BY cantidad DESC;


-- 10. Buscar posibles duplicados en los registros de pago
SELECT
    order_id,
    payment_sequential,
    COUNT(*) AS cantidad
FROM order_payments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1
ORDER BY cantidad DESC;



-- 11. Buscar identificadores de reseña duplicados
SELECT
    review_id,
    COUNT(*) AS cantidad
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY cantidad DESC;


-- 12. Cuantificar los review_id duplicados
SELECT
    COUNT(*) AS identificadores_duplicados,
    SUM(cantidad) AS registros_afectados,
    SUM(cantidad - 1) AS registros_excedentes
FROM (
    SELECT
        review_id,
        COUNT(*) AS cantidad
    FROM order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
) AS duplicados;



-- 13. Examinar un review_id repetido
SELECT *
FROM order_reviews
WHERE review_id = '1fb4ddc969e6bea80e38deec00393a6f';


-- 14. Verificar los pedidos asociados a la reseña repetida
SELECT
    r.review_id,
    r.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date
FROM order_reviews AS r
LEFT JOIN orders AS o
    ON r.order_id = o.order_id
WHERE r.review_id = '1fb4ddc969e6bea80e38deec00393a6f'
ORDER BY r.order_id;




-- 15. Revisar cuántos pedidos distintos tiene cada review_id repetido
SELECT
    r.review_id,
    COUNT(*) AS registros_resena,
    COUNT(DISTINCT r.order_id) AS pedidos_distintos
FROM order_reviews AS r
GROUP BY r.review_id
HAVING COUNT(*) > 1
ORDER BY pedidos_distintos DESC, registros_resena DESC
LIMIT 20;


-- 16. Distribución de review_id repetidos según pedidos distintos
SELECT
    pedidos_distintos,
    COUNT(*) AS cantidad_review_id
FROM (
    SELECT
        review_id,
        COUNT(*) AS registros_resena,
        COUNT(DISTINCT order_id) AS pedidos_distintos
    FROM order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
) AS duplicados
GROUP BY pedidos_distintos
ORDER BY pedidos_distintos;


-- 17. Comparar puntuaciones y comentarios de review_id repetidos
SELECT
    review_id,
    COUNT(*) AS registros,
    COUNT(DISTINCT order_id) AS pedidos_distintos,
    COUNT(DISTINCT review_score) AS puntuaciones_distintas,
    COUNT(DISTINCT review_comment_message) AS comentarios_distintos
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY comentarios_distintos DESC, puntuaciones_distintas DESC
LIMIT 20;


-- 18. Inspeccionar las filas de un review_id repetido
SELECT
    review_id,
    order_id,
    review_score,
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM order_reviews
WHERE review_id = '0ec0f24aa34a9b25fb0f7b32034965ce'
ORDER BY order_id;



-- 19. Revisar si los review_id repetidos tienen
-- una sola combinación de puntuación, comentario y fechas
SELECT
    COUNT(*) AS review_id_repetidos,
    COUNT(*) FILTER (
        WHERE combinaciones_contenido = 1
    ) AS ids_con_una_combinacion,
    COUNT(*) FILTER (
        WHERE combinaciones_contenido > 1
    ) AS ids_con_varias_combinaciones
FROM (
    SELECT
        review_id,
        COUNT(DISTINCT (
            review_score,
            review_comment_title,
            review_comment_message,
            review_creation_date,
            review_answer_timestamp
        )) AS combinaciones_contenido
    FROM order_reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
) AS resumen;



    
-- 20. Distribución de puntuaciones en todas las filas
SELECT
    review_score,
    COUNT(*) AS cantidad_resenas,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
        2
    ) AS porcentaje
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;



-- 21. Comparar puntuaciones: todas las filas vs. review_id únicos
WITH resenas_unicas AS (
    SELECT DISTINCT ON (review_id)
        review_id,
        review_score
    FROM order_reviews
    ORDER BY review_id
),
distribucion_filas AS (
    SELECT
        review_score,
        COUNT(*) AS cantidad_filas
    FROM order_reviews
    GROUP BY review_score
),
distribucion_unicas AS (
    SELECT
        review_score,
        COUNT(*) AS cantidad_ids_unicos
    FROM resenas_unicas
    GROUP BY review_score
)
SELECT
    f.review_score,
    f.cantidad_filas,
    u.cantidad_ids_unicos,
    f.cantidad_filas - u.cantidad_ids_unicos AS diferencia
FROM distribucion_filas AS f
JOIN distribucion_unicas AS u
    ON f.review_score = u.review_score
ORDER BY f.review_score;


-- 22. Comparar porcentajes por puntuación
WITH resenas_unicas AS (
    SELECT DISTINCT ON (review_id)
        review_id,
        review_score
    FROM order_reviews
    ORDER BY review_id
),
por_filas AS (
    SELECT
        review_score,
        COUNT(*) AS cantidad,
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS porcentaje
    FROM order_reviews
    GROUP BY review_score
),
por_ids AS (
    SELECT
        review_score,
        COUNT(*) AS cantidad,
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS porcentaje
    FROM resenas_unicas
    GROUP BY review_score
)
SELECT
    f.review_score,
    ROUND(f.porcentaje, 2) AS porcentaje_todas_filas,
    ROUND(u.porcentaje, 2) AS porcentaje_ids_unicos,
    ROUND(u.porcentaje - f.porcentaje, 2) AS cambio_puntos_porcentuales
FROM por_filas AS f
JOIN por_ids AS u
    ON f.review_score = u.review_score
ORDER BY f.review_score;


-- 23. Revisar valores nulos y valores no positivos
-- en artículos de pedido
SELECT
    COUNT(*) AS total_registros,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulos,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id_nulos,
    COUNT(*) FILTER (WHERE seller_id IS NULL) AS seller_id_nulos,
    COUNT(*) FILTER (WHERE price IS NULL) AS precio_nulo,
    COUNT(*) FILTER (WHERE price <= 0) AS precio_no_positivo,
    COUNT(*) FILTER (WHERE freight_value IS NULL) AS flete_nulo,
    COUNT(*) FILTER (WHERE freight_value < 0) AS flete_negativo
FROM order_items;


-- 24. Validar valores de order_payments
SELECT
    COUNT(*) AS total_registros,
    COUNT(*) FILTER (WHERE order_id IS NULL) AS order_id_nulos,
    COUNT(*) FILTER (WHERE payment_sequential IS NULL) AS secuencia_nula,
    COUNT(*) FILTER (WHERE payment_type IS NULL) AS tipo_pago_nulo,
    COUNT(*) FILTER (WHERE payment_installments IS NULL) AS cuotas_nulas,
    COUNT(*) FILTER (WHERE payment_value IS NULL) AS valor_pago_nulo,
    COUNT(*) FILTER (WHERE payment_value <= 0) AS pago_no_positivo,
    COUNT(*) FILTER (WHERE payment_installments <= 0) AS cuotas_no_positivas
FROM order_payments;



-- 25. Investigar pagos con valor cero o negativo
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM order_payments
WHERE payment_value <= 0
ORDER BY payment_value, order_id;



-- 26. Investigar pagos con cuotas iguales o inferiores a cero
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value
FROM order_payments
WHERE payment_installments <= 0
ORDER BY order_id, payment_sequential;



-- 27. Distribución de tipos de pago
SELECT
    payment_type,
    COUNT(*) AS registros,
    COUNT(DISTINCT order_id) AS pedidos_distintos,
    SUM(payment_value) AS valor_total
FROM order_payments
GROUP BY payment_type
ORDER BY registros DESC;


-- 28. Pedidos con más de un tipo de pago
SELECT
    COUNT(*) AS pedidos_con_varios_tipos
FROM (
    SELECT order_id
    FROM order_payments
    GROUP BY order_id
    HAVING COUNT(DISTINCT payment_type) > 1
) AS pedidos;


-- 29. Validar campos de la tabla products
SELECT
    COUNT(*) AS total_productos,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS product_id_nulos,
    COUNT(*) FILTER (WHERE product_category_name IS NULL) AS categoria_nula,
    COUNT(*) FILTER (WHERE product_name_lenght IS NULL) AS nombre_largo_nulo,
    COUNT(*) FILTER (WHERE product_description_lenght IS NULL) AS descripcion_larga_nula,
    COUNT(*) FILTER (WHERE product_photos_qty IS NULL) AS fotos_nulas,
    COUNT(*) FILTER (WHERE product_weight_g IS NULL) AS peso_nulo,
    COUNT(*) FILTER (WHERE product_length_cm IS NULL) AS largo_nulo,
    COUNT(*) FILTER (WHERE product_height_cm IS NULL) AS alto_nulo,
    COUNT(*) FILTER (WHERE product_width_cm IS NULL) AS ancho_nulo
FROM products;



-- 30. Comprobar coincidencia de valores nulos en products
SELECT
    COUNT(*) FILTER (
        WHERE product_category_name IS NULL
    ) AS categoria_nula,
    COUNT(*) FILTER (
        WHERE product_name_lenght IS NULL
    ) AS nombre_largo_nulo,
    COUNT(*) FILTER (
        WHERE product_description_lenght IS NULL
    ) AS descripcion_larga_nula,
    COUNT(*) FILTER (
        WHERE product_photos_qty IS NULL
    ) AS fotos_nulas,
    COUNT(*) FILTER (
        WHERE product_category_name IS NULL
          AND product_name_lenght IS NULL
          AND product_description_lenght IS NULL
          AND product_photos_qty IS NULL
    ) AS todos_esos_campos_nulos
FROM products;



-- 31. Categorías de productos sin traducción al inglés
SELECT DISTINCT
    p.product_category_name
FROM products AS p
LEFT JOIN product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL
ORDER BY p.product_category_name;



-- 32. Revisar valores físicos no positivos en products
SELECT
    COUNT(*) FILTER (WHERE product_weight_g <= 0) AS peso_no_positivo,
    COUNT(*) FILTER (WHERE product_length_cm <= 0) AS largo_no_positivo,
    COUNT(*) FILTER (WHERE product_height_cm <= 0) AS alto_no_positivo,
    COUNT(*) FILTER (WHERE product_width_cm <= 0) AS ancho_no_positivo,
    COUNT(*) FILTER (WHERE product_weight_g IS NULL) AS peso_nulo,
    COUNT(*) FILTER (WHERE product_length_cm IS NULL) AS largo_nulo,
    COUNT(*) FILTER (WHERE product_height_cm IS NULL) AS alto_nulo,
    COUNT(*) FILTER (WHERE product_width_cm IS NULL) AS ancho_nulo
FROM products;



-- 33. Identificar productos con peso no positivo
SELECT
    product_id,
    product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM products
WHERE product_weight_g <= 0
ORDER BY product_weight_g, product_id;



-- 34. Identificar productos sin peso ni dimensiones
SELECT
    product_id,
    product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM products
WHERE product_weight_g IS NULL
   OR product_length_cm IS NULL
   OR product_height_cm IS NULL
   OR product_width_cm IS NULL
ORDER BY product_id;



-- 35. Revisar campos nulos en sellers
SELECT
    COUNT(*) AS total_vendedores,
    COUNT(*) FILTER (WHERE seller_id IS NULL) AS seller_id_nulos,
    COUNT(*) FILTER (WHERE seller_zip_code_prefix IS NULL) AS codigo_postal_nulo,
    COUNT(*) FILTER (WHERE seller_city IS NULL) AS ciudad_nula,
    COUNT(*) FILTER (WHERE seller_state IS NULL) AS estado_nulo
FROM sellers;



-- 36. Buscar identificadores de vendedor duplicados
SELECT
    seller_id,
    COUNT(*) AS cantidad
FROM sellers
GROUP BY seller_id
HAVING COUNT(*) > 1
ORDER BY cantidad DESC;



-- 37. Revisar campos nulos en customers
SELECT
    COUNT(*) AS total_clientes,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS customer_id_nulos,
    COUNT(*) FILTER (
        WHERE customer_unique_id IS NULL
    ) AS customer_unique_id_nulos,
    COUNT(*) FILTER (
        WHERE customer_zip_code_prefix IS NULL
    ) AS codigo_postal_nulo,
    COUNT(*) FILTER (WHERE customer_city IS NULL) AS ciudad_nula,
    COUNT(*) FILTER (WHERE customer_state IS NULL) AS estado_nulo
FROM customers;



-- 38. Comparar registros e identificadores únicos de clientes
SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT customer_id) AS customer_id_distintos,
    COUNT(DISTINCT customer_unique_id) AS clientes_unicos
FROM customers;



-- 39. Identificar clientes únicos asociados a varios registros
SELECT
    customer_unique_id,
    COUNT(*) AS cantidad_registros
FROM customers
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY cantidad_registros DESC
LIMIT 10;



-- 40. Comprobar pedidos por cliente único
SELECT
    c.customer_unique_id,
    COUNT(o.order_id) AS cantidad_pedidos
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(o.order_id) > 1
ORDER BY cantidad_pedidos DESC
LIMIT 10;



-- 41. Medir recurrencia de compra en toda la base
WITH pedidos_por_cliente AS (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS cantidad_pedidos
    FROM customers AS c
    JOIN orders AS o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS clientes_unicos,
    COUNT(*) FILTER (
        WHERE cantidad_pedidos = 1
    ) AS clientes_un_pedido,
    COUNT(*) FILTER (
        WHERE cantidad_pedidos > 1
    ) AS clientes_recurrentes,
    ROUND(
        100.0 * COUNT(*) FILTER (
            WHERE cantidad_pedidos > 1
        ) / COUNT(*),
        2
    ) AS porcentaje_recurrentes
FROM pedidos_por_cliente;



-- 42. Validar rango de puntuaciones de reseñas
SELECT
    COUNT(*) AS total_resenas,
    COUNT(*) FILTER (
        WHERE review_score IS NULL
    ) AS puntuaciones_nulas,
    COUNT(*) FILTER (
        WHERE review_score < 1 OR review_score > 5
    ) AS puntuaciones_fuera_de_rango,
    MIN(review_score) AS puntuacion_minima,
    MAX(review_score) AS puntuacion_maxima
FROM order_reviews;



-- 43. Validar fechas de las reseñas
SELECT
    COUNT(*) AS total_resenas,
    COUNT(*) FILTER (
        WHERE review_creation_date IS NULL
    ) AS fecha_creacion_nula,
    COUNT(*) FILTER (
        WHERE review_answer_timestamp IS NULL
    ) AS fecha_respuesta_nula,
    COUNT(*) FILTER (
        WHERE review_answer_timestamp < review_creation_date
    ) AS respuesta_antes_de_creacion
FROM order_reviews;



-- 44. Comprobar correspondencia de códigos postales
SELECT
    COUNT(DISTINCT c.customer_zip_code_prefix)
        AS codigos_postales_clientes,
    COUNT(DISTINCT c.customer_zip_code_prefix) FILTER (
        WHERE g.geolocation_zip_code_prefix IS NOT NULL
    ) AS codigos_con_geolocalizacion
FROM customers AS c
LEFT JOIN (
    SELECT DISTINCT geolocation_zip_code_prefix
    FROM geolocation
) AS g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix;



-- 45. Identificar códigos postales de clientes sin geolocalización
SELECT DISTINCT
    c.customer_zip_code_prefix
FROM customers AS c
LEFT JOIN (
    SELECT DISTINCT geolocation_zip_code_prefix
    FROM geolocation
) AS g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL
ORDER BY c.customer_zip_code_prefix
LIMIT 20;



-- 46. Comparar estados de clientes y geolocalización
SELECT
    c.customer_state,
    COUNT(DISTINCT c.customer_zip_code_prefix)
        AS codigos_postales_clientes,
    COUNT(DISTINCT c.customer_zip_code_prefix) FILTER (
        WHERE g.geolocation_zip_code_prefix IS NOT NULL
    ) AS codigos_con_geolocalizacion
FROM customers AS c
LEFT JOIN (
    SELECT DISTINCT
        geolocation_zip_code_prefix,
        geolocation_state
    FROM geolocation
) AS g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix
   AND c.customer_state = g.geolocation_state
GROUP BY c.customer_state
ORDER BY codigos_postales_clientes DESC;



-- 47. Detectar fechas de entrega anteriores a la compra
SELECT
    COUNT(*) FILTER (
        WHERE order_delivered_customer_date
              < order_purchase_timestamp
    ) AS entregas_antes_de_compra,
    COUNT(*) FILTER (
        WHERE order_delivered_carrier_date
              < order_purchase_timestamp
    ) AS transportista_antes_de_compra,
    COUNT(*) FILTER (
        WHERE order_estimated_delivery_date
              < order_purchase_timestamp
    ) AS fecha_estimada_antes_de_compra
FROM orders;



-- 48. Inspeccionar pedidos con entrega al transportista anterior a la compra
SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM orders
WHERE order_delivered_carrier_date
      < order_purchase_timestamp
ORDER BY order_purchase_timestamp
LIMIT 20;



-- 49. Medir diferencia entre compra y entrega al transportista
SELECT
    COUNT(*) AS pedidos_inconsistentes,
    ROUND(
        AVG(EXTRACT(EPOCH FROM (
            order_purchase_timestamp
            - order_delivered_carrier_date
        )) / 60)::numeric,
        2
    ) AS diferencia_promedio_minutos,
    MIN(EXTRACT(EPOCH FROM (
        order_purchase_timestamp
        - order_delivered_carrier_date
    )) / 60) AS diferencia_minima_minutos,
    MAX(EXTRACT(EPOCH FROM (
        order_purchase_timestamp
        - order_delivered_carrier_date
    )) / 60) AS diferencia_maxima_minutos
FROM orders
WHERE order_delivered_carrier_date
      < order_purchase_timestamp;


