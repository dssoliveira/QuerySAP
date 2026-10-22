SELECT 
    T3."DocEntry" AS "Num_Interno_NF",       -- Chave interna do banco (DocEntry)
    T3."DocNum" AS "Num_Documento_SAP",     -- Número sequencial do SAP (DocNum)
    T3."Serial" AS "Numero_Nota_Fiscal",    -- Número da NF-e / Código Fiscal (Serial)
    T3."DocDate" AS "Data_Emissao",
    T3."CardCode" AS "Cod_Cliente",
    T3."CardName" AS "Nome_Cliente",
    T0."DocNum" AS "Pedido_Venda",
    
    -- Centro de Custo/Departamento direto da linha do Pedido (RDR1)
    T1."OcrCode" AS "Departamento",
    
    T2."ItemCode" AS "Cod_Item",
    T2."Dscription" AS "Descricao_Item",
    T2."Quantity" AS "Quantidade",
    T2."LineTotal" AS "Total_Linha",
    
    -- Campo calculado do cabeçalho da nota para soma sem duplicação
    CASE 
        WHEN ROW_NUMBER() OVER (PARTITION BY T3."DocEntry" ORDER BY T2."LineNum") = 1 
        THEN (T3."DocTotal" + T3."DiscSum" - T3."VatSum" - T3."TotalExpns") 
        ELSE 0 
    END AS "Total_Antes_Desc_Para_Soma"
    
FROM ORDR T0
INNER JOIN RDR1 T1 ON T0."DocEntry" = T1."DocEntry"

INNER JOIN INV1 T2 ON T2."BaseEntry" = T1."DocEntry" 
                  AND T2."BaseLine" = T1."LineNum" 
                  AND T2."BaseType" = 17
                         
INNER JOIN OINV T3 ON T3."DocEntry" = T2."DocEntry"

WHERE 
    T3."DocDate" BETWEEN [%0] AND [%1]
    AND T3."CANCELED" = 'N'
    AND T1."OcrCode" IS NOT NULL 
    
ORDER BY 
    T3."DocDate" DESC, 
    T3."DocNum",
    T2."LineNum";

outra query 

com relatorio anterior
