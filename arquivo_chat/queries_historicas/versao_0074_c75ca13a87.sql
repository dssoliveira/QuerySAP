SELECT
    B."CentroCusto" AS "Centro de Custo",
    B."NumeroContrato" AS "Numero Contrato",
    B."CodigoPN" AS "Codigo PN",
    B."NomeParceiro" AS "Nome Parceiro",

    B."DataInicio" AS "Data Inicio",
    B."DataTermino" AS "Data Termino",
    B."DiasRestantes" AS "Dias Restantes",
    B."Situacao",

    B."ValorMensalContrato" AS "Valor Mensal Contrato",
    B."QuantidadeParcelas" AS "Quantidade Parcelas",
    B."ValorTotalContrato" AS "Valor Total Contrato",
    B."PrevistoAteFinalAno" AS "Previsto Ate Final Ano",

    B."PedidoVenda" AS "Pedido Venda",
    B."NumeroProjeto" AS "Numero Projeto",
    B."TipoProjeto" AS "Tipo Projeto",
    B."Vendedor",

    CASE
        WHEN UPPER(IFNULL(B."Filial", '')) LIKE '%ENGENHARIA%' THEN 'Sistel Engenharia'
        WHEN UPPER(IFNULL(B."Filial", '')) LIKE '%COMERCIO%' THEN 'Sistel Comercio'
        ELSE B."Filial"
    END AS "Filial",

    B."Departamento",
    B."DescricaoItem" AS "Descricao Item",
    B."QtdLinhasCentroCusto" AS "Qtd Linhas Centro Custo",
    B."AlertaLinhaPedido" AS "Alerta Linha Pedido",

    B."TipoContrato" AS "Tipo Contrato",
    B."TipoContratacao" AS "Tipo Contratacao",
    B."TipoAtivo" AS "Tipo Ativo",
    B."PublicoPrivado" AS "Publico Privado",
    B."FornecimentoMaterial" AS "Fornecimento Material",
    B."PeriodicidadePreventiva" AS "Periodicidade Preventiva",
    B."ChecklistVisitas" AS "Checklist Visitas",
    B."AreaRota" AS "Area Rota",
    B."MacroRegiao" AS "Macro Regiao",
    B."MonitoramentoLOGSIS" AS "Monitoramento LOGSIS",
    B."IntegracaoTecnico" AS "Integracao Tecnico",
    B."PassagemBastao" AS "Passagem Bastao",
    B."PassagemBastao2" AS "Passagem Bastao 2",

    B."PeriodicidadeFaturamento" AS "Periodicidade de faturamento",
    TO_VARCHAR(B."InicioFaturamentoData", 'MM/YYYY') AS "Inicio de faturamento",

    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN TO_DATE('2026-01-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "01/2026",
    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN TO_DATE('2026-02-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "02/2026",

    ROUND(
        CASE
            WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0
            WHEN B."PeriodicidadeFaturamento" = 'Trimestral'
                 AND TO_DATE('2026-03-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato" * 3
            WHEN B."PeriodicidadeFaturamento" <> 'Trimestral'
                 AND TO_DATE('2026-03-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato"
            ELSE 0
        END
    , 2) AS "03/2026",

    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2026-04-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "04/2026",
    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2026-05-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "05/2026",

    ROUND(
        CASE
            WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0
            WHEN B."PeriodicidadeFaturamento" = 'Trimestral'
                 AND TO_DATE('2026-06-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato" * 3
            WHEN B."PeriodicidadeFaturamento" <> 'Trimestral'
                 AND TO_DATE('2026-06-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato"
            ELSE 0
        END
    , 2) AS "06/2026",

    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2026-07-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "07/2026",
    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2026-08-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "08/2026",

    ROUND(
        CASE
            WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0
            WHEN B."PeriodicidadeFaturamento" = 'Trimestral'
                 AND TO_DATE('2026-09-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato" * 3
            WHEN B."PeriodicidadeFaturamento" <> 'Trimestral'
                 AND TO_DATE('2026-09-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato"
            ELSE 0
        END
    , 2) AS "09/2026",

    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2026-10-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "10/2026",
    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2026-11-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "11/2026",

    ROUND(
        CASE
            WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0
            WHEN B."PeriodicidadeFaturamento" = 'Trimestral'
                 AND TO_DATE('2026-12-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato" * 3
            WHEN B."PeriodicidadeFaturamento" <> 'Trimestral'
                 AND TO_DATE('2026-12-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato"
            ELSE 0
        END
    , 2) AS "12/2026",

    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2027-01-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "01/2027",
    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2027-02-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "02/2027",

    ROUND(
        CASE
            WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0
            WHEN B."PeriodicidadeFaturamento" = 'Trimestral'
                 AND TO_DATE('2027-03-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato" * 3
            WHEN B."PeriodicidadeFaturamento" <> 'Trimestral'
                 AND TO_DATE('2027-03-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato"
            ELSE 0
        END
    , 2) AS "03/2027",

    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2027-04-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "04/2027",
    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2027-05-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "05/2027",

    ROUND(
        CASE
            WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0
            WHEN B."PeriodicidadeFaturamento" = 'Trimestral'
                 AND TO_DATE('2027-06-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato" * 3
            WHEN B."PeriodicidadeFaturamento" <> 'Trimestral'
                 AND TO_DATE('2027-06-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato"
            ELSE 0
        END
    , 2) AS "06/2027",

    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2027-07-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "07/2027",
    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2027-08-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "08/2027",

    ROUND(
        CASE
            WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0
            WHEN B."PeriodicidadeFaturamento" = 'Trimestral'
                 AND TO_DATE('2027-09-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato" * 3
            WHEN B."PeriodicidadeFaturamento" <> 'Trimestral'
                 AND TO_DATE('2027-09-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato"
            ELSE 0
        END
    , 2) AS "09/2027",

    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2027-10-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "10/2027",
    ROUND(CASE WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0 WHEN B."PeriodicidadeFaturamento" = 'Trimestral' THEN 0 WHEN TO_DATE('2027-11-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData" THEN B."ValorMensalContrato" ELSE 0 END, 2) AS "11/2027",

    ROUND(
        CASE
            WHEN B."PeriodicidadeFaturamento" = 'Medicao' THEN 0
            WHEN B."PeriodicidadeFaturamento" = 'Trimestral'
                 AND TO_DATE('2027-12-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato" * 3
            WHEN B."PeriodicidadeFaturamento" <> 'Trimestral'
                 AND TO_DATE('2027-12-01', 'YYYY-MM-DD') BETWEEN B."InicioFaturamentoData" AND B."FimFaturamentoData"
            THEN B."ValorMensalContrato"
            ELSE 0
        END
    , 2) AS "12/2027"

FROM (
    SELECT
        T0."ContractID" AS "NumeroContrato",
        T0."CstmrCode" AS "CodigoPN",
        T0."CstmrName" AS "NomeParceiro",

        T0."StartDate" AS "DataInicio",
        T0."EndDate" AS "DataTermino",

        DAYS_BETWEEN(CURRENT_DATE, T0."EndDate") AS "DiasRestantes",

        CASE
            WHEN DAYS_BETWEEN(CURRENT_DATE, T0."EndDate") <= 0 THEN 'Vencido'
            WHEN DAYS_BETWEEN(CURRENT_DATE, T0."EndDate") <= 30 THEN 'Vence em 30 dias'
            WHEN DAYS_BETWEEN(CURRENT_DATE, T0."EndDate") <= 60 THEN 'Vence em 60 dias'
            ELSE 'Ativo'
        END AS "Situacao",

        T2."ValorMensalCentroCusto" AS "ValorMensalContrato",
        T2."QuantidadeParcelas" AS "QuantidadeParcelas",
        T2."ValorTotalCentroCusto" AS "ValorTotalContrato",

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
        , 2) AS "PrevistoAteFinalAno",

        T1."DocNum" AS "PedidoVenda",
        T1."Project" AS "NumeroProjeto",
        T5."PrjName" AS "TipoProjeto",
        T3."SlpName" AS "Vendedor",
        T4."BPLName" AS "Filial",
        T2."OcrCode" AS "Departamento",

        CASE
            WHEN T2."OcrCode" = 'GERADOR' THEN 'Gerador'
            WHEN T2."OcrCode" = 'NOBREAK' THEN 'Nobreak'
            ELSE T2."OcrCode"
        END AS "CentroCusto",

        T2."Dscription" AS "DescricaoItem",
        T2."QtdLinhasCentroCusto" AS "QtdLinhasCentroCusto",
        T2."AlertaLinhaPedido" AS "AlertaLinhaPedido",

        CASE
            WHEN T0."U_MM_Tipo_Contrato" = 0 THEN 'Ampliado'
            WHEN T0."U_MM_Tipo_Contrato" = 1 THEN 'Essencial'
            WHEN T0."U_MM_Tipo_Contrato" = 2 THEN 'Service'
            ELSE 'Nao Definido'
        END AS "TipoContrato",

        CASE
            WHEN T0."U_MM_Tipo_Contratacao" = 0 THEN 'Manutencao'
            WHEN T0."U_MM_Tipo_Contratacao" = 1 THEN 'Locacao'
            WHEN T0."U_MM_Tipo_Contratacao" = 2 THEN 'Abastecimento'
            ELSE 'Nao Definido'
        END AS "TipoContratacao",

        CASE
            WHEN T0."U_MM_Tipo_Ativo" = 0 THEN 'Ativo Proprio'
            WHEN T0."U_MM_Tipo_Ativo" = 1 THEN 'Ativo Terceiro'
            ELSE 'Nao Definido'
        END AS "TipoAtivo",

        CASE
            WHEN T0."U_MM_Modelo_Contrato" = 0 THEN 'Publico'
            WHEN T0."U_MM_Modelo_Contrato" = 1 THEN 'Privado'
            ELSE 'Nao Definido'
        END AS "PublicoPrivado",

        CASE
            WHEN T0."U_MM_Preve_Material" = 0 THEN 'Previsto'
            WHEN T0."U_MM_Preve_Material" = 1 THEN 'Nao Previsto'
            ELSE 'Nao Definido'
        END AS "FornecimentoMaterial",

        CASE
            WHEN T0."U_MM_Periodicidade" = 0 THEN 'Mensal'
            WHEN T0."U_MM_Periodicidade" = 1 THEN 'Bimestral'
            WHEN T0."U_MM_Periodicidade" = 2 THEN 'Trimestral'
            WHEN T0."U_MM_Periodicidade" = 3 THEN 'Semestral'
            WHEN T0."U_MM_Periodicidade" = 4 THEN 'Anual'
            ELSE 'Nao Definido'
        END AS "PeriodicidadePreventiva",

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
        END AS "ChecklistVisitas",

        T0."U_MM_Area_Rota" AS "AreaRota",
        T0."U_MM_Macro_Regiao" AS "MacroRegiao",

        CASE
            WHEN T0."U_MM_Logsis" = 0 THEN 'Nao'
            WHEN T0."U_MM_Logsis" = 1 THEN 'Sim'
            ELSE 'Nao Definido'
        END AS "MonitoramentoLOGSIS",

        CASE
            WHEN T0."U_MM_Integracao" = 0 THEN 'Nao Definido'
            WHEN T0."U_MM_Integracao" = 1 THEN 'Sim'
            WHEN T0."U_MM_Integracao" = 2 THEN 'Nao'
            ELSE 'Nao Definido'
        END AS "IntegracaoTecnico",

        CASE
            WHEN T1."U_MM_PDB" = '0' THEN 'Nao'
            WHEN T1."U_MM_PDB" = '1' THEN 'Sim'
            ELSE 'Nao Definido'
        END AS "PassagemBastao",

        CASE
            WHEN T1."U_MM_Passagem_Bastao" = '0' THEN 'PCP'
            WHEN T1."U_MM_Passagem_Bastao" = '1' THEN 'PCM'
            WHEN T1."U_MM_Passagem_Bastao" = '2' THEN 'Locacao'
            WHEN T1."U_MM_Passagem_Bastao" = '3' THEN 'Engenharia'
            ELSE 'Nao Definido'
        END AS "PassagemBastao2",

        CASE
            WHEN T0."ContractID" = 267 THEN 'Trimestral'
            WHEN T0."ContractID" IN (399, 402, 445) THEN 'Medicao'
            ELSE 'Mensal'
        END AS "PeriodicidadeFaturamento",

        TO_DATE(TO_VARCHAR(T0."StartDate", 'YYYY-MM') || '-01', 'YYYY-MM-DD') AS "InicioFaturamentoData",
        TO_DATE(TO_VARCHAR(T0."EndDate", 'YYYY-MM') || '-01', 'YYYY-MM-DD') AS "FimFaturamentoData"

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
) B

ORDER BY
    B."CentroCusto",
    B."DataTermino",
    B."NumeroContrato";
