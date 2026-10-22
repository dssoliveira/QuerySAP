IFNULL(A."AcumuladoSAP", 0)
    + IFNULL(M."RetroJan", 0)
    + IFNULL(M."RetroFev", 0) AS "Acumulado",
