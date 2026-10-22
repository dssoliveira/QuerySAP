SELECT
    S4."Object" AS "ObjetoDocumento",
    S4."ObjectType" AS "TipoObjetoDocumento",

    CASE
        WHEN S4."Object" = '60' THEN 'Saida de Mercadoria'
        WHEN S4."Object" = '59' THEN 'Entrada de Mercadoria'
        WHEN S4."Object" = '22' THEN 'Pedido de Compra'
        WHEN S4."Object" = '20' THEN 'Recebimento de Mercadoria'
        WHEN S4."Object" = '18' THEN 'Nota Fiscal de Entrada'
        WHEN S4."Object" = '17' THEN 'Pedido de Venda'
        WHEN S4."Object" = '13' THEN 'Nota Fiscal de Saida'
        ELSE 'Outro / Validar'
    END AS "DescricaoObjeto",

    COUNT(*) AS "QuantidadeVinculos"

FROM SCL4 S4

GROUP BY
    S4."Object",
    S4."ObjectType"

ORDER BY
    COUNT(*) DESC;
