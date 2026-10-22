NF_BASE AS (

    /* =========================================================
       BASE FISCAL OFICIAL DE FATURAMENTO

       Regra:
       - Mantem a estrutura original da DRE
       - Mantem uma linha por NF
       - NF normal: usa OINV."NfeValue"
       - NF futura com entrega vinculada: usa ODLN."DocTotal"
       - NF futura sem entrega vinculada: nao consolida
       - Espelha o campo "Valor_NFe_ML" do relatorio de faturamento
    ========================================================= */

    SELECT
        X."DocEntry",
        X."DocDate",
        X."NfeValue",
        X."OcrCode"

    FROM (

        SELECT
            T0."DocEntry",
            T0."DocDate",

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

            U."Usage" AS "Utilizacao",

            ENT."Num_Documento_Entrega",

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

        LEFT JOIN (
            SELECT
                Z."DocEntryNFOrigem",
                Z."Num_Documento_Entrega",
                Z."Valor_Entrega"

            FROM (
                SELECT
                    D1E."BaseEntry" AS "DocEntryNFOrigem",
                    E0."DocNum" AS "Num_Documento_Entrega",
                    E0."DocTotal" AS "Valor_Entrega",

                    ROW_NUMBER() OVER (
                        PARTITION BY D1E."BaseEntry"
                        ORDER BY
                            E0."DocDate" DESC,
                            E0."DocNum" DESC
                    ) AS "LinhaControle"

                FROM ODLN E0

                INNER JOIN DLN1 D1E
                    ON D1E."DocEntry" = E0."DocEntry"

                WHERE
                    D1E."BaseType" = 13
                    AND E0."CANCELED" = 'N'
            ) Z

            WHERE
                Z."LinhaControle" = 1
        ) ENT
            ON ENT."DocEntryNFOrigem" = T0."DocEntry"

        WHERE
            T0."CANCELED" = 'N'
            AND YEAR(T0."DocDate") = YEAR(CURRENT_DATE)

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

            AND (
                ENT."Num_Documento_Entrega" IS NOT NULL

                OR (
                    UPPER(IFNULL(U."Usage", '')) NOT LIKE '%ENTR. FUTURA%'
                    AND UPPER(IFNULL(U."Usage", '')) NOT LIKE '%ENTREGA FUTURA%'
                )
            )

    ) X

    WHERE
        X."LinhaControle" = 1
),
