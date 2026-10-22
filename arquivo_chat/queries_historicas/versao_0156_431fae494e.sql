SELECT
    YEAR(T0."DocDate") AS "Ano",
    MONTH(T0."DocDate") AS "Mes",

    LIN."Departamento" AS "Centro_Custo",

    LIN."Utilizacao" AS "Utilizacao",

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

    COUNT(DISTINCT T0."DocEntry") AS "Quantidade_NFs",

    ROUND(
        SUM(T0."NfeValue"),
        2
    ) AS "Faturamento_NFe_ML",

    SUM(
        CASE
            WHEN PV."DocNum" IS NULL THEN 1
            ELSE 0
        END
    ) AS "Quantidade_NFs_Sem_Pedido"

FROM OINV T0

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

GROUP BY
    YEAR(T0."DocDate"),
    MONTH(T0."DocDate"),
    LIN."Departamento",
    LIN."Utilizacao",

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
    END

ORDER BY
    YEAR(T0."DocDate"),
    MONTH(T0."DocDate"),
    LIN."Departamento",
    LIN."Utilizacao",
    "Tipo_Pedido";
