
-- ============================================================
-- PROYECTO OLIST: MODELO DIMENSIONAL PARA POWER BI
-- Archivo: sql/04_modelo_bi.sql
-- ============================================================


-- 1. HECHOS DE VENTAS: una fila por artículo de pedido
-- Incluye cliente y fecha de compra para facilitar
-- las relaciones con las dimensiones en Power BI.

CREATE OR REPLACE VIEW bi_items AS
SELECT
    oi.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    o.customer_id,
    o.order_purchase_timestamp::date AS fecha_compra
FROM order_items AS oi
JOIN orders AS o
    ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable');


-- 2. HECHOS DE PEDIDOS: una fila por pedido
-- Se agregan reseñas y pagos antes de unirlos a orders.
CREATE OR REPLACE VIEW bi_pedidos AS
WITH resena AS (
    SELECT
        order_id,
        AVG(review_score) AS puntuacion
    FROM order_reviews
    GROUP BY order_id
),
pago AS (
    SELECT
        order_id,
        SUM(payment_value) AS valor_pagado
    FROM order_payments
    GROUP BY order_id
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_status AS estado_pedido,
    o.order_purchase_timestamp::date AS fecha_compra,
    o.order_delivered_customer_date::date AS fecha_entrega,
    o.order_estimated_delivery_date::date AS fecha_estimada,

    CASE
        WHEN o.order_status = 'delivered'
         AND o.order_delivered_customer_date IS NOT NULL
        THEN EXTRACT(
            EPOCH FROM (
                o.order_delivered_customer_date
                - o.order_purchase_timestamp
            )
        ) / 86400.0
    END AS dias_entrega,

    CASE
        WHEN o.order_estimated_delivery_date IS NOT NULL
        THEN EXTRACT(
            EPOCH FROM (
                o.order_estimated_delivery_date
                - o.order_purchase_timestamp
            )
        ) / 86400.0
    END AS dias_prometidos,

    CASE
        WHEN o.order_status = 'delivered'
         AND o.order_delivered_customer_date IS NOT NULL
         AND o.order_estimated_delivery_date IS NOT NULL
        THEN
            CASE
                WHEN o.order_delivered_customer_date
                     > o.order_estimated_delivery_date
                THEN 'Tardía'
                ELSE 'A tiempo'
            END
    END AS estado_entrega,

    r.puntuacion,
    p.valor_pagado

FROM orders AS o
LEFT JOIN resena AS r
    ON r.order_id = o.order_id
LEFT JOIN pago AS p
    ON p.order_id = o.order_id;


-- 3. DIMENSION DE CLIENTES: una fila por customer_id
CREATE OR REPLACE VIEW bi_clientes AS
SELECT
    customer_id,
    customer_unique_id,
    customer_city AS ciudad,
    customer_state AS estado,
    CASE
        WHEN customer_state IN ('SP', 'RJ', 'MG', 'ES')
            THEN 'Sudeste'
        WHEN customer_state IN ('PR', 'SC', 'RS')
            THEN 'Sur'
        WHEN customer_state IN (
            'BA', 'CE', 'MA', 'PB', 'PE',
            'PI', 'RN', 'SE', 'AL'
        ) THEN 'Nordeste'
        WHEN customer_state IN ('DF', 'GO', 'MT', 'MS')
            THEN 'Centro-Oeste'
        WHEN customer_state IN (
            'AC', 'AP', 'AM', 'PA', 'RO', 'RR', 'TO'
        ) THEN 'Norte'
        ELSE 'Sin clasificar'
    END AS region
FROM customers;


-- 4. DIMENSION DE PRODUCTOS: una fila por product_id
-- DISTINCT evita duplicados en la tabla de traducciones.
CREATE OR REPLACE VIEW bi_productos AS
WITH traducciones AS (
    SELECT
        product_category_name,
        MAX(product_category_name_english)
            AS categoria_ingles
    FROM product_category_name_translation
    GROUP BY product_category_name
)
SELECT
    p.product_id,
    COALESCE(
        t.categoria_ingles,
        p.product_category_name,
        'Sin categoría'
    ) AS categoria
FROM products AS p
LEFT JOIN traducciones AS t
    ON t.product_category_name = p.product_category_name;


-- 5. DIMENSION DE VENDEDORES: una fila por seller_id
CREATE OR REPLACE VIEW bi_vendedores AS
SELECT
    seller_id,
    seller_city AS ciudad,
    seller_state AS estado
FROM sellers;



-- ============================================================
-- 6. VALIDACIONES DEL MODELO BI
-- ============================================================

-- 6.1. Conteo de registros por vista
SELECT 'bi_items' AS vista, COUNT(*) AS registros
FROM bi_items

UNION ALL
SELECT 'bi_pedidos', COUNT(*)
FROM bi_pedidos

UNION ALL
SELECT 'bi_clientes', COUNT(*)
FROM bi_clientes

UNION ALL
SELECT 'bi_productos', COUNT(*)
FROM bi_productos

UNION ALL
SELECT 'bi_vendedores', COUNT(*)
FROM bi_vendedores;


-- 6.2. Validar granularidad y claves únicas
SELECT
    'bi_pedidos' AS validacion,
    COUNT(*) AS registros,
    COUNT(DISTINCT order_id) AS claves_unicas
FROM bi_pedidos

UNION ALL

SELECT
    'bi_items',
    COUNT(*),
    COUNT(DISTINCT (order_id, order_item_id))
FROM bi_items;



-- 6.3. Validar integridad referencial
    
SELECT
    'bi_items -> bi_productos' AS relacion,
    COUNT(*) AS registros_sin_correspondencia
FROM bi_items AS i
LEFT JOIN bi_productos AS p
    ON i.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT
    'bi_items -> bi_vendedores',
    COUNT(*)
FROM bi_items AS i
LEFT JOIN bi_vendedores AS v
    ON i.seller_id = v.seller_id
WHERE v.seller_id IS NULL

UNION ALL

SELECT
    'bi_pedidos -> bi_clientes',
    COUNT(*)
FROM bi_pedidos AS p
LEFT JOIN bi_clientes AS c
    ON p.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT
    'bi_items -> bi_pedidos',
    COUNT(*)
FROM bi_items AS i
LEFT JOIN bi_pedidos AS p
    ON i.order_id = p.order_id
WHERE p.order_id IS NULL;
