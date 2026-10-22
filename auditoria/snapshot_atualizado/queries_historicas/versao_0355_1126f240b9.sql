LOC1_CRIADOR_OS AS (
    SELECT
        X."NumeroOS",
        X."CriadoPorLOC1",
        X."DataCriacaoLOC1"

    FROM (
        SELECT
            L."U_callID" AS "NumeroOS",
            L."U_User" AS "CriadoPorLOC1",
            L."U_LogDateTime" AS "DataCriacaoLOC1",

            ROW_NUMBER() OVER (
                PARTITION BY L."U_callID"
                ORDER BY L."U_LogDateTime" ASC
            ) AS "LinhaControle"

        FROM "@LOC1_SCL7" L

        WHERE
            L."U_callID" IS NOT NULL
    ) X

    WHERE
        X."LinhaControle" = 1
),
