WITH VALOR_SAIDA AS
(
    SELECT
        IM_SAIDA."CreatedBy" AS "DocEntry_Saida",
        IM_SAIDA."DocLineNum" AS "Linha_Saida",
        SUM(IM_SAIDA."OutQty") AS "Quantidade_Baixada",
        SUM(ABS(IM_SAIDA."TransValue")) AS "Custo_Total_Saida"
    FROM OINM IM_SAIDA
    WHERE IM_SAIDA."TransType" = 60
    GROUP BY
        IM_SAIDA."CreatedBy",
        IM_SAIDA."DocLineNum"
),

SAIDAS AS
(
    SELECT
        H."DocEntry" AS "DocEntry_Saida",
        H."DocNum" AS "Numero_Saida",
        H."DocDate" AS "Data_Saida",
        H."Comments" AS "Observacoes_Saida",
        H."UserSign" AS "Usuario_Saida",

        L."LineNum" AS "Linha_Saida",
        L."ItemCode",
        L."Dscription" AS "Descricao_Item",
        L."WhsCode" AS "Deposito_Saida",
        L."Quantity" AS "Quantidade_Saida",

        V."Custo_Total_Saida",

        COALESCE(
            NULLIF(TRIM(TO_NVARCHAR(H."U_LOC1_CallID")), ''),
            NULLIF(TRIM(TO_NVARCHAR(H."U_MM_OS")), '')
        ) AS "Chave_OS_Saida"

    FROM OIGE H
    INNER JOIN IGE1 L
        ON L."DocEntry" = H."DocEntry"

    LEFT JOIN VALOR_SAIDA V
        ON V."DocEntry_Saida" = H."DocEntry"
       AND V."Linha_Saida" = L."LineNum"

    WHERE H."CANCELED" = 'N'
      AND L."ItemCode" IN (
          'MA003838',
          'MA004404',
          'MA003628'
      )
),

TRANSFERENCIAS AS
(
    SELECT
        IM_TRANSFERENCIA."ItemCode",
        IM_TRANSFERENCIA."Warehouse" AS "Deposito_Destino",
        IM_TRANSFERENCIA."DocDate" AS "Data_Transferencia",
        IM_TRANSFERENCIA."InQty" AS "Quantidade_Transferida",

        TR."DocEntry" AS "DocEntry_Transferencia",
        TR."DocNum" AS "Transferencia_Estoque",
        TR."Filler" AS "Deposito_Origem_Transferencia",
        TR."ToWhsCode" AS "Deposito_Destino_Transferencia",

        PTR."DocNum" AS "Pedido_Transferencia",

        COALESCE(
            NULLIF(TRIM(TO_NVARCHAR(PTR."U_LOC1_CallID")), ''),
            NULLIF(TRIM(TO_NVARCHAR(PTR."U_MM_OS")), '')
        ) AS "Chave_OS_Transferencia"

    FROM OINM IM_TRANSFERENCIA
    INNER JOIN OWTR TR
        ON IM_TRANSFERENCIA."CreatedBy" = TR."DocEntry"
       AND IM_TRANSFERENCIA."TransType" = 67

    LEFT JOIN WTR1 TRL
        ON TRL."DocEntry" = TR."DocEntry"
       AND TRL."LineNum" = IM_TRANSFERENCIA."DocLineNum"

    LEFT JOIN OWTQ PTR
        ON TRL."BaseType" = 1250000001
       AND TRL."BaseEntry" = PTR."DocEntry"

    WHERE IM_TRANSFERENCIA."TransType" = 67
      AND IM_TRANSFERENCIA."InQty" > 0
      AND IM_TRANSFERENCIA."ItemCode" IN (
          'MA003838',
          'MA004404',
          'MA003628'
      )
),

PV_BASE AS
(
    SELECT
        PV."DocNum" AS "Pedido_Venda",
        PV."CardCode" AS "Codigo_Cliente",
        PV."CardName" AS "Nome_Cliente",
        PV."U_MM_Tipo" AS "Tipo_Pedido_Venda",

        COALESCE(
            NULLIF(TRIM(TO_NVARCHAR(PV."U_LOC1_CallID")), ''),
            NULLIF(TRIM(TO_NVARCHAR(PV."U_MM_OS")), '')
        ) AS "Chave_OS",

        COUNT(*) OVER
        (
            PARTITION BY COALESCE(
                NULLIF(TRIM(TO_NVARCHAR(PV."U_LOC1_CallID")), ''),
                NULLIF(TRIM(TO_NVARCHAR(PV."U_MM_OS")), '')
            )
        ) AS "Qtd_Pedidos_Mesma_OS",

        ROW_NUMBER() OVER
        (
            PARTITION BY COALESCE(
                NULLIF(TRIM(TO_NVARCHAR(PV."U_LOC1_CallID")), ''),
                NULLIF(TRIM(TO_NVARCHAR(PV."U_MM_OS")), '')
            )
            ORDER BY
                PV."CreateDate" DESC,
                PV."DocEntry" DESC
        ) AS "Ordem_PV"

    FROM ORDR PV
    WHERE PV."CANCELED" = 'N'
      AND COALESCE(
          NULLIF(TRIM(TO_NVARCHAR(PV."U_LOC1_CallID")), ''),
          NULLIF(TRIM(TO_NVARCHAR(PV."U_MM_OS")), '')
      ) IS NOT NULL
),

PV_POR_OS AS
(
    SELECT
        "Chave_OS",
        "Pedido_Venda",
        "Codigo_Cliente",
        "Nome_Cliente",
        "Tipo_Pedido_Venda",
        "Qtd_Pedidos_Mesma_OS"
    FROM PV_BASE
    WHERE "Ordem_PV" = 1
),

TRANSFERENCIA_CANDIDATA AS
(
    SELECT
        S.*,

        T."Data_Transferencia",
        T."Quantidade_Transferida",
        T."Transferencia_Estoque",
        T."Pedido_Transferencia",
        T."Deposito_Origem_Transferencia",
        T."Deposito_Destino_Transferencia",
        T."Chave_OS_Transferencia",

        DAYS_BETWEEN(
            T."Data_Transferencia",
            S."Data_Saida"
        ) AS "Dias_Entre_Transferencia_e_Saida",

        ROW_NUMBER() OVER
        (
            PARTITION BY
                S."DocEntry_Saida",
                S."Linha_Saida"
            ORDER BY
                T."Data_Transferencia" DESC,
                T."DocEntry_Transferencia" DESC
        ) AS "Ordem_Transferencia"

    FROM SAIDAS S
    LEFT JOIN TRANSFERENCIAS T
        ON T."ItemCode" = S."ItemCode"
       AND T."Deposito_Destino" = S."Deposito_Saida"
       AND T."Data_Transferencia" <= S."Data_Saida"
)

SELECT
    C."Data_Saida",
    C."Numero_Saida" AS "Numero_Saida_Mercadorias",
    C."Linha_Saida",

    C."ItemCode" AS "Codigo_Item",
    C."Descricao_Item",
    C."Deposito_Saida",

    C."Quantidade_Saida",

    CASE
        WHEN IFNULL(C."Quantidade_Saida", 0) = 0 THEN 0
        ELSE C."Custo_Total_Saida" / C."Quantidade_Saida"
    END AS "Custo_Unitario_Real",

    C."Custo_Total_Saida",

    C."Data_Transferencia",
    C."Transferencia_Estoque",
    C."Pedido_Transferencia",
    C."Deposito_Origem_Transferencia",
    C."Deposito_Destino_Transferencia",
    C."Quantidade_Transferida",

    COALESCE(
        C."Chave_OS_Saida",
        C."Chave_OS_Transferencia"
    ) AS "Numero_OS",

    PV."Pedido_Venda" AS "Pedido_Venda_Gerado_OS",
    PV."Tipo_Pedido_Venda",
    PV."Codigo_Cliente",
    PV."Nome_Cliente",
    PV."Qtd_Pedidos_Mesma_OS",

    C."Dias_Entre_Transferencia_e_Saida",

    CASE
        WHEN C."Transferencia_Estoque" IS NULL
        THEN 'Sem evidencia de transferencia anterior'

        WHEN C."Data_Transferencia" = C."Data_Saida"
         AND C."Quantidade_Transferida" >= C."Quantidade_Saida"
        THEN 'Indireto - transferencia para o mesmo deposito no mesmo dia'

        WHEN C."Dias_Entre_Transferencia_e_Saida" BETWEEN 1 AND 7
        THEN 'Indireto - ultima transferencia para o deposito nos ultimos 7 dias'

        ELSE 'Indireto - transferencia anterior; validar manualmente'
    END AS "Status_Rastreio",

    CASE
        WHEN PV."Pedido_Venda" IS NOT NULL
         AND TO_NVARCHAR(PV."Tipo_Pedido_Venda") = '4'
        THEN 'PV gerado por OS identificado'

        WHEN PV."Pedido_Venda" IS NOT NULL
        THEN 'PV vinculado a OS - validar tipo do pedido'

        WHEN COALESCE(
            C."Chave_OS_Saida",
            C."Chave_OS_Transferencia"
        ) IS NOT NULL
        THEN 'OS identificada, sem PV localizado'

        ELSE 'Sem OS/PV identificado'
    END AS "Status_Vinculo_PV_OS",

    C."Observacoes_Saida",
    U."U_NAME" AS "Criado_Por"

FROM TRANSFERENCIA_CANDIDATA C

LEFT JOIN PV_POR_OS PV
    ON PV."Chave_OS" = COALESCE(
        C."Chave_OS_Saida",
        C."Chave_OS_Transferencia"
    )

LEFT JOIN OUSR U
    ON U."USERID" = C."Usuario_Saida"

WHERE C."Ordem_Transferencia" = 1
  AND C."Data_Saida" BETWEEN '[%0]' AND '[%1]'

ORDER BY
    C."Data_Saida",
    C."Numero_Saida",
    C."Linha_Saida";
