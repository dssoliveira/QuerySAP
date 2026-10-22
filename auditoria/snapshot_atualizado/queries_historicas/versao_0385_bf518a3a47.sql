AND NOT (
    TO_VARCHAR(T1."CFOPCode") IN ('5922', '6922')
    AND ENT."Num_Documento_Entrega" IS NULL
)
