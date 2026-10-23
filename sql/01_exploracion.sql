-- Olist Brazilian E-commerce
-- FASE 01 - Exploración inicial

-- 1. Conteo de registros por tabla
SELECT 'customers' AS tabla, COUNT(*) AS registros FROM customers
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL
SELECT 'product_category_name_translation', COUNT(*)
FROM product_category_name_translation
ORDER BY tabla;

-- 2. Rango de fechas y pedidos sin fecha
SELECT
    MIN(order_purchase_timestamp) AS primer_pedido,
    MAX(order_purchase_timestamp) AS ultimo_pedido,
    COUNT(*) AS total_pedidos,
    COUNT(order_purchase_timestamp) AS pedidos_con_fecha,
    COUNT(*) - COUNT(order_purchase_timestamp) AS pedidos_sin_fecha
FROM orders;

-- 3. Estados de los pedidos
SELECT
    order_status,
    COUNT(*) AS cantidad
FROM orders
GROUP BY order_status
ORDER BY cantidad DESC;

-- 4. Pedidos por año y mes
SELECT
    DATE_TRUNC('month', order_purchase_timestamp)::date AS mes,
    COUNT(*) AS pedidos
FROM orders
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY 1
ORDER BY 1;