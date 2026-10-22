CASE
    WHEN B."Quantidade Parcelas" = 1
     AND B."Mes Termino" = TO_DATE('2026-08-01', 'YYYY-MM-DD')
    THEN B."Valor Total Contrato"

    WHEN B."Quantidade Parcelas" > 1
     AND TO_DATE('2026-08-01', 'YYYY-MM-DD')
         BETWEEN B."Mes Inicio" AND B."Mes Fim Provisionamento"
    THEN B."Valor Mensal Contrato"

    ELSE 0
END AS "08/2026"
