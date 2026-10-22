NF_BASE AS (

    /* =========================================================
       BASE OFICIAL DE FATURAMENTO PARA DRE

       Regra:
       - NF normal de saida: OINV."NfeValue"
       - NF de entrega futura: nao consolida
       - Documento de entrega vinculado a NF futura: ODLN."DocTotal"
       - Uma linha por documento para evitar duplicidade
       - Mantem a estrutura original da DRE
    ========================================================= */

    SELECT
        B."DocEntry",
        B."DocDate",
        B."NfeValue",
        B."OcrCode"

    FROM (

        /* =====================================================
           1) NOTAS FISCAIS NORMAIS DE SAIDA
        ===================================================== */

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

                U."Usage" AS "Utilizacao",

                ROW_NUMBER() OVER (
                    PARTITION BY T0."DocEntry"
                    ORDER BY
                        T1."LineNum"
                ) AS "LinhaControle"

            FROM OINV T0

            INNER JOIN INV1 T1
                ON T1."DocEntry" = T0."DocEntry"

            LEFT JOIN RDR1 R1
                ON T1."BaseType" = 17
                AND T1."BaseEntry" = R1."DocEntry"
                AND T1."BaseLine" = R1."LineNum"

            LEFT JOIN OUSG U
                ON U."ID" = T1."Usage"

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

                AND UPPER(IFNULL(U."Usage", '')) NOT LIKE '%ENTR. FUTURA%'
                AND UPPER(IFNULL(U."Usage", '')) NOT LIKE '%ENTREGA FUTURA%'

        ) X

        WHERE
            X."LinhaControle" = 1


        UNION ALL


        /* =====================================================
           2) DOCUMENTOS DE ENTREGA VINCULADOS A NF FUTURA

           Caminho:
           Pedido de venda -> NF de entrega futura -> Entrega
        ===================================================== */

        SELECT
            Y."DocEntry",
            Y."DocDate",
            Y."NfeValue",
            Y."OcrCode"

        FROM (

            SELECT
                E0."DocEntry",
                E0."DocDate",
                E0."DocTotal" AS "NfeValue",

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

        ) Y

        WHERE
            Y."LinhaControle" = 1

    ) B
),
