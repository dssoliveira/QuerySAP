SELECT
    T0."insID" AS "NumeroCartaoEquipamento",
    T0."manufSN" AS "SerieFabricante",
    T0."internalSN" AS "NumeroSerieInterno",
    T0."itemCode" AS "CodigoItem",
    T0."itemName" AS "DescricaoItem",
    T0."customer" AS "CodigoCliente",
    T0."custmrName" AS "NomeCliente",
    T0."contractID" AS "NumeroContrato",
    T0."cntrctDate" AS "DataContrato",
    T0."status" AS "StatusCodigo",
    T0."technician" AS "Tecnico",
    T0."territory" AS "Territorio",
    T0."U_ICL_Horimeter" AS "HorimetroCartao"
FROM OINS T0
ORDER BY
    T0."custmrName",
    T0."itemCode",
    T0."insID";
