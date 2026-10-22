SELECT
    T0."DocEntry" AS "Num_Interno_NF",
    T0."DocNum" AS "Num_Documento_SAP",
    T0."Serial" AS "Numero_Nota_Fiscal",
    T0."DocDate" AS "Data_Emissao",
    T0."CardCode" AS "Cod_Cliente",
    T0."CardName" AS "Nome_Cliente",

    T0."DocTotal" AS "Valor_NFe_ML",

    T0."DocTotal"
        + T0."DiscSum"
        - T0."VatSum"
        - T0."TotalExpns" AS "Valor_Calculo_Antigo",

    T0."DocTotal"
        -
        (
            T0."DocTotal"
            + T0."DiscSum"
            - T0."VatSum"
            - T0."TotalExpns"
        ) AS "Diferenca",

    T0."DiscSum" AS "Desconto_NF",
    T0."VatSum" AS "Imposto_NF",
    T0."TotalExpns" AS "Despesas_NF"

FROM OINV T0

WHERE
    T0."DocDate" BETWEEN '[%0]' AND '[%1]'
    AND T0."CANCELED" = 'N'

ORDER BY
    T0."DocDate" DESC,
    T0."DocNum";
