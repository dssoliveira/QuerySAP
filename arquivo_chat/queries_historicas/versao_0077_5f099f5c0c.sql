SELECT
    T0."ContractID" AS "Numero Contrato",

    CASE
        WHEN T2."OcrCode" = 'GERADOR' THEN 'Gerador'
        WHEN T2."OcrCode" = 'NOBREAK' THEN 'Nobreak'
        ELSE T2."OcrCode"
    END AS "Centro de Custo",

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
    T2."AlertaLinhaPedido" AS "Alerta Linha Pedido"

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

ORDER BY
    T2."OcrCode",
    T0."EndDate",
    T0."ContractID";
