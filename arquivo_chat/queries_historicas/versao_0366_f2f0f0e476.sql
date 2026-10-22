SELECT
    PV."CreateDate" AS "Dt. Criacao Pedido",

    PV."DocNum" AS "Numero",

    CASE
        WHEN PV."U_MM_Tipo" = '0' THEN 'Nao Definido'
        WHEN PV."U_MM_Tipo" = '2' THEN 'Aditivo'
        WHEN PV."U_MM_Tipo" = '3' THEN 'Pre-Contrato'
        WHEN PV."U_MM_Tipo" = '4' THEN 'Gerado por OS (Pre-Consumo)'
        WHEN PV."U_MM_Tipo" = '5' THEN 'Venda (Avulsa)'
        WHEN PV."U_MM_Tipo" = '9' THEN 'Precor'
        ELSE 'Nao Definido'
    END AS "Tipo",

    CASE
        WHEN PV."DocNum" IN (
            4565, 4452, 1817, 1815, 1666, 1654, 1541, 1538, 1525,
            1383, 1251, 1250, 1249, 1214, 1106, 1101, 1080, 1047,
            961, 941, 922, 899, 882, 877, 875, 874, 849, 843,
            823, 820, 812, 808, 804, 791, 789, 641, 638, 627,
            583, 561, 470, 316, 304, 242, 204, 199, 197, 193,
            190, 188, 186, 185, 166, 56, 53, 21
        )
        THEN 2025
        ELSE YEAR(PV."CreateDate")
    END AS "Ano Competencia Comercial",

    CC."CentroCusto" AS "Centro Custo",

    PV."CardName" AS "Nome do Cliente",

    CASE
        WHEN PV."U_MM_Faturamento" = '1' THEN 'Sim'
        WHEN PV."U_MM_Faturamento" = '0' THEN 'Nao'
        ELSE 'Nao Definido'
    END AS "Liberar Faturamento?",

    CASE
        WHEN
            ROUND(
                IFNULL(NF."ValorFaturado", 0)
                +
                CASE
                    WHEN IFNULL(PV."DocTotal", 0) = 0
                    THEN IFNULL(LEG."ValorFaturadoLegado", 0)
                    ELSE
                        IFNULL(LEG."ValorFaturadoLegado", 0)
                        * CC."ValorPedidoCentroCusto"
                        / NULLIF(PV."DocTotal", 0)
                END,
                2
            ) = 0
        THEN 'A Faturar'

        WHEN
            ROUND(
                IFNULL(NF."ValorFaturado", 0)
                +
                CASE
                    WHEN IFNULL(PV."DocTotal", 0) = 0
                    THEN IFNULL(LEG."ValorFaturadoLegado", 0)
                    ELSE
                        IFNULL(LEG."ValorFaturadoLegado", 0)
                        * CC."ValorPedidoCentroCusto"
                        / NULLIF(PV."DocTotal", 0)
                END,
                2
            ) >= CC."ValorPedidoCentroCusto"
        THEN 'Faturado'

        ELSE 'Parcial'
    END AS "Status Pedido",

    PV."DocDueDate" AS "Dt. Entrega",

    CC."ValorPedidoCentroCusto" AS "Vl. Total",

    ROUND(IFNULL(PV."U_MM_Material", 0) / NULLIF(CC."QtdCentrosCusto", 0), 2) AS "Material",
    ROUND(IFNULL(PV."U_MM_MO_DIRETA", 0) / NULLIF(CC."QtdCentrosCusto", 0), 2) AS "MO Direta",
    ROUND(IFNULL(PV."U_MM_MO_INDIRETA", 0) / NULLIF(CC."QtdCentrosCusto", 0), 2) AS "MO Indireta",
    ROUND(IFNULL(PV."U_MM_Alimentacao", 0) / NULLIF(CC."QtdCentrosCusto", 0), 2) AS "Alimentacao",
    ROUND(IFNULL(PV."U_MM_Hospedagem", 0) / NULLIF(CC."QtdCentrosCusto", 0), 2) AS "Hospedagem",
    ROUND(IFNULL(PV."U_MM_Equipamento", 0) / NULLIF(CC."QtdCentrosCusto", 0), 2) AS "Equipamento (Locacao)",
    ROUND(IFNULL(PV."U_MM_Deslocamento", 0) / NULLIF(CC."QtdCentrosCusto", 0), 2) AS "Deslocamento",
    ROUND(IFNULL(PV."U_MM_Frete", 0) / NULLIF(CC."QtdCentrosCusto", 0), 2) AS "Frete",
    ROUND(IFNULL(PV."U_MM_Servicos", 0) / NULLIF(CC."QtdCentrosCusto", 0), 2) AS "Servicos",
    ROUND(IFNULL(PV."U_MM_Pedagio", 0) / NULLIF(CC."QtdCentrosCusto", 0), 2) AS "Pedagios",

    ROUND(
        (
            IFNULL(PV."U_MM_Material", 0)
            + IFNULL(PV."U_MM_MO_DIRETA", 0)
            + IFNULL(PV."U_MM_MO_INDIRETA", 0)
            + IFNULL(PV."U_MM_Alimentacao", 0)
            + IFNULL(PV."U_MM_Hospedagem", 0)
            + IFNULL(PV."U_MM_Equipamento", 0)
            + IFNULL(PV."U_MM_Deslocamento", 0)
            + IFNULL(PV."U_MM_Frete", 0)
            + IFNULL(PV."U_MM_Servicos", 0)
            + IFNULL(PV."U_MM_Pedagio", 0)
        ) / NULLIF(CC."QtdCentrosCusto", 0),
        2
    ) AS "Custo Total",

    ROUND(
        IFNULL(NF."ValorFaturado", 0)
        +
        CASE
            WHEN IFNULL(PV."DocTotal", 0) = 0
            THEN IFNULL(LEG."ValorFaturadoLegado", 0)
            ELSE
                IFNULL(LEG."ValorFaturadoLegado", 0)
                * CC."ValorPedidoCentroCusto"
                / NULLIF(PV."DocTotal", 0)
        END,
        2
    ) AS "Valor Faturado",

    CC."ValorPedidoCentroCusto"
        -
    ROUND(
        IFNULL(NF."ValorFaturado", 0)
        +
        CASE
            WHEN IFNULL(PV."DocTotal", 0) = 0
            THEN IFNULL(LEG."ValorFaturadoLegado", 0)
            ELSE
                IFNULL(LEG."ValorFaturadoLegado", 0)
                * CC."ValorPedidoCentroCusto"
                / NULLIF(PV."DocTotal", 0)
        END,
        2
    ) AS "A Faturar",

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

    PV."Project" AS "NumProjeto",

    VEND."SlpName" AS "Nome do Repr."

FROM ORDR PV

INNER JOIN (
    SELECT
        C."DocEntry",
        C."CentroCusto",
        QTD_CC."QtdCentrosCusto",

        ROUND(
            CASE
                WHEN IFNULL(B."ValorBasePedido", 0) = 0
                THEN C."ValorLinhasCentroCusto"

                ELSE
                    PV_CC."DocTotal"
                    * C."ValorLinhasCentroCusto"
                    / NULLIF(B."ValorBasePedido", 0)
            END,
            2
        ) AS "ValorPedidoCentroCusto"

    FROM (
        SELECT
            R1."DocEntry",
            R1."OcrCode" AS "CentroCusto",
            SUM(R1."LineTotal") AS "ValorLinhasCentroCusto"

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
    ) C

    INNER JOIN (
        SELECT
            R1_TOTAL."DocEntry",
            SUM(R1_TOTAL."LineTotal") AS "ValorBasePedido"

        FROM RDR1 R1_TOTAL

        GROUP BY
            R1_TOTAL."DocEntry"
    ) B
        ON B."DocEntry" = C."DocEntry"

    INNER JOIN (
        SELECT
            Q."DocEntry",
            COUNT(*) AS "QtdCentrosCusto"

        FROM (
            SELECT DISTINCT
                R1_QTD."DocEntry",
                R1_QTD."OcrCode"

            FROM RDR1 R1_QTD

            WHERE
                R1_QTD."OcrCode" IN (
                    'GERADOR',
                    'NOBREAK',
                    'EXE_ELET',
                    'FOTOV',
                    'REV_DIRE'
                )
        ) Q

        GROUP BY
            Q."DocEntry"
    ) QTD_CC
        ON QTD_CC."DocEntry" = C."DocEntry"

    INNER JOIN ORDR PV_CC
        ON PV_CC."DocEntry" = C."DocEntry"
) CC
    ON CC."DocEntry" = PV."DocEntry"

LEFT JOIN (
    SELECT
        FAT."PedidoDocEntry",
        FAT."CentroCusto",

        STRING_AGG(FAT."NFTexto", ', ') AS "NumNF",

        MAX(FAT."DocDate") AS "DtFaturamento",

        SUM(FAT."ValorNFeML") AS "ValorFaturado"

    FROM (
        SELECT
            NF_LINHA."PedidoDocEntry",
            NF_LINHA."CentroCusto",
            NF_LINHA."NFTexto",
            NF_LINHA."DocDate",
            NF_LINHA."ValorNFeML"

        FROM (
            SELECT
                I1."BaseEntry" AS "PedidoDocEntry",

                IFNULL(I1."OcrCode", R1."OcrCode") AS "CentroCusto",

                TO_VARCHAR(NF0."Serial") AS "NFTexto",

                NF0."DocDate",

                NF0."NfeValue" AS "ValorNFeML",

                ROW_NUMBER() OVER (
                    PARTITION BY
                        NF0."DocEntry",
                        I1."BaseEntry",
                        IFNULL(I1."OcrCode", R1."OcrCode")
                    ORDER BY
                        I1."LineNum"
                ) AS "LinhaControle"

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

            WHERE
                I1."BaseType" = 17

                AND IFNULL(I1."OcrCode", R1."OcrCode") IN (
                    'GERADOR',
                    'NOBREAK',
                    'EXE_ELET',
                    'FOTOV',
                    'REV_DIRE'
                )

                AND NF0."Serial" IS NOT NULL

                AND IFNULL(I1."TaxOnly", 'N') <> 'Y'
                AND IFNULL(U."TaxOnly", 'N') <> 'Y'
                AND IFNULL(I1."Usage", -1) <> 37
        ) NF_LINHA

        WHERE
            NF_LINHA."LinhaControle" = 1
    ) FAT

    GROUP BY
        FAT."PedidoDocEntry",
        FAT."CentroCusto"
) NF
    ON NF."PedidoDocEntry" = PV."DocEntry"
    AND NF."CentroCusto" = CC."CentroCusto"

LEFT JOIN (
    SELECT 4565 AS "DocNum", CAST(0.00 AS DECIMAL(21, 2)) AS "ValorFaturadoLegado" FROM DUMMY UNION ALL
    SELECT 4452, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1817, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1815, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1666, CAST(69000.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1654, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1541, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1538, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1525, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1383, CAST(434155.55 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1251, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1250, CAST(75753.30 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1249, CAST(59712.90 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1214, CAST(371480.42 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1106, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1101, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1080, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 1047, CAST(1500000.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 961, CAST(730249.58 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 941, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 922, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 899, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 882, CAST(55899.42 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 877, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 875, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 874, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 849, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 843, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 823, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 820, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 812, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 808, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 804, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 791, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 789, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 641, CAST(56111.18 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 638, CAST(3480.30 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 627, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 583, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 561, CAST(16936.80 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 470, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 316, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 304, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 242, CAST(11485.44 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 204, CAST(11485.44 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 199, CAST(6519.24 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 197, CAST(11485.44 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 193, CAST(11485.44 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 190, CAST(11485.44 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 188, CAST(11485.44 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 186, CAST(11485.44 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 185, CAST(11485.44 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 166, CAST(0.00 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 56, CAST(18682.80 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 53, CAST(18876.36 AS DECIMAL(21, 2)) FROM DUMMY UNION ALL
    SELECT 21, CAST(10189.60 AS DECIMAL(21, 2)) FROM DUMMY
) LEG
    ON LEG."DocNum" = PV."DocNum"

LEFT JOIN (
    SELECT
        OS_AGRUPADA."PedidoDocNum",

        STRING_AGG(OS_AGRUPADA."NumOSTexto", ', ') AS "NumOS",
        STRING_AGG(OS_AGRUPADA."StatusTexto", ', ') AS "StatusOS",
        STRING_AGG(OS_AGRUPADA."AssuntoTexto", ' | ') AS "AssuntoOS",

        MAX(OS_AGRUPADA."DataCriacao") AS "DtCriacaoOS"

    FROM (
        SELECT DISTINCT
            TO_VARCHAR(OS0."U_MM_PV") AS "PedidoDocNum",

            TO_VARCHAR(OS0."callID") AS "NumOSTexto",

            CASE
                WHEN OS0."status" = -3 THEN 'Aberto'
                WHEN OS0."status" = -2 THEN 'Pendente'
                WHEN OS0."status" = -1 THEN 'Fechado'
                WHEN OS0."status" = 1 THEN 'Aguardando Pecas'
                WHEN OS0."status" = 2 THEN 'Encerrado IClass'
                WHEN OS0."status" = 3 THEN 'Enviar IClass'
                WHEN OS0."status" = 4 THEN 'Enviado IClass'
                WHEN OS0."status" = 5 THEN 'Equipamento Parado'
                WHEN OS0."status" IS NULL THEN NULL
                ELSE 'Nao Definido'
            END AS "StatusTexto",

            OS0."subject" AS "AssuntoTexto",
            OS0."createDate" AS "DataCriacao"

        FROM OSCL OS0

        WHERE
            OS0."U_MM_PV" IS NOT NULL
    ) OS_AGRUPADA

    GROUP BY
        OS_AGRUPADA."PedidoDocNum"
) OS
    ON OS."PedidoDocNum" = TO_VARCHAR(PV."DocNum")

LEFT JOIN OSLP VEND
    ON VEND."SlpCode" = PV."SlpCode"

WHERE
    PV."CANCELED" = 'N'
    AND PV."Confirmed" = 'Y'
    AND PV."U_MM_Tipo" IN ('5', '9')

ORDER BY
    PV."CreateDate",
    PV."DocNum",
    CC."CentroCusto";
