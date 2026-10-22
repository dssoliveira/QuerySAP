INNER JOIN (
    SELECT
        Q."DocEntry",
        COUNT(*) AS "QtdCentrosCusto"
    FROM (
        SELECT DISTINCT
            R1_QTD."DocEntry",
            R1_QTD."OcrCode"
        FROM RDR1 R1_QTD
        WHERE
            R1_QTD."OcrCode" IN (
                'GERADOR',
                'NOBREAK',
                'EXE_ELET',
                'FOTOV',
                'REV_DIRE'
            )
    ) Q
    GROUP BY
        Q."DocEntry"
) QTD_CC
    ON QTD_CC."DocEntry" = C."DocEntry"
