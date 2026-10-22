LEFT JOIN (
    SELECT
        X."NumeroOS",

        SUM(X."CustoIncidente") AS "CustoIncidente",
        SUM(X."CustoOpcaoCompra") AS "CustoOpcaoCompra",
        SUM(X."CustoCombustivel") AS "CustoCombustivel"

    FROM (
        SELECT
            S5."U_callID" AS "NumeroOS",

            CASE
                WHEN IFNULL(S5."U_IncidentTotal", 0) <> 0
                THEN IFNULL(S5."U_IncidentTotal", 0)
                ELSE IFNULL(S5."U_IncidentAmount", 0) + IFNULL(S5."U_IncidentFine", 0)
            END AS "CustoIncidente",

            0 AS "CustoOpcaoCompra",
            0 AS "CustoCombustivel"

        FROM "@LOC1_SCL5" S5

        UNION ALL

        SELECT
            S6."U_callID" AS "NumeroOS",

            0 AS "CustoIncidente",

            CASE
                WHEN IFNULL(S6."U_PurOptTotal", 0) <> 0
                THEN IFNULL(S6."U_PurOptTotal", 0)
                ELSE
                    IFNULL(S6."U_PurOptValue", 0)
                    - IFNULL(S6."U_PurOptDiscount", 0)
                    + IFNULL(S6."U_PurOptFine", 0)
            END AS "CustoOpcaoCompra",

            0 AS "CustoCombustivel"

        FROM "@LOC1_SCL6" S6

        UNION ALL

        SELECT
            S3."U_callID" AS "NumeroOS",

            0 AS "CustoIncidente",
            0 AS "CustoOpcaoCompra",
            IFNULL(S3."U_FuelAmount", 0) AS "CustoCombustivel"

        FROM "@LOC1_SCL3" S3
    ) X

    GROUP BY
        X."NumeroOS"
) LOC1C
    ON LOC1C."NumeroOS" = OS0."callID"
