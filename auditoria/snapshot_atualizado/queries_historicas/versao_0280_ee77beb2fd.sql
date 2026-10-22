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
    T0."StreetNo" AS "NumeroEndereco",
    T0."block" AS "Bairro",
    T0."city" AS "Cidade",
    T0."state" AS "Estado",
    T0."zip" AS "CEP",
    T0."instLction" AS "LocalizacaoInstalacao",

    T0."U_ICL_Horimeter" AS "HorimetroCartao",

    T0."createDate" AS "DataCriacaoCartao",
    T0."updateDate" AS "DataAtualizacaoCartao",

    OS0."callID" AS "NumeroOS",
    OS0."DocNum" AS "DocumentoOS",
    OS0."createDate" AS "DataCriacaoOS",
    OS0."createTime" AS "HoraCriacaoOS",
    OS0."StartDate" AS "DataInicioOS",
    OS0."EndDate" AS "DataFimPrevistaOS",
    OS0."closeDate" AS "DataFechamentoOS",

    OS0."subject" AS "AssuntoOS",
    OS0."descrption" AS "DescricaoOS",
    OS0."resolution" AS "ResolucaoOS",

    OS0."status" AS "StatusOSCodigo",

    CASE
        WHEN OS0."status" = -3 THEN 'Aberto'
        WHEN OS0."status" = -2 THEN 'Pendente'
        WHEN OS0."status" = -1 THEN 'Fechado'
        WHEN OS0."status" = 1 THEN 'Aguardando Pecas'
        WHEN OS0."status" = 2 THEN 'Encerrado IClass'
        WHEN OS0."status" = 3 THEN 'Enviar IClass'
        WHEN OS0."status" = 4 THEN 'Enviado IClass'
        WHEN OS0."status" = 5 THEN 'Equipamento Parado'
        ELSE 'Nao Definido'
    END AS "StatusOS",

    OS0."customer" AS "CodigoClienteOS",
    OS0."custmrName" AS "NomeClienteOS",

    OS0."itemCode" AS "CodigoEquipamentoOS",
    OS0."itemName" AS "DescricaoEquipamentoOS",

    OS0."contractID" AS "ContratoOS",
    OS0."U_MM_CC" AS "CentroCustoOS",
    OS0."U_MM_PV" AS "PedidoVendaOS",
    OS0."U_ExternalID" AS "ExternalID",
    OS0."U_ICL_ProjectTag" AS "ProjectTagIClass",

    CASE
        WHEN OS0."insID" = T0."insID"
         AND OS0."itemCode" = T0."itemCode"
        THEN 'OK: OS vinculada ao cartão e ao mesmo equipamento'

        WHEN OS0."insID" = T0."insID"
         AND IFNULL(OS0."itemCode", '') <> IFNULL(T0."itemCode", '')
        THEN 'Validar: OS vinculada ao cartão, mas código do equipamento diferente'

        ELSE 'Validar vínculo'
    END AS "AuditoriaVinculo"

FROM OINS T0

INNER JOIN OSCL OS0
    ON OS0."insID" = T0."insID"

WHERE
    OS0."status" NOT IN (-1, 2)

ORDER BY
    T0."custmrName",
    T0."itemCode",
    T0."insID",
    OS0."createDate",
    OS0."callID";
