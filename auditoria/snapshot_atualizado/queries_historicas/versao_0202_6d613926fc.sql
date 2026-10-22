A AS (
    SELECT
        "OcrCode",
        SUM("Jan") AS "Jan",
        SUM("Fev") AS "Fev",
        ...
        SUM("AcumuladoSAP") AS "AcumuladoSAP"
    FROM (
        -- realizado atual da NF_BASE
        UNION ALL
        -- valores das entregas
    )
    GROUP BY
        "OcrCode"
),
