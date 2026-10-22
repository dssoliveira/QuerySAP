SELECT
    T0."DocEntry" AS "Num_Interno_NF",

    T0."DocNum" AS "Num_Documento_SAP",

    T0."Serial" AS "Numero_Nota_Fiscal",

    T0."DocDate" AS "Data_Emissao",

    T0."CardCode" AS "Cod_Cliente",

    T0."CardName" AS "Nome_Cliente",

    PV."DocNum" AS "Pedido_Venda",

    CASE
        WHEN PV."DocNum" IS NULL
        THEN 'Validar: NF sem vinculo com Pedido de Venda'
        ELSE 'OK: NF vinculada ao Pedido de Venda'
    END AS "Status_Vinculo_Pedido",

    LIN."Departamento" AS "Departamento",

    T0."DocTotal" AS "Valor_NFe_ML"

FROM OINV T0

INNER JOIN (
    SELECT
        X."DocEntryNF",
        X."DocEntryPV",
        X."Departamento"
    FROM (
        SELECT
            I1."DocEntry" AS "DocEntryNF",

            CASE
                WHEN I1."BaseType" = 17 THEN I1."BaseEntry"
                ELSE NULL
            END AS "DocEntryPV",

            IFNULL(I1."OcrCode", R1."OcrCode") AS "Departamento",

            ROW_NUMBER() OVER (
                PARTITION BY I1."DocEntry"
                ORDER BY
                    CASE
                        WHEN I1."BaseType" = 17 THEN 0
                        ELSE 1
                    END,
                    I1."LineNum"
            ) AS "LinhaControle"

        FROM INV1 I1

        LEFT JOIN RDR1 R1
            ON I1."BaseType" = 17
            AND I1."BaseEntry" = R1."DocEntry"
            AND I1."BaseLine" = R1."LineNum"

        LEFT JOIN OUSG U
            ON I1."Usage" = U."ID"

        WHERE
            IFNULL(I1."OcrCode", R1."OcrCode") IN (
                'GERADOR',
                'NOBREAK',
                'LOCACAO',
                'EXE_ELET',
                'FOTOV',
                'REV_DIRE',
                'SEMINOVO'
            )

            AND IFNULL(I1."TaxOnly", 'N') <> 'Y'
            AND IFNULL(U."TaxOnly", 'N') <> 'Y'
            AND IFNULL(I1."Usage", -1) <> 37
    ) X

    WHERE
        X."LinhaControle" = 1
) LIN
    ON LIN."DocEntryNF" = T0."DocEntry"

LEFT JOIN ORDR PV
    ON PV."DocEntry" = LIN."DocEntryPV"

WHERE
    T0."DocDate" BETWEEN '[%0]' AND '[%1]'

    AND T0."CANCELED" = 'N'

    AND NOT EXISTS (
        SELECT
            1
        FROM INV1 E
        WHERE
            E."DocEntry" = T0."DocEntry"
            AND E."BaseType" = 15
    )

ORDER BY
    T0."DocDate" DESC,
    T0."DocNum";
