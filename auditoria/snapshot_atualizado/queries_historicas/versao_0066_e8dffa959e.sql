B."TipoProjeto" AS "Tipo Projeto",
B."Vendedor",

CASE
    WHEN UPPER(IFNULL(B."Filial", '')) LIKE '%ENGENHARIA%'
    THEN 'Sistel Engenharia'

    WHEN UPPER(IFNULL(B."Filial", '')) LIKE '%COMERCIO%'
    THEN 'Sistel Comercio'

    ELSE B."Filial"
END AS "Filial",

B."Departamento",
B."DescricaoItem" AS "Descricao Item",
