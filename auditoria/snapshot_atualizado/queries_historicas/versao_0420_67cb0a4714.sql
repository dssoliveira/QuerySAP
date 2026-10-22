WITH LINHAS AS
(
    SELECT
        L."DocEntry",

        CASE
            WHEN COUNT(DISTINCT IFNULL(L."Project", '')) <= 1
            THEN MAX(L."Project")
            ELSE 'MULTIPLOS'
        END AS "Projeto",

        CASE
            WHEN COUNT(DISTINCT IFNULL(L."OcrCode", '')) <= 1
            THEN MAX(L."OcrCode")
            ELSE 'MULTIPLOS'
        END AS "Departamento"

    FROM WTQ1 L
    GROUP BY L."DocEntry"
),

SOLICITACOES AS
(
    SELECT DISTINCT
        T."DocEntry" AS "TransferenciaEntry",
        S."DocEntry" AS "SolicitacaoEntry",
        S."DocNum" AS "SolicitacaoNumero",
        S."CANCELED" AS "SolicitacaoCancelada"

    FROM OWTQ T

    INNER JOIN PRQ21 R
        ON R."RefDocEntr" = T."DocEntry"
       AND R."RefObjType" = '1250000001'
       AND R."RefType" = 'S'

    INNER JOIN OPRQ S
        ON S."DocEntry" = R."DocEntry"

    WHERE T."DocStatus" = 'O'
),

SOLICITACOES_RESUMO AS
(
    SELECT
        S."TransferenciaEntry",

        STRING_AGG(
            TO_NVARCHAR(S."SolicitacaoNumero")
            || CASE
                   WHEN S."SolicitacaoCancelada" = 'Y'
                   THEN ' (cancelada)'
                   ELSE ''
               END,
            ', '
        ) AS "NumerosSolicitacoes"

    FROM SOLICITACOES S
    GROUP BY S."TransferenciaEntry"
),

DOCUMENTOS_COMPRA AS
(
    SELECT
        'PC' AS "Classe",
        P."DocEntry",
        P."DocNum",
        P."CardName",
        P."DocStatus",
        P."CANCELED",
        P."WddStatus"

    FROM OPOR P

    UNION ALL

    SELECT
        'ESBOCO',
        D."DocEntry",
        D."DocNum",
        D."CardName",
        D."DocStatus",
        D."CANCELED",
        D."WddStatus"

    FROM ODRF D

    WHERE D."ObjType" = '22'
      AND D."DocStatus" = 'O'
      AND D."CANCELED" = 'N'

      AND NOT EXISTS
      (
          SELECT 1
          FROM OPOR P
          WHERE P."draftKey" = D."DocEntry"
      )
),

LINHAS_COMPRA AS
(
    SELECT
        D."Classe",
        D."DocEntry",
        L."BaseType",
        L."BaseEntry",
        L."BaseLine"

    FROM DOCUMENTOS_COMPRA D

    INNER JOIN POR1 L
        ON L."DocEntry" = D."DocEntry"

    WHERE D."Classe" = 'PC'

    UNION ALL

    SELECT
        D."Classe",
        D."DocEntry",
        L."BaseType",
        L."BaseEntry",
        L."BaseLine"

    FROM DOCUMENTOS_COMPRA D

    INNER JOIN DRF1 L
        ON L."DocEntry" = D."DocEntry"

    WHERE D."Classe" = 'ESBOCO'
),

VINCULOS_COMPRA AS
(
    /* Solicitação -> pedido de compra ou esboço */
    SELECT
        S."TransferenciaEntry",
        C."Classe",
        C."DocEntry"

    FROM SOLICITACOES S

    INNER JOIN LINHAS_COMPRA C
        ON C."BaseType" = 1470000113
       AND C."BaseEntry" = S."SolicitacaoEntry"

    UNION

    /* Solicitação -> cotação -> pedido de compra ou esboço */
    SELECT
        S."TransferenciaEntry",
        C."Classe",
        C."DocEntry"

    FROM SOLICITACOES S

    INNER JOIN PQT1 Q
        ON Q."BaseType" = 1470000113
       AND Q."BaseEntry" = S."SolicitacaoEntry"

    INNER JOIN LINHAS_COMPRA C
        ON C."BaseType" = 540000006
       AND C."BaseEntry" = Q."DocEntry"
       AND C."BaseLine" = Q."LineNum"

    UNION

    /* Pedido de compra referencia a solicitação */
    SELECT
        S."TransferenciaEntry",
        'PC',
        R."DocEntry"

    FROM SOLICITACOES S

    INNER JOIN POR21 R
        ON R."RefDocEntr" = S."SolicitacaoEntry"
       AND R."RefObjType" = '1470000113'
       AND R."RefType" = 'S'

    UNION

    /* Esboço referencia a solicitação */
    SELECT
        S."TransferenciaEntry",
        'ESBOCO',
        R."DocEntry"

    FROM SOLICITACOES S

    INNER JOIN DRF21 R
        ON R."RefDocEntr" = S."SolicitacaoEntry"
       AND R."RefObjType" = '1470000113'
       AND R."RefType" = 'S'
),

COMPRAS_DETALHE AS
(
    SELECT DISTINCT
        V."TransferenciaEntry",
        D."Classe",
        D."DocEntry",
        D."DocNum",
        D."CardName",

        CASE
            WHEN D."CANCELED" = 'Y' THEN 'Cancelado'
            WHEN D."DocStatus" = 'O' THEN 'Aberto'
            WHEN D."DocStatus" = 'C' THEN 'Fechado'
            ELSE IFNULL(D."DocStatus", 'Nao identificado')
        END AS "StatusDocumento",

        CASE D."WddStatus"
            WHEN 'W' THEN 'Pendente de aprovacao'
            WHEN 'Y' THEN 'Aprovado'
            WHEN 'N' THEN 'Rejeitado'
            WHEN 'P' THEN 'Gerado'
            WHEN 'A' THEN 'Gerado pelo autorizador'
            WHEN 'C' THEN 'Processo de aprovacao cancelado'
            WHEN '-' THEN 'Sem processo de aprovacao'
            ELSE 'Status de aprovacao nao identificado'
        END AS "StatusAprovacao"

    FROM VINCULOS_COMPRA V

    INNER JOIN DOCUMENTOS_COMPRA D
        ON D."Classe" = V."Classe"
       AND D."DocEntry" = V."DocEntry"
),

COMPRAS_RESUMO AS
(
    SELECT
        C."TransferenciaEntry",

        /* Contagem interna utilizada no status do vínculo */
        SUM(
            CASE WHEN C."Classe" = 'PC'
                 THEN 1 ELSE 0 END
        ) AS "QuantidadePC",

        SUM(
            CASE WHEN C."Classe" = 'ESBOCO'
                 THEN 1 ELSE 0 END
        ) AS "QuantidadeEsbocos",

        STRING_AGG(
            CASE
                WHEN C."Classe" = 'PC'
                THEN TO_NVARCHAR(C."DocNum")
                ELSE NULL
            END,
            ', '
        ) AS "NumerosPC",

        STRING_AGG(
            CASE
                WHEN C."Classe" = 'PC'
                THEN
                    TO_NVARCHAR(C."DocNum")
                    || ': '
                    || C."StatusAprovacao"
                ELSE NULL
            END,
            ' | '
        ) AS "AprovacaoPC",

        STRING_AGG(
            CASE
                WHEN C."Classe" = 'PC'
                THEN
                    TO_NVARCHAR(C."DocNum")
                    || ': '
                    || C."StatusDocumento"
                ELSE NULL
            END,
            ' | '
        ) AS "StatusPC",

        STRING_AGG(
            CASE
                WHEN C."Classe" = 'PC'
                THEN
                    TO_NVARCHAR(C."DocNum")
                    || ': '
                    || IFNULL(C."CardName", '')
                ELSE NULL
            END,
            ' | '
        ) AS "FornecedoresPC",

        STRING_AGG(
            CASE
                WHEN C."Classe" = 'ESBOCO'
                THEN
                    'Esboco '
                    || TO_NVARCHAR(C."DocEntry")
                    || ': '
                    || C."StatusAprovacao"
                    || ' - '
                    || IFNULL(C."CardName", '')
                ELSE NULL
            END,
            ' | '
        ) AS "EsbocosAprovacao"

    FROM COMPRAS_DETALHE C

    GROUP BY C."TransferenciaEntry"
)

SELECT
    USR_CRIADOR."U_NAME" AS "Criado por - Nome Usuario",

    T0."DocNum" AS "Numero Pedido Transferencia",

    T0."DocDate" AS "Data Lancamento",
    T0."DocDueDate" AS "Data Vencimento",

    T0."CardCode" AS "Codigo Parceiro Negocio",
    T0."CardName" AS "Nome Parceiro Negocio",

    CASE
        WHEN UPPER(T0."BPLName") LIKE '%ENGENHARIA%'
        THEN 'Sistel Engenharia'

        WHEN UPPER(T0."BPLName") LIKE '%COMERCIO%'
        THEN 'Sistel Comercio'

        ELSE T0."BPLName"
    END AS "Empresa",

    OS."callID" AS "Numero OS",
    OS."itemCode" AS "Codigo Item OS",
    OS."itemName" AS "Descricao Item OS",
    OS."subject" AS "Assunto OS",

    LINHAS."Projeto",
    PRJ."PrjName" AS "Nome Projeto",

    LINHAS."Departamento",

    T0."DocTotal" AS "Valor Total Pedido Transferencia",

    SR."NumerosSolicitacoes" AS "Solicitacoes de Compra",

    CR."NumerosPC" AS "Pedidos de Compra Relacionados",
    CR."AprovacaoPC" AS "Aprovacao por Pedido de Compra",
    CR."StatusPC" AS "Situacao por Pedido de Compra",
    CR."FornecedoresPC" AS "Fornecedores dos Pedidos",

    CR."EsbocosAprovacao" AS "Esbocos Compra e Aprovacao",

    IFNULL(
        CR."QuantidadeEsbocos", 0
    ) AS "Quantidade Esbocos Compra",

    CASE
        WHEN SR."TransferenciaEntry" IS NULL
        THEN 'Solicitacao nao localizada nas referencias pesquisadas'

        WHEN IFNULL(CR."QuantidadePC", 0) > 0
         AND IFNULL(CR."QuantidadeEsbocos", 0) > 0
        THEN 'PC e esboco relacionados via solicitacao'

        WHEN IFNULL(CR."QuantidadePC", 0) > 0
        THEN 'PC relacionado via solicitacao'

        WHEN IFNULL(CR."QuantidadeEsbocos", 0) > 0
        THEN 'Esboco relacionado via solicitacao; consultar aprovacao'

        ELSE 'Solicitacao localizada; PC ou esboco nao localizado nos caminhos pesquisados'
    END AS "Status Vinculo Compras",

    T0."Comments" AS "Observacoes",

    CAST(
        SUBSTRING(T0."U_MM_OBS_INTERNO", 1, 254)
        AS NVARCHAR(254)
    ) AS "Observacoes Internas"

FROM OWTQ T0

LEFT JOIN LINHAS
    ON LINHAS."DocEntry" = T0."DocEntry"

LEFT JOIN OSCL OS
    ON OS."callID" = T0."U_MM_OS"

LEFT JOIN OPRJ PRJ
    ON PRJ."PrjCode" = LINHAS."Projeto"

LEFT JOIN OUSR USR_CRIADOR
    ON USR_CRIADOR."USERID" = T0."UserSign"

LEFT JOIN SOLICITACOES_RESUMO SR
    ON SR."TransferenciaEntry" = T0."DocEntry"

LEFT JOIN COMPRAS_RESUMO CR
    ON CR."TransferenciaEntry" = T0."DocEntry"

WHERE
    T0."DocStatus" = 'O'

ORDER BY
    T0."DocDueDate",
    T0."DocNum";
