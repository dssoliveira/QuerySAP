SELECT
    T0."DocEntry" AS "Num_Interno_NF",
    T0."DocNum" AS "Num_Documento_SAP",
    T0."Serial" AS "Numero_Nota_Fiscal",

    T0."DocDate" AS "Data_Emissao",

    CASE
        WHEN ENT."Data_Entrega" IS NOT NULL
        THEN ENT."Data_Entrega"
        ELSE T0."DocDate"
    END AS "Data_Referencia_Faturamento",

    T0."CardCode" AS "Cod_Cliente",
    T0."CardName" AS "Nome_Cliente",

    CASE
        WHEN UPPER(IFNULL(FIL."BPLName", '')) LIKE '%ENGENHARIA%'
        THEN 'Sistel Engenharia'

        WHEN UPPER(IFNULL(FIL."BPLName", '')) LIKE '%COMERCIO%'
          OR UPPER(IFNULL(FIL."BPLName", '')) LIKE '%COMÉRCIO%'
        THEN 'Sistel Comercio'

        ELSE IFNULL(FIL."BPLName", 'Nao Definido')
    END AS "Filial",

    CASE
        WHEN ENT."Num_Documento_Entrega" IS NOT NULL
        THEN 'Nota Fiscal de Entrega'

        WHEN LIN."FlagEntregaCFOP" = 1
        THEN 'Nota Fiscal de Entrega'

        WHEN LIN."FlagVendaFutura" = 1
        THEN 'Nota Fiscal de Venda Futura'

        ELSE 'Nota Fiscal de Saida'
    END AS "Tipo_Nota_Fiscal",

    LIN."CFOP" AS "CFOP",

    PV."DocNum" AS "Pedido_Venda",

    CASE
        WHEN PV."U_MM_Tipo" = '0' THEN 'Nao Definido'
        WHEN PV."U_MM_Tipo" = '2' THEN 'Aditivo'
        WHEN PV."U_MM_Tipo" = '3' THEN 'Pre-Contrato'
        WHEN PV."U_MM_Tipo" = '4' THEN 'Gerado por OS (Pre-Consumo)'
        WHEN PV."U_MM_Tipo" = '5' THEN 'Venda (Avulsa)'
        WHEN PV."U_MM_Tipo" = '6' THEN 'Faturamento LOC1'
        WHEN PV."U_MM_Tipo" = '9' THEN 'Precor'
        WHEN PV."U_MM_Tipo" = '10' THEN 'Integrado por Iclass'
        WHEN PV."U_MM_Tipo" = '7' THEN 'Ajuste interno'
        WHEN PV."U_MM_Tipo" = '8' THEN 'Duplicado'
        WHEN PV."U_MM_Tipo" = '11' THEN 'Cancelado'
        WHEN PV."U_MM_Tipo" IS NULL THEN 'Sem Pedido de Venda'
        ELSE 'Nao Definido'
    END AS "Tipo_Pedido",

    LIN."Departamento" AS "Departamento",

    LIN."Utilizacao" AS "Utilizacao",

    CASE
        WHEN ENT."Valor_Entrega" IS NOT NULL
        THEN ENT."Valor_Entrega"
        ELSE T0."NfeValue"
    END AS "Valor_NFe_ML",

    ENT."Num_Interno_Entrega" AS "Num_Interno_Entrega",
    ENT."Num_Documento_Entrega" AS "Num_Documento_Entrega",
    ENT."Data_Entrega" AS "Data_Entrega",

    CASE
        WHEN PV."DocNum" IS NULL
        THEN 'Validar: NF sem vinculo com Pedido de Venda'

        WHEN ENT."Num_Documento_Entrega" IS NOT NULL
        THEN 'OK: NF de entrega vinculada'

        ELSE 'OK: NF vinculada ao Pedido de Venda'
    END AS "Status_Vinculo_Pedido"

FROM OINV T0

LEFT JOIN OBPL FIL
    ON FIL."BPLId" = T0."BPLId"

INNER JOIN (
    SELECT
        X."DocEntryNF",
        X."DocEntryPV",
        X."Departamento",
        X."Utilizacao",
        X."CFOP",
        X."FlagVendaFutura",
        X."FlagEntregaCFOP"

    FROM (
        SELECT
            I1."DocEntry" AS "DocEntryNF",

            CASE
                WHEN I1."BaseType" = 17
                THEN I1."BaseEntry"
                ELSE NULL
            END AS "DocEntryPV",

            IFNULL(I1."OcrCode", R1."OcrCode") AS "Departamento",

            U."Usage" AS "Utilizacao",

            TO_VARCHAR(I1."CFOPCode") AS "CFOP",

            MAX(
                CASE
                    WHEN TO_VARCHAR(I1."CFOPCode") IN ('5922', '6922')
                    THEN 1
                    ELSE 0
                END
            ) OVER (PARTITION BY I1."DocEntry") AS "FlagVendaFutura",

            MAX(
                CASE
                    WHEN TO_VARCHAR(I1."CFOPCode") IN ('5908', '6908')
                    THEN 1
                    ELSE 0
                END
            ) OVER (PARTITION BY I1."DocEntry") AS "FlagEntregaCFOP",

            ROW_NUMBER() OVER (
                PARTITION BY I1."DocEntry"
                ORDER BY
                    I1."LineNum"
            ) AS "LinhaControle"

        FROM INV1 I1

        LEFT JOIN RDR1 R1
            ON I1."BaseType" = 17
            AND I1."BaseEntry" = R1."DocEntry"
            AND I1."BaseLine" = R1."LineNum"

        LEFT JOIN OUSG U
            ON U."ID" = I1."Usage"

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
    ) X

    WHERE
        X."LinhaControle" = 1
) LIN
    ON LIN."DocEntryNF" = T0."DocEntry"

LEFT JOIN ORDR PV
    ON PV."DocEntry" = LIN."DocEntryPV"

LEFT JOIN (
    SELECT
        X."DocEntryNFOrigem",
        X."Num_Interno_Entrega",
        X."Num_Documento_Entrega",
        X."Data_Entrega",
        X."Valor_Entrega"

    FROM (
        SELECT
            D1."BaseEntry" AS "DocEntryNFOrigem",
            E0."DocEntry" AS "Num_Interno_Entrega",
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
            D1."BaseType" = 13
            AND E0."CANCELED" = 'N'
    ) X

    WHERE
        X."LinhaControle" = 1
) ENT
    ON ENT."DocEntryNFOrigem" = T0."DocEntry"

WHERE
    CASE
        WHEN ENT."Data_Entrega" IS NOT NULL
        THEN ENT."Data_Entrega"
        ELSE T0."DocDate"
    END BETWEEN '[%0]' AND '[%1]'

    AND T0."CANCELED" = 'N'

    AND NOT (
        LIN."FlagVendaFutura" = 1
        AND ENT."Num_Documento_Entrega" IS NULL
    )

ORDER BY
    "Data_Referencia_Faturamento" DESC,
    T0."DocNum";
