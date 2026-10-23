-- FASE 03: Análisis de Negocio 

-- 50. Indicadores generales de ventas
SELECT
    COUNT(DISTINCT order_id) AS pedidos_con_items,
    COUNT(*) AS total_items,
    ROUND(SUM(price)::numeric, 2) AS ventas_productos_brl,
    ROUND(SUM(freight_value)::numeric, 2) AS fletes_brl,
    ROUND(SUM(price + freight_value)::numeric, 2)
        AS valor_productos_mas_fletes_brl,
    ROUND(AVG(price)::numeric, 2) AS precio_promedio_item_brl
FROM order_items;


-- 51. Revisar pedidos sin artículos asociados
SELECT
    o.order_status,
    COUNT(*) AS pedidos_sin_items
FROM orders AS o
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL
GROUP BY o.order_status
ORDER BY pedidos_sin_items DESC;

-- 52. Inspeccionar pedidos sin artículos
-- en estados que requieren revisión
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date
FROM orders AS o
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE oi.order_id IS NULL
  AND o.order_status NOT IN ('unavailable', 'canceled')
ORDER BY o.order_status, o.order_purchase_timestamp;


-- 53. Revisar pagos de los ocho pedidos sin artículos
SELECT
    o.order_id,
    o.order_status,
    COUNT(p.order_id) AS registros_pago,
    COALESCE(SUM(p.payment_value), 0) AS total_pagado_brl
FROM orders AS o
LEFT JOIN order_items AS oi
    ON o.order_id = oi.order_id
LEFT JOIN order_payments AS p
    ON o.order_id = p.order_id
WHERE oi.order_id IS NULL
  AND o.order_status NOT IN ('unavailable', 'canceled')
GROUP BY
    o.order_id,
    o.order_status
ORDER BY o.order_status, o.order_id;


-- 54. Pedidos y valor de artículos por estado
WITH ventas_por_pedido AS (
    SELECT
        order_id,
        SUM(price) AS valor_productos,
        SUM(freight_value) AS valor_fletes
    FROM order_items
    GROUP BY order_id
)
SELECT
    o.order_status,
    COUNT(*) AS total_pedidos,
    COUNT(v.order_id) AS pedidos_con_items,
    ROUND(
        COALESCE(SUM(v.valor_productos), 0)::numeric,
        2
    ) AS ventas_productos_brl,
    ROUND(
        COALESCE(SUM(v.valor_fletes), 0)::numeric,
        2
    ) AS fletes_brl
FROM orders AS o
LEFT JOIN ventas_por_pedido AS v
    ON o.order_id = v.order_id
GROUP BY o.order_status
ORDER BY total_pedidos DESC;

-- 55. Pagos registrados en pedidos cancelados
WITH pagos_por_pedido AS (
    SELECT
        order_id,
        COUNT(*) AS registros_pago,
        SUM(payment_value) AS valor_pagos
    FROM order_payments
    GROUP BY order_id
)
SELECT
    COUNT(*) AS pedidos_cancelados,
    COUNT(p.order_id) AS pedidos_con_pago,
    ROUND(
        COALESCE(SUM(p.valor_pagos), 0)::numeric,
        2
    ) AS valor_pagos_registrados_brl
FROM orders AS o
LEFT JOIN pagos_por_pedido AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'canceled';


-- 56. Tipos de pago en pedidos cancelados
SELECT
    p.payment_type,
    COUNT(*) AS registros_pago,
    COUNT(DISTINCT p.order_id) AS pedidos,
    ROUND(SUM(p.payment_value)::numeric, 2)
        AS valor_pagos_brl
FROM orders AS o
INNER JOIN order_payments AS p
    ON o.order_id = p.order_id
WHERE o.order_status = 'canceled'
GROUP BY p.payment_type
ORDER BY valor_pagos_brl DESC;

-- Vista de apoyo: artículos de pedidos válidos para el análisis de ventas
CREATE OR REPLACE VIEW v_items_validos AS
SELECT
    oi.order_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp
FROM order_items AS oi
JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable');


-- 57. Ventas, pedidos y ticket promedio por mes
SELECT
    DATE_TRUNC('month', order_purchase_timestamp)::date AS mes,
    COUNT(DISTINCT order_id) AS pedidos,
    ROUND(SUM(price)::numeric, 2) AS ventas_brl,
    ROUND(
        (SUM(price) / COUNT(DISTINCT order_id))::numeric,
        2
    ) AS ticket_promedio_brl
FROM v_items_validos
GROUP BY 1
ORDER BY 1;


-- 58. Top 10 categorías por ventas
SELECT COALESCE(t.product_category_name_english, p.product_category_name, 'Sin categoría') AS categoria,
       COUNT(DISTINCT v.order_id) AS pedidos,
       ROUND(SUM(v.price)::numeric, 2) AS ventas_brl,
       ROUND((100.0 * SUM(v.price) / SUM(SUM(v.price)) OVER ())::numeric, 2) AS pct_ventas
FROM v_items_validos AS v
JOIN products AS p ON v.product_id = p.product_id
LEFT JOIN product_category_name_translation AS t
       ON p.product_category_name = t.product_category_name
GROUP BY 1 ORDER BY ventas_brl DESC LIMIT 10;

-- 59. Ventas y peso del flete por estado del cliente
SELECT c.customer_state,
       COUNT(DISTINCT v.order_id) AS pedidos,
       ROUND(SUM(v.price)::numeric, 2) AS ventas_brl,
       ROUND((100.0 * SUM(v.price) / SUM(SUM(v.price)) OVER ())::numeric, 2) AS pct_ventas,
       ROUND((100.0 * SUM(v.freight_value) / SUM(v.price))::numeric, 2) AS flete_pct_ventas
FROM v_items_validos AS v
JOIN customers AS c ON v.customer_id = c.customer_id
GROUP BY 1 ORDER BY ventas_brl DESC;

-- 60. Concentración de vendedores: cuántos explican el 80 % de las ventas
WITH ventas AS (
    SELECT seller_id, SUM(price) AS total FROM v_items_validos GROUP BY 1
),
acum AS (
    SELECT seller_id, total,
           ROW_NUMBER() OVER (ORDER BY total DESC) AS ranking,
           SUM(total) OVER (ORDER BY total DESC) / SUM(total) OVER () AS pct_acum
    FROM ventas
)
SELECT (SELECT COUNT(*) FROM ventas) AS total_vendedores,
       MIN(ranking) AS vendedores_para_80pct
FROM acum WHERE pct_acum >= 0.8;

-- 61. Entregas tardías y tiempo promedio de entrega
SELECT COUNT(*) AS pedidos_entregados,
       COUNT(*) FILTER (WHERE order_delivered_customer_date > order_estimated_delivery_date) AS tardios,
       ROUND((100.0 * COUNT(*) FILTER (WHERE order_delivered_customer_date > order_estimated_delivery_date)
              / COUNT(*))::numeric, 2) AS pct_tardios,
       ROUND(AVG(EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)) / 86400)::numeric, 1)
           AS dias_promedio_entrega
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL;

-- 62. Reseñas según entrega a tiempo o tardía (una puntuación por pedido)
WITH resena_pedido AS (
    SELECT order_id, AVG(review_score) AS puntuacion
    FROM order_reviews GROUP BY order_id
),
entregas AS (
    SELECT order_id,
           CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
                THEN 'Tardía' ELSE 'A tiempo' END AS entrega
    FROM orders
    WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL
)
SELECT e.entrega,
       COUNT(*) AS pedidos,
       ROUND(AVG(r.puntuacion)::numeric, 2) AS puntuacion_promedio,
       ROUND((100.0 * COUNT(*) FILTER (WHERE r.puntuacion <= 2) / COUNT(*))::numeric, 2) AS pct_resenas_negativas
FROM entregas AS e
JOIN resena_pedido AS r ON e.order_id = r.order_id
GROUP BY 1;

   -- 63. Pedidos con más de una reseña
   SELECT COUNT(*) AS pedidos_con_varias_resenas
   FROM (SELECT order_id FROM order_reviews
         GROUP BY order_id HAVING COUNT(*) > 1) AS t;

        
-- 64. Entregas tardías, días de entrega y reseñas por estado del cliente
WITH resena_pedido AS (
    SELECT order_id, AVG(review_score) AS puntuacion
    FROM order_reviews GROUP BY order_id
)
SELECT c.customer_state,
       COUNT(*) AS pedidos_entregados,
       ROUND((100.0 * COUNT(*) FILTER (
           WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date)
           / COUNT(*))::numeric, 2) AS pct_tardios,
       ROUND(AVG(EXTRACT(EPOCH FROM (
           o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400)::numeric, 1)
           AS dias_promedio,
       ROUND(AVG(r.puntuacion)::numeric, 2) AS puntuacion_promedio
FROM orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
LEFT JOIN resena_pedido AS r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
HAVING COUNT(*) >= 100
ORDER BY pct_tardios DESC;



-- 65. Días prometidos vs. días reales de entrega por estado
SELECT c.customer_state,
       COUNT(*) AS pedidos_entregados,
       ROUND(AVG(EXTRACT(EPOCH FROM (o.order_estimated_delivery_date - o.order_purchase_timestamp)) / 86400)::numeric, 1) AS dias_prometidos,
       ROUND(AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400)::numeric, 1) AS dias_reales
FROM orders AS o
JOIN customers AS c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered' AND o.order_delivered_customer_date IS NOT NULL
GROUP BY 1
HAVING COUNT(*) >= 100
ORDER BY dias_prometidos DESC;

-- 66. Peso de las entregas tardías en los pedidos con reseña negativa
WITH resena_pedido AS (
    SELECT order_id, AVG(review_score) AS puntuacion
    FROM order_reviews GROUP BY order_id
)
SELECT COUNT(*) AS pedidos_negativos,
       COUNT(*) FILTER (WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date) AS negativos_tardios,
       ROUND((100.0 * COUNT(*) FILTER (WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date)
              / COUNT(*))::numeric, 2) AS pct_tardios
FROM orders AS o
JOIN resena_pedido AS r ON r.order_id = o.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND r.puntuacion <= 2;