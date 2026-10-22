WITH OS_BASE AS (
    SELECT
        OS0."callID" AS "NumeroOS",
        OS0."DocNum" AS "DocumentoOS",
        OS0."contractID" AS "NumeroContratoLOC1",
        OS0."createDate" AS "DataCriacaoOS",
        OS0."closeDate" AS "DataFechamentoOS",
        OS0."subject" AS "AssuntoOS",
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

        OS0."U_MM_PV" AS "PedidoVendaInformadoOS",
        OS0."U_MM_CC" AS "CentroCustoOS",

        EQ."insID" AS "NumeroCartaoEquipamento",
        EQ."itemCode" AS "CodigoEquipamento",
        EQ."itemName" AS "DescricaoEquipamento",
        EQ."manufSN" AS "SerieFabricante",
        EQ."customer" AS "CodigoCliente",
        EQ."custmrName" AS "NomeCliente",

        CASE
            WHEN EQ."status" = 'A' THEN 'Ativo'
            WHEN EQ."status" = 'T' THEN 'Terminado'
            WHEN EQ."status" = 'R' THEN 'Renovado'
            WHEN EQ."status" = 'L' THEN 'Emprestado'
            ELSE 'Nao Definido'
        END AS "StatusCartao",

        EQ."U_ICL_Horimeter" AS "HorimetroCartao"

    FROM OSCL OS0

    INNER JOIN OINS EQ
        ON EQ."insID" = OS0."insID"

    WHERE
        OS0."insID" IS NOT NULL
),

TRANSF_BASE AS (
    SELECT
        TR0."U_MM_OS" AS "NumeroOS",

        TR0."DocEntry" AS "DocEntryTransferencia",
        TR0."DocNum" AS "PedidoTransferencia",
        TR0."DocDate" AS "DataTransferencia",

        TR1."ItemCode" AS "CodigoMaterial",
        TR1."Dscription" AS "DescricaoMaterial",
        TR1."Quantity" AS "QuantidadeMaterial",
        TR1."LineTotal" AS "ValorMaterialLinha"

    FROM OWTQ TR0

    INNER JOIN WTQ1 TR1
        ON TR1."DocEntry" = TR0."DocEntry"

    WHERE
        TR0."CANCELED" = 'N'
        AND TR0."U_MM_OS" IS NOT NULL
),

TRANSF_AGR AS (
    SELECT
        T."NumeroOS",

        STRING_AGG(T."PedidoTransferenciaTexto", ', ') AS "PedidosTransferencia",
        MAX(T."DataTransferencia") AS "UltimaDataTransferencia",

        SUM(T."ValorMaterialLinha") AS "ValorTransferenciaEstoque",

        STRING_AGG(T."MateriaisTexto", ' | ') AS "MateriaisTransferencia"

    FROM (
        SELECT DISTINCT
            TB."NumeroOS",
            TO_VARCHAR(TB."PedidoTransferencia") AS "PedidoTransferenciaTexto",
            TB."DataTransferencia",
            TB."ValorMaterialLinha",

            TB."CodigoMaterial"
                || ' - '
                || TB."DescricaoMaterial"
                || ' - Qtd: '
                || TO_VARCHAR(TB."QuantidadeMaterial") AS "MateriaisTexto"

        FROM TRANSF_BASE TB
    ) T

    GROUP BY
        T."NumeroOS"
),

PV_OS_BASE AS (
    SELECT
        OSB."NumeroOS",

        PV."DocEntry" AS "DocEntryPedidoVenda",
        PV."DocNum" AS "PedidoVenda",
        PV."DocDate" AS "DataPedidoVenda",
        PV."DocTotal" AS "ValorPedidoVenda",

        PV."CardCode" AS "CodigoClientePedidoVenda",
        PV."CardName" AS "NomeClientePedidoVenda",

        CASE
            WHEN PV."U_MM_Tipo" = '4' THEN 'Gerado por OS (Pre-Consumo)'
            ELSE 'Nao Definido'
        END AS "TipoPedidoVenda"

    FROM OS_BASE OSB

    INNER JOIN ORDR PV
        ON PV."CANCELED" = 'N'
        AND PV."U_MM_Tipo" = '4'
        AND (
            PV."DocNum" = OSB."PedidoVendaInformadoOS"

            OR UPPER(IFNULL(PV."NumAtCard", '')) LIKE
                '%' || TO_VARCHAR(OSB."NumeroOS") || '%'

            OR UPPER(IFNULL(PV."Comments", '')) LIKE
                '%' || TO_VARCHAR(OSB."NumeroOS") || '%'
        )
),

PV_OS_AGR AS (
    SELECT
        P."NumeroOS",

        STRING_AGG(P."PedidoVendaTexto", ', ') AS "PedidosVendaGeradosOS",
        MAX(P."DataPedidoVenda") AS "UltimaDataPedidoVenda",

        SUM(P."ValorPedidoVenda") AS "ValorPedidosVendaGeradosOS"

    FROM (
        SELECT DISTINCT
            PB."NumeroOS",
            TO_VARCHAR(PB."PedidoVenda") AS "PedidoVendaTexto",
            PB."DataPedidoVenda",
            PB."ValorPedidoVenda"

        FROM PV_OS_BASE PB
    ) P

    GROUP BY
        P."NumeroOS"
),

RELATORIO AS (
    SELECT
        OSB."NumeroContratoLOC1",
        OSB."NumeroCartaoEquipamento",
        OSB."CodigoEquipamento",
        OSB."DescricaoEquipamento",
        OSB."SerieFabricante",
        OSB."CodigoCliente",
        OSB."NomeCliente",
        OSB."StatusCartao",
        OSB."HorimetroCartao",

        OSB."NumeroOS",
        OSB."DocumentoOS",
        OSB."DataCriacaoOS",
        OSB."DataFechamentoOS",
        OSB."AssuntoOS",
        OSB."StatusOS",
        OSB."CentroCustoOS",

        IFNULL(TRF."PedidosTransferencia", '') AS "Pedidos Transferencia",
        TRF."UltimaDataTransferencia" AS "Ultima Data Transferencia",
        IFNULL(TRF."ValorTransferenciaEstoque", 0) AS "Valor Transferencia Estoque",
        IFNULL(TRF."MateriaisTransferencia", '') AS "Materiais Transferencia",

        IFNULL(PVG."PedidosVendaGeradosOS", '') AS "Pedidos Venda Gerados OS",
        PVG."UltimaDataPedidoVenda" AS "Ultima Data Pedido Venda Gerado OS",
        IFNULL(PVG."ValorPedidosVendaGeradosOS", 0) AS "Valor Pedidos Venda Gerados OS",

        (
            IFNULL(TRF."ValorTransferenciaEstoque", 0)
            +
            IFNULL(PVG."ValorPedidosVendaGeradosOS", 0)
        ) AS "Custo Total OS"

    FROM OS_BASE OSB

    LEFT JOIN TRANSF_AGR TRF
        ON TRF."NumeroOS" = OSB."NumeroOS"

    LEFT JOIN PV_OS_AGR PVG
        ON PVG."NumeroOS" = OSB."NumeroOS"
)

SELECT
    R."NumeroContratoLOC1" AS "Numero Contrato LOC1",
    R."NumeroCartaoEquipamento" AS "Numero Cartao Equipamento",
    R."CodigoEquipamento" AS "Codigo Equipamento",
    R."DescricaoEquipamento" AS "Descricao Equipamento",
    R."SerieFabricante" AS "Serie Fabricante",
    R."CodigoCliente" AS "Codigo Cliente",
    R."NomeCliente" AS "Nome Cliente",
    R."StatusCartao" AS "Status Cartao",
    R."HorimetroCartao" AS "Horimetro Cartao",

    R."NumeroOS" AS "Numero OS",
    R."DocumentoOS" AS "Documento OS",
    R."DataCriacaoOS" AS "Data Criacao OS",
    R."DataFechamentoOS" AS "Data Fechamento OS",
    R."AssuntoOS" AS "Assunto OS",
    R."StatusOS" AS "Status OS",
    R."CentroCustoOS" AS "Centro Custo OS",

    R."Pedidos Transferencia",
    R."Ultima Data Transferencia",
    R."Valor Transferencia Estoque",
    R."Materiais Transferencia",

    R."Pedidos Venda Gerados OS",
    R."Ultima Data Pedido Venda Gerado OS",
    R."Valor Pedidos Venda Gerados OS",

    R."Custo Total OS",

    SUM(R."Custo Total OS") OVER (
        PARTITION BY R."NumeroCartaoEquipamento"
    ) AS "Custo Total Vida Equipamento",

    CASE
        WHEN R."Valor Transferencia Estoque" = 0
         AND R."Valor Pedidos Venda Gerados OS" = 0
        THEN 'Sem custo vinculado'

        WHEN R."Valor Transferencia Estoque" > 0
         AND R."Valor Pedidos Venda Gerados OS" > 0
        THEN 'Custo por transferencia e pedido gerado por OS'

        WHEN R."Valor Transferencia Estoque" > 0
        THEN 'Custo por transferencia de estoque'

        WHEN R."Valor Pedidos Venda Gerados OS" > 0
        THEN 'Custo por pedido de venda gerado por OS'

        ELSE 'Validar'
    END AS "Origem Custo OS"

FROM RELATORIO R

ORDER BY
    R."NomeCliente",
    R."CodigoEquipamento",
    R."NumeroCartaoEquipamento",
    R."NumeroOS";
