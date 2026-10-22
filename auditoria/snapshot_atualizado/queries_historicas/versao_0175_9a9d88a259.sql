SELECT
    T0."DocEntry" AS "Num_Interno_NF",
    T0."DocNum" AS "Num_Documento_SAP",
    T0."Serial" AS "Numero_Nota_Fiscal",
    T0."DocDate" AS "Data_Emissao",
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

    LIN."TipoNotaFiscal" AS "Tipo_Nota_Fiscal",

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

    T0."NfeValue" AS "Valor_NFe_ML",

    CASE
        WHEN PV."DocNum" IS NULL
        THEN 'Validar: NF sem vinculo com Pedido de Venda'
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
        X."TipoNotaFiscal"

    FROM (
        SELECT
            I1."DocEntry" AS "DocEntryNF",

            CASE
                WHEN I1."BaseType" = 17
                THEN I1."BaseEntry"

                WHEN I1."BaseType" = 15
                     AND D1."BaseType" = 17
                THEN D1."BaseEntry"

                WHEN I1."BaseType" = 15
                     AND D1."BaseType" = 13
                     AND F1."BaseType" = 17
                THEN F1."BaseEntry"

                ELSE NULL
            END AS "DocEntryPV",

            IFNULL(
                I1."OcrCode",
                IFNULL(
                    R1."OcrCode",
                    IFNULL(D1."OcrCode", R1F."OcrCode")
                )
            ) AS "Departamento",

            U."Usage" AS "Utilizacao",

            CASE
                WHEN I1."BaseType" = 15
                THEN 'Nota Fiscal de Entrega'

                WHEN I1."BaseType" = 17
                THEN 'Nota Fiscal de Saida'

                ELSE 'Validar: Origem da NF nao identificada'
            END AS "TipoNotaFiscal",

            ROW_NUMBER() OVER (
                PARTITION BY I1."DocEntry"
                ORDER BY
                    CASE
                        WHEN I1."BaseType" = 15 THEN 0
                        WHEN I1."BaseType" = 17 THEN 1
                        ELSE 2
                    END,
                    I1."LineNum"
            ) AS "LinhaControle"

        FROM INV1 I1

        LEFT JOIN RDR1 R1
            ON I1."BaseType" = 17
            AND I1."BaseEntry" = R1."DocEntry"
            AND I1."BaseLine" = R1."LineNum"

        LEFT JOIN DLN1 D1
            ON I1."BaseType" = 15
            AND I1."BaseEntry" = D1."DocEntry"
            AND I1."BaseLine" = D1."LineNum"

        LEFT JOIN INV1 F1
            ON D1."BaseType" = 13
            AND D1."BaseEntry" = F1."DocEntry"
            AND D1."BaseLine" = F1."LineNum"

        LEFT JOIN RDR1 R1F
            ON F1."BaseType" = 17
            AND F1."BaseEntry" = R1F."DocEntry"
            AND F1."BaseLine" = R1F."LineNum"

        LEFT JOIN OUSG U
            ON I1."Usage" = U."ID"

        WHERE
            IFNULL(
                I1."OcrCode",
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

            AND IFNULL(I1."TaxOnly", 'N') <> 'Y'
            AND IFNULL(U."TaxOnly", 'N') <> 'Y'

            AND UPPER(IFNULL(U."Usage", '')) NOT LIKE '%ENTR. FUTURA%'
            AND UPPER(IFNULL(U."Usage", '')) NOT LIKE '%ENTREGA FUTURA%'
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

ORDER BY
    T0."DocDate" DESC,
    T0."DocNum";
