CASE
    WHEN ENT."Valor_Entrega" IS NOT NULL
    THEN ENT."Valor_Entrega"
    ELSE T0."NfeValue"
END AS "NfeValue"
