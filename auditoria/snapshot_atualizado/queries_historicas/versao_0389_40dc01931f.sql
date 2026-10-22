WITH MOVIMENTO AS
(
    SELECT
        M."ItemCode",
        I."ItemName",
        M."DocDate",
        M."TransType",
        M."CreatedBy",
        M."DocLineNum",
        M."Warehouse",
        M."InQty",
        M."OutQty",
        M."TransValue",
        M."CalcPrice",
        M."Balance",
        M."TransNum"
    FROM OINM M
    INNER JOIN OITM I
        ON I."ItemCode" = M."ItemCode"
    WHERE M."ItemCode" IN ('MA003838', 'MA004404', 'MA003628')
)

SELECT
    M."ItemCode" AS "Codigo_Item",
    M."ItemName" AS "Descricao_Item",
    M."DocDate" AS "Data_Lancamento",
    M."TransNum" AS "Numero_Transacao_Estoque",

    CASE M."TransType"
        WHEN 20 THEN 'Entrada de mercadoria - compra'
        WHEN 59 THEN 'Entrada de mercadorias'
        WHEN 60 THEN 'Saida de mercadorias'
        WHEN 67 THEN 'Transferencia de estoque'
        WHEN 13 THEN 'Nota fiscal de saida'
        WHEN 15 THEN 'Entrega'
        WHEN 14 THEN 'Devolucao de cliente'
        WHEN 21 THEN 'Devolucao ao fornecedor'
        WHEN -2 THEN 'Saldo inicial'
        ELSE 'Outro movimento'
    END AS "Tipo_Movimento",

    M."CreatedBy" AS "Chave_Interna_Origem",
    M."DocLineNum" + 1 AS "Linha_Documento",
    M."Warehouse" AS "Deposito",
    M."InQty" AS "Quantidade_Entrada",
    M."OutQty" AS "Quantidade_Saida",
    M."CalcPrice" AS "Custo_Unitario",
    M."TransValue" AS "Valor_Movimento",
    M."Balance" AS "Saldo_Apos_Movimento",

    /* Transferência efetivada */
    TR."DocNum" AS "Transferencia_Estoque",
    PTR."DocNum" AS "Pedido_Transferencia",
    PTR."U_MM_OS" AS "Numero_OS",

    CASE
        WHEN TR."DocEntry" IS NOT NULL
        THEN TR."Filler" || ' -> ' || TR."ToWhsCode"
    END AS "Rota_Transferencia",

    /* Pedido de venda identificado pela origem do documento */
    COALESCE(
        PV_SAIDA."DocNum",
        PV_ENTREGA."DocNum",
        PV_NF_DIRETA."DocNum",
        PV_NF_VIA_ENTREGA."DocNum",
        PV_PEDIDO_TRANSF."DocNum"
    ) AS "Pedido_Venda",

    CASE
        WHEN PV_SAIDA."DocEntry" IS NOT NULL
            THEN 'Pedido de venda vinculado a saida de mercadorias'
        WHEN PV_ENTREGA."DocEntry" IS NOT NULL
            THEN 'Pedido de venda vinculado a entrega'
        WHEN PV_NF_DIRETA."DocEntry" IS NOT NULL
            THEN 'Pedido de venda vinculado diretamente a NF'
        WHEN PV_NF_VIA_ENTREGA."DocEntry" IS NOT NULL
            THEN 'Pedido de venda vinculado a NF via entrega'
        WHEN PV_PEDIDO_TRANSF."DocEntry" IS NOT NULL
            THEN 'Pedido de venda vinculado ao pedido de transferencia'
        WHEN PTR."U_MM_OS" IS NOT NULL
            THEN 'OS vinculada ao pedido de transferencia'
        ELSE 'Sem vinculo identificado'
    END AS "Origem_Relacao",

    COALESCE(
        PV_SAIDA."CardCode",
        PV_ENTREGA."CardCode",
        PV_NF_DIRETA."CardCode",
        PV_NF_VIA_ENTREGA."CardCode",
        PV_PEDIDO_TRANSF."CardCode"
    ) AS "Codigo_Cliente_PV",

    COALESCE(
        PV_SAIDA."CardName",
        PV_ENTREGA."CardName",
        PV_NF_DIRETA."CardName",
        PV_NF_VIA_ENTREGA."CardName",
        PV_PEDIDO_TRANSF."CardName"
    ) AS "Cliente_PV",

    CASE
        WHEN M."TransType" IN (20, 59)
        THEN M."TransValue"
        ELSE 0
    END AS "Valor_Compra",

    CASE
        WHEN M."TransType" IN (13, 15, 60)
             AND M."OutQty" > 0
        THEN ABS(M."TransValue")
        ELSE 0
    END AS "Valor_Saida_Efetiva",

    CASE
        WHEN M."TransType" = 67
        THEN 0
        ELSE M."TransValue"
    END AS "Valor_Sem_Transferencia"

FROM MOVIMENTO M

/* Transferência de estoque efetivada */
LEFT JOIN OWTR TR
    ON M."TransType" = 67
   AND M."CreatedBy" = TR."DocEntry"

LEFT JOIN WTR1 TR1
    ON TR1."DocEntry" = TR."DocEntry"
   AND TR1."LineNum" = M."DocLineNum"

/* Pedido de transferência que originou a transferência */
LEFT JOIN OWTQ PTR
    ON TR1."BaseType" = 1250000001
   AND TR1."BaseEntry" = PTR."DocEntry"

LEFT JOIN WTQ1 PTR1
    ON PTR1."DocEntry" = PTR."DocEntry"
   AND PTR1."LineNum" = TR1."BaseLine"

/* Pedido de venda diretamente relacionado ao pedido de transferência */
LEFT JOIN ORDR PV_PEDIDO_TRANSF
    ON PTR1."BaseType" = 17
   AND PTR1."BaseEntry" = PV_PEDIDO_TRANSF."DocEntry"

/* Saída de mercadorias */
LEFT JOIN OIGE SM
    ON M."TransType" = 60
   AND M."CreatedBy" = SM."DocEntry"

LEFT JOIN IGE1 SML
    ON SML."DocEntry" = SM."DocEntry"
   AND SML."LineNum" = M."DocLineNum"

LEFT JOIN ORDR PV_SAIDA
    ON SML."BaseType" = 17
   AND SML."BaseEntry" = PV_SAIDA."DocEntry"

/* Entrega */
LEFT JOIN ODLN ENTREGA
    ON M."TransType" = 15
   AND M."CreatedBy" = ENTREGA."DocEntry"

LEFT JOIN DLN1 ENTREGA_LINHA
    ON ENTREGA_LINHA."DocEntry" = ENTREGA."DocEntry"
   AND ENTREGA_LINHA."LineNum" = M."DocLineNum"

LEFT JOIN ORDR PV_ENTREGA
    ON ENTREGA_LINHA."BaseType" = 17
   AND ENTREGA_LINHA."BaseEntry" = PV_ENTREGA."DocEntry"

/* NF de saída baseada diretamente no pedido */
LEFT JOIN OINV NF
    ON M."TransType" = 13
   AND M."CreatedBy" = NF."DocEntry"

LEFT JOIN INV1 NF_LINHA
    ON NF_LINHA."DocEntry" = NF."DocEntry"
   AND NF_LINHA."LineNum" = M."DocLineNum"

LEFT JOIN ORDR PV_NF_DIRETA
    ON NF_LINHA."BaseType" = 17
   AND NF_LINHA."BaseEntry" = PV_NF_DIRETA."DocEntry"

/* NF de saída baseada em entrega, que por sua vez veio de PV */
LEFT JOIN DLN1 ENTREGA_DA_NF
    ON NF_LINHA."BaseType" = 15
   AND NF_LINHA."BaseEntry" = ENTREGA_DA_NF."DocEntry"
   AND NF_LINHA."BaseLine" = ENTREGA_DA_NF."LineNum"

LEFT JOIN ORDR PV_NF_VIA_ENTREGA
    ON ENTREGA_DA_NF."BaseType" = 17
   AND ENTREGA_DA_NF."BaseEntry" = PV_NF_VIA_ENTREGA."DocEntry"

ORDER BY
    M."ItemCode",
    M."DocDate",
    M."TransNum",
    M."DocLineNum";
