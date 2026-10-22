CASE
    WHEN T1."DocEntry" IS NULL THEN 'Sem pedido de venda vinculado'
    WHEN T2."DocEntry" IS NULL THEN 'Sem linha do centro de custo selecionado'
    WHEN IFNULL(T2."LineTotal", 0) = 0 THEN 'Linha com valor zerado'
    WHEN IFNULL(T2."Quantity", 0) = 0 THEN 'Linha com quantidade zerada'
    ELSE ''
END AS "Alerta Auditoria"
