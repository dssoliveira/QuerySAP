CASE
    WHEN T1."DocEntry" IS NULL
    THEN 'Validar: sem pedido de venda vinculado'

    WHEN T2."DocEntry" IS NULL
    THEN 'Validar: sem linha do centro de custo selecionado'

    WHEN IFNULL(T2."Quantity", 0) = 0
    THEN 'Validar: linha com quantidade zerada'

    WHEN IFNULL(T2."LineTotal", 0) = 0
         AND IFNULL(T2."Quantity", 0) > 1
    THEN 'Validar: quantidade maior que 1 com valor zerado'

    WHEN IFNULL(T2."LineTotal", 0) = 0
    THEN 'Validar: linha com valor zerado'

    ELSE ''
END AS "Alerta Auditoria"
