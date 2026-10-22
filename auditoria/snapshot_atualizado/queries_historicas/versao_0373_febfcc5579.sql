CASE
    WHEN ENT."Num_Documento_Entrega" IS NOT NULL
    THEN 'Nota Fiscal de Entrega Futura com Entrega Vinculada'
    ELSE 'Nota Fiscal de Saida'
END AS "Tipo_Nota_Fiscal"
