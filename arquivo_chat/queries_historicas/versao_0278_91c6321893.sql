SELECT
    OS0."callID" AS "NumeroOS",
    OS0."DocNum" AS "DocumentoOS",
    OS0."createDate" AS "DataCriacaoOS",
    OS0."closeDate" AS "DataFechamentoOS",

    OS0."insID" AS "NumeroCartaoEquipamento",
    OS0."itemCode" AS "CodigoEquipamento",
    OS0."itemName" AS "DescricaoEquipamento",

    OS0."customer" AS "CodigoCliente",
    OS0."custmrName" AS "NomeCliente",

    OS0."subject" AS "AssuntoOS",

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

    S4."Object" AS "ObjetoDocumento",
    S4."DocAbs" AS "DocEntryDocumento",
    S4."DocNumber" AS "NumeroDocumento",

    PV."DocNum" AS "PedidoVenda",
    PV."DocDate" AS "DataPedidoVenda",
    PV."DocTotal" AS "ValorTotalPedidoVenda",

    IFNULL(PV."U_MM_Material", 0) AS "Material",
    IFNULL(PV."U_MM_MO_DIRETA", 0) AS "MO Direta",
    IFNULL(PV."U_MM_MO_INDIRETA", 0) AS "MO Indireta",
    IFNULL(PV."U_MM_Alimentacao", 0) AS "Alimentacao",
    IFNULL(PV."U_MM_Hospedagem", 0) AS "Hospedagem",
    IFNULL(PV."U_MM_Equipamento", 0) AS "Equipamento",
    IFNULL(PV."U_MM_Deslocamento", 0) AS "Deslocamento",
    IFNULL(PV."U_MM_Frete", 0) AS "Frete",
    IFNULL(PV."U_MM_Servicos", 0) AS "Servicos",
    IFNULL(PV."U_MM_Pedagio", 0) AS "Pedagio",
    IFNULL(PV."U_MM_Comissao", 0) AS "Comissao",
    IFNULL(PV."U_MM_Despesa_Fixa", 0) AS "Despesa Fixa",

    ROUND(
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
        + IFNULL(PV."U_MM_Comissao", 0)
        + IFNULL(PV."U_MM_Despesa_Fixa", 0),
        2
    ) AS "CustoTotalPedidoVenda"

FROM OSCL OS0

INNER JOIN SCL4 S4
    ON S4."SrcvCallID" = OS0."callID"
    AND S4."Object" = '17'

INNER JOIN ORDR PV
    ON PV."DocEntry" = S4."DocAbs"
    AND PV."CANCELED" = 'N'

WHERE
    OS0."insID" IS NOT NULL

ORDER BY
    OS0."callID",
    PV."DocNum";
