WITH OS_BASE AS (
    SELECT
        OS0."callID" AS "NumeroOS",
        OS0."DocNum" AS "DocumentoOS",
        OS0."contractID" AS "NumeroContratoLOC1",
        OS0."createDate" AS "DataCriacaoOS",
        OS0."closeDate" AS "DataFechamentoOS",
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

        CASE
            WHEN IFNULL(CCOS."OcrName", '') <> ''
            THEN CCOS."OcrName"

            WHEN OS0."U_MM_CC" = '6' THEN 'Gerador'
            WHEN OS0."U_MM_CC" = '7' THEN 'Locacao'
            WHEN OS0."U_MM_CC" = '10' THEN 'Nobreak'
            WHEN OS0."U_MM_CC" = '3' THEN 'Execucao Eletrica'

            WHEN IFNULL(OS0."U_MM_CC", '') = '' THEN ''
            ELSE OS0."U_MM_CC"
        END AS "CentroCustoOS",

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

    LEFT JOIN OOCR CCOS
        ON CCOS."OcrCode" = OS0."U_MM_CC"

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

TRANSF_DOC_AGR AS (
    SELECT
        D."NumeroOS",
        STRING_AGG(D."PedidoTransferenciaTexto", ', ') AS "PedidosTransferencia",
        MAX(D."DataTransferencia") AS "UltimaDataTransferencia"

    FROM (
        SELECT DISTINCT
            TB."NumeroOS",
            TO_VARCHAR(TB."PedidoTransferencia") AS "PedidoTransferenciaTexto",
            TB."DataTransferencia"

        FROM TRANSF_BASE TB
    ) D

    GROUP BY
        D."NumeroOS"
),

TRANSF_MAT_AGR AS (
    SELECT
        M."NumeroOS",
        SUM(M."ValorMaterialLinha") AS "ValorTransferenciaEstoque",
        STRING_AGG(M."MateriaisTexto", ' | ') AS "MateriaisTransferencia"

    FROM (
        SELECT
            TB."NumeroOS",
            TB."ValorMaterialLinha",

            TB."CodigoMaterial"
                || ' - '
                || TB."DescricaoMaterial"
                || ' - Qtd: '
                || TO_VARCHAR(TB."QuantidadeMaterial") AS "MateriaisTexto"

        FROM TRANSF_BASE TB
    ) M

    GROUP BY
        M."NumeroOS"
),

TRANSF_AGR AS (
    SELECT
        DOC."NumeroOS",
        DOC."PedidosTransferencia",
        DOC."UltimaDataTransferencia",
        IFNULL(MAT."ValorTransferenciaEstoque", 0) AS "ValorTransferenciaEstoque",
        IFNULL(MAT."MateriaisTransferencia", '') AS "MateriaisTransferencia"

    FROM TRANSF_DOC_AGR DOC

    LEFT JOIN TRANSF_MAT_AGR MAT
        ON MAT."NumeroOS" = DOC."NumeroOS"
),

PV_OS_CANDIDATOS AS (
    SELECT
        OSB."NumeroOS",

        PV."DocEntry" AS "DocEntryPedidoVenda",
        PV."DocNum" AS "PedidoVenda",
        PV."DocDate" AS "DataPedidoVenda",
        PV."DocTotal" AS "ValorPedidoVenda",

        CASE
            WHEN PV."U_LOC1_CallID" = OSB."NumeroOS"
            THEN 1
            ELSE 2
        END AS "PrioridadeVinculo"

    FROM OS_BASE OSB

    INNER JOIN ORDR PV
        ON PV."CANCELED" = 'N'
        AND PV."U_MM_Tipo" = '4'
        AND (
            PV."U_LOC1_CallID" = OSB."NumeroOS"

            OR UPPER(IFNULL(PV."Comments", '')) LIKE
                '%CHAMADO DE SERVIÇO ' || TO_VARCHAR(OSB."NumeroOS") || ' (%'

            OR UPPER(IFNULL(PV."Comments", '')) LIKE
                '%CHAMADO DE SERVICO ' || TO_VARCHAR(OSB."NumeroOS") || ' (%'
        )
),

PV_OS_RANK AS (
    SELECT
        P."NumeroOS",
        P."DocEntryPedidoVenda",
        P."PedidoVenda",
        P."DataPedidoVenda",
        P."ValorPedidoVenda",

        ROW_NUMBER() OVER (
            PARTITION BY P."NumeroOS"
            ORDER BY
                P."PrioridadeVinculo",
                P."DataPedidoVenda" DESC,
                P."PedidoVenda" DESC
        ) AS "LinhaControle"

    FROM PV_OS_CANDIDATOS P
),

PV_OS_UNICO AS (
    SELECT
        P."NumeroOS",
        P."PedidoVenda" AS "PedidoVendaGeradoOS",
        P."DataPedidoVenda" AS "DataPedidoVendaGeradoOS",
        P."ValorPedidoVenda" AS "ValorPedidoVendaGeradoOS"

    FROM PV_OS_RANK P

    WHERE
        P."LinhaControle" = 1
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

        IFNULL(TRF."PedidosTransferencia", '') AS "PedidosTransferencia",
        TRF."UltimaDataTransferencia",
        IFNULL(TRF."ValorTransferenciaEstoque", 0) AS "ValorTransferenciaEstoque",
        IFNULL(TRF."MateriaisTransferencia", '') AS "MateriaisTransferencia",

        PVG."PedidoVendaGeradoOS",
        PVG."DataPedidoVendaGeradoOS",
        IFNULL(PVG."ValorPedidoVendaGeradoOS", 0) AS "ValorPedidoVendaGeradoOS",

        (
            IFNULL(TRF."ValorTransferenciaEstoque", 0)
            +
            IFNULL(PVG."ValorPedidoVendaGeradoOS", 0)
        ) AS "CustoTotalOS"

    FROM OS_BASE OSB

    LEFT JOIN TRANSF_AGR TRF
        ON TRF."NumeroOS" = OSB."NumeroOS"

    LEFT JOIN PV_OS_UNICO PVG
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

    R."PedidosTransferencia" AS "Pedidos Transferencia",
    R."UltimaDataTransferencia" AS "Ultima Data Transferencia",
    R."ValorTransferenciaEstoque" AS "Valor Transferencia Estoque",
    R."MateriaisTransferencia" AS "Materiais Transferencia",

    R."PedidoVendaGeradoOS" AS "Pedido Venda Gerado OS",
    R."DataPedidoVendaGeradoOS" AS "Data Pedido Venda Gerado OS",
    R."ValorPedidoVendaGeradoOS" AS "Valor Pedido Venda Gerado OS",

    R."CustoTotalOS" AS "Custo Total OS",

    CASE
        WHEN R."ValorTransferenciaEstoque" = 0
         AND R."ValorPedidoVendaGeradoOS" = 0
        THEN 'Sem custo vinculado'

        WHEN R."ValorTransferenciaEstoque" > 0
         AND R."ValorPedidoVendaGeradoOS" > 0
        THEN 'Custo por transferencia e pedido gerado por OS'

        WHEN R."ValorTransferenciaEstoque" > 0
        THEN 'Custo por transferencia de estoque'

        WHEN R."ValorPedidoVendaGeradoOS" > 0
        THEN 'Custo por pedido de venda gerado por OS'

        ELSE 'Validar'
    END AS "Origem Custo OS"

FROM RELATORIO R

ORDER BY
    R."NomeCliente",
    R."CodigoEquipamento",
    R."NumeroCartaoEquipamento",
    R."NumeroOS";
