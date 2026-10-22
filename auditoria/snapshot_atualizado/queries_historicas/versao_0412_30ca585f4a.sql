OR
(
    R."Categoria" = 'Óleo lubrificante'
    AND I."Descricao_Normalizada" LIKE '%VALVOLINE%'
    AND I."Descricao_Normalizada" LIKE '%15W40%'
    AND I."Descricao_Normalizada" LIKE '%CI4%'
    AND I."Descricao_Normalizada" LIKE '%LITRO%'
    AND I."Descricao_Normalizada" NOT LIKE '%DUPLICADO%'
)
