AND (
    ENT."Num_Documento_Entrega" IS NOT NULL
    OR (
        UPPER(IFNULL(U."Usage", '')) NOT LIKE '%ENTR. FUTURA%'
        AND UPPER(IFNULL(U."Usage", '')) NOT LIKE '%ENTREGA FUTURA%'
    )
)
