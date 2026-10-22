CASE
    WHEN ENT."Data_Entrega" IS NOT NULL
    THEN ENT."Data_Entrega"
    ELSE T0."DocDate"
END AS "DocDate"
