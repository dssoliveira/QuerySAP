SELECT
    CASE
        WHEN T2."OcrCode" = 'GERADOR' THEN 'Gerador'
        WHEN T2."OcrCode" = 'NOBREAK' THEN 'Nobreak'
        ELSE T2."OcrCode"
    END AS "Centro de Custo",

    T0."ContractID" AS "Numero Contrato",
    T0."CstmrCode" AS "Codigo PN",
    T0."CstmrName" AS "Nome Parceiro",

    T0."StartDate" AS "Data Inicio",
    T0."EndDate" AS "Data Termino",

    DAYS_BETWEEN(CURRENT_DATE, T0."EndDate") AS "Dias Restantes",

    CASE
        WHEN DAYS_BETWEEN(CURRENT_DATE, T0."EndDate") <= 0 THEN 'Vencido'
        WHEN DAYS_BETWEEN(CURRENT_DATE, T0."EndDate") <= 30 THEN 'Vence em 30 dias'
        WHEN DAYS_BETWEEN(CURRENT_DATE, T0."EndDate") <= 60 THEN 'Vence em 60 dias'
        ELSE 'Ativo'
    END AS "Situacao",

    T2."ValorMensalCentroCusto" AS "Valor Mensal Contrato",
    T2."QuantidadeParcelas" AS "Quantidade Parcelas",
    T2."ValorTotalCentroCusto" AS "Valor Total Contrato",

    ROUND(
        CASE
            WHEN T0."EndDate" < CURRENT_DATE THEN 0
            WHEN T2."QuantidadeParcelas" = 1 THEN T2."ValorTotalCentroCusto"
            ELSE
                T2."ValorMensalCentroCusto"
                *
                CASE
                    WHEN YEAR(T0."EndDate") = YEAR(CURRENT_DATE)
                    THEN
                        CASE
                            WHEN MONTH(T0."EndDate") - MONTH(CURRENT_DATE) <= 0 THEN 1
                            ELSE MONTH(T0."EndDate") - MONTH(CURRENT_DATE)
                        END
                    ELSE 12 - MONTH(CURRENT_DATE)
                END
        END
    , 2) AS "Previsto Ate Final Ano",

    T1."DocNum" AS "Pedido Venda",
    T1."Project" AS "Numero Projeto",
    T5."PrjName" AS "Tipo Projeto",
    T3."SlpName" AS "Vendedor",

    CASE
        WHEN UPPER(IFNULL(T4."BPLName", '')) LIKE '%ENGENHARIA%' THEN 'Sistel Engenharia'
        WHEN UPPER(IFNULL(T4."BPLName", '')) LIKE '%COMERCIO%' THEN 'Sistel Comercio'
        ELSE T4."BPLName"
    END AS "Filial",

    T2."OcrCode" AS "Departamento",
    T2."Dscription" AS "Descricao Item",
    T2."QtdLinhasCentroCusto" AS "Qtd Linhas Centro Custo",
    T2."AlertaLinhaPedido" AS "Alerta Linha Pedido",

    CASE
        WHEN T0."U_MM_Tipo_Contrato" = 0 THEN 'Ampliado'
        WHEN T0."U_MM_Tipo_Contrato" = 1 THEN 'Essencial'
        WHEN T0."U_MM_Tipo_Contrato" = 2 THEN 'Service'
        ELSE 'Nao Definido'
    END AS "Tipo Contrato",

    CASE
        WHEN T0."U_MM_Tipo_Contratacao" = 0 THEN 'Manutencao'
        WHEN T0."U_MM_Tipo_Contratacao" = 1 THEN 'Locacao'
        WHEN T0."U_MM_Tipo_Contratacao" = 2 THEN 'Abastecimento'
        ELSE 'Nao Definido'
    END AS "Tipo Contratacao",

    CASE
        WHEN T0."U_MM_Tipo_Ativo" = 0 THEN 'Ativo Proprio'
        WHEN T0."U_MM_Tipo_Ativo" = 1 THEN 'Ativo Terceiro'
        ELSE 'Nao Definido'
    END AS "Tipo Ativo",

    CASE
        WHEN T0."U_MM_Modelo_Contrato" = 0 THEN 'Publico'
        WHEN T0."U_MM_Modelo_Contrato" = 1 THEN 'Privado'
        ELSE 'Nao Definido'
    END AS "Publico Privado",

    CASE
        WHEN T0."U_MM_Preve_Material" = 0 THEN 'Previsto'
        WHEN T0."U_MM_Preve_Material" = 1 THEN 'Nao Previsto'
        ELSE 'Nao Definido'
    END AS "Fornecimento Material",

    CASE
        WHEN T0."U_MM_Periodicidade" = 0 THEN 'Mensal'
        WHEN T0."U_MM_Periodicidade" = 1 THEN 'Bimestral'
        WHEN T0."U_MM_Periodicidade" = 2 THEN 'Trimestral'
        WHEN T0."U_MM_Periodicidade" = 3 THEN 'Semestral'
        WHEN T0."U_MM_Periodicidade" = 4 THEN 'Anual'
        ELSE 'Nao Definido'
    END AS "Periodicidade Preventiva",

    CASE
        WHEN T0."U_MM_Checklist" = 0 THEN 'Semanal'
        WHEN T0."U_MM_Checklist" = 1 THEN 'Quinzenal'
        WHEN T0."U_MM_Checklist" = 2 THEN 'Mensal'
        WHEN T0."U_MM_Checklist" = 3 THEN 'Bimestral'
        WHEN T0."U_MM_Checklist" = 4 THEN 'Trimestral'
        WHEN T0."U_MM_Checklist" = 5 THEN 'Semestral'
        WHEN T0."U_MM_Checklist" = 6 THEN 'Anual'
        WHEN T0."U_MM_Checklist" = 7 THEN 'Sem Checklist'
        ELSE 'Nao Definido'
    END AS "Checklist Visitas",

    T0."U_MM_Area_Rota" AS "Area Rota",
    T0."U_MM_Macro_Regiao" AS "Macro Regiao",

    CASE
        WHEN T0."U_MM_Logsis" = 0 THEN 'Nao'
        WHEN T0."U_MM_Logsis" = 1 THEN 'Sim'
        ELSE 'Nao Definido'
    END AS "Monitoramento LOGSIS",

    CASE
        WHEN T0."U_MM_Integracao" = 0 THEN 'Nao Definido'
        WHEN T0."U_MM_Integracao" = 1 THEN 'Sim'
        WHEN T0."U_MM_Integracao" = 2 THEN 'Nao'
        ELSE 'Nao Definido'
    END AS "Integracao Tecnico",

    CASE
        WHEN T1."U_MM_PDB" = '0' THEN 'Nao'
        WHEN T1."U_MM_PDB" = '1' THEN 'Sim'
        ELSE 'Nao Definido'
    END AS "Passagem Bastao",

    CASE
        WHEN T1."U_MM_Passagem_Bastao" = '0' THEN 'PCP'
        WHEN T1."U_MM_Passagem_Bastao" = '1' THEN 'PCM'
        WHEN T1."U_MM_Passagem_Bastao" = '2' THEN 'Locacao'
        WHEN T1."U_MM_Passagem_Bastao" = '3' THEN 'Engenharia'
        ELSE 'Nao Definido'
    END AS "Passagem Bastao 2",

    CASE
        WHEN T0."ContractID" = 267 THEN 'Trimestral'
        WHEN T0."ContractID" IN (399, 402, 445) THEN 'Medicao'
        ELSE 'Mensal'
    END AS "Periodicidade de faturamento",

    TO_VARCHAR(T0."StartDate", 'MM/YYYY') AS "Inicio de faturamento"

FROM OCTR T0

LEFT JOIN (
    SELECT
        TL."U_ContractID",
        MAX(TO_INTEGER(TL."U_DocEntry")) AS "DocEntryPV"
    FROM "@LOC1_DOC" TL
    WHERE
        TL."U_DocTypeNum" = 17
    GROUP BY
        TL."U_ContractID"
) UD
    ON UD."U_ContractID" = T0."ContractID"

LEFT JOIN ORDR T1
    ON T1."DocEntry" = UD."DocEntryPV"

LEFT JOIN (
    SELECT
        R1."DocEntry",
        R1."OcrCode",

        MIN(R1."Dscription") AS "Dscription",

        ROUND(
            SUM(R1."LineTotal" / NULLIF(R1."Quantity", 0)),
            2
        ) AS "ValorMensalCentroCusto",

        MAX(R1."Quantity") AS "QuantidadeParcelas",

        ROUND(
            SUM(R1."LineTotal"),
            2
        ) AS "ValorTotalCentroCusto",

        COUNT(*) AS "QtdLinhasCentroCusto",

        CASE
            WHEN MIN(R1."Quantity") <> MAX(R1."Quantity")
            THEN 'Validar parcelas nas linhas do pedido'
            ELSE ''
        END AS "AlertaLinhaPedido"

    FROM RDR1 R1

    WHERE
        R1."OcrCode" IN ('GERADOR', 'NOBREAK')

    GROUP BY
        R1."DocEntry",
        R1."OcrCode"
) T2
    ON T2."DocEntry" = T1."DocEntry"

LEFT JOIN OSLP T3
    ON T3."SlpCode" = T1."SlpCode"

LEFT JOIN OBPL T4
    ON T4."BPLId" = T1."BPLId"

LEFT JOIN OPRJ T5
    ON T5."PrjCode" = T1."Project"

WHERE
    T0."Status" = 'A'
    AND T2."OcrCode" IN ('GERADOR', 'NOBREAK')
    AND (T2."OcrCode" = '[%0]' OR '[%0]' = '')

ORDER BY
    T2."OcrCode",
    T0."EndDate",
    T0."ContractID";
