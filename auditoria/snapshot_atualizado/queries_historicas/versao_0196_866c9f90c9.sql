A AS (

    /* =========================================================
       FATURAMENTO REAL POR CENTRO DE CUSTO

       Regra:
       - Mantem o realizado original vindo da NF_BASE
       - Acrescenta os documentos de entrega vinculados
         as NFs de entrega futura
       - Nao altera a estrutura final da DRE
    ========================================================= */

    SELECT
        CONS."OcrCode",

        SUM(CONS."Jan") AS "Jan",
        SUM(CONS."Fev") AS "Fev",
        SUM(CONS."Mar") AS "Mar",
        SUM(CONS."Abr") AS "Abr",
        SUM(CONS."Mai") AS "Mai",
        SUM(CONS."Jun") AS "Jun",
        SUM(CONS."Jul") AS "Jul",
        SUM(CONS."Ago") AS "Ago",
        SUM(CONS."Set") AS "Set",
        SUM(CONS."Out") AS "Out",
        SUM(CONS."Nov") AS "Nov",
        SUM(CONS."Dez") AS "Dez",

        SUM(CONS."AcumuladoSAP") AS "AcumuladoSAP"

    FROM (

        /* =====================================================
           1) REALIZADO ORIGINAL DA QUERY
           Base: NF_BASE
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
           2) VALORES DAS NOTAS FISCAIS DE ENTREGA
           Base: ODLN / DLN1

           Caminho:
           Pedido de venda -> NF de entrega futura -> Entrega
        ===================================================== */

        SELECT
            ENT."OcrCode",

            SUM(CASE WHEN MONTH(ENT."DocDate") = 1 THEN ENT."DocTotal" ELSE 0 END) AS "Jan",
            SUM(CASE WHEN MONTH(ENT."DocDate") = 2 THEN ENT."DocTotal" ELSE 0 END) AS "Fev",
            SUM(CASE WHEN MONTH(ENT."DocDate") = 3 THEN ENT."DocTotal" ELSE 0 END) AS "Mar",
            SUM(CASE WHEN MONTH(ENT."DocDate") = 4 THEN ENT."DocTotal" ELSE 0 END) AS "Abr",
            SUM(CASE WHEN MONTH(ENT."DocDate") = 5 THEN ENT."DocTotal" ELSE 0 END) AS "Mai",
            SUM(CASE WHEN MONTH(ENT."DocDate") = 6 THEN ENT."DocTotal" ELSE 0 END) AS "Jun",
            SUM(CASE WHEN MONTH(ENT."DocDate") = 7 THEN ENT."DocTotal" ELSE 0 END) AS "Jul",
            SUM(CASE WHEN MONTH(ENT."DocDate") = 8 THEN ENT."DocTotal" ELSE 0 END) AS "Ago",
            SUM(CASE WHEN MONTH(ENT."DocDate") = 9 THEN ENT."DocTotal" ELSE 0 END) AS "Set",
            SUM(CASE WHEN MONTH(ENT."DocDate") = 10 THEN ENT."DocTotal" ELSE 0 END) AS "Out",
            SUM(CASE WHEN MONTH(ENT."DocDate") = 11 THEN ENT."DocTotal" ELSE 0 END) AS "Nov",
            SUM(CASE WHEN MONTH(ENT."DocDate") = 12 THEN ENT."DocTotal" ELSE 0 END) AS "Dez",

            SUM(ENT."DocTotal") AS "AcumuladoSAP"

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

        ) ENT

        GROUP BY
            ENT."OcrCode"

    ) CONS

    GROUP BY
        CONS."OcrCode"
),
