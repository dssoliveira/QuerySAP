SELECT
    TO_VARCHAR(I1."CFOPCode") AS "CFOP",

    I1."TaxCode" AS "Codigo_Imposto",

    IFNULL(I1."OcrCode", R1."OcrCode") AS "Departamento",

    U."Usage" AS "Utilizacao",

    COUNT(DISTINCT T0."DocEntry") AS "Qtd_NFs",

    COUNT(*) AS "Qtd_Linhas",

    SUM(I1."LineTotal") AS "Valor_Linhas",

    SUM(
        CASE
            WHEN RNF."LinhaControle" = 1
            THEN T0."NfeValue"
            ELSE 0
        END
    ) AS "Valor_NFe_ML",

    MIN(T0."DocDate") AS "Primeira_Data_Emissao",

    MAX(T0."DocDate") AS "Ultima_Data_Emissao"

FROM OINV T0

INNER JOIN INV1 I1
    ON I1."DocEntry" = T0."DocEntry"

LEFT JOIN RDR1 R1
    ON I1."BaseType" = 17
    AND I1."BaseEntry" = R1."DocEntry"
    AND I1."BaseLine" = R1."LineNum"

LEFT JOIN OUSG U
    ON U."ID" = I1."Usage"

INNER JOIN (
    SELECT
        I1_RNF."DocEntry",
        I1_RNF."LineNum",

        ROW_NUMBER() OVER (
            PARTITION BY I1_RNF."DocEntry"
            ORDER BY I1_RNF."LineNum"
        ) AS "LinhaControle"

    FROM INV1 I1_RNF
) RNF
    ON RNF."DocEntry" = I1."DocEntry"
    AND RNF."LineNum" = I1."LineNum"

WHERE
    T0."DocDate" BETWEEN '[%0]' AND '[%1]'

    AND T0."CANCELED" = 'N'

    AND IFNULL(I1."TaxOnly", 'N') <> 'Y'
    AND IFNULL(U."TaxOnly", 'N') <> 'Y'

GROUP BY
    TO_VARCHAR(I1."CFOPCode"),
    I1."TaxCode",
    IFNULL(I1."OcrCode", R1."OcrCode"),
    U."Usage"

ORDER BY
    TO_VARCHAR(I1."CFOPCode"),
    I1."TaxCode",
    IFNULL(I1."OcrCode", R1."OcrCode"),
    U."Usage";
