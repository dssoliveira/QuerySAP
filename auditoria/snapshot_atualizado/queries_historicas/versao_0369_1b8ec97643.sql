CASE
    WHEN DAYS_BETWEEN(PV."DocDate", PV."DocDueDate") <= 31
    THEN 'Locacao Curto Prazo'
    ELSE 'Locacao Prazo Maior'
END AS "Classificacao_Prazo"
