SELECT
    H."DocNum" AS "Numero_Saida",
    H."DocEntry" AS "Chave_Interna_Saida",
    H."DocDate" AS "Data_Saida",
    H."Comments" AS "Observacoes_Saida",

    L."LineNum" + 1 AS "Linha",
    L."ItemCode" AS "Codigo_Item",
    L."Dscription" AS "Descricao_Item",
    L."Quantity" AS "Quantidade",

    L."BaseType" AS "Tipo_Documento_Base",
    L."BaseEntry" AS "Chave_Documento_Base",
    L."BaseLine" + 1 AS "Linha_Documento_Base",

    CASE L."BaseType"
        WHEN 17 THEN 'Pedido de Venda'
        WHEN 15 THEN 'Entrega'
        WHEN 67 THEN 'Transferencia de Estoque'
        WHEN 1250000001 THEN 'Pedido de Transferencia'
        ELSE 'Sem documento-base'
    END AS "Descricao_Documento_Base"

FROM OIGE H
INNER JOIN IGE1 L
    ON L."DocEntry" = H."DocEntry"

WHERE L."ItemCode" IN (
    'MA003838',
    'MA004404',
    'MA003628'
)

ORDER BY
    H."DocDate",
    H."DocNum",
    L."LineNum";
