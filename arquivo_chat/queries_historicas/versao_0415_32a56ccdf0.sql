WITH LANCAMENTO AS
(
    SELECT
        J."TransId",
        J."RefDate",
        J."TransType",
        J."Memo"
    FROM OJDT J
    WHERE J."TransId" IN
    (
        19239,
        23147,
        23548,
        23882,
        24790,
        26322,
        26358,
        26421,
        26433,
        26946,
        28486,
        29826,
        31714
    )
),

DOCUMENTOS AS
(
    /* NOTA FISCAL DE ENTRADA */
    SELECT
        H."TransId",
        'Nota fiscal de entrada' AS "Tipo_Documento",
        H."DocEntry" AS "Chave_Documento",
        H."DocNum" AS "Numero_Documento",
        H."CANCELED" AS "Cancelado",
        H."CardCode" AS "Codigo_Parceiro",
        H."CardName" AS "Nome_Parceiro",

        L."LineNum" AS "Linha",
        L."ItemCode",
        L."Dscription",
        L."Quantity",
        L."Price",
        L."Currency",
        L."LineTotal",
        L."WhsCode",
        L."Project",
        L."OcrCode"

    FROM OPCH H

    INNER JOIN LANCAMENTO J
        ON J."TransId" = H."TransId"

    INNER JOIN PCH1 L
        ON L."DocEntry" = H."DocEntry"

    UNION ALL

    /* RECEBIMENTO DE MERCADORIAS DE COMPRA */
    SELECT
        H."TransId",
        'Recebimento de mercadorias de compra',
        H."DocEntry",
        H."DocNum",
        H."CANCELED",
        H."CardCode",
        H."CardName",

        L."LineNum",
        L."ItemCode",
        L."Dscription",
        L."Quantity",
        L."Price",
        L."Currency",
        L."LineTotal",
        L."WhsCode",
        L."Project",
        L."OcrCode"

    FROM OPDN H

    INNER JOIN LANCAMENTO J
        ON J."TransId" = H."TransId"

    INNER JOIN PDN1 L
        ON L."DocEntry" = H."DocEntry"

    UNION ALL

    /* TRANSFERENCIA DE ESTOQUE
       WhsCode representa o deposito de destino da linha. */
    SELECT
        H."TransId",
        'Transferencia de estoque',
        H."DocEntry",
        H."DocNum",
        H."CANCELED",
        H."CardCode",
        H."CardName",

        L."LineNum",
        L."ItemCode",
        L."Dscription",
        L."Quantity",
        L."Price",
        L."Currency",
        L."LineTotal",
        L."WhsCode",
        L."Project",
        L."OcrCode"

    FROM OWTR H

    INNER JOIN LANCAMENTO J
        ON J."TransId" = H."TransId"

    INNER JOIN WTR1 L
        ON L."DocEntry" = H."DocEntry"

    UNION ALL

    /* ENTRADA DE MERCADORIAS */
    SELECT
        H."TransId",
        'Entrada de mercadorias',
        H."DocEntry",
        H."DocNum",
        H."CANCELED",
        NULL,
        NULL,

        L."LineNum",
        L."ItemCode",
        L."Dscription",
        L."Quantity",
        L."Price",
        L."Currency",
        L."LineTotal",
        L."WhsCode",
        L."Project",
        L."OcrCode"

    FROM OIGN H

    INNER JOIN LANCAMENTO J
        ON J."TransId" = H."TransId"

    INNER JOIN IGN1 L
        ON L."DocEntry" = H."DocEntry"

    UNION ALL

    /* SAIDA DE MERCADORIAS */
    SELECT
        H."TransId",
        'Saida de mercadorias',
        H."DocEntry",
        H."DocNum",
        H."CANCELED",
        NULL,
        NULL,

        L."LineNum",
        L."ItemCode",
        L."Dscription",
        L."Quantity",
        L."Price",
        L."Currency",
        L."LineTotal",
        L."WhsCode",
        L."Project",
        L."OcrCode"

    FROM OIGE H

    INNER JOIN LANCAMENTO J
        ON J."TransId" = H."TransId"

    INNER JOIN IGE1 L
        ON L."DocEntry" = H."DocEntry"
)

SELECT
    J."TransId" AS "Numero_Transacao",
    J."RefDate" AS "Data_Lancamento",
    J."TransType" AS "Tipo_Origem_Contabil",

    D."Tipo_Documento",
    D."Chave_Documento",
    D."Numero_Documento",
    D."Cancelado",

    D."Codigo_Parceiro",
    D."Nome_Parceiro",

    D."Linha" + 1 AS "Linha_Documento",
    D."ItemCode" AS "Codigo_Material",
    D."Dscription" AS "Descricao_Material",

    D."Quantity" AS "Quantidade_Documento",
    D."Price" AS "Preco_Unitario_Documento",
    D."Currency" AS "Moeda_Preco_Unitario",
    D."LineTotal" AS "Valor_Linha_Moeda_Local",

    D."WhsCode" AS "Deposito_Linha",
    W."WhsName" AS "Nome_Deposito",

    D."Project" AS "Codigo_Projeto_Linha",
    P."PrjName" AS "Nome_Projeto",

    D."OcrCode" AS "Centro_Custo_Linha",
    C."OcrName" AS "Nome_Centro_Custo",

    CASE
        WHEN D."Chave_Documento" IS NULL
        THEN 'Origem nao contemplada nesta consulta - verificar tipo contabil'

        WHEN IFNULL(D."ItemCode", '') = ''
        THEN 'Linha sem codigo de material'

        ELSE 'Material localizado no documento de origem'
    END AS "Status_Consulta",

    J."Memo" AS "Observacoes_Lancamento"

FROM LANCAMENTO J

LEFT JOIN DOCUMENTOS D
    ON D."TransId" = J."TransId"

LEFT JOIN OWHS W
    ON W."WhsCode" = D."WhsCode"

LEFT JOIN OPRJ P
    ON P."PrjCode" = D."Project"

LEFT JOIN OOCR C
    ON C."OcrCode" = D."OcrCode"

ORDER BY
    J."RefDate",
    J."TransId",
    D."Tipo_Documento",
    D."Numero_Documento",
    D."Linha";
