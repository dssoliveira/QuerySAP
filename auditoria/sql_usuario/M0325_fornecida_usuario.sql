SELECT
    T0."CreateDate" AS "Dt. Criacao Pedido",

    T0."DocNum" AS "Numero",

    CASE
        WHEN T0."U_MM_Tipo" = '0' THEN 'Nao Definido'
        WHEN T0."U_MM_Tipo" = '2' THEN 'Aditivo'
        WHEN T0."U_MM_Tipo" = '3' THEN 'Pre-Contrato'
        WHEN T0."U_MM_Tipo" = '4' THEN 'Gerado por OS (Pre-Consumo)'
        WHEN T0."U_MM_Tipo" = '5' THEN 'Venda (Avulsa)'
        ELSE 'Nao Definido'
    END AS "Tipo",

    CC."CentroCusto" AS "Centro Custo",

    T0."CardName" AS "Nome do Cliente",

    CASE
        WHEN T0."U_MM_Faturamento" = '1' THEN 'Sim'
        WHEN T0."U_MM_Faturamento" = '0' THEN 'Nao'
        ELSE 'Nao Definido'
    END AS "Liberar Faturamento?",

    CASE
        WHEN IFNULL(NF."ValorFaturado", 0) = 0 THEN 'A Faturar'
        WHEN IFNULL(NF."ValorFaturado", 0) >= CC."ValorPedidoCentroCusto" THEN 'Faturado'
        ELSE 'Parcial'
    END AS "Status Pedido",

    T0."DocDueDate" AS "Dt. Entrega",

    CC."ValorPedidoCentroCusto" AS "Vl. Total",

    IFNULL(NF."ValorFaturado", 0) AS "Valor Faturado",

    CC."ValorPedidoCentroCusto" - IFNULL(NF."ValorFaturado", 0) AS "A Faturar",

    NF."NumNF" AS "Num. NF",

    NF."DtFaturamento" AS "Dt. Faturamento",

    OS."NumOS" AS "NumOS",

    CASE
        WHEN OS."NumOS" IS NULL THEN 'Sem OS'
        ELSE 'Com OS'
    END AS "Status Vinculo OS",

    OS."StatusOS" AS "Status OS",

    CAST(
        CASE
            WHEN LENGTH(IFNULL(OS."AssuntoOS", '')) > 120
            THEN SUBSTRING(OS."AssuntoOS", 1, 120) || '...'
            ELSE OS."AssuntoOS"
        END
        AS NVARCHAR(123)
    ) AS "Assunto OS",

    OS."DtCriacaoOS" AS "Dt. Criacao OS",

    T0."Project" AS "NumProjeto",

    VEND."SlpName" AS "Nome do Repr."

FROM ORDR T0

INNER JOIN (
    SELECT
        R1."DocEntry",
        R1."OcrCode" AS "CentroCusto",
        SUM(R1."LineTotal") AS "ValorPedidoCentroCusto"
    FROM RDR1 R1
    WHERE
        R1."OcrCode" IN (
            'GERADOR',
            'NOBREAK',
            'EXE_ELET',
            'FOTOV',
            'REV_DIRE'
        )
    GROUP BY
        R1."DocEntry",
        R1."OcrCode"
) CC
    ON CC."DocEntry" = T0."DocEntry"

LEFT JOIN (
    SELECT
        Z."PedidoDocEntry",
        Z."CentroCusto",
        STRING_AGG(Z."NFTexto", ', ') AS "NumNF",
        MAX(Z."DocDate") AS "DtFaturamento",
        SUM(Z."ValorLinhaFaturada") AS "ValorFaturado"
    FROM (
        SELECT
            I1."BaseEntry" AS "PedidoDocEntry",
            I1."OcrCode" AS "CentroCusto",
            TO_VARCHAR(NF0."Serial") AS "NFTexto",
            NF0."DocDate",
            I1."LineTotal" AS "ValorLinhaFaturada"
        FROM INV1 I1

        INNER JOIN OINV NF0
            ON NF0."DocEntry" = I1."DocEntry"
            AND NF0."CANCELED" = 'N'

        WHERE
            I1."BaseType" = 17
            AND I1."OcrCode" IN (
                'GERADOR',
                'NOBREAK',
                'EXE_ELET',
                'FOTOV',
                'REV_DIRE'
            )
            AND NF0."Serial" IS NOT NULL
    ) Z
    GROUP BY
        Z."PedidoDocEntry",
        Z."CentroCusto"
) NF
    ON NF."PedidoDocEntry" = T0."DocEntry"
    AND NF."CentroCusto" = CC."CentroCusto"

LEFT JOIN (
    SELECT
        X."PedidoDocNum",

        STRING_AGG(X."NumOSTexto", ', ') AS "NumOS",
        STRING_AGG(X."StatusTexto", ', ') AS "StatusOS",
        STRING_AGG(X."AssuntoTexto", ' | ') AS "AssuntoOS",
        MAX(X."DataCriacao") AS "DtCriacaoOS"

    FROM (
        SELECT DISTINCT
            TO_VARCHAR(S."U_MM_PV") AS "PedidoDocNum",
            TO_VARCHAR(S."callID") AS "NumOSTexto",

            CASE
                WHEN S."status" = -3 THEN 'Aberto'
                WHEN S."status" = -2 THEN 'Pendente'
                WHEN S."status" = -1 THEN 'Fechado'
                WHEN S."status" = 1 THEN 'Aguardando Pecas'
                WHEN S."status" = 2 THEN 'Encerrado IClass'
                WHEN S."status" = 3 THEN 'Enviar IClass'
                WHEN S."status" = 4 THEN 'Enviado IClass'
                WHEN S."status" = 5 THEN 'Equipamento Parado'
                WHEN S."status" IS NULL THEN NULL
                ELSE 'Nao Definido'
            END AS "StatusTexto",

            S."subject" AS "AssuntoTexto",
            S."createDate" AS "DataCriacao"

        FROM OSCL S

        WHERE
            S."U_MM_PV" IS NOT NULL
    ) X

    GROUP BY
        X."PedidoDocNum"
) OS
    ON OS."PedidoDocNum" = TO_VARCHAR(T0."DocNum")

LEFT JOIN OSLP VEND
    ON VEND."SlpCode" = T0."SlpCode"

WHERE
    T0."CANCELED" = 'N'
    AND T0."Confirmed" = 'Y'
    AND T0."U_MM_Tipo" = '5'

ORDER BY
    T0."CreateDate",
    T0."DocNum",
    CC."CentroCusto";
