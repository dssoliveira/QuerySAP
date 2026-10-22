WITH M AS (

    /* =========================================================
       METAS E RETROATIVOS POR CENTRO DE CUSTO
    ========================================================= */

    SELECT
        1 AS "OrdemDepto",
        'Gerador' AS "Departamento",
        'GERADOR' AS "OcrCode",
        712000 AS "MetaJan", 712000 AS "MetaFev", 712000 AS "MetaMar",
        753000 AS "MetaAbr", 753000 AS "MetaMai", 753000 AS "MetaJun",
        838000 AS "MetaJul", 838000 AS "MetaAgo", 838000 AS "MetaSet",
        1029000 AS "MetaOut", 1031000 AS "MetaNov", 1031000 AS "MetaDez",
        10034000 AS "MetaAno",
        507091.15 AS "RetroJan",
        465528.46 AS "RetroFev"
    FROM DUMMY

    UNION ALL

    SELECT
        2, 'Nobreak', 'NOBREAK',
        135000, 135000, 135000,
        175000, 175000, 175000,
        228000, 228000, 228000,
        295000, 295000, 296000,
        2496000,
        167580.25,
        192585.73
    FROM DUMMY

    UNION ALL

    SELECT
        3, 'Locacao', 'LOCACAO',
        1318000, 1318000, 1318000,
        1396000, 1396000, 1396000,
        1554000, 1554000, 1554000,
        2121000, 2121000, 2121000,
        19167000,
        999929.41,
        1097137.99
    FROM DUMMY

    UNION ALL

    SELECT
        4, 'Execucao Eletrica', 'EXE_ELET',
        870000, 870000, 870000,
        972000, 972000, 972000,
        1364000, 1369000, 1369000,
        1624000, 1624000, 1624000,
        14500000,
        77793.41,
        369339.30
    FROM DUMMY

    UNION ALL

    SELECT
        5, 'Fotovoltaico', 'FOTOV',
        192000, 192000, 192000,
        220000, 220000, 220000,
        246500, 246500, 246500,
        308000, 308000, 308500,
        2900000,
        4112.88,
        0
    FROM DUMMY

    UNION ALL

    SELECT
        6, 'Revenda Direta', 'REV_DIRE',
        557000, 557000, 557000,
        591000, 591000, 591000,
        657000, 657000, 657000,
        823000, 825000, 825000,
        7888000,
        64000,
        0
    FROM DUMMY

    UNION ALL

    SELECT
        7, 'Seminovo', 'SEMINOVO',
        0, 0, 0,
        0, 0, 0,
        0, 0, 0,
        0, 0, 0,
        0,
        0,
        0
    FROM DUMMY
),

ENT AS (

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

NF_BASE AS (

    /* =========================================================
       BASE FISCAL OFICIAL DE FATURAMENTO / METAS

       Regra alinhada com o relatório oficial de NF:
       - NF normal entra no realizado
       - NF venda futura pura sai do realizado:
            CFOP 5922/6922 sem entrega vinculada
       - NF futura com entrega vinculada entra como entrega:
            usa data e valor da ODLN
       - Mantém uma linha por NF para evitar duplicidade
    ========================================================= */

    SELECT
        X."DocEntry",
        X."DocDate",
        X."NfeValue",
        X."OcrCode"

    FROM (
        SELECT
            T0."DocEntry",

            CASE
                WHEN ENT."Data_Entrega" IS NOT NULL
                THEN ENT."Data_Entrega"
                ELSE T0."DocDate"
            END AS "DocDate",

            CASE
                WHEN ENT."Valor_Entrega" IS NOT NULL
                THEN ENT."Valor_Entrega"
                ELSE T0."NfeValue"
            END AS "NfeValue",

            IFNULL(
                T1."OcrCode",
                IFNULL(
                    R1."OcrCode",
                    IFNULL(D1."OcrCode", R1F."OcrCode")
                )
            ) AS "OcrCode",

            ENT."Num_Documento_Entrega",

            MAX(
                CASE
                    WHEN TO_VARCHAR(T1."CFOPCode") IN ('5922', '6922')
                    THEN 1
                    ELSE 0
                END
            ) OVER (PARTITION BY T0."DocEntry") AS "FlagVendaFutura",

            ROW_NUMBER() OVER (
                PARTITION BY T0."DocEntry"
                ORDER BY
                    CASE
                        WHEN ENT."Num_Documento_Entrega" IS NOT NULL THEN 0
                        WHEN T1."BaseType" = 15 THEN 1
                        WHEN T1."BaseType" = 17 THEN 2
                        ELSE 3
                    END,
                    T1."LineNum"
            ) AS "LinhaControle"

        FROM OINV T0

        INNER JOIN INV1 T1
            ON T1."DocEntry" = T0."DocEntry"

        LEFT JOIN RDR1 R1
            ON T1."BaseType" = 17
            AND T1."BaseEntry" = R1."DocEntry"
            AND T1."BaseLine" = R1."LineNum"

        LEFT JOIN DLN1 D1
            ON T1."BaseType" = 15
            AND T1."BaseEntry" = D1."DocEntry"
            AND T1."BaseLine" = D1."LineNum"

        LEFT JOIN INV1 F1
            ON D1."BaseType" = 13
            AND D1."BaseEntry" = F1."DocEntry"
            AND D1."BaseLine" = F1."LineNum"

        LEFT JOIN RDR1 R1F
            ON F1."BaseType" = 17
            AND F1."BaseEntry" = R1F."DocEntry"
            AND F1."BaseLine" = R1F."LineNum"

        LEFT JOIN OUSG U
            ON U."ID" = T1."Usage"

        LEFT JOIN ENT
            ON ENT."DocEntryNFOrigem" = T0."DocEntry"

        WHERE
            T0."CANCELED" = 'N'

            AND YEAR(
                CASE
                    WHEN ENT."Data_Entrega" IS NOT NULL
                    THEN ENT."Data_Entrega"
                    ELSE T0."DocDate"
                END
            ) = YEAR(CURRENT_DATE)

            AND IFNULL(
                T1."OcrCode",
                IFNULL(
                    R1."OcrCode",
                    IFNULL(D1."OcrCode", R1F."OcrCode")
                )
            ) IN (
                'GERADOR',
                'NOBREAK',
                'LOCACAO',
                'EXE_ELET',
                'FOTOV',
                'REV_DIRE',
                'SEMINOVO'
            )

            AND IFNULL(T1."TaxOnly", 'N') <> 'Y'
            AND IFNULL(U."TaxOnly", 'N') <> 'Y'
    ) X

    WHERE
        X."LinhaControle" = 1

        AND NOT (
            X."FlagVendaFutura" = 1
            AND X."Num_Documento_Entrega" IS NULL
        )
),

A AS (

    SELECT
        NF."OcrCode",

        SUM(CASE WHEN MONTH(NF."DocDate") = 1 THEN NF."NfeValue" ELSE 0 END) AS "Jan",
        SUM(CASE WHEN MONTH(NF."DocDate") = 2 THEN NF."NfeValue" ELSE 0 END) AS "Fev",
        SUM(CASE WHEN MONTH(NF."DocDate") = 3 THEN NF."NfeValue" ELSE 0 END) AS "Mar",
        SUM(CASE WHEN MONTH(NF."DocDate") = 4 THEN NF."NfeValue" ELSE 0 END) AS "Abr",
        SUM(CASE WHEN MONTH(NF."DocDate") = 5 THEN NF."NfeValue" ELSE 0 END) AS "Mai",
        SUM(CASE WHEN MONTH(NF."DocDate") = 6 THEN NF."NfeValue" ELSE 0 END) AS "Jun",
        SUM(CASE WHEN MONTH(NF."DocDate") = 7 THEN NF."NfeValue" ELSE 0 END) AS "Jul",
        SUM(CASE WHEN MONTH(NF."DocDate") = 8 THEN NF."NfeValue" ELSE 0 END) AS "Ago",
        SUM(CASE WHEN MONTH(NF."DocDate") = 9 THEN NF."NfeValue" ELSE 0 END) AS "Set",
        SUM(CASE WHEN MONTH(NF."DocDate") = 10 THEN NF."NfeValue" ELSE 0 END) AS "Out",
        SUM(CASE WHEN MONTH(NF."DocDate") = 11 THEN NF."NfeValue" ELSE 0 END) AS "Nov",
        SUM(CASE WHEN MONTH(NF."DocDate") = 12 THEN NF."NfeValue" ELSE 0 END) AS "Dez",

        SUM(NF."NfeValue") AS "AcumuladoSAP"

    FROM NF_BASE NF

    GROUP BY
        NF."OcrCode"
),

R AS (

    SELECT
        M."OrdemDepto" * 2 - 1 AS "Ordem",
        M."Departamento",
        M."OcrCode",
        'Meta' AS "Indicador",

        M."MetaJan" AS "Jan",
        M."MetaFev" AS "Fev",
        M."MetaMar" AS "Mar",
        M."MetaAbr" AS "Abr",
        M."MetaMai" AS "Mai",
        M."MetaJun" AS "Jun",
        M."MetaJul" AS "Jul",
        M."MetaAgo" AS "Ago",
        M."MetaSet" AS "Set",
        M."MetaOut" AS "Out",
        M."MetaNov" AS "Nov",
        M."MetaDez" AS "Dez",

        M."MetaAno" AS "Acumulado",

        NULL AS "%Alcancado"

    FROM M

    UNION ALL

    SELECT
        M."OrdemDepto" * 2 AS "Ordem",
        '' AS "Departamento",
        M."OcrCode",
        'Realizado' AS "Indicador",

        IFNULL(A."Jan", 0) + M."RetroJan" AS "Jan",
        IFNULL(A."Fev", 0) + M."RetroFev" AS "Fev",
        IFNULL(A."Mar", 0) AS "Mar",
        IFNULL(A."Abr", 0) AS "Abr",
        IFNULL(A."Mai", 0) AS "Mai",
        IFNULL(A."Jun", 0) AS "Jun",
        IFNULL(A."Jul", 0) AS "Jul",
        IFNULL(A."Ago", 0) AS "Ago",
        IFNULL(A."Set", 0) AS "Set",
        IFNULL(A."Out", 0) AS "Out",
        IFNULL(A."Nov", 0) AS "Nov",
        IFNULL(A."Dez", 0) AS "Dez",

        IFNULL(A."AcumuladoSAP", 0)
            + M."RetroJan"
            + M."RetroFev" AS "Acumulado",

        CASE
            WHEN M."MetaAno" = 0 THEN 0
            ELSE ROUND(
                (
                    IFNULL(A."AcumuladoSAP", 0)
                    + M."RetroJan"
                    + M."RetroFev"
                ) / M."MetaAno" * 100,
                2
            )
        END AS "%Alcancado"

    FROM M

    LEFT JOIN A
        ON A."OcrCode" = M."OcrCode"
),

S AS (

    SELECT
        R."Indicador",

        SUM(R."Jan") AS "Jan",
        SUM(R."Fev") AS "Fev",
        SUM(R."Mar") AS "Mar",
        SUM(R."Abr") AS "Abr",
        SUM(R."Mai") AS "Mai",
        SUM(R."Jun") AS "Jun",
        SUM(R."Jul") AS "Jul",
        SUM(R."Ago") AS "Ago",
        SUM(R."Set") AS "Set",
        SUM(R."Out") AS "Out",
        SUM(R."Nov") AS "Nov",
        SUM(R."Dez") AS "Dez",

        SUM(R."Acumulado") AS "Acumulado"

    FROM R

    WHERE
        R."OcrCode" IN (
            'EXE_ELET',
            'FOTOV',
            'REV_DIRE',
            'SEMINOVO'
        )

    GROUP BY
        R."Indicador"
),

T AS (

    SELECT
        R."Indicador",

        SUM(R."Jan") AS "Jan",
        SUM(R."Fev") AS "Fev",
        SUM(R."Mar") AS "Mar",
        SUM(R."Abr") AS "Abr",
        SUM(R."Mai") AS "Mai",
        SUM(R."Jun") AS "Jun",
        SUM(R."Jul") AS "Jul",
        SUM(R."Ago") AS "Ago",
        SUM(R."Set") AS "Set",
        SUM(R."Out") AS "Out",
        SUM(R."Nov") AS "Nov",
        SUM(R."Dez") AS "Dez",

        SUM(R."Acumulado") AS "Acumulado"

    FROM R

    GROUP BY
        R."Indicador"
)

SELECT
    X."Departamento",
    X."Indicador",
    X."Jan",
    X."Fev",
    X."Mar",
    X."Abr",
    X."Mai",
    X."Jun",
    X."Jul",
    X."Ago",
    X."Set",
    X."Out",
    X."Nov",
    X."Dez",
    X."Acumulado",
    X."%Alcancado"

FROM (

    SELECT
        R."Ordem",
        R."Departamento",
        R."Indicador",
        R."Jan",
        R."Fev",
        R."Mar",
        R."Abr",
        R."Mai",
        R."Jun",
        R."Jul",
        R."Ago",
        R."Set",
        R."Out",
        R."Nov",
        R."Dez",
        R."Acumulado",
        R."%Alcancado"

    FROM R

    UNION ALL

    SELECT
        997 AS "Ordem",
        'Somatoria EXE/FV/RVD/SN' AS "Departamento",
        'Meta' AS "Indicador",

        SM."Jan",
        SM."Fev",
        SM."Mar",
        SM."Abr",
        SM."Mai",
        SM."Jun",
        SM."Jul",
        SM."Ago",
        SM."Set",
        SM."Out",
        SM."Nov",
        SM."Dez",
        SM."Acumulado",

        NULL AS "%Alcancado"

    FROM S SM

    WHERE
        SM."Indicador" = 'Meta'

    UNION ALL

    SELECT
        998 AS "Ordem",
        '' AS "Departamento",
        'Realizado' AS "Indicador",

        SR."Jan",
        SR."Fev",
        SR."Mar",
        SR."Abr",
        SR."Mai",
        SR."Jun",
        SR."Jul",
        SR."Ago",
        SR."Set",
        SR."Out",
        SR."Nov",
        SR."Dez",
        SR."Acumulado",

        CASE
            WHEN IFNULL(SM."Acumulado", 0) = 0 THEN 0
            ELSE ROUND(
                SR."Acumulado" / SM."Acumulado" * 100,
                2
            )
        END AS "%Alcancado"

    FROM S SR

    LEFT JOIN S SM
        ON SM."Indicador" = 'Meta'

    WHERE
        SR."Indicador" = 'Realizado'

    UNION ALL

    SELECT
        999 AS "Ordem",
        'Subtotal' AS "Departamento",
        'Meta' AS "Indicador",

        TM."Jan",
        TM."Fev",
        TM."Mar",
        TM."Abr",
        TM."Mai",
        TM."Jun",
        TM."Jul",
        TM."Ago",
        TM."Set",
        TM."Out",
        TM."Nov",
        TM."Dez",
        TM."Acumulado",

        NULL AS "%Alcancado"

    FROM T TM

    WHERE
        TM."Indicador" = 'Meta'

    UNION ALL

    SELECT
        1000 AS "Ordem",
        '' AS "Departamento",
        'Realizado' AS "Indicador",

        TR."Jan",
        TR."Fev",
        TR."Mar",
        TR."Abr",
        TR."Mai",
        TR."Jun",
        TR."Jul",
        TR."Ago",
        TR."Set",
        TR."Out",
        TR."Nov",
        TR."Dez",
        TR."Acumulado",

        CASE
            WHEN IFNULL(TM."Acumulado", 0) = 0 THEN 0
            ELSE ROUND(
                TR."Acumulado" / TM."Acumulado" * 100,
                2
            )
        END AS "%Alcancado"

    FROM T TR

    LEFT JOIN T TM
        ON TM."Indicador" = 'Meta'

    WHERE
        TR."Indicador" = 'Realizado'

) X

ORDER BY
    X."Ordem";
