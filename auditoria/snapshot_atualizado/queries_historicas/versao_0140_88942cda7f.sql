SELECT
    T0."DocEntry",
    T0."DocNum",
    T0."Serial",
    T0."DocDate",

    T0."DocTotal" AS "DocTotal",

    T0."NfeValue" AS "NfeValue",

    T0."DiscSum" AS "Desconto",
    T0."VatSum" AS "Imposto",
    T0."TotalExpns" AS "Despesas"

FROM OINV T0

WHERE
    T0."DocNum" = 2772;
