CASE
    WHEN OS0."status" = -3 THEN 'Aberto'
    WHEN OS0."status" = -2 THEN 'Pendente'
    WHEN OS0."status" = -1 THEN 'Fechado'
    WHEN OS0."status" = 1 THEN 'Aguardando Pecas'
    WHEN OS0."status" = 2 THEN 'Encerrado IClass'
    WHEN OS0."status" = 3 THEN 'Enviar IClass'
    WHEN OS0."status" = 4 THEN 'Enviado IClass'
    WHEN OS0."status" = 5 THEN 'Equipamento Parado'
    WHEN OS0."status" IS NULL THEN NULL
    ELSE 'Nao Definido'
END AS "StatusOS"
