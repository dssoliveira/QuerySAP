SELECT
    T0."DocEntry" AS "Num_Interno_NF",
    T0."DocNum" AS "Num_Documento_SAP",
    T0."Serial" AS "Numero_Nota_Fiscal",
    T0."DocDate" AS "Data_Emissao",
    T0."CardCode" AS "Cod_Cliente",
    T0."CardName" AS "Nome_Cliente",

    I1."LineNum" AS "Linha_NF",

    I1."BaseType" AS "BaseType_Linha_NF",

    CASE
        WHEN I1."BaseType" = 17 THEN 'Base Pedido de Venda'
        WHEN I1."BaseType" = 15 THEN 'Base Entrega'
        WHEN I1."BaseType" = 13 THEN 'Base Nota Fiscal'
        WHEN I1."BaseType" IS NULL THEN 'Sem Base'
        ELSE 'Outro'
    END AS "Origem_Linha_NF",

    I1."BaseEntry" AS "BaseEntry_Linha_NF",
    I1."BaseLine" AS "BaseLine_Linha_NF",

    D1."DocEntry" AS "DocEntry_Entrega",
    D1."BaseType" AS "BaseType_Entrega",
    D1."BaseEntry" AS "BaseEntry_Origem_Entrega",
    D1."BaseLine" AS "BaseLine_Origem_Entrega",

    PV_DIR."DocNum" AS "Pedido_Direto_NF",
    PV_ENT."DocNum" AS "Pedido_Origem_Entrega",

    IFNULL(
        I1."OcrCode",
        IFNULL(D1."OcrCode", IFNULL(R1_DIR."OcrCode", R1_ENT."OcrCode"))
    ) AS "Departamento",

    I1."Usage" AS "Cod_Utilizacao",
    U."Usage" AS "Utilizacao",

    T0."U_TX_finNFe" AS "Finalidade_NFe",
    T0."U_TX_DesctNfFut" AS "Desconta_NF_Futura",

    T0."NfeValue" AS "Valor_NFe_ML"

FROM OINV T0

INNER JOIN INV1 I1
    ON I1."DocEntry" = T0."DocEntry"

LEFT JOIN OUSG U
    ON U."ID" = I1."Usage"

LEFT JOIN RDR1 R1_DIR
    ON I1."BaseType" = 17
    AND I1."BaseEntry" = R1_DIR."DocEntry"
    AND I1."BaseLine" = R1_DIR."LineNum"

LEFT JOIN ORDR PV_DIR
    ON PV_DIR."DocEntry" = R1_DIR."DocEntry"

LEFT JOIN DLN1 D1
    ON I1."BaseType" = 15
    AND I1."BaseEntry" = D1."DocEntry"
    AND I1."BaseLine" = D1."LineNum"

LEFT JOIN RDR1 R1_ENT
    ON D1."BaseType" = 17
    AND D1."BaseEntry" = R1_ENT."DocEntry"
    AND D1."BaseLine" = R1_ENT."LineNum"

LEFT JOIN ORDR PV_ENT
    ON PV_ENT."DocEntry" = R1_ENT."DocEntry"

WHERE
    T0."DocDate" BETWEEN '[%0]' AND '[%1]'
    AND T0."CANCELED" = 'N'

    AND IFNULL(
        I1."OcrCode",
        IFNULL(D1."OcrCode", IFNULL(R1_DIR."OcrCode", R1_ENT."OcrCode"))
    ) IN (
        'GERADOR',
        'NOBREAK',
        'LOCACAO',
        'EXE_ELET',
        'FOTOV',
        'REV_DIRE',
        'SEMINOVO'
    )

    AND IFNULL(I1."TaxOnly", 'N') <> 'Y'

ORDER BY
    T0."DocDate" DESC,
    T0."DocNum",
    I1."LineNum";
