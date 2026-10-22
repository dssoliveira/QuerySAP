ROUND(
    (
        IFNULL(PV."U_MM_Material", 0)
        + IFNULL(PV."U_MM_MO_DIRETA", 0)
        + IFNULL(PV."U_MM_MO_INDIRETA", 0)
        + IFNULL(PV."U_MM_Alimentacao", 0)
        + IFNULL(PV."U_MM_Hospedagem", 0)
        + IFNULL(PV."U_MM_Equipamento", 0)
        + IFNULL(PV."U_MM_Deslocamento", 0)
        + IFNULL(PV."U_MM_Frete", 0)
        + IFNULL(PV."U_MM_Servicos", 0)
        + IFNULL(PV."U_MM_Pedagio", 0)
    ) / NULLIF(CC."QtdCentrosCusto", 0),
    2
) AS "Custo Total",
