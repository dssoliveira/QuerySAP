WITH DECISOES AS (
    SELECT
        A."WddCode",

        MAX(
            CASE
                WHEN A."Status" = 'Y'
                THEN A."UpdateDate"
            END
        ) AS "DataUltimaAprovacao",

        MAX(
            CASE
                WHEN A."Status" = 'N'
                THEN A."UpdateDate"
            END
        ) AS "DataUltimaRecusa"

    FROM WDD1 A

    GROUP BY
        A."WddCode"
),

PROCESSOS AS (
    SELECT
        W."WddCode",
        W."DocEntry",
        W."DraftEntry",
        W."IsDraft",
        W."BFType",
        W."CreateDate",

        COALESCE(
            NULLIF(TRIM(W."ProcesStat"), ''),
            W."Status"
        ) AS "StatusProcesso",

        W."Status" AS "StatusSolicitacao",

        D."DataUltimaAprovacao",
        D."DataUltimaRecusa"

    FROM OWDD W

    LEFT JOIN DECISOES D
        ON D."WddCode" = W."WddCode"

    WHERE
        W."ObjType" = '22'
),

VINCULOS_PC AS (
    /* Pedido efetivo identificado pelo processo. */
    SELECT
        W."WddCode",
        P."DocEntry" AS "PedidoEntry"

    FROM PROCESSOS W

    INNER JOIN OPOR P
        ON P."DocEntry" = W."DocEntry"

    WHERE
        W."IsDraft" = 'N'

    UNION

    /* Pedido efetivo identificado pelo esboco de origem. */
    SELECT
        W."WddCode",
        P."DocEntry" AS "PedidoEntry"

    FROM PROCESSOS W

    INNER JOIN OPOR P
        ON P."draftKey" = W."DraftEntry"

    WHERE
        W."DraftEntry" > 0
)

SELECT
    W."WddCode" AS "Codigo Processo Aprovacao",

    CASE
        WHEN W."BFType" = 'A' THEN 'Criacao'
        WHEN W."BFType" = 'U' THEN 'Atualizacao'
        ELSE W."BFType"
    END AS "Finalidade Aprovacao",

    P."DocNum" AS "Numero Pedido Compra",

    D."DocEntry" AS "Chave Esboco Compra",

    CASE
        WHEN P."DocEntry" IS NOT NULL
            THEN 'Pedido de compra '
                 || TO_NVARCHAR(P."DocNum")

        WHEN D."DocEntry" IS NOT NULL
            THEN 'Esboco de pedido de compra '
                 || TO_NVARCHAR(D."DocEntry")

        ELSE 'Documento nao localizado'
    END AS "Documento Compra",

    COALESCE(
        P."CardName",
        D."CardName"
    ) AS "Fornecedor",

    CASE W."StatusProcesso"
        WHEN 'Y' THEN 'Autorizado'
        WHEN 'P' THEN 'Autorizado - documento gerado'
        WHEN 'A' THEN 'Autorizado - gerado pelo autorizador'
        WHEN 'N' THEN 'Recusado'
        WHEN 'W' THEN 'Aguardando aprovacao'
        WHEN 'C' THEN 'Processo cancelado'
        ELSE 'Status nao identificado'
    END AS "Status Aprovacao",

    CASE
        WHEN W."StatusProcesso" IN ('Y', 'P', 'A')
        THEN W."DataUltimaAprovacao"
    END AS "Data Autorizacao a Validar",

    CASE
        WHEN W."StatusProcesso" = 'N'
        THEN W."DataUltimaRecusa"
    END AS "Data Recusa a Validar",

    W."CreateDate" AS "Data Inicio Processo",

    W."StatusProcesso" AS "Status Processo SAP",

    W."StatusSolicitacao" AS "Status Solicitacao SAP"

FROM PROCESSOS W

LEFT JOIN VINCULOS_PC V
    ON V."WddCode" = W."WddCode"

LEFT JOIN OPOR P
    ON P."DocEntry" = V."PedidoEntry"

LEFT JOIN ODRF D
    ON D."ObjType" = '22'
   AND D."DocEntry" =
       CASE
           WHEN W."DraftEntry" > 0
               THEN W."DraftEntry"
           WHEN W."IsDraft" = 'Y'
               THEN W."DocEntry"
           ELSE NULL
       END

ORDER BY
    W."WddCode" DESC,
    P."DocNum";
