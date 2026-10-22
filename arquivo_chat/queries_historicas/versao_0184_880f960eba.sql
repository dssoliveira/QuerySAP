NF_BASE AS (

    /* =========================================================
       BASE OFICIAL DE FATURAMENTO PARA DRE

       Conceito:
       - Mantem a DRE no formato original
       - NF normal: considera OINV."NfeValue"
       - NF de entrega futura com entrega vinculada:
         considera ODLN."DocTotal" e ODLN."DocDate"
       - NF de entrega futura sem entrega vinculada:
         nao consolida
       - Uma linha por NF para evitar duplicidade
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

            IFNULL(T1."OcrCode", R1."OcrCode") AS "OcrCode",

            U."Usage" AS "Utilizacao",

            ENT."Num_Documento_Entrega",

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

        LEFT JOIN (
            SELECT
                Z."DocEntryNFOrigem",
                Z."Num_Documento_Entrega",
                Z."Data_Entrega",
                Z."Valor_Entrega"

            FROM (
                SELECT
                    D1."BaseEntry" AS "DocEntryNFOrigem",
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
                    E0."CANCELED" = 'N'
                    AND D1."BaseType" = 13
            ) Z

            WHERE
                Z."LinhaControle" = 1
        ) ENT
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
