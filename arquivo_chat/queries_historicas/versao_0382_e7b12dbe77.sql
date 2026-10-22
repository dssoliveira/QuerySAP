SELECT
    T0."DocEntry" AS "Num_Interno_NF",
    T0."DocNum" AS "Num_Documento_SAP",
    T0."Serial" AS "Numero_Nota_Fiscal",
    T0."DocDate" AS "Data_Emissao",

    PV."DocNum" AS "Pedido_Venda",

    TO_VARCHAR(I1."CFOPCode") AS "CFOP",
    I1."TaxCode" AS "Codigo_Imposto",

    IFNULL(I1."OcrCode", R1."OcrCode") AS "Departamento",
    U."Usage" AS "Utilizacao",

    T0."NfeValue" AS "Valor_NFe_ML",

    CASE
        WHEN TO_VARCHAR(I1."CFOPCode") IN ('5922', '6922')
        THEN 'Sair do relatorio: NF de venda futura'

        ELSE 'Compor relatorio: NF de saida'
    END AS "Auditoria_Relatorio"

FROM OINV T0

INNER JOIN INV1 I1
    ON I1."DocEntry" = T0."DocEntry"

LEFT JOIN RDR1 R1
    ON I1."BaseType" = 17
    AND I1."BaseEntry" = R1."DocEntry"
    AND I1."BaseLine" = R1."LineNum"

LEFT JOIN ORDR PV
    ON PV."DocEntry" = I1."BaseEntry"
    AND I1."BaseType" = 17

LEFT JOIN OUSG U
    ON U."ID" = I1."Usage"

WHERE
    PV."DocNum" = 1569
    AND T0."CANCELED" = 'N'

ORDER BY
    T0."DocDate",
    T0."DocNum";
