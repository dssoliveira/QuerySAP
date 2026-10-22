SELECT
    L."U_LogDate" AS "Data Log",
    L."U_User" AS "Usuario LOC1",
    L."U_Operation" AS "Operacao",
    L."U_DataCode" AS "Codigo Dados",
    L."U_DataTable" AS "Tabela Dados",

    CAST(
        SUBSTRING(L."U_Log", 1, 5000)
        AS NVARCHAR(5000)
    ) AS "Log LOC1"

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

ORDER BY
    L."U_LogDate" DESC;
