LOC1_CRIADOR_OS AS (
    SELECT
        TO_INTEGER(
            SUBSTRING(
                L."CampoLog",
                LOCATE(L."CampoLog", 'Chamado de Serviço adicionado: ') + LENGTH('Chamado de Serviço adicionado: ')
            )
        ) AS "NumeroOS",

        L."Usuario" AS "CriadoPorLOC1",
        L."Data" AS "DataCriacaoLOC1"

    FROM "TABELA_LOG_LOC1" L

    WHERE
        L."Operacao" = 'Adicionar'
        AND L."CampoLog" LIKE '%Chamado de Serviço adicionado:%'
)
