WITH CENTRO_CUSTO AS (

    /* =========================================================
       CENTROS DE CUSTO ENVOLVIDOS NO PEDIDO
    ========================================================= */

    SELECT
        CC_BASE."DocEntry",

        STRING_AGG(CC_BASE."OcrCode", ', ') AS "Centro Custo"

    FROM (
        SELECT DISTINCT
            R1."DocEntry",
            R1."OcrCode"

        FROM RDR1 R1

        WHERE
            IFNULL(R1."OcrCode", '') <> ''
    ) CC_BASE

    GROUP BY
        CC_BASE."DocEntry"
),

DETALHES_LOC1 AS (

    /* =========================================================
       DETALHES DO LOC1 CONSOLIDADOS POR PEDIDO

       Atenção:
       - Confirmar se o campo técnico do SAP é RDR1."U_LOC1_Detalhes"
       - Caso o SAP acuse coluna inválida, substituir aqui pelo nome
         técnico correto do campo "Detalhes do LOC1"
    ========================================================= */

    SELECT
        DET_BASE."DocEntry",

        STRING_AGG(DET_BASE."DetalheLOC1", ' | ') AS "Detalhes do LOC1"

    FROM (
        SELECT DISTINCT
            R1."DocEntry",

            CAST(
                R1."U_LOC1_Detalhes"
                AS NVARCHAR(500)
            ) AS "DetalheLOC1"

        FROM RDR1 R1

        WHERE
            IFNULL(
                CAST(R1."U_LOC1_Detalhes" AS NVARCHAR(500)),
                ''
            ) <> ''
    ) DET_BASE

    GROUP BY
        DET_BASE."DocEntry"
),

FATU AS (

    /* =========================================================
       FATURAMENTO POR PEDIDO

       Regra atual:
       - Não tratar por linha
       - Valor oficial faturado: OINV."NfeValue"
       - Uma NF considerada apenas uma vez por pedido
    ========================================================= */

    SELECT
        FAT_BASE."PedidoDocEntry" AS "BaseEntry",

        STRING_AGG(FAT_BASE."NFTexto", ', ') AS "Numero NF",

        MAX(FAT_BASE."Data Lancamento") AS "Data Lancamento",

        SUM(FAT_BASE."Qtd Faturada") AS "Qtd Faturada",

        SUM(FAT_BASE."Valor NFe ML") AS "Total Faturado",

        SUM(FAT_BASE."Imposto") AS "Imposto",

        SUM(FAT_BASE."Imposto Retido") AS "Imposto Retido",

        MAX(FAT_BASE."Comissao NF") AS "Comissao NF"

    FROM (
        SELECT
            NF_UNICA."PedidoDocEntry",
            NF_UNICA."DocEntryNF",

            TO_VARCHAR(NF_UNICA."Numero NF") AS "NFTexto",

            NF_UNICA."Data Lancamento",

            NF_UNICA."Qtd Faturada",

            NF_UNICA."Valor NFe ML",

            NF_UNICA."Imposto",

            NF_UNICA."Imposto Retido",

            NF_UNICA."Comissao NF"

        FROM (
            SELECT
                I1."BaseEntry" AS "PedidoDocEntry",

                NF0."DocEntry" AS "DocEntryNF",

                NF0."Serial" AS "Numero NF",

                NF0."DocDate" AS "Data Lancamento",

                SUM(I1."Quantity") OVER (
                    PARTITION BY
                        NF0."DocEntry",
                        I1."BaseEntry"
                ) AS "Qtd Faturada",

                NF0."NfeValue" AS "Valor NFe ML",

                NF0."VatSum" AS "Imposto",

                NF0."WTSum" AS "Imposto Retido",

                MAX(I1."Commission") OVER (
                    PARTITION BY
                        NF0."DocEntry",
                        I1."BaseEntry"
                ) AS "Comissao NF",

                ROW_NUMBER() OVER (
                    PARTITION BY
                        NF0."DocEntry",
                        I1."BaseEntry"
                    ORDER BY
                        I1."LineNum"
                ) AS "LinhaControle"

            FROM OINV NF0

            INNER JOIN INV1 I1
                ON I1."DocEntry" = NF0."DocEntry"

            LEFT JOIN RDR1 R1
                ON I1."BaseType" = 17
                AND I1."BaseEntry" = R1."DocEntry"
                AND I1."BaseLine" = R1."LineNum"

            LEFT JOIN OUSG U
                ON U."ID" = I1."Usage"

            WHERE
                NF0."CANCELED" = 'N'
                AND NF0."Serial" IS NOT NULL
                AND I1."BaseType" = 17

                AND IFNULL(I1."TaxOnly", 'N') <> 'Y'
                AND IFNULL(U."TaxOnly", 'N') <> 'Y'

                AND IFNULL(
                    I1."OcrCode",
                    R1."OcrCode"
                ) IS NOT NULL
        ) NF_UNICA

        WHERE
            NF_UNICA."LinhaControle" = 1
    ) FAT_BASE

    GROUP BY
        FAT_BASE."PedidoDocEntry"
)

SELECT
    CASE
        WHEN UPPER(IFNULL(T4."BPLName", '')) LIKE '%ENGENHARIA%'
        THEN 'Sistel Engenharia'

        WHEN UPPER(IFNULL(T4."BPLName", '')) LIKE '%COMERCIO%'
          OR UPPER(IFNULL(T4."BPLName", '')) LIKE '%COMÉRCIO%'
        THEN 'Sistel Comercio'

        ELSE 'Nao Definido'
    END AS "Empresa",

    T0."DocNum" AS "Pedido",

    T0."DocDate" AS "Data Pedido",

    CASE
        WHEN T0."U_MM_Tipo" = '0' THEN 'Nao Definido'
        WHEN T0."U_MM_Tipo" = '2' THEN 'Aditivo'
        WHEN T0."U_MM_Tipo" = '3' THEN 'Pre-Contrato'
        WHEN T0."U_MM_Tipo" = '4' THEN 'Gerado por OS (Pre-Consumo)'
        WHEN T0."U_MM_Tipo" = '5' THEN 'Venda (Avulsa)'
        WHEN T0."U_MM_Tipo" = '6' THEN 'Faturamento LOC1'
        WHEN T0."U_MM_Tipo" = '7' THEN 'Ajuste interno'
        WHEN T0."U_MM_Tipo" = '8' THEN 'Duplicado'
        WHEN T0."U_MM_Tipo" = '9' THEN 'Precor'
        WHEN T0."U_MM_Tipo" = '10' THEN 'Integrado por Iclass'
        WHEN T0."U_MM_Tipo" = '11' THEN 'Cancelado'
        ELSE 'Nao Definido'
    END AS "Tipo Pedido",

    T6."ContractID" AS "Numero Contrato",

    T0."CardCode" AS "Cod PN",

    T0."CardName" AS "Nome PN",

    IFNULL(CC."Centro Custo", 'Nao Definido') AS "Centro Custo",

    IFNULL(DET."Detalhes do LOC1", '') AS "Detalhes do LOC1",

    T2."SlpName" AS "Vendedor",

    T0."DocTotal" AS "Valor Total Pedido",

    T0."U_MM_Comissao" AS "Comissao Pedido (UDF)",

    T2."Commission" AS "Comissao Vendedor",

    T3."Numero NF",

    T3."Data Lancamento",

    T3."Qtd Faturada",

    IFNULL(T3."Total Faturado", 0) AS "Total Faturado",

    IFNULL(T3."Imposto", 0) AS "Imposto",

    IFNULL(T3."Imposto Retido", 0) AS "Imposto Retido",

    T3."Comissao NF",

    (
        COALESCE(T0."U_MM_Material", 0) +
        COALESCE(T0."U_MM_MO_DIRETA", 0) +
        COALESCE(T0."U_MM_MO_INDIRETA", 0) +
        COALESCE(T0."U_MM_Alimentacao", 0) +
        COALESCE(T0."U_MM_Hospedagem", 0) +
        COALESCE(T0."U_MM_Equipamento", 0) +
        COALESCE(T0."U_MM_Deslocamento", 0) +
        COALESCE(T0."U_MM_Frete", 0) +
        COALESCE(T0."U_MM_Servicos", 0) +
        COALESCE(T0."U_MM_Pedagio", 0) +
        COALESCE(T0."U_MM_Comissao", 0) +
        COALESCE(T0."U_MM_Despesa_Fixa", 0)
    ) AS "Custo Total",

    T0."U_MM_Material" AS "Material",
    T0."U_MM_MO_DIRETA" AS "MO Direta",
    T0."U_MM_MO_INDIRETA" AS "MO Indireta",
    T0."U_MM_Alimentacao" AS "Alimentacao",
    T0."U_MM_Hospedagem" AS "Hospedagem",
    T0."U_MM_Equipamento" AS "Equipamento",
    T0."U_MM_Deslocamento" AS "Deslocamento",
    T0."U_MM_Frete" AS "Frete",
    T0."U_MM_Servicos" AS "Servicos",
    T0."U_MM_Pedagio" AS "Pedagio",
    T0."U_MM_Despesa_Fixa" AS "Despesa Fixa",

    T0."U_MM_Margem" AS "Margem Pedido",

    NDIV0(
        IFNULL(T3."Total Faturado", 0),
        T0."U_MM_Margem"
    ) * 100 AS "IMC %",

    NDIV0(
        IFNULL(T3."Total Faturado", 0),
        T0."U_MM_Despesa_Fixa"
    ) * 100 AS "Despesa Fixa %",

    (
        IFNULL(T3."Total Faturado", 0)
        - IFNULL(T3."Imposto", 0)
        - IFNULL(T3."Imposto Retido", 0)
        - COALESCE(T0."U_MM_Despesa_Fixa", 0)
    ) AS "Lucro Liquido",

    NDIV0(
        (
            IFNULL(T3."Total Faturado", 0)
            - IFNULL(T3."Imposto", 0)
            - IFNULL(T3."Imposto Retido", 0)
            - COALESCE(T0."U_MM_Despesa_Fixa", 0)
        ) * 100,
        IFNULL(T3."Total Faturado", 0)
    ) AS "Margem % Faturado",

    CASE
        WHEN T3."BaseEntry" IS NULL
        THEN 'NAO FATURADO'

        WHEN IFNULL(T3."Total Faturado", 0) >= T0."DocTotal"
        THEN 'FATURADO'

        ELSE 'PARCIALMENTE FATURADO'
    END AS "Status Faturamento"

FROM ORDR T0

INNER JOIN OSLP T2
    ON T0."SlpCode" = T2."SlpCode"

INNER JOIN OBPL T4
    ON T0."BPLId" = T4."BPLId"

LEFT JOIN CENTRO_CUSTO CC
    ON CC."DocEntry" = T0."DocEntry"

LEFT JOIN DETALHES_LOC1 DET
    ON DET."DocEntry" = T0."DocEntry"

LEFT JOIN "@LOC1_DOC" TL
    ON TL."U_DocEntry" = CAST(T0."DocEntry" AS NVARCHAR)
   AND TL."U_DocTypeNum" = 17

LEFT JOIN OCTR T6
    ON T6."ContractID" = TL."U_ContractID"

LEFT JOIN FATU T3
    ON T3."BaseEntry" = T0."DocEntry"

WHERE
    T0."CANCELED" = 'N'

    AND IFNULL(T0."U_MM_Tipo", '') <> '4'

    AND NOT EXISTS (
        SELECT
            1
        FROM RDR1 EXC
        WHERE
            EXC."DocEntry" = T0."DocEntry"
            AND EXC."ItemCode" IN (
                'SV000045',
                'SV000044'
            )
    )

ORDER BY
    T0."DocDate",
    T0."DocNum";
