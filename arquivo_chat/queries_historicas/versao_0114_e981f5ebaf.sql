CASE
    WHEN T1."DocEntry" IS NULL THEN 'Validar: sem pedido de venda vinculado'
    WHEN IFNULL(T2."Quantity", 0) = 0 THEN 'Validar: linha com quantidade zerada'
    WHEN IFNULL(T2."LineTotal", 0) = 0 AND IFNULL(T2."Quantity", 0) > 1 THEN 'Validar: quantidade maior que 1 com valor zerado'
    WHEN IFNULL(T2."LineTotal", 0) = 0 THEN 'Validar: linha com valor zerado'
    ELSE ''
END AS "Alerta Auditoria",

TO_VARCHAR(T2."LineNum") AS "LineNum SAP",

T2."LineNum" + 1 AS "Linha Pedido",

TO_VARCHAR(T0."ContractID")
    || ' | PV '
    || TO_VARCHAR(T1."DocNum")
    || ' | Linha '
    || TO_VARCHAR(T2."LineNum" + 1)
    || ' | '
    || T2."OcrCode" AS "Chave Auditoria"
