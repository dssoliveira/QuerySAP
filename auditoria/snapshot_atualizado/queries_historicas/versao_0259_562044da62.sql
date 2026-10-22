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

    OS0."contractID" AS "NumeroContratoLOC1",
    OS0."U_MM_CC" AS "CentroCustoOS",
    OS0."U_MM_PV" AS "PedidoVendaOS",

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

    S4."Line" AS "LinhaDocumentoOS",
    S4."Object" AS "ObjetoDocumento",
    S4."ObjectType" AS "TipoObjetoDocumento",
    S4."DocAbs" AS "DocEntryDocumento",
    S4."DocNumber" AS "NumeroDocumento",
    S4."DocPstDate" AS "DataLancamentoDocumento",

    CASE
        WHEN S4."Object" = '60' THEN 'Saida de Mercadoria'
        WHEN S4."Object" = '59' THEN 'Entrada de Mercadoria'
        WHEN S4."Object" = '22' THEN 'Pedido de Compra'
        WHEN S4."Object" = '20' THEN 'Recebimento de Mercadoria'
        WHEN S4."Object" = '18' THEN 'Nota Fiscal de Entrada'
        WHEN S4."Object" = '17' THEN 'Pedido de Venda'
        WHEN S4."Object" = '13' THEN 'Nota Fiscal de Saida'
        ELSE 'Outro / Validar'
    END AS "DescricaoObjetoDocumento"

FROM OSCL OS0

LEFT JOIN SCL4 S4
    ON S4."SrcvCallID" = OS0."callID"

WHERE
    OS0."insID" IS NOT NULL

ORDER BY
    OS0."callID",
    S4."Line";
