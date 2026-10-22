INNER JOIN RDR1 T2
    ON T2."DocEntry" = T1."DocEntry"
    AND (
        '[%0]' = ''
        OR UPPER(TRIM(T2."OcrCode")) = UPPER(TRIM('[%0]'))
    )
