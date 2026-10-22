SELECT
    T0."DocEntry" AS "Nº interno",
    T0."DocNum" AS "Nº do documento",
    T0."Serial" AS "Nº de série",
    T0."DocDate" AS "Data de lançamento",
    T0."DocTotal" AS "Total do documento",
    T0."NfeValue" AS "Valor da NF-e",
    T0."DiscSum" AS "Desconto",
    T0."VatSum" AS "Imposto",
    T0."TotalExpns" AS "Despesas",

    T0."NfeValue" - T0."DocTotal" AS "Diferença NFe x DocTotal"

FROM OINV T0

WHERE
    T0."DocDate" BETWEEN '[%0]' AND '[%1]'
    AND T0."CANCELED" = 'N'
    AND IFNULL(T0."NfeValue", 0) <> IFNULL(T0."DocTotal", 0)

ORDER BY
    T0."DocDate",
    T0."DocNum";
