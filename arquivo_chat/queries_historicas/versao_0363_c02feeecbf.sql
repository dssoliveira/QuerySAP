ROUND(
    IFNULL(PV."U_MM_Material", 0) / NULLIF(CC."QtdCentrosCusto", 0),
    2
) AS "Material",
