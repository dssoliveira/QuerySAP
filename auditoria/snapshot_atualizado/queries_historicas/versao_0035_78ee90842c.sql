SELECT
    T0."DocNum"                         AS "Pedido Compra",
    T0."DocEntry"                       AS "DocEntry PC",

    T0."BPLId"                          AS "Codigo Filial",
    BPL."BPLName"                       AS "Nome Filial",

    T0."DocDate"                        AS "Data Lancamento PC",
    T0."TaxDate"                        AS "Data Documento PC",
    T0."DocDueDate"                     AS "Data Entrega PC",

    T0."CardCode"                       AS "Cod. Fornecedor",
    T0."CardName"                       AS "Nome Fornecedor",

    CAST(T0."Header" AS NVARCHAR(5000)) AS "Observacoes Internas",
    CAST(T0."Comments" AS NVARCHAR(5000)) AS "Observacoes Externas",

    T1."LineNum"                        AS "Linha PC",
    T1."ItemCode"                       AS "Cod. Item",
    T1."Dscription"                     AS "Descricao Item",

    T1."Project"                        AS "Codigo Projeto Linha",
    PJ_LIN."PrjName"                    AS "Nome Projeto Linha",

    T1."OcrCode"                        AS "Departamento",
    DEP."OcrName"                       AS "Nome Departamento",

    T1."OcrCode2"                       AS "Etapa",
    ETA."OcrName"                       AS "Nome Etapa",

    T1."OcrCode3"                       AS "Titular",
    TIT."OcrName"                       AS "Nome Titular",

    T1."Quantity"                       AS "Qtd. Pedido",
    T1."OpenQty"                        AS "Qtd. Aberta",
    T1."Price"                          AS "Preco Unitario",
    T1."LineTotal"                      AS "Valor Linha PC",

    CASE
        WHEN T0."DocStatus" = 'O' THEN 'Aberto'
        WHEN T0."DocStatus" = 'C' THEN 'Fechado'
        ELSE T0."DocStatus"
    END                                 AS "Status Pedido",

    GR."DocNums"                        AS "Recebimento Mercadoria",
    GR."DocDate"                        AS "Data Recebimento",
    IFNULL(GR."Quantity", 0)            AS "Qtd. Recebida",
    IFNULL(GR."LineTotal", 0)           AS "Valor Recebido",

    NF_DIR."DocNums"                    AS "NF Entrada Direta PC",
    NF_DIR."Serials"                    AS "Numero NF Direta",
    NF_DIR."DocDate"                    AS "Data NF Direta",
    IFNULL(NF_DIR."Quantity", 0)        AS "Qtd. NF Direta",
    IFNULL(NF_DIR."LineTotal", 0)       AS "Valor NF Direta",

    NF_GR."DocNums"                     AS "NF Entrada via Recebimento",
    NF_GR."Serials"                     AS "Numero NF via Recebimento",
    NF_GR."DocDate"                     AS "Data NF via Recebimento",
    IFNULL(NF_GR."Quantity", 0)         AS "Qtd. NF via Recebimento",
    IFNULL(NF_GR."LineTotal", 0)        AS "Valor NF via Recebimento",

    DEV."DocNums"                       AS "Devolucao Mercadoria",
    DEV."DocDate"                       AS "Data Devolucao",
    IFNULL(DEV."Quantity", 0)           AS "Qtd. Devolvida",
    IFNULL(DEV."LineTotal", 0)          AS "Valor Devolvido",

    CASE
        WHEN NF_DIR."DocNums" IS NOT NULL
             AND NF_GR."DocNums" IS NOT NULL
        THEN 'NF direta e via Recebimento'

        WHEN NF_DIR."DocNums" IS NOT NULL
        THEN 'NF direta do Pedido'

        WHEN NF_GR."DocNums" IS NOT NULL
        THEN 'NF via Recebimento'

        WHEN GR."DocNums" IS NOT NULL
        THEN 'Recebido sem NF'

        ELSE 'Sem documento vinculado'
    END                                 AS "Situacao Vinculo"

FROM OPOR T0

INNER JOIN POR1 T1
    ON T1."DocEntry" = T0."DocEntry"

LEFT JOIN OBPL BPL
    ON BPL."BPLId" = T0."BPLId"

LEFT JOIN OPRJ PJ_LIN
    ON PJ_LIN."PrjCode" = T1."Project"

LEFT JOIN OOCR DEP
    ON DEP."OcrCode" = T1."OcrCode"

LEFT JOIN OOCR ETA
    ON ETA."OcrCode" = T1."OcrCode2"

LEFT JOIN OOCR TIT
    ON TIT."OcrCode" = T1."OcrCode3"

LEFT JOIN (
    SELECT
        L."BaseEntry",
        L."BaseLine",
        STRING_AGG(TO_VARCHAR(H."DocNum"), ', ') AS "DocNums",
        MAX(H."DocDate")                         AS "DocDate",
        SUM(L."Quantity")                        AS "Quantity",
        SUM(L."LineTotal")                       AS "LineTotal"
    FROM PDN1 L
    INNER JOIN OPDN H
        ON H."DocEntry" = L."DocEntry"
        AND H."CANCELED" = 'N'
    WHERE
        L."BaseType" = 22
    GROUP BY
        L."BaseEntry",
        L."BaseLine"
) GR
    ON GR."BaseEntry" = T1."DocEntry"
    AND GR."BaseLine" = T1."LineNum"

LEFT JOIN (
    SELECT
        L."BaseEntry",
        L."BaseLine",
        STRING_AGG(TO_VARCHAR(H."DocNum"), ', ') AS "DocNums",
        STRING_AGG(TO_VARCHAR(H."Serial"), ', ') AS "Serials",
        MAX(H."DocDate")                         AS "DocDate",
        SUM(L."Quantity")                        AS "Quantity",
        SUM(L."LineTotal")                       AS "LineTotal"
    FROM PCH1 L
    INNER JOIN OPCH H
        ON H."DocEntry" = L."DocEntry"
        AND H."CANCELED" = 'N'
    WHERE
        L."BaseType" = 22
    GROUP BY
        L."BaseEntry",
        L."BaseLine"
) NF_DIR
    ON NF_DIR."BaseEntry" = T1."DocEntry"
    AND NF_DIR."BaseLine" = T1."LineNum"

LEFT JOIN (
    SELECT
        GRL."BaseEntry",
        GRL."BaseLine",
        STRING_AGG(TO_VARCHAR(NF."DocNum"), ', ') AS "DocNums",
        STRING_AGG(TO_VARCHAR(NF."Serial"), ', ') AS "Serials",
        MAX(NF."DocDate")                         AS "DocDate",
        SUM(NFL."Quantity")                       AS "Quantity",
        SUM(NFL."LineTotal")                      AS "LineTotal"
    FROM PDN1 GRL
    INNER JOIN OPDN GR
        ON GR."DocEntry" = GRL."DocEntry"
        AND GR."CANCELED" = 'N'
    INNER JOIN PCH1 NFL
        ON NFL."BaseType" = 20
        AND NFL."BaseEntry" = GRL."DocEntry"
        AND NFL."BaseLine" = GRL."LineNum"
    INNER JOIN OPCH NF
        ON NF."DocEntry" = NFL."DocEntry"
        AND NF."CANCELED" = 'N'
    WHERE
        GRL."BaseType" = 22
    GROUP BY
        GRL."BaseEntry",
        GRL."BaseLine"
) NF_GR
    ON NF_GR."BaseEntry" = T1."DocEntry"
    AND NF_GR."BaseLine" = T1."LineNum"

LEFT JOIN (
    SELECT
        GRL."BaseEntry",
        GRL."BaseLine",
        STRING_AGG(TO_VARCHAR(DEV."DocNum"), ', ') AS "DocNums",
        MAX(DEV."DocDate")                         AS "DocDate",
        SUM(DEVL."Quantity")                       AS "Quantity",
        SUM(DEVL."LineTotal")                      AS "LineTotal"
    FROM PDN1 GRL
    INNER JOIN OPDN GR
        ON GR."DocEntry" = GRL."DocEntry"
        AND GR."CANCELED" = 'N'
    INNER JOIN RPD1 DEVL
        ON DEVL."BaseType" = 20
        AND DEVL."BaseEntry" = GRL."DocEntry"
        AND DEVL."BaseLine" = GRL."LineNum"
    INNER JOIN ORPD DEV
        ON DEV."DocEntry" = DEVL."DocEntry"
        AND DEV."CANCELED" = 'N'
    WHERE
        GRL."BaseType" = 22
    GROUP BY
        GRL."BaseEntry",
        GRL."BaseLine"
) DEV
    ON DEV."BaseEntry" = T1."DocEntry"
    AND DEV."BaseLine" = T1."LineNum"

WHERE
    T0."CANCELED" = 'N'
    AND (T0."DocDate" >= '[%0]' OR '[%0]' = '')
    AND (T0."CardCode" = '[%1]' OR '[%1]' = '')

ORDER BY
    T0."DocDate",
    T0."DocNum",
    T1."LineNum";
