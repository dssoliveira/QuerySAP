WITH VALOR_SAIDA AS
(
    SELECT
        M."CreatedBy" AS "DocEntry_Saida",
        M."DocLineNum" AS "Linha_Saida",
        SUM(M."OutQty") AS "Quantidade_Baixada",
        SUM(ABS(M."TransValue")) AS "Custo_Total_Saida"
    FROM OINM M
    WHERE M."TransType" = 60
    GROUP BY
        M."CreatedBy",
        M."DocLineNum"
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

    WHERE L."ItemCode" IN (
        'MA003838',
        'MA004404',
        'MA003628'
    )
),

TRANSFERENCIAS AS
(
    SELECT
        M."ItemCode",
        M."Warehouse" AS "Deposito_Destino",
        M."DocDate" AS "Data_Transferencia",
        M."InQty" AS "Quantidade_Transferida",

        TR."DocEntry" AS "DocEntry_Transferencia",
        TR."DocNum" AS "Transferencia_Estoque",
        TR."Filler" AS "Deposito_Origem_Transferencia",
        TR."ToWhsCode" AS "Deposito_Destino_Transferencia",

        PTR."DocNum" AS "Pedido_Transferencia",

        COALESCE(
            NULLIF(TRIM(TO_NVARCHAR(PTR."U_LOC1_CallID")), ''),
            NULLIF(TRIM(TO_NVARCHAR(PTR."U_MM_OS")), '')
        ) AS "Chave_OS_Transferencia"

    FROM OINM M
    INNER JOIN OWTR TR
        ON M."TransType" = 67
       AND M."CreatedBy" = TR."DocEntry"

    LEFT JOIN WTR1 TRL
        ON TRL."DocEntry" = TR."DocEntry"
       AND TRL."LineNum" = M."DocLineNum"

    LEFT JOIN OWTQ PTR
        ON TRL."BaseType" = 1250000001
       AND TRL."BaseEntry" = PTR."DocEntry"

    WHERE M."TransType" = 67
      AND M."InQty" > 0
      AND M."ItemCode" IN (
          'MA003838',
          'MA004404',
          'MA003628'
      )
),

PEDIDOS_VENDA_OS AS
(
    SELECT
        COALESCE(
            NULLIF(TRIM(TO_NVARCHAR(PV."U_LOC1_CallID")), ''),
            NULLIF(TRIM(TO_NVARCHAR(PV."U_MM_OS")), '')
        ) AS "Chave_OS",

        STRING_AGG(TO_NVARCHAR(PV."DocNum"), ', ') AS "Pedidos_Venda_OS",
        STRING_AGG(IFNULL(TO_NVARCHAR(PV."U_MM_Tipo"), ''), ', ') AS "Tipo_Pedido_Venda",
        STRING_AGG(PV."CardCode", ', ') AS "Codigos_Cliente",
        STRING_AGG(PV."CardName", ', ') AS "Clientes"

    FROM ORDR PV
    WHERE COALESCE(
        NULLIF(TRIM(TO_NVARCHAR(PV."U_LOC1_CallID")), ''),
        NULLIF(TRIM(TO_NVARCHAR(PV."U_MM_OS")), '')
    ) IS NOT NULL
    GROUP BY
        COALESCE(
            NULLIF(TRIM(TO_NVARCHAR(PV."U_LOC1_CallID")), ''),
            NULLIF(TRIM(TO_NVARCHAR(PV."U_MM_OS")), '')
        )
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
        ) AS "Ordem_Candidata"

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

    PV."Pedidos_Venda_OS" AS "Pedido_Venda_Gerado_OS",
    PV."Tipo_Pedido_Venda",
    PV."Codigos_Cliente" AS "Codigo_Cliente",
    PV."Clientes" AS "Nome_Cliente",

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
        WHEN PV."Pedidos_Venda_OS" IS NOT NULL
             AND PV."Tipo_Pedido_Venda" LIKE '%4%'
        THEN 'PV gerado por OS identificado'

        WHEN PV."Pedidos_Venda_OS" IS NOT NULL
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

LEFT JOIN PEDIDOS_VENDA_OS PV
    ON PV."Chave_OS" = COALESCE(
        C."Chave_OS_Saida",
        C."Chave_OS_Transferencia"
    )

LEFT JOIN OUSR U
    ON U."USERID" = C."Usuario_Saida"

WHERE C."Ordem_Candidata" = 1
  AND C."Data_Saida" BETWEEN '[%0]' AND '[%1]'

ORDER BY
    C."Data_Saida",
    C."Numero_Saida",
    C."Linha_Saida";
