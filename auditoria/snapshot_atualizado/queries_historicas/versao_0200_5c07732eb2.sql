SELECT
    E0."DocEntry" AS "Num_Interno_Entrega",
    E0."DocNum" AS "Num_Documento_Entrega",
    E0."DocDate" AS "Data_Entrega",
    E0."CardCode" AS "Cod_Cliente",
    E0."CardName" AS "Nome_Cliente",
    E0."DocTotal" AS "Valor_Entrega",

    D1."LineNum" AS "Linha_Entrega",
    D1."BaseType" AS "BaseType_Entrega",
    D1."BaseEntry" AS "DocEntry_NF_Futura",
    D1."BaseLine" AS "Linha_NF_Futura",

    NF0."DocNum" AS "Num_Documento_NF_Futura",
    NF0."Serial" AS "Numero_NF_Futura",
    NF0."DocDate" AS "Data_NF_Futura",

    F1."BaseType" AS "BaseType_NF_Futura",
    F1."BaseEntry" AS "DocEntry_Pedido_Venda",
    F1."BaseLine" AS "Linha_Pedido_Venda",

    PV."DocNum" AS "Pedido_Venda",

    IFNULL(
        D1."OcrCode",
        IFNULL(F1."OcrCode", R1."OcrCode")
    ) AS "Departamento",

    U."Usage" AS "Utilizacao_Entrega",
    UF."Usage" AS "Utilizacao_NF_Futura"

FROM ODLN E0

INNER JOIN DLN1 D1
    ON D1."DocEntry" = E0."DocEntry"

LEFT JOIN OINV NF0
    ON D1."BaseType" = 13
    AND D1."BaseEntry" = NF0."DocEntry"

LEFT JOIN INV1 F1
    ON D1."BaseType" = 13
    AND D1."BaseEntry" = F1."DocEntry"
    AND D1."BaseLine" = F1."LineNum"

LEFT JOIN RDR1 R1
    ON F1."BaseType" = 17
    AND F1."BaseEntry" = R1."DocEntry"
    AND F1."BaseLine" = R1."LineNum"

LEFT JOIN ORDR PV
    ON PV."DocEntry" = R1."DocEntry"

LEFT JOIN OUSG U
    ON U."ID" = D1."Usage"

LEFT JOIN OUSG UF
    ON UF."ID" = F1."Usage"

WHERE
    E0."DocDate" BETWEEN '[%0]' AND '[%1]'
    AND E0."CANCELED" = 'N'

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

ORDER BY
    E0."DocDate" DESC,
    E0."DocNum",
    D1."LineNum";
