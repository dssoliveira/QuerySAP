SELECT DISTINCT
    T0."U_ContractID" AS "Nº CONTRATO",
    T4."OcrCode"      AS "DEPARTAMENTO/CENTRO DE CUSTO",

    T3."CardCode"     AS "CÓD.CLIENTE",
    T3."CardName"     AS "NOME CLIENTE",

    T3."DocNum"       AS "PED.VENDA",
    T3."DocDate"      AS "DATA PED.VENDA",
    T3."DocTotal"     AS "VALOR PED.VENDA",

    T6."DocNum"       AS "DOCUMENTO SAP NF",
    T6."Serial"       AS "Nº NOTA FISCAL",
    T6."DocDate"      AS "DATA NF",
    T6."DocTotal"     AS "VALOR TOTAL NF",

    CASE
        WHEN T6."DocEntry" IS NULL
            THEN 'SEM NOTA FISCAL'

        WHEN T6."CANCELED" = 'Y'
            THEN 'NOTA FISCAL CANCELADA'

        ELSE 'FATURADO'
    END AS "STATUS FATURAMENTO"

FROM "@LOC1_CTR" T0

INNER JOIN "@LOC1_BILL" T1
    ON T1."U_ContractID" = T0."U_ContractID"

INNER JOIN "@LOC1_BILL1" T2
    ON T2."U_BillCode" = T1."Code"

INNER JOIN ORDR T3
    ON T3."DocEntry" = TO_INTEGER(T2."U_DocEntry")

INNER JOIN RDR1 T4
    ON T4."DocEntry" = T3."DocEntry"
    AND T4."OcrCode" = 'GERADOR'

LEFT JOIN INV1 T5
    ON T5."BaseEntry" = T4."DocEntry"
    AND T5."BaseLine" = T4."LineNum"
    AND T5."BaseType" = 17

LEFT JOIN OINV T6
    ON T6."DocEntry" = T5."DocEntry"

WHERE
    T1."U_BillingStatus" = 'Confirmed'
    AND T3."CANCELED" = 'N'
    AND (
        T3."DocDate" BETWEEN '[%0]' AND '[%1]'
        OR ('[%0]' = '' AND '[%1]' = '')
    )

ORDER BY
    1,
    6
