CASE
    WHEN UPPER(IFNULL(T4."BPLName", '')) LIKE '%ENGENHARIA%'
    THEN 'Sistel Engenharia'

    WHEN UPPER(IFNULL(T4."BPLName", '')) LIKE '%COMERCIO%'
      OR UPPER(IFNULL(T4."BPLName", '')) LIKE '%COMÉRCIO%'
    THEN 'Sistel Comercio'

    ELSE 'Nao Definido'
END AS "Empresa",
