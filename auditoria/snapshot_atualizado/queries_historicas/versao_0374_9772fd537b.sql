CASE
    WHEN TO_VARCHAR(LIN."CFOP") IN ('5922', '6922')
    THEN 'Nota Fiscal de Venda Futura'

    WHEN ENT."Num_Documento_Entrega" IS NOT NULL
    THEN 'Nota Fiscal de Entrega'

    ELSE 'Nota Fiscal de Saida'
END AS "Tipo_Nota_Fiscal",
