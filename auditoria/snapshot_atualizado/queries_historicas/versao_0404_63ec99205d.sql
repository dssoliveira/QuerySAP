CASE
    WHEN IFNULL(M."MetaAno", 0) = 0 THEN NULL
    ELSE ROUND(
        (
            IFNULL(A."AcumuladoSAP", 0)
            + IFNULL(M."RetroJan", 0)
            + IFNULL(M."RetroFev", 0)
        ) / M."MetaAno" * 100,
        2
    )
END AS "%Alcancado"
