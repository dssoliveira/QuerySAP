WITH TRANSACOES AS
(
    SELECT
        J."TransId",
        J."RefDate",
        J."TransType",
        J."Memo"

    FROM OJDT J

    WHERE J."TransId" IN
    (
        18950, 19239, 22013, 23147, 23548,
        23882, 24251, 24790, 25251, 26322,
        26358, 26421, 26433, 26946, 28486,
        29541, 29826, 30264, 30459, 31714,
        31863, 31973, 32179, 32377, 32442,
        33304
    )
),

DOCUMENTOS AS
(
    SELECT
        H."TransId",
        'Nota fiscal de entrada' AS "TipoDocumento",
        H."DocEntry",
        H."DocNum",
        H."CardCode",
        H."CardName",
        H."DocTotal" AS "TotalDocumentoML",
        H."CANCELED" AS "Cancelado"

    FROM OPCH H
    INNER JOIN TRANSACOES T
        ON T."TransId" = H."TransId"

    UNION ALL

    SELECT
        H."TransId",
        'Recebimento de compra',
        H."DocEntry",
        H."DocNum",
        H."CardCode",
        H."CardName",
        H."DocTotal",
        H."CANCELED"

    FROM OPDN H
    INNER JOIN TRANSACOES T
        ON T."TransId" = H."TransId"

    UNION ALL

    SELECT
        H."TransId",
        'Transferencia de estoque',
        H."DocEntry",
        H."DocNum",
        H."CardCode",
        H."CardName",
        H."DocTotal",
        H."CANCELED"

    FROM OWTR H
    INNER JOIN TRANSACOES T
        ON T."TransId" = H."TransId"

    UNION ALL

    SELECT
        H."TransId",
        'Entrada de mercadorias',
        H."DocEntry",
        H."DocNum",
        NULL,
        NULL,
        H."DocTotal",
        H."CANCELED"

    FROM OIGN H
    INNER JOIN TRANSACOES T
        ON T."TransId" = H."TransId"

    UNION ALL

    SELECT
        H."TransId",
        'Saida de mercadorias',
        H."DocEntry",
        H."DocNum",
        NULL,
        NULL,
        H."DocTotal",
        H."CANCELED"

    FROM OIGE H
    INNER JOIN TRANSACOES T
        ON T."TransId" = H."TransId"

    UNION ALL

    SELECT
        H."TransId",
        'Adiantamento de fornecedor',
        H."DocEntry",
        H."DocNum",
        H."CardCode",
        H."CardName",
        H."DocTotal",
        H."CANCELED"

    FROM ODPO H
    INNER JOIN TRANSACOES T
        ON T."TransId" = H."TransId"

    UNION ALL

    SELECT
        H."TransId",
        'Devolucao / credito de fornecedor',
        H."DocEntry",
        H."DocNum",
        H."CardCode",
        H."CardName",
        H."DocTotal",
        H."CANCELED"

    FROM ORPC H
    INNER JOIN TRANSACOES T
        ON T."TransId" = H."TransId"
),

CONTAS_BASE AS
(
    /*
       Consolida parcelas e linhas repetidas na mesma conta.

       Valor líquido da conta = débito - crédito.
       Não soma todas as contas como custo, pois um lançamento
       contábil completo deve ter débito igual a crédito.
    */
    SELECT
        L."TransId",
        L."Account",
        A."FormatCode",
        A."AcctName",

        REPLACE(
            REPLACE(
                IFNULL(A."FormatCode", L."Account"),
                '.',
                ''
            ),
            ' ',
            ''
        ) AS "ContaNormalizada",

        UPPER(IFNULL(A."AcctName", '')) AS "NomeContaMaiusculo",

        SUM(L."Debit") AS "Debito",
        SUM(L."Credit") AS "Credito",
        SUM(L."Debit" - L."Credit") AS "Liquido"

    FROM JDT1 L

    INNER JOIN TRANSACOES T
        ON T."TransId" = L."TransId"

    LEFT JOIN OACT A
        ON A."AcctCode" = L."Account"

    GROUP BY
        L."TransId",
        L."Account",
        A."FormatCode",
        A."AcctName"
),

CONTAS_CLASSIFICADAS AS
(
    SELECT
        C.*,

        /*
           Contas visíveis na imagem enviada.
           Comparação sem pontos para aceitar o FormatCode
           com ou sem máscara.
        */
        CASE
            WHEN C."ContaNormalizada" =
                 REPLACE('1.1.3.01.0001', '.', '')
            THEN 'MATERIA_PRIMA'

            WHEN C."ContaNormalizada" =
                 REPLACE('1.1.3.01.0003', '.', '')
            THEN 'PRODUTO_ACABADO'

            WHEN C."ContaNormalizada" =
                 REPLACE('1.1.3.01.0009', '.', '')
            THEN 'MATERIAL_EXPEDICAO'

            WHEN C."ContaNormalizada" =
                 REPLACE('2.1.1.01.0001', '.', '')
            THEN 'FORNECEDORES_NACIONAIS'

            ELSE 'OUTRA_CONTA'
        END AS "GrupoConta",

        /*
           Identificação provisória de crédito fiscal.

           Exige nome de tributo + indicação de recuperação
           ou compensação. Precisa ser validada com as contas
           fiscais efetivamente utilizadas pela empresa.
        */
        CASE
            WHEN
            (
                C."NomeContaMaiusculo" LIKE '%ICMS%'
                OR C."NomeContaMaiusculo" LIKE '%IPI%'
                OR C."NomeContaMaiusculo" LIKE '%PIS%'
                OR C."NomeContaMaiusculo" LIKE '%COFINS%'
            )
            AND
            (
                C."NomeContaMaiusculo" LIKE '%RECUPER%'
                OR C."NomeContaMaiusculo" LIKE '%COMPENS%'
            )
            THEN 1
            ELSE 0
        END AS "CreditoFiscalCandidato"

    FROM CONTAS_BASE C
),

CONTABIL AS
(
    SELECT
        C."TransId",

        SUM(C."Debito") AS "DebitoTotalLancamento",
        SUM(C."Credito") AS "CreditoTotalLancamento",

        SUM(
            CASE WHEN C."GrupoConta" = 'MATERIA_PRIMA'
                 THEN C."Debito" ELSE 0 END
        ) AS "DebitoMateriaPrima",

        SUM(
            CASE WHEN C."GrupoConta" = 'MATERIA_PRIMA'
                 THEN C."Credito" ELSE 0 END
        ) AS "CreditoMateriaPrima",

        SUM(
            CASE WHEN C."GrupoConta" = 'MATERIA_PRIMA'
                 THEN C."Liquido" ELSE 0 END
        ) AS "LiquidoMateriaPrima",

        SUM(
            CASE WHEN C."GrupoConta" = 'PRODUTO_ACABADO'
                 THEN C."Liquido" ELSE 0 END
        ) AS "LiquidoProdutoAcabado",

        SUM(
            CASE WHEN C."GrupoConta" = 'MATERIAL_EXPEDICAO'
                 THEN C."Liquido" ELSE 0 END
        ) AS "LiquidoMaterialExpedicao",

        SUM(
            CASE WHEN C."GrupoConta" IN
                 (
                     'MATERIA_PRIMA',
                     'PRODUTO_ACABADO',
                     'MATERIAL_EXPEDICAO'
                 )
                 THEN C."Liquido" ELSE 0 END
        ) AS "LiquidoEstoqueContasSelecionadas",

        SUM(
            CASE WHEN C."GrupoConta" IN
                 (
                     'MATERIA_PRIMA',
                     'PRODUTO_ACABADO',
                     'MATERIAL_EXPEDICAO'
                 )
                 THEN 1 ELSE 0 END
        ) AS "QtdContasEstoque",

        SUM(
            CASE WHEN C."GrupoConta" = 'FORNECEDORES_NACIONAIS'
                 THEN C."Debito" ELSE 0 END
        ) AS "DebitoFornecedores",

        SUM(
            CASE WHEN C."GrupoConta" = 'FORNECEDORES_NACIONAIS'
                 THEN C."Credito" ELSE 0 END
        ) AS "CreditoFornecedores",

        SUM(
            CASE WHEN C."CreditoFiscalCandidato" = 1
                 THEN C."Liquido" ELSE 0 END
        ) AS "CreditoFiscalCandidatoML",

        SUM(C."CreditoFiscalCandidato") AS "QtdContasFiscaisCandidatas"

    FROM CONTAS_CLASSIFICADAS C

    GROUP BY
        C."TransId"
),

CONTAS_FISCAIS AS
(
    SELECT
        C."TransId",

        STRING_AGG(
            IFNULL(C."FormatCode", C."Account")
            || ' - '
            || IFNULL(C."AcctName", ''),
            ' | '
        ) AS "ContasFiscaisCandidatas"

    FROM CONTAS_CLASSIFICADAS C

    WHERE C."CreditoFiscalCandidato" = 1

    GROUP BY
        C."TransId"
),

PROJETOS_DISTINTOS AS
(
    SELECT DISTINCT
        L."TransId",
        L."Project"

    FROM JDT1 L

    INNER JOIN TRANSACOES T
        ON T."TransId" = L."TransId"

    WHERE NULLIF(TRIM(L."Project"), '') IS NOT NULL
),

PROJETOS AS
(
    SELECT
        P."TransId",
        STRING_AGG(P."Project", ', ') AS "ProjetosContabeis"

    FROM PROJETOS_DISTINTOS P

    GROUP BY
        P."TransId"
),

PAINEL AS
(
    SELECT
        T."TransId",
        T."RefDate",
        T."TransType",
        T."Memo",

        D."TipoDocumento",
        D."DocEntry",
        D."DocNum",
        D."CardCode",
        D."CardName",
        D."TotalDocumentoML",
        D."Cancelado",

        P."ProjetosContabeis",

        C."DebitoTotalLancamento",
        C."CreditoTotalLancamento",
        C."DebitoMateriaPrima",
        C."CreditoMateriaPrima",
        C."LiquidoMateriaPrima",
        C."LiquidoProdutoAcabado",
        C."LiquidoMaterialExpedicao",
        C."LiquidoEstoqueContasSelecionadas",
        C."QtdContasEstoque",
        C."DebitoFornecedores",
        C."CreditoFornecedores",
        C."CreditoFiscalCandidatoML",
        C."QtdContasFiscaisCandidatas",

        F."ContasFiscaisCandidatas",

        /*
           A comparação fiscal automática fica restrita
           a notas de entrada e recebimentos não cancelados.
        */
        CASE
            WHEN D."TipoDocumento" IN
                 (
                     'Nota fiscal de entrada',
                     'Recebimento de compra'
                 )
             AND D."Cancelado" = 'N'
            THEN 1
            ELSE 0
        END AS "PermiteComparacao"

    FROM TRANSACOES T

    LEFT JOIN DOCUMENTOS D
        ON D."TransId" = T."TransId"

    LEFT JOIN CONTABIL C
        ON C."TransId" = T."TransId"

    LEFT JOIN CONTAS_FISCAIS F
        ON F."TransId" = T."TransId"

    LEFT JOIN PROJETOS P
        ON P."TransId" = T."TransId"
)

SELECT
    P."TransId" AS "Numero_Transacao",
    P."RefDate" AS "Data_Lancamento",
    P."TransType" AS "Tipo_Origem_SAP",

    IFNULL(
        P."TipoDocumento",
        'Origem nao detalhada - consultar lancamento contabil'
    ) AS "Tipo_Documento",

    P."DocEntry" AS "Chave_Documento",
    P."DocNum" AS "Numero_Documento",
    P."Cancelado",

    P."CardCode" AS "Codigo_Parceiro",
    P."CardName" AS "Nome_Parceiro",
    P."ProjetosContabeis" AS "Projetos_No_Lancamento",

    /* Total do documento: não é o total do pedido de compra */
    P."TotalDocumentoML" AS "Total_Documento_ML",

    /* Valores efetivamente contabilizados */
    P."DebitoMateriaPrima" AS "Debito_Materia_Prima",
    P."CreditoMateriaPrima" AS "Credito_Materia_Prima",
    P."LiquidoMateriaPrima" AS "Liquido_Materia_Prima",

    P."LiquidoProdutoAcabado" AS "Liquido_Produto_Acabado",
    P."LiquidoMaterialExpedicao" AS "Liquido_Material_Expedicao",

    P."LiquidoEstoqueContasSelecionadas"
        AS "Liquido_Estoque_Contas_Selecionadas",

    /* Parcelas consolidadas do fornecedor */
    P."DebitoFornecedores" AS "Debito_Fornecedores_Nacionais",
    P."CreditoFornecedores" AS "Credito_Fornecedores_Nacionais",

    /* Diferença observada: ainda não classificada como imposto */
    CASE
        WHEN P."PermiteComparacao" = 1
         AND P."QtdContasEstoque" > 0
        THEN
            P."TotalDocumentoML"
            - P."LiquidoEstoqueContasSelecionadas"
        ELSE NULL
    END AS "Diferenca_Documento_x_Estoque_ML",

    /*
       NULL significa que não foi identificada uma conta
       fiscal pelo critério de nome; não significa imposto zero.
    */
    CASE
        WHEN P."PermiteComparacao" = 1
         AND P."QtdContasFiscaisCandidatas" > 0
        THEN P."CreditoFiscalCandidatoML"
        ELSE NULL
    END AS "Credito_Fiscal_Candidato_ML",

    P."ContasFiscaisCandidatas"
        AS "Contas_Fiscais_Para_Validar",

    CASE
        WHEN P."PermiteComparacao" = 1
         AND P."QtdContasFiscaisCandidatas" > 0
        THEN
            P."TotalDocumentoML"
            - P."CreditoFiscalCandidatoML"
        ELSE NULL
    END AS "Liquido_Apos_Credito_Candidato_ML",

    /*
       Se houver diferença residual, o crédito candidato
       não explica sozinho a diferença para o estoque.
    */
    CASE
        WHEN P."PermiteComparacao" = 1
         AND P."QtdContasEstoque" > 0
         AND P."QtdContasFiscaisCandidatas" > 0
        THEN
            P."TotalDocumentoML"
            - P."CreditoFiscalCandidatoML"
            - P."LiquidoEstoqueContasSelecionadas"
        ELSE NULL
    END AS "Diferenca_Residual_Para_Conciliar_ML",

    CASE
        WHEN P."TipoDocumento" IS NULL
        THEN 'Consultar origem: valores contabeis disponiveis'

        WHEN IFNULL(P."Cancelado", 'N') <> 'N'
        THEN 'Documento cancelado ou de cancelamento - analisar separado'

        WHEN P."PermiteComparacao" = 0
        THEN 'Comparacao fiscal nao aplicada a este tipo de documento'

        WHEN P."QtdContasEstoque" = 0
        THEN 'Sem movimento nas tres contas de estoque selecionadas'

        WHEN P."QtdContasFiscaisCandidatas" = 0
        THEN 'Validar contas fiscais: diferenca nao classificada como imposto'

        WHEN ABS(
            P."TotalDocumentoML"
            - P."CreditoFiscalCandidatoML"
            - P."LiquidoEstoqueContasSelecionadas"
        ) <= 0.01
        THEN 'Valores conciliam; confirmar classificacao das contas fiscais'

        ELSE 'Ha diferenca residual: revisar impostos, fretes e demais contas'
    END AS "Status_Conciliacao",

    P."DebitoTotalLancamento" AS "Debito_Total_Lancamento",
    P."CreditoTotalLancamento" AS "Credito_Total_Lancamento",

    P."DebitoTotalLancamento"
        - P."CreditoTotalLancamento"
        AS "Diferenca_Balanceamento",

    P."Memo" AS "Observacoes_Lancamento"

FROM PAINEL P

ORDER BY
    P."RefDate",
    P."TransId";
