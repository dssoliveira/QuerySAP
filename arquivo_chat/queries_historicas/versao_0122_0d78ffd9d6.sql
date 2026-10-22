SELECT
    T0."DocEntry" AS "Num_Interno_NF",

    T0."DocNum" AS "Num_Documento_SAP",

    T0."Serial" AS "Numero_Nota_Fiscal",

    T0."DocDate" AS "Data_Emissao",

    T0."CardCode" AS "Cod_Cliente",

    T0."CardName" AS "Nome_Cliente",

    T3."DocNum" AS "Pedido_Venda",

    CASE
        WHEN T3."DocNum" IS NULL THEN 'NF sem vinculo com Pedido de Venda'
        ELSE 'NF vinculada ao Pedido de Venda'
    END AS "Origem_NF",

    IFNULL(T1."OcrCode", T2."OcrCode") AS "Departamento",

    T1."ItemCode" AS "Cod_Item",

    T1."Dscription" AS "Descricao_Item",

    T1."Quantity" AS "Quantidade",

    T1."LineTotal" AS "Total_Linha_Referencia",

    T0."DocTotal" AS "Valor_NFe_ML",

    CASE
        WHEN ROW_NUMBER() OVER (
            PARTITION BY T0."DocEntry"
            ORDER BY T1."LineNum"
        ) = 1
        THEN T0."DocTotal"
        ELSE 0
    END AS "Valor_NFe_ML_Para_Soma",

    CASE
        WHEN SUM(T1."LineTotal") OVER (
            PARTITION BY T0."DocEntry"
        ) = 0
        THEN 0
        ELSE
            ROUND(
                T0."DocTotal"
                *
                (
                    T1."LineTotal"
                    /
                    NULLIF(
                        SUM(T1."LineTotal") OVER (
                            PARTITION BY T0."DocEntry"
                        ),
                        0
                    )
                ),
                2
            )
    END AS "Valor_NFe_ML_Rateado_Linha"

FROM OINV T0

INNER JOIN INV1 T1
    ON T1."DocEntry" = T0."DocEntry"

LEFT JOIN RDR1 T2
    ON T1."BaseType" = 17
    AND T1."BaseEntry" = T2."DocEntry"
    AND T1."BaseLine" = T2."LineNum"

LEFT JOIN ORDR T3
    ON T3."DocEntry" = T2."DocEntry"

WHERE
    T0."DocDate" BETWEEN '[%0]' AND '[%1]'
    AND T0."CANCELED" = 'N'
    AND IFNULL(T1."OcrCode", T2."OcrCode") IS NOT NULL

ORDER BY
    T0."DocDate" DESC,
    T0."DocNum",
    T1."LineNum";
