PV_ICLASS_AGR AS (
    SELECT
        DOC."NumeroOS",
        REF."DocEntryPVGeradoIClass" AS "DocEntryPVGeradoIClassRef",
        DOC."PVsGeradosIClass",
        DOC."UltimaDataPVGeradoIClass",
        IFNULL(IT."ItensPVGeradoIClass", '') AS "ItensPVGeradoIClass",
        IFNULL(VAL."QuantidadePVGeradoIClass", 0) AS "QuantidadePVGeradoIClass",
        IFNULL(VAL."HorasPVGeradoIClass", 0) AS "HorasPVGeradoIClass",
        IFNULL(VAL."CustoHoraHomemPVGeradoIClass", 0) AS "CustoHoraHomemPVGeradoIClass",
        IFNULL(VAL."ValorPVGeradoIClass", 0) AS "ValorPVGeradoIClass"

    FROM PV_ICLASS_DOC_AGR DOC

    LEFT JOIN PV_ICLASS_DOC_REF REF
        ON REF."NumeroOS" = DOC."NumeroOS"

    LEFT JOIN PV_ICLASS_ITEM_AGR IT
        ON IT."NumeroOS" = DOC."NumeroOS"

    LEFT JOIN PV_ICLASS_VALOR_AGR VAL
        ON VAL."NumeroOS" = DOC."NumeroOS"
),
