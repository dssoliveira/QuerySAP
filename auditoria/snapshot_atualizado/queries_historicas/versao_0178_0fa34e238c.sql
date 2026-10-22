SELECT
    Q."Num_Interno_NF",
    Q."Num_Documento_SAP",
    Q."Numero_Nota_Fiscal",
    Q."Data_Emissao",
    Q."Cod_Cliente",
    Q."Nome_Cliente",
    Q."Filial",
    Q."Tipo_Nota_Fiscal",
    Q."Pedido_Venda",
    Q."Tipo_Pedido",
    Q."Departamento",
    Q."Utilizacao",
    Q."Valor_NFe_ML",
    Q."Status_Vinculo_Pedido"

FROM (

    /* =========================================================
       NOTAS FISCAIS DE SAIDA
       Base: OINV / INV1

       Regra:
       - Considera NF de saída normal
       - Exclui entrega futura pela utilização
       - Valor oficial: OINV."NfeValue"
    ========================================================= */

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

        'Nota Fiscal de Saida' AS "Tipo_Nota_Fiscal",

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

        LIN."Departamento",
        LIN."Utilizacao",

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
            X."Utilizacao"

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


    UNION ALL


    /* =========================================================
       NOTAS FISCAIS DE ENTREGA / DOCUMENTOS DE ENTREGA
       Base: ODLN / DLN1

       Regra:
       - Considera entrega gerada a partir da NF de entrega futura
       - Caminho: Pedido de venda -> NF entrega futura -> Entrega
       - Valor utilizado: ODLN."DocTotal"
    ========================================================= */

    SELECT
        E0."DocEntry" AS "Num_Interno_NF",
        E0."DocNum" AS "Num_Documento_SAP",
        NULL AS "Numero_Nota_Fiscal",
        E0."DocDate" AS "Data_Emissao",
        E0."CardCode" AS "Cod_Cliente",
        E0."CardName" AS "Nome_Cliente",

        CASE
            WHEN UPPER(IFNULL(FIL."BPLName", '')) LIKE '%ENGENHARIA%'
            THEN 'Sistel Engenharia'

            WHEN UPPER(IFNULL(FIL."BPLName", '')) LIKE '%COMERCIO%'
              OR UPPER(IFNULL(FIL."BPLName", '')) LIKE '%COMÉRCIO%'
            THEN 'Sistel Comercio'

            ELSE IFNULL(FIL."BPLName", 'Nao Definido')
        END AS "Filial",

        'Nota Fiscal de Entrega' AS "Tipo_Nota_Fiscal",

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

        LIN."Departamento",
        LIN."Utilizacao",

        E0."DocTotal" AS "Valor_NFe_ML",

        CASE
            WHEN PV."DocNum" IS NULL
            THEN 'Validar: Entrega sem vinculo com Pedido de Venda'
            ELSE 'OK: Entrega vinculada ao Pedido de Venda'
        END AS "Status_Vinculo_Pedido"

    FROM ODLN E0

    LEFT JOIN OBPL FIL
        ON FIL."BPLId" = E0."BPLId"

    INNER JOIN (
        SELECT
            X."DocEntryEntrega",
            X."DocEntryPV",
            X."Departamento",
            X."Utilizacao"

        FROM (
            SELECT
                D1."DocEntry" AS "DocEntryEntrega",

                CASE
                    WHEN F1."BaseType" = 17
                    THEN F1."BaseEntry"
                    ELSE NULL
                END AS "DocEntryPV",

                IFNULL(
                    D1."OcrCode",
                    IFNULL(F1."OcrCode", R1."OcrCode")
                ) AS "Departamento",

                U."Usage" AS "Utilizacao",

                ROW_NUMBER() OVER (
                    PARTITION BY D1."DocEntry"
                    ORDER BY
                        D1."LineNum"
                ) AS "LinhaControle"

            FROM DLN1 D1

            INNER JOIN INV1 F1
                ON D1."BaseType" = 13
                AND D1."BaseEntry" = F1."DocEntry"
                AND D1."BaseLine" = F1."LineNum"

            LEFT JOIN RDR1 R1
                ON F1."BaseType" = 17
                AND F1."BaseEntry" = R1."DocEntry"
                AND F1."BaseLine" = R1."LineNum"

            LEFT JOIN OUSG U
                ON U."ID" = D1."Usage"

            WHERE
                F1."BaseType" = 17

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

        ) X

        WHERE
            X."LinhaControle" = 1
    ) LIN
        ON LIN."DocEntryEntrega" = E0."DocEntry"

    LEFT JOIN ORDR PV
        ON PV."DocEntry" = LIN."DocEntryPV"

    WHERE
        E0."DocDate" BETWEEN '[%0]' AND '[%1]'
        AND E0."CANCELED" = 'N'

) Q

ORDER BY
    Q."Data_Emissao" DESC,
    Q."Num_Documento_SAP";
