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
)

SELECT
    H."DocDate" AS "Data_Saida",
    H."DocNum" AS "Numero_Saida_Mercadorias",
    L."LineNum" + 1 AS "Linha_Saida",

    L."ItemCode" AS "Codigo_Item",
    I."ItemName" AS "Descricao_Item",

    L."WhsCode" AS "Deposito_Saida",
    W."WhsName" AS "Nome_Deposito_Saida",

    V."Quantidade_Baixada" AS "Quantidade_Saida",
    CASE
        WHEN IFNULL(V."Quantidade_Baixada", 0) = 0 THEN 0
        ELSE V."Custo_Total_Saida" / V."Quantidade_Baixada"
    END AS "Custo_Unitario_Real",

    V."Custo_Total_Saida" AS "Custo_Total_Saida",

    /* Pedido de venda diretamente vinculado à saída */
    COALESCE(
        PV_DIRETO."DocNum",
        PV_VIA_ENTREGA."DocNum"
    ) AS "Pedido_Venda",

    COALESCE(
        PV_DIRETO."CardCode",
        PV_VIA_ENTREGA."CardCode"
    ) AS "Codigo_Cliente",

    COALESCE(
        PV_DIRETO."CardName",
        PV_VIA_ENTREGA."CardName"
    ) AS "Nome_Cliente",

    /* Transferência e pedido de transferência, quando existirem */
    TR."DocNum" AS "Transferencia_Estoque",

    COALESCE(
        PTR_DIRETO."DocNum",
        PTR_VIA_TRANSFERENCIA."DocNum"
    ) AS "Pedido_Transferencia",

    COALESCE(
        PTR_DIRETO."U_MM_OS",
        PTR_VIA_TRANSFERENCIA."U_MM_OS"
    ) AS "Numero_OS",

    CASE
        WHEN COALESCE(
            PTR_DIRETO."U_MM_OS",
            PTR_VIA_TRANSFERENCIA."U_MM_OS"
        ) IS NOT NULL
        AND COALESCE(
            PV_DIRETO."DocNum",
            PV_VIA_ENTREGA."DocNum"
        ) IS NOT NULL
        THEN 'OS e Pedido de Venda identificados'

        WHEN COALESCE(
            PTR_DIRETO."U_MM_OS",
            PTR_VIA_TRANSFERENCIA."U_MM_OS"
        ) IS NOT NULL
        THEN 'OS identificada pelo Pedido de Transferencia'

        WHEN COALESCE(
            PV_DIRETO."DocNum",
            PV_VIA_ENTREGA."DocNum"
        ) IS NOT NULL
        THEN 'Pedido de Venda identificado'

        ELSE 'Saida sem vinculo de OS/PV'
    END AS "Status_Vinculo",

    CASE
        WHEN PV_DIRETO."DocEntry" IS NOT NULL
        THEN 'Saida baseada diretamente em Pedido de Venda'

        WHEN PV_VIA_ENTREGA."DocEntry" IS NOT NULL
        THEN 'Saida baseada em Entrega vinculada ao Pedido de Venda'

        WHEN PTR_DIRETO."DocEntry" IS NOT NULL
        THEN 'Saida baseada diretamente em Pedido de Transferencia'

        WHEN PTR_VIA_TRANSFERENCIA."DocEntry" IS NOT NULL
        THEN 'Saida baseada em Transferencia vinculada ao Pedido de Transferencia'

        ELSE 'Saida avulsa - verificar observacoes'
    END AS "Origem_Relacao",

    H."Comments" AS "Observacoes_Saida",
    U."U_NAME" AS "Criado_Por"

FROM OIGE H
INNER JOIN IGE1 L
    ON L."DocEntry" = H."DocEntry"

INNER JOIN OITM I
    ON I."ItemCode" = L."ItemCode"

LEFT JOIN OWHS W
    ON W."WhsCode" = L."WhsCode"

LEFT JOIN OUSR U
    ON U."USERID" = H."UserSign"

LEFT JOIN VALOR_SAIDA V
    ON V."DocEntry_Saida" = H."DocEntry"
   AND V."Linha_Saida" = L."LineNum"

/* Pedido de venda direto */
LEFT JOIN ORDR PV_DIRETO
    ON L."BaseType" = 17
   AND L."BaseEntry" = PV_DIRETO."DocEntry"

/* Saída baseada em entrega, e entrega baseada em pedido */
LEFT JOIN ODLN ENTREGA
    ON L."BaseType" = 15
   AND L."BaseEntry" = ENTREGA."DocEntry"

LEFT JOIN DLN1 ENTREGA_LINHA
    ON ENTREGA_LINHA."DocEntry" = ENTREGA."DocEntry"
   AND ENTREGA_LINHA."LineNum" = L."BaseLine"

LEFT JOIN ORDR PV_VIA_ENTREGA
    ON ENTREGA_LINHA."BaseType" = 17
   AND ENTREGA_LINHA."BaseEntry" = PV_VIA_ENTREGA."DocEntry"

/* Saída baseada diretamente em pedido de transferência */
LEFT JOIN OWTQ PTR_DIRETO
    ON L."BaseType" = 1250000001
   AND L."BaseEntry" = PTR_DIRETO."DocEntry"

/* Saída baseada em transferência efetivada */
LEFT JOIN OWTR TR
    ON L."BaseType" = 67
   AND L."BaseEntry" = TR."DocEntry"

LEFT JOIN WTR1 TR_LINHA
    ON TR_LINHA."DocEntry" = TR."DocEntry"
   AND TR_LINHA."LineNum" = L."BaseLine"

LEFT JOIN OWTQ PTR_VIA_TRANSFERENCIA
    ON TR_LINHA."BaseType" = 1250000001
   AND TR_LINHA."BaseEntry" = PTR_VIA_TRANSFERENCIA."DocEntry"

WHERE L."ItemCode" IN (
    'MA003838',
    'MA004404',
    'MA003628'
)
AND H."DocDate" BETWEEN '[%0]' AND '[%1]'

ORDER BY
    H."DocDate",
    H."DocNum",
    L."LineNum";
