AND NOT (
    TO_VARCHAR(LIN."CFOP") IN ('5922', '6922')
    AND ENT."Num_Documento_Entrega" IS NULL
)
