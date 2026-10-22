SELECT
    T0."insID" AS "NumeroCartaoEquipamento",

    T0."itemCode" AS "CodigoEquipamento",
    T0."itemName" AS "DescricaoEquipamento",

    T0."manufSN" AS "SerieFabricante",
    T0."internalSN" AS "SerieInterna",

    T0."customer" AS "CodigoCliente",
    T0."custmrName" AS "NomeCliente",

    T0."directCsmr" AS "CodigoConsumidorFinal",
    T0."drctCsmNam" AS "NomeConsumidorFinal",

    T0."contract" AS "ContratoCartao",
    T0."cntrctStrt" AS "InicioContratoCartao",
    T0."cntrctEnd" AS "FimContratoCartao",

    T0."status" AS "StatusCartaoCodigo",

    CASE
        WHEN T0."status" = 'A' THEN 'Ativo'
        WHEN T0."status" = 'T' THEN 'Terminado'
        WHEN T0."status" = 'R' THEN 'Renovado'
        WHEN T0."status" = 'L' THEN 'Emprestado'
        ELSE 'Nao Definido'
    END AS "StatusCartao",

    T0."technician" AS "CodigoTecnico",

    T0."territory" AS "CodigoTerritorio",

    T0."street" AS "Rua",
    T0."StreetNo" AS "Numero",
    T0."block" AS "Bairro",
    T0."city" AS "Cidade",
    T0."state" AS "Estado",
    T0."zip" AS "CEP",
    T0."instLction" AS "LocalizacaoInstalacao",

    T0."U_ICL_Horimeter" AS "HorimetroCartao",

    T0."createDate" AS "DataCriacaoCartao",
    T0."updateDate" AS "DataAtualizacaoCartao"

FROM OINS T0

ORDER BY
    T0."custmrName",
    T0."itemCode",
    T0."insID";
