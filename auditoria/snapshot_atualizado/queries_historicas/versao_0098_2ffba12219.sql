CASE
    WHEN IFNULL(T2."LineTotal", 0) = 0
         AND T2."Quantity" > 1
    THEN 'Validar: quantidade maior que 1 com valor zerado'

    WHEN IFNULL(T2."LineTotal", 0) = 0
    THEN 'Validar: linha com valor zerado'

    WHEN IFNULL(T2."Quantity", 0) = 0
    THEN 'Validar: linha com quantidade zerada'

    ELSE ''
END AS "Alerta Auditoria"
