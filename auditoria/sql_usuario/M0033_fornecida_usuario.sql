SELECT DISTINCT 
    T0."U_ContractID"           AS "Nº CONTRATO",
    T4."OcrCode"                AS "DEPARTAMENTO/CENTRO DE CUSTO",
    T3."CardCode"               AS "CÓD.CLIENTE",
    T3."CardName"               AS "NOME CLIENTE",
    T3."DocNum"                 AS "PED.VENDA",
    T3."DocDate"                AS "DATA PED.VENDA",
    T3."DocTotal"               AS "VALOR PED.VENDA",
    T6."DocNum"                 AS "Nº NOTA FISCAL",
    T6."DocDate"                AS "DATA NF",
    T6."GrosProfit"                AS "VALOR NOTA FISCAL"

FROM "@LOC1_CTR" T0
INNER JOIN "@LOC1_BILL" T1 
    ON T0."U_ContractID" = T1."U_ContractID"

INNER JOIN "@LOC1_BILL1" T2 
    ON T2."U_BillCode" = T1."Code"

INNER JOIN "ORDR" T3 
    ON T2."U_DocEntry" = T3."DocEntry"

INNER JOIN "RDR1" T4 
    ON T3."DocEntry" = T4."DocEntry"

-- Ligação com NF
LEFT JOIN "INV1" T5 
    ON T5."BaseEntry" = T4."DocEntry"
   AND T5."BaseLine" = T4."LineNum"
   AND T5."BaseType" = 17

LEFT JOIN "OINV" T6 
    ON T6."DocEntry" = T5."DocEntry"

WHERE
    T1."U_BillingStatus" = 'Confirmed'
    AND ((T3."DocDate" BETWEEN '[%0]' AND '[%1]') OR  ('[%0]' = '' AND  '[%1]' = ''))
    AND T3."CANCELED" = 'N'

ORDER BY
1,6


ESSA QUERY FOI CRIADA POR UM PROGRAMADOR DA MANYMINDS GESTORA DO NOSSO CONTRATO DE USO DO SAP 
EU QUERO UMA VERSÃO DESSA PARA NOBREAK E PARA GERADOR 

PELO QUE PUDE VERIFICAR O OBJETIVO DESSA QUERY É SABER O PEDIDO DE VENDA DE FATURAMENTO DA PARCELA CONTRATUAL QUE FOI GERADO NO MES
OU SEJA CONFERIR SE TODOS OS CONTRATOS QUE DEVERIAM SER FATURADOS SE FORAM REALMENTE
