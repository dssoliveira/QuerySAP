A AS (

    /* =========================================================
       FATURAMENTO REAL POR DEPARTAMENTO
       Valor oficial da NF-e: OINV."NfeValue"
    ========================================================= */

    SELECT
        NF."OcrCode",

        SUM(
            CASE WHEN MONTH(NF."DocDate") = 1
            THEN NF."NfeValue" ELSE 0 END
        ) AS "Jan",

        SUM(
            CASE WHEN MONTH(NF."DocDate") = 2
            THEN NF."NfeValue" ELSE 0 END
        ) AS "Fev",

        SUM(
            CASE WHEN MONTH(NF."DocDate") = 3
            THEN NF."NfeValue" ELSE 0 END
        ) AS "Mar",

        SUM(
            CASE WHEN MONTH(NF."DocDate") = 4
            THEN NF."NfeValue" ELSE 0 END
        ) AS "Abr",

        SUM(
            CASE WHEN MONTH(NF."DocDate") = 5
            THEN NF."NfeValue" ELSE 0 END
        ) AS "Mai",

        SUM(
            CASE WHEN MONTH(NF."DocDate") = 6
            THEN NF."NfeValue" ELSE 0 END
        ) AS "Jun",

        SUM(
            CASE WHEN MONTH(NF."DocDate") = 7
            THEN NF."NfeValue" ELSE 0 END
        ) AS "Jul",

        SUM(
            CASE WHEN MONTH(NF."DocDate") = 8
            THEN NF."NfeValue" ELSE 0 END
        ) AS "Ago",

        SUM(
            CASE WHEN MONTH(NF."DocDate") = 9
            THEN NF."NfeValue" ELSE 0 END
        ) AS "Set",

        SUM(
            CASE WHEN MONTH(NF."DocDate") = 10
            THEN NF."NfeValue" ELSE 0 END
        ) AS "Out",

        SUM(
            CASE WHEN MONTH(NF."DocDate") = 11
            THEN NF."NfeValue" ELSE 0 END
        ) AS "Nov",

        SUM(
            CASE WHEN MONTH(NF."DocDate") = 12
            THEN NF."NfeValue" ELSE 0 END
        ) AS "Dez",

        SUM(NF."NfeValue") AS "AcumuladoSAP"

    FROM (

        SELECT
            X."DocEntry",
            X."DocDate",
            X."NfeValue",
            X."OcrCode"
        FROM (

            SELECT
                T0."DocEntry",
                T0."DocDate",
                T0."NfeValue",

                IFNULL(T1."OcrCode", R1."OcrCode") AS "OcrCode",

                ROW_NUMBER() OVER (
                    PARTITION BY T0."DocEntry"
                    ORDER BY
                        CASE
                            WHEN T1."BaseType" = 17 THEN 0
                            ELSE 1
                        END,
                        T1."LineNum"
                ) AS "LinhaControle"

            FROM OINV T0

            INNER JOIN INV1 T1
                ON T0."DocEntry" = T1."DocEntry"

            LEFT JOIN RDR1 R1
                ON T1."BaseType" = 17
                AND T1."BaseEntry" = R1."DocEntry"
                AND T1."BaseLine" = R1."LineNum"

            LEFT JOIN OUSG U
                ON T1."Usage" = U."ID"

            WHERE
                T0."CANCELED" = 'N'
                AND YEAR(T0."DocDate") = YEAR(CURRENT_DATE)

                AND IFNULL(T1."OcrCode", R1."OcrCode") IN (
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
                AND IFNULL(T1."Usage", -1) <> 37

                AND NOT EXISTS (
                    SELECT
                        1
                    FROM INV1 E
                    WHERE
                        E."DocEntry" = T0."DocEntry"
                        AND E."BaseType" = 15
                )

        ) X

        WHERE
            X."LinhaControle" = 1

    ) NF

    GROUP BY
        NF."OcrCode"
),
