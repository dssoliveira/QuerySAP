CASE
    WHEN T0."Comments" IS NOT NULL
         AND LENGTH(TRIM(CAST(T0."Comments" AS NVARCHAR(5000)))) > 0
    THEN CAST(T0."Comments" AS NVARCHAR(5000))

    WHEN T0."Header" IS NOT NULL
         AND LENGTH(TRIM(CAST(T0."Header" AS NVARCHAR(5000)))) > 0
    THEN CAST(T0."Header" AS NVARCHAR(5000))

    ELSE ''
END AS "Observacoes",
