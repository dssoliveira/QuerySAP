LOC1_CRIADOR_OS_BASE AS (
    SELECT
        TO_INTEGER(
            SUBSTRING(
                LTRIM(
                    SUBSTRING(
                        B."LogLOC1",
                        LOCATE(UPPER(B."LogLOC1"), 'ADICIONADO:') + LENGTH('ADICIONADO:')
                    )
                ),
                1,
                LOCATE(
                    LTRIM(
                        SUBSTRING(
                            B."LogLOC1",
                            LOCATE(UPPER(B."LogLOC1"), 'ADICIONADO:') + LENGTH('ADICIONADO:')
                        )
                    ) || ' ',
                    ' '
                ) - 1
            )
        ) AS "NumeroOS",

        B."UsuarioLOC1" AS "CriadoPorLOC1",
        B."DataLogLOC1" AS "DataCriacaoLOC1"

    FROM (
        SELECT
            L."U_User" AS "UsuarioLOC1",
            L."U_LogDate" AS "DataLogLOC1",

            CAST(
                SUBSTRING(L."U_Log", 1, 5000)
                AS NVARCHAR(5000)
            ) AS "LogLOC1"

        FROM "@LOC1_CHLO" L

        WHERE
            UPPER(L."U_Operation") = 'ADICIONAR'
            AND UPPER(
                CAST(
                    SUBSTRING(L."U_Log", 1, 5000)
                    AS NVARCHAR(5000)
                )
            ) LIKE '%CHAMADO DE SERVI%'
            AND UPPER(
                CAST(
                    SUBSTRING(L."U_Log", 1, 5000)
                    AS NVARCHAR(5000)
                )
            ) LIKE '%ADICIONADO:%'
    ) B
),

LOC1_CRIADOR_OS_RANK AS (
    SELECT
        L."NumeroOS",
        L."CriadoPorLOC1",
        L."DataCriacaoLOC1",

        ROW_NUMBER() OVER (
            PARTITION BY L."NumeroOS"
            ORDER BY
                L."DataCriacaoLOC1" ASC
        ) AS "LinhaControle"

    FROM LOC1_CRIADOR_OS_BASE L
),

LOC1_CRIADOR_OS AS (
    SELECT
        L."NumeroOS",
        L."CriadoPorLOC1",
        L."DataCriacaoLOC1"

    FROM LOC1_CRIADOR_OS_RANK L

    WHERE
        L."LinhaControle" = 1
),
