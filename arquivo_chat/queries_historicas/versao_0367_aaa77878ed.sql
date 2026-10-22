WITH PV_LOCACAO_LINHAS AS (
    SELECT
        PV."DocEntry",
        PV."DocNum",
        PV."CreateDate",
        PV."DocDate",
        PV."DocDueDate",
        PV."CardCode",
        PV."CardName",
        PV."BPLId",
        PV."U_MM_Tipo",
        PV."U_MM_Faturamento",
        PV."DocTotal",
        PV."Project",
        R1."LineNum",
        R1."ItemCode",
        R1."Dscription",
        R1."OcrCode",
        U."Usage" AS "Utilizacao",
        R1."LineTotal"
    FROM ORDR PV

    INNER JOIN RDR1 R1
        ON R1."DocEntry" = PV."DocEntry"

    LEFT JOIN OUSG U
        ON U."ID" = R1."Usage"

    WHERE
        PV."CANCELED" = 'N'
        AND PV."Confirmed" = 'Y'

        AND (
            IFNULL(R1."OcrCode", '') = 'LOCACAO'
            OR UPPER(IFNULL(U."Usage", '')) LIKE '%LOCACAO%'
            OR UPPER(IFNULL(U."Usage", '')) LIKE '%LOCAÇÃO%'
            OR UPPER(IFNULL(R1."Dscription", '')) LIKE '%LOCACAO%'
            OR UPPER(IFNULL(R1."Dscription", '')) LIKE '%LOCAÇÃO%'
        )
),

PV_LOCACAO AS (
    SELECT
        P."DocEntry",
        P."DocNum",
        P."CreateDate",
        P."DocDate",
        P."DocDueDate",
        P."CardCode",
        P."CardName",
        P."BPLId",
        P."U_MM_Tipo",
        P."U_MM_Faturamento",
        P."DocTotal",
        P."Project",

        STRING_AGG(P."ItemCode", ', ') AS "Itens_Locacao",
        STRING_AGG(P."Dscription", ' | ') AS "Descricoes_Locacao",
        STRING_AGG(IFNULL(P."OcrCode", ''), ', ') AS "Departamentos_Locacao",
        STRING_AGG(IFNULL(P."Utilizacao", ''), ', ') AS "Utilizacoes_Locacao",

        SUM(P."LineTotal") AS "Valor_Pedido_Locacao"

    FROM PV_LOCACAO_LINHAS P

    GROUP BY
        P."DocEntry",
        P."DocNum",
        P."CreateDate",
        P."DocDate",
        P."DocDueDate",
        P."CardCode",
        P."CardName",
        P."BPLId",
        P."U_MM_Tipo",
        P."U_MM_Faturamento",
        P."DocTotal",
        P."Project"
),

ENTREGA_NF AS (
    SELECT
        X."DocEntryNFOrigem",
        X."Num_Interno_Entrega",
        X."Num_Documento_Entrega",
        X."Data_Entrega",
        X."Valor_Entrega"

    FROM (
        SELECT
            D1."BaseEntry" AS "DocEntryNFOrigem",
            E0."DocEntry" AS "Num_Interno_Entrega",
            E0."DocNum" AS "Num_Documento_Entrega",
            E0."DocDate" AS "Data_Entrega",
            E0."DocTotal" AS "Valor_Entrega",

            ROW_NUMBER() OVER (
                PARTITION BY D1."BaseEntry"
                ORDER BY
                    E0."DocDate" DESC,
                    E0."DocNum" DESC
            ) AS "LinhaControle"

        FROM ODLN E0

        INNER JOIN DLN1 D1
            ON D1."DocEntry" = E0."DocEntry"

        WHERE
            D1."BaseType" = 13
            AND E0."CANCELED" = 'N'
    ) X

    WHERE
        X."LinhaControle" = 1
),

NF_LOCACAO_POR_NOTA AS (
    SELECT
        X."DocEntryPV",
        X."DocEntryNF",
        X."DocNumNF",
        X."SerialNF",
        X."DataEmissaoNF",
        X."DataReferenciaFaturamento",
        X."TipoNotaFiscal",
        X."NumDocumentoEntrega",
        X."DataEntrega",

        SUM(X."ValorLinhaLocacaoNF") AS "ValorFaturadoLocacaoNF",
        MAX(X."ValorNFeML") AS "ValorNFeML"

    FROM (
        SELECT
            I1."BaseEntry" AS "DocEntryPV",

            NF0."DocEntry" AS "DocEntryNF",
            NF0."DocNum" AS "DocNumNF",
            NF0."Serial" AS "SerialNF",
            NF0."DocDate" AS "DataEmissaoNF",

            CASE
                WHEN ENT."Data_Entrega" IS NOT NULL
                THEN ENT."Data_Entrega"
                ELSE NF0."DocDate"
            END AS "DataReferenciaFaturamento",

            CASE
                WHEN ENT."Num_Documento_Entrega" IS NOT NULL
                THEN 'Nota Fiscal de Entrega Futura com Entrega Vinculada'
                ELSE 'Nota Fiscal de Saida'
            END AS "TipoNotaFiscal",

            ENT."Num_Documento_Entrega" AS "NumDocumentoEntrega",
            ENT."Data_Entrega" AS "DataEntrega",

            I1."LineTotal" AS "ValorLinhaLocacaoNF",

            CASE
                WHEN ENT."Valor_Entrega" IS NOT NULL
                THEN ENT."Valor_Entrega"
                ELSE NF0."NfeValue"
            END AS "ValorNFeML"

        FROM INV1 I1

        INNER JOIN OINV NF0
            ON NF0."DocEntry" = I1."DocEntry"
            AND NF0."CANCELED" = 'N'

        LEFT JOIN RDR1 R1
            ON I1."BaseType" = 17
            AND I1."BaseEntry" = R1."DocEntry"
            AND I1."BaseLine" = R1."LineNum"

        LEFT JOIN OUSG U
            ON U."ID" = I1."Usage"

        LEFT JOIN ENTREGA_NF ENT
            ON ENT."DocEntryNFOrigem" = NF0."DocEntry"

        WHERE
            I1."BaseType" = 17

            AND IFNULL(I1."TaxOnly", 'N') <> 'Y'
            AND IFNULL(U."TaxOnly", 'N') <> 'Y'

            AND (
                IFNULL(IFNULL(I1."OcrCode", R1."OcrCode"), '') = 'LOCACAO'
                OR UPPER(IFNULL(U."Usage", '')) LIKE '%LOCACAO%'
                OR UPPER(IFNULL(U."Usage", '')) LIKE '%LOCAÇÃO%'
                OR UPPER(IFNULL(IFNULL(I1."Dscription", R1."Dscription"), '')) LIKE '%LOCACAO%'
                OR UPPER(IFNULL(IFNULL(I1."Dscription", R1."Dscription"), '')) LIKE '%LOCAÇÃO%'
            )
    ) X

    GROUP BY
        X."DocEntryPV",
        X."DocEntryNF",
        X."DocNumNF",
        X."SerialNF",
        X."DataEmissaoNF",
        X."DataReferenciaFaturamento",
        X."TipoNotaFiscal",
        X."NumDocumentoEntrega",
        X."DataEntrega"
),

NF_LOCACAO_AGRUPADA AS (
    SELECT
        N."DocEntryPV",

        STRING_AGG(TO_VARCHAR(N."DocNumNF"), ', ') AS "Num_Documento_SAP_NF",
        STRING_AGG(TO_VARCHAR(N."SerialNF"), ', ') AS "Numero_Nota_Fiscal",

        MIN(N."DataEmissaoNF") AS "Primeira_Data_Emissao_NF",
        MAX(N."DataEmissaoNF") AS "Ultima_Data_Emissao_NF",

        MIN(N."DataReferenciaFaturamento") AS "Primeira_Data_Referencia_Faturamento",
        MAX(N."DataReferenciaFaturamento") AS "Ultima_Data_Referencia_Faturamento",

        STRING_AGG(N."TipoNotaFiscal", ' | ') AS "Tipo_Nota_Fiscal",

        STRING_AGG(TO_VARCHAR(N."NumDocumentoEntrega"), ', ') AS "Num_Documento_Entrega",
        MAX(N."DataEntrega") AS "Data_Entrega",

        SUM(N."ValorFaturadoLocacaoNF") AS "Valor_Faturado_Locacao",
        SUM(N."ValorNFeML") AS "Valor_NFe_ML"

    FROM NF_LOCACAO_POR_NOTA N

    GROUP BY
        N."DocEntryPV"
)

SELECT
    PV."CreateDate" AS "Dt_Criacao_Pedido",

    PV."DocNum" AS "Pedido_Venda",

    CASE
        WHEN PV."U_MM_Tipo" = '0' THEN 'Nao Definido'
        WHEN PV."U_MM_Tipo" = '2' THEN 'Aditivo'
        WHEN PV."U_MM_Tipo" = '3' THEN 'Pre-Contrato'
        WHEN PV."U_MM_Tipo" = '4' THEN 'Gerado por OS (Pre-Consumo)'
        WHEN PV."U_MM_Tipo" = '5' THEN 'Venda (Avulsa)'
        WHEN PV."U_MM_Tipo" = '6' THEN 'Faturamento LOC1'
        WHEN PV."U_MM_Tipo" = '7' THEN 'Ajuste interno'
        WHEN PV."U_MM_Tipo" = '8' THEN 'Duplicado'
        WHEN PV."U_MM_Tipo" = '9' THEN 'Precor'
        WHEN PV."U_MM_Tipo" = '10' THEN 'Integrado por Iclass'
        WHEN PV."U_MM_Tipo" = '11' THEN 'Cancelado'
        ELSE 'Nao Definido'
    END AS "Tipo_Pedido",

    CASE
        WHEN PV."U_MM_Tipo" = '3'
        THEN 'OK: Pedido de locacao como Pre-Contrato'
        ELSE 'Validar: Pedido de locacao nao esta como Pre-Contrato'
    END AS "Status_Tipo_Pedido_Locacao",

    PV."DocDate" AS "Data_Pedido",
    PV."DocDueDate" AS "Data_Entrega_Pedido",

    PV."CardCode" AS "Cod_Cliente",
    PV."CardName" AS "Nome_Cliente",

    CASE
        WHEN UPPER(IFNULL(FIL."BPLName", '')) LIKE '%ENGENHARIA%'
        THEN 'Sistel Engenharia'

        WHEN UPPER(IFNULL(FIL."BPLName", '')) LIKE '%COMERCIO%'
          OR UPPER(IFNULL(FIL."BPLName", '')) LIKE '%COMÉRCIO%'
        THEN 'Sistel Comercio'

        ELSE IFNULL(FIL."BPLName", 'Nao Definido')
    END AS "Filial",

    PV."Project" AS "Projeto",

    PV."Itens_Locacao" AS "Itens_Locacao",
    PV."Descricoes_Locacao" AS "Descricoes_Locacao",
    PV."Departamentos_Locacao" AS "Departamentos_Locacao",
    PV."Utilizacoes_Locacao" AS "Utilizacoes_Locacao",

    PV."Valor_Pedido_Locacao" AS "Valor_Pedido_Locacao",

    IFNULL(NF."Valor_Faturado_Locacao", 0) AS "Valor_Faturado_Locacao",

    PV."Valor_Pedido_Locacao" - IFNULL(NF."Valor_Faturado_Locacao", 0) AS "Valor_A_Faturar_Locacao",

    IFNULL(NF."Valor_NFe_ML", 0) AS "Valor_NFe_ML",

    NF."Num_Documento_SAP_NF",
    NF."Numero_Nota_Fiscal",

    NF."Primeira_Data_Emissao_NF",
    NF."Ultima_Data_Emissao_NF",

    NF."Primeira_Data_Referencia_Faturamento",
    NF."Ultima_Data_Referencia_Faturamento",

    NF."Tipo_Nota_Fiscal",

    NF."Num_Documento_Entrega",
    NF."Data_Entrega",

    CASE
        WHEN IFNULL(NF."Valor_Faturado_Locacao", 0) = 0
        THEN 'A Faturar'

        WHEN ROUND(IFNULL(NF."Valor_Faturado_Locacao", 0), 2) >= ROUND(PV."Valor_Pedido_Locacao", 2)
        THEN 'Faturado'

        ELSE 'Parcial'
    END AS "Status_Faturamento_Locacao",

    CASE
        WHEN NF."Primeira_Data_Referencia_Faturamento" IS NULL
        THEN NULL
        ELSE DAYS_BETWEEN(PV."DocDate", NF."Primeira_Data_Referencia_Faturamento")
    END AS "Dias_Ate_Primeiro_Faturamento",

    CASE
        WHEN DAYS_BETWEEN(PV."DocDate", PV."DocDueDate") <= 31
        THEN 'Locacao Curto Prazo'
        ELSE 'Locacao Prazo Maior'
    END AS "Classificacao_Prazo"

FROM PV_LOCACAO PV

LEFT JOIN OBPL FIL
    ON FIL."BPLId" = PV."BPLId"

LEFT JOIN NF_LOCACAO_AGRUPADA NF
    ON NF."DocEntryPV" = PV."DocEntry"

ORDER BY
    PV."CreateDate",
    PV."DocNum";
