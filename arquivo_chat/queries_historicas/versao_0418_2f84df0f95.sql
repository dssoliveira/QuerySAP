WITH TRANSFERENCIAS AS
(
    SELECT
        T."DocEntry",
        T."DocNum",
        T."CardName"
    FROM OWTQ T
    WHERE T."DocStatus" = 'O'
),

REFERENCIAS AS
(
    /* Solicitação de compra que referencia o pedido de transferência */
    SELECT
        T."DocNum" AS "Pedido Transferencia",
        T."DocEntry" AS "Chave Pedido Transferencia",
        T."CardName" AS "Parceiro Transferencia",

        'Solicitacao de compra' AS "Tipo Documento Relacionado",

        H."DocEntry" AS "Chave Documento Relacionado",
        H."DocNum" AS "Numero Documento Relacionado",
        H."DocDate" AS "Data Documento Relacionado",

        CAST(NULL AS NVARCHAR(200)) AS "Fornecedor",
        CAST(NULL AS NVARCHAR(1)) AS "Codigo Aprovacao",

        R."Remark" AS "Observacao Referencia"

    FROM TRANSFERENCIAS T

    INNER JOIN PRQ21 R
        ON R."RefDocEntr" = T."DocEntry"
       AND R."RefObjType" = '1250000001'
       AND R."RefType" = 'S'

    INNER JOIN OPRQ H
        ON H."DocEntry" = R."DocEntry"

    UNION ALL

    /* Pedido de compra que referencia o pedido de transferência */
    SELECT
        T."DocNum",
        T."DocEntry",
        T."CardName",

        'Pedido de compra',

        H."DocEntry",
        H."DocNum",
        H."DocDate",

        H."CardName",
        H."WddStatus",

        R."Remark"

    FROM TRANSFERENCIAS T

    INNER JOIN POR21 R
        ON R."RefDocEntr" = T."DocEntry"
       AND R."RefObjType" = '1250000001'
       AND R."RefType" = 'S'

    INNER JOIN OPOR H
        ON H."DocEntry" = R."DocEntry"

    UNION ALL

    /* Esboço de pedido de compra que referencia a transferência */
    SELECT
        T."DocNum",
        T."DocEntry",
        T."CardName",

        'Esboco de pedido de compra',

        H."DocEntry",
        H."DocNum",
        H."DocDate",

        H."CardName",
        H."WddStatus",

        R."Remark"

    FROM TRANSFERENCIAS T

    INNER JOIN DRF21 R
        ON R."RefDocEntr" = T."DocEntry"
       AND R."RefObjType" = '1250000001'
       AND R."RefType" = 'S'

    INNER JOIN ODRF H
        ON H."DocEntry" = R."DocEntry"
       AND H."ObjType" = '22'
)

SELECT DISTINCT
    R."Pedido Transferencia",
    R."Chave Pedido Transferencia",
    R."Parceiro Transferencia",

    R."Tipo Documento Relacionado",
    R."Chave Documento Relacionado",
    R."Numero Documento Relacionado",
    R."Data Documento Relacionado",

    R."Fornecedor",
    R."Codigo Aprovacao",

    CASE
        WHEN R."Tipo Documento Relacionado" = 'Solicitacao de compra'
        THEN 'Consultar pedido de compra posterior'

        WHEN R."Codigo Aprovacao" = 'W'
        THEN 'Pendente de aprovacao'

        WHEN R."Codigo Aprovacao" = 'Y'
        THEN 'Aprovado'

        WHEN R."Codigo Aprovacao" = 'N'
        THEN 'Rejeitado'

        WHEN R."Codigo Aprovacao" = 'P'
        THEN 'Gerado'

        WHEN R."Codigo Aprovacao" = 'A'
        THEN 'Gerado pelo autorizador'

        WHEN R."Codigo Aprovacao" = 'C'
        THEN 'Processo de aprovacao cancelado'

        WHEN R."Codigo Aprovacao" = '-'
        THEN 'Sem processo de aprovacao'

        ELSE 'Status nao identificado'
    END AS "Status Aprovacao",

    R."Observacao Referencia"

FROM REFERENCIAS R

ORDER BY
    R."Pedido Transferencia",
    R."Tipo Documento Relacionado",
    R."Numero Documento Relacionado";
