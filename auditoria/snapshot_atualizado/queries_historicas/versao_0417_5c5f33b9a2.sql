SELECT
    T0."DocNum" AS "Pedido Transferencia",
    T0."DocEntry" AS "Chave Pedido Transferencia",
    T0."DocDate" AS "Data Lancamento",

    T0."CardCode" AS "Codigo Parceiro",
    T0."CardName" AS "Nome Parceiro",

    T0."U_MM_OS" AS "Referencia OS",

    CAST(
        SUBSTRING(
            TO_NVARCHAR(T0."U_MM_NumDoc"),
            1,
            254
        ) AS NVARCHAR(254)
    ) AS "Referencia Solicitacao Compra",

    L."LineNum" + 1 AS "Linha",
    L."ItemCode" AS "Codigo Item",
    L."Dscription" AS "Descricao Item",
    L."Quantity" AS "Quantidade",

    L."BaseType" AS "Tipo Documento Origem",
    L."BaseEntry" AS "Chave Documento Origem",
    L."BaseLine" AS "Linha Documento Origem",

    L."TargetType" AS "Tipo Documento Destino",
    L."TrgetEntry" AS "Chave Documento Destino",

    T0."Comments" AS "Observacoes"

FROM OWTQ T0

LEFT JOIN WTQ1 L
    ON L."DocEntry" = T0."DocEntry"

WHERE
    T0."DocStatus" = 'O'

ORDER BY
    T0."DocNum",
    L."LineNum";
