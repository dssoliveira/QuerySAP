WHEN B."Quantidade Parcelas" = 1
 AND B."Mes Termino" = TO_DATE('2026-08-01', 'YYYY-MM-DD')
THEN B."Valor Total Contrato"
