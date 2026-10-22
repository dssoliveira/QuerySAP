LEFT JOIN (
    SELECT
        R1."DocEntry",
        R1."OcrCode",
        MIN(R1."Dscription") AS "Dscription",
        SUM(R1."Quantity") AS "Quantity",
        SUM(R1."LineTotal") AS "LineTotal"
    FROM RDR1 R1
    WHERE
        R1."OcrCode" IN ('GERADOR', 'NOBREAK')
    GROUP BY
        R1."DocEntry",
        R1."OcrCode"
) T2
    ON T2."DocEntry" = T1."DocEntry"
