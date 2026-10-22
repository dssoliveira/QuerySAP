ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2) AS "ValorMensalContrato",
T2."Quantity" AS "QuantidadeParcelas",
ROUND(T2."LineTotal", 2) AS "ValorTotalContrato",
