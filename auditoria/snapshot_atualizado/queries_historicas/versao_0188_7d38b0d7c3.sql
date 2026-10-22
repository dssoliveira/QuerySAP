A AS (

    /* =========================================================
       FATURAMENTO REAL POR CENTRO DE CUSTO

       Mantem o realizado original vindo da NF_BASE
       e apenas acrescenta os documentos de entrega vinculados
       a NF de entrega futura.
    ========================================================= */

    SELECT
        R."OcrCode",

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

        SUM(R."AcumuladoSAP") AS "AcumuladoSAP"

    FROM (

        /* =====================================================
           REALIZADO ORIGINAL
           Nao altera o que a query ja calculava
        ===================================================== */

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


        UNION ALL


        /* =====================================================
           VALORES FALTANTES
           Documentos de entrega vinculados a NF de entrega futura
        ===================================================== */

        SELECT
            E."OcrCode",

            SUM(CASE WHEN MONTH(E."DocDate") = 1 THEN E."DocTotal" ELSE 0 END) AS "Jan",
            SUM(CASE WHEN MONTH(E."DocDate") = 2 THEN E."DocTotal" ELSE 0 END) AS "Fev",
            SUM(CASE WHEN MONTH(E."DocDate") = 3 THEN E."DocTotal" ELSE 0 END) AS "Mar",
            SUM(CASE WHEN MONTH(E."DocDate") = 4 THEN E."DocTotal" ELSE 0 END) AS "Abr",
            SUM(CASE WHEN MONTH(E."DocDate") = 5 THEN E."DocTotal" ELSE 0 END) AS "Mai",
            SUM(CASE WHEN MONTH(E."DocDate") = 6 THEN E."DocTotal" ELSE 0 END) AS "Jun",
            SUM(CASE WHEN MONTH(E."DocDate") = 7 THEN E."DocTotal" ELSE 0 END) AS "Jul",
            SUM(CASE WHEN MONTH(E."DocDate") = 8 THEN E."DocTotal" ELSE 0 END) AS "Ago",
            SUM(CASE WHEN MONTH(E."DocDate") = 9 THEN E."DocTotal" ELSE 0 END) AS "Set",
            SUM(CASE WHEN MONTH(E."DocDate") = 10 THEN E."DocTotal" ELSE 0 END) AS "Out",
            SUM(CASE WHEN MONTH(E."DocDate") = 11 THEN E."DocTotal" ELSE 0 END) AS "Nov",
            SUM(CASE WHEN MONTH(E."DocDate") = 12 THEN E."DocTotal" ELSE 0 END) AS "Dez",

            SUM(E."DocTotal") AS "AcumuladoSAP"

        FROM (

            SELECT
                X."DocEntry",
                X."DocDate",
                X."DocTotal",
                X."OcrCode"

            FROM (

                SELECT
                    E0."DocEntry",
                    E0."DocDate",
                    E0."DocTotal",

                    IFNULL(
                        D1."OcrCode",
                        IFNULL(F1."OcrCode", R1."OcrCode")
                    ) AS "OcrCode",

                    ROW_NUMBER() OVER (
                        PARTITION BY E0."DocEntry"
                        ORDER BY
                            D1."LineNum"
                    ) AS "LinhaControle"

                FROM ODLN E0

                INNER JOIN DLN1 D1
                    ON D1."DocEntry" = E0."DocEntry"

                INNER JOIN INV1 F1
                    ON D1."BaseType" = 13
                    AND D1."BaseEntry" = F1."DocEntry"
                    AND D1."BaseLine" = F1."LineNum"

                LEFT JOIN RDR1 R1
                    ON F1."BaseType" = 17
                    AND F1."BaseEntry" = R1."DocEntry"
                    AND F1."BaseLine" = R1."LineNum"

                LEFT JOIN OUSG UF
                    ON UF."ID" = F1."Usage"

                WHERE
                    E0."CANCELED" = 'N'
                    AND YEAR(E0."DocDate") = YEAR(CURRENT_DATE)

                    AND F1."BaseType" = 17

                    AND IFNULL(
                        D1."OcrCode",
                        IFNULL(F1."OcrCode", R1."OcrCode")
                    ) IN (
                        'GERADOR',
                        'NOBREAK',
                        'LOCACAO',
                        'EXE_ELET',
                        'FOTOV',
                        'REV_DIRE',
                        'SEMINOVO'
                    )

                    AND IFNULL(F1."TaxOnly", 'N') <> 'Y'
                    AND IFNULL(UF."TaxOnly", 'N') <> 'Y'

                    AND (
                        UPPER(IFNULL(UF."Usage", '')) LIKE '%ENTR. FUTURA%'
                        OR UPPER(IFNULL(UF."Usage", '')) LIKE '%ENTREGA FUTURA%'
                    )

            ) X

            WHERE
                X."LinhaControle" = 1

        ) E

        GROUP BY
            E."OcrCode"

    ) R

    GROUP BY
        R."OcrCode"
),
