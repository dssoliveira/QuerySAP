CASE
    WHEN IFNULL(T0."Comments", '') <> '' THEN T0."Comments"
    WHEN IFNULL(T0."Header", '') <> '' THEN T0."Header"
    ELSE ''
END AS "Observacao Principal",
