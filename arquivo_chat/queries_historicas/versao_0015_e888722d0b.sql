SELECT
    T0."DocNum"                         AS "Pedido Compra",
    T0."DocEntry"                       AS "DocEntry PC",
    T0."DocDate"                        AS "Data Lancamento PC",
    T0."TaxDate"                        AS "Data Documento PC",
    T0."DocDueDate"                     AS "Data Entrega PC",

    T0."CardCode"                       AS "Cod. Fornecedor",
    T0."CardName"                       AS "Nome Fornecedor",

    T0."Project"                        AS "Codigo Projeto",
    PJ."PrjName"                        AS "Nome Projeto",
    T0."Comments"                       AS "Observacoes Externas",

    T1."LineNum"                        AS "Linha PC",
    T1."ItemCode"                       AS "Cod. Item",
    T1."Dscription"                     AS "Descricao Item",
    T1."Quantity"                       AS "Qtd. Pedido",
    T1."OpenQty"                        AS "Qtd. Aberta",
    T1."Price"                          AS "Preco Unitario",
    T1."LineTotal"                      AS "Valor Linha PC",

    CASE
        WHEN T0."DocStatus" = 'O' THEN 'Aberto'
        WHEN T0."DocStatus" = 'C' THEN 'Fechado'
        ELSE T0."DocStatus"
    END                                 AS "Status Pedido",

    GR."DocNum"                         AS "Recebimento Mercadoria",
    GR."DocDate"                        AS "Data Recebimento",
    GRL."Quantity"                      AS "Qtd. Recebida",
    GRL."LineTotal"                     AS "Valor Recebido",

    NF_DIR."DocNum"                     AS "NF Entrada Direta PC",
    NF_DIR."Serial"                     AS "Numero NF Direta",
    NF_DIR."DocDate"                    AS "Data NF Direta",
    NFL_DIR."Quantity"                  AS "Qtd. NF Direta",
    NFL_DIR."LineTotal"                 AS "Valor NF Direta",

    NF_GR."DocNum"                      AS "NF Entrada via Recebimento",
    NF_GR."Serial"                      AS "Numero NF via Recebimento",
    NF_GR."DocDate"                     AS "Data NF via Recebimento",
    NFL_GR."Quantity"                   AS "Qtd. NF via Recebimento",
    NFL_GR."LineTotal"                  AS "Valor NF via Recebimento",

    DEV."DocNum"                        AS "Devolucao Mercadoria",
    DEV."DocDate"                       AS "Data Devolucao",
    DEVL."Quantity"                     AS "Qtd. Devolvida",
    DEVL."LineTotal"                    AS "Valor Devolvido",

    CASE
        WHEN NF_DIR."DocNum" IS NOT NULL THEN 'NF direta do Pedido'
        WHEN NF_GR."DocNum" IS NOT NULL THEN 'NF via Recebimento'
        WHEN GR."DocNum" IS NOT NULL THEN 'Recebido sem NF'
        ELSE 'Sem documento vinculado'
    END                                 AS "Situacao Vinculo"

FROM OPOR T0

INNER JOIN POR1 T1
    ON T1."DocEntry" = T0."DocEntry"

LEFT JOIN OPRJ PJ
    ON PJ."PrjCode" = T0."Project"

LEFT JOIN PDN1 GRL
    ON GRL."BaseType" = 22
    AND GRL."BaseEntry" = T1."DocEntry"
    AND GRL."BaseLine" = T1."LineNum"

LEFT JOIN OPDN GR
    ON GR."DocEntry" = GRL."DocEntry"
    AND GR."CANCELED" = 'N'

LEFT JOIN PCH1 NFL_DIR
    ON NFL_DIR."BaseType" = 22
    AND NFL_DIR."BaseEntry" = T1."DocEntry"
    AND NFL_DIR."BaseLine" = T1."LineNum"

LEFT JOIN OPCH NF_DIR
    ON NF_DIR."DocEntry" = NFL_DIR."DocEntry"
    AND NF_DIR."CANCELED" = 'N'

LEFT JOIN PCH1 NFL_GR
    ON NFL_GR."BaseType" = 20
    AND NFL_GR."BaseEntry" = GRL."DocEntry"
    AND NFL_GR."BaseLine" = GRL."LineNum"

LEFT JOIN OPCH NF_GR
    ON NF_GR."DocEntry" = NFL_GR."DocEntry"
    AND NF_GR."CANCELED" = 'N'

LEFT JOIN RPD1 DEVL
    ON DEVL."BaseType" = 20
    AND DEVL."BaseEntry" = GRL."DocEntry"
    AND DEVL."BaseLine" = GRL."LineNum"

LEFT JOIN ORPD DEV
    ON DEV."DocEntry" = DEVL."DocEntry"
    AND DEV."CANCELED" = 'N'

WHERE
    T0."CANCELED" = 'N'
    AND (T0."DocDate" >= '[%0]' OR '[%0]' = '')
    AND (T0."CardCode" = '[%1]' OR '[%1]' = '')

ORDER BY
    T0."DocDate",
    T0."DocNum",
    T1."LineNum";
