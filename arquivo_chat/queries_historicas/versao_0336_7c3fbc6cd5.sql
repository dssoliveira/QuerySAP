WITH TRANSF_HEADER AS (
    SELECT
        TR0."DocEntry" AS "DocEntryTransferencia",
        TR0."DocNum" AS "PedidoTransferencia",
        TR0."DocDate" AS "DataTransferencia",
        TR0."U_MM_OS" AS "NumeroOS",
        TR0."CardCode" AS "CodigoClienteTransferencia",
        TR0."CardName" AS "NomeClienteTransferencia",

        CAST(
            SUBSTRING(TR0."U_MM_OBS_INTERNO", 1, 5000)
            AS NVARCHAR(5000)
        ) AS "ObservacaoInternaTransferencia"

    FROM OWTQ TR0

    WHERE
        TR0."CANCELED" = 'N'
        AND TR0."U_MM_OS" IS NOT NULL
),

OS_NUMEROS AS (
    SELECT DISTINCT
        OS0."callID" AS "NumeroOS"
    FROM OSCL OS0

    UNION

    SELECT DISTINCT
        TH."NumeroOS"
    FROM TRANSF_HEADER TH

    UNION

    SELECT DISTINCT
        PV."U_LOC1_CallID" AS "NumeroOS"
    FROM ORDR PV
    WHERE
        PV."CANCELED" = 'N'
        AND PV."U_MM_Tipo" = '4'
        AND PV."U_LOC1_CallID" IS NOT NULL

    UNION

    SELECT DISTINCT
        S4."SrcvCallID" AS "NumeroOS"
    FROM SCL4 S4

    INNER JOIN ORDR PV
        ON PV."DocEntry" = S4."DocAbs"
        AND PV."CANCELED" = 'N'

    INNER JOIN RDR1 PV1
        ON PV1."DocEntry" = PV."DocEntry"
        AND PV1."ItemCode" IN ('SV000045', 'SV000044')

    WHERE
        S4."Object" = '17'
),

OS_BASE AS (
    SELECT
        O."NumeroOS",

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
            WHEN OS0."status" IS NULL THEN ''
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

        IFNULL(EQ."itemCode", OS0."itemCode") AS "CodigoEquipamento",
        IFNULL(EQ."itemName", OS0."itemName") AS "DescricaoEquipamento",
        IFNULL(EQ."manufSN", OS0."manufSN") AS "SerieFabricante",

        IFNULL(EQ."customer", OS0."customer") AS "CodigoCliente",
        IFNULL(EQ."custmrName", OS0."custmrName") AS "NomeCliente",

        CASE
            WHEN EQ."status" = 'A' THEN 'Ativo'
            WHEN EQ."status" = 'T' THEN 'Terminado'
            WHEN EQ."status" = 'R' THEN 'Renovado'
            WHEN EQ."status" = 'L' THEN 'Emprestado'
            WHEN EQ."status" IS NULL THEN ''
            ELSE 'Nao Definido'
        END AS "StatusCartao",

        EQ."U_ICL_Horimeter" AS "HorimetroCartao"

    FROM OS_NUMEROS O

    LEFT JOIN OSCL OS0
        ON OS0."callID" = O."NumeroOS"

    LEFT JOIN OINS EQ
        ON EQ."insID" = OS0."insID"

    LEFT JOIN OOCR CCOS
        ON CCOS."OcrCode" = OS0."U_MM_CC"
),

TRANSF_BASE AS (
    SELECT
        TH."NumeroOS",
        TH."DocEntryTransferencia",
        TH."PedidoTransferencia",
        TH."DataTransferencia",
        TH."CodigoClienteTransferencia",
        TH."NomeClienteTransferencia",
        TH."ObservacaoInternaTransferencia",

        TR1."ItemCode" AS "CodigoMaterial",
        TR1."Dscription" AS "DescricaoMaterial",
        TR1."Quantity" AS "QuantidadeMaterial",
        TR1."LineTotal" AS "ValorMaterialLinha",

        IFNULL(CCTR."OcrName", TR1."OcrCode") AS "CentroCustoTransferencia"

    FROM TRANSF_HEADER TH

    INNER JOIN WTQ1 TR1
        ON TR1."DocEntry" = TH."DocEntryTransferencia"

    LEFT JOIN OOCR CCTR
        ON CCTR."OcrCode" = TR1."OcrCode"
),

TRANSF_DOC_AGR AS (
    SELECT
        D."NumeroOS",
        STRING_AGG(D."PedidoTransferenciaTexto", ', ') AS "PedidosTransferencia",
        MAX(D."DataTransferencia") AS "UltimaDataTransferencia"

    FROM (
        SELECT DISTINCT
            TH."NumeroOS",
            TO_VARCHAR(TH."PedidoTransferencia") AS "PedidoTransferenciaTexto",
            TH."DataTransferencia"
        FROM TRANSF_HEADER TH
    ) D

    GROUP BY
        D."NumeroOS"
),

TRANSF_DOC_REF AS (
    SELECT
        X."NumeroOS",
        X."DocEntryTransferencia"

    FROM (
        SELECT
            TH."NumeroOS",
            TH."DocEntryTransferencia",

            ROW_NUMBER() OVER (
                PARTITION BY TH."NumeroOS"
                ORDER BY
                    TH."DataTransferencia" DESC,
                    TH."PedidoTransferencia" DESC
            ) AS "LinhaControle"

        FROM TRANSF_HEADER TH
    ) X

    WHERE
        X."LinhaControle" = 1
),

TRANSF_CLIENTE_RANK AS (
    SELECT
        TH."NumeroOS",
        TH."CodigoClienteTransferencia",
        TH."NomeClienteTransferencia",

        ROW_NUMBER() OVER (
            PARTITION BY TH."NumeroOS"
            ORDER BY
                TH."DataTransferencia" DESC,
                TH."PedidoTransferencia" DESC
        ) AS "LinhaControle"

    FROM TRANSF_HEADER TH
),

TRANSF_CLIENTE_UNICO AS (
    SELECT
        T."NumeroOS",
        T."CodigoClienteTransferencia",
        T."NomeClienteTransferencia"

    FROM TRANSF_CLIENTE_RANK T

    WHERE
        T."LinhaControle" = 1
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

TRANSF_CC_AGR AS (
    SELECT
        C."NumeroOS",
        STRING_AGG(C."CentroCustoTransferencia", ', ') AS "CentroCustoTransferencia"

    FROM (
        SELECT DISTINCT
            TB."NumeroOS",
            TB."CentroCustoTransferencia"

        FROM TRANSF_BASE TB

        WHERE
            IFNULL(TB."CentroCustoTransferencia", '') <> ''
    ) C

    GROUP BY
        C."NumeroOS"
),

TRANSF_EQ_CAND AS (
    SELECT
        TH."NumeroOS",

        EQT."insID" AS "NumeroCartaoEquipamento",
        EQT."itemCode" AS "CodigoEquipamento",
        EQT."itemName" AS "DescricaoEquipamento",
        EQT."manufSN" AS "SerieFabricante",
        EQT."customer" AS "CodigoCliente",
        EQT."custmrName" AS "NomeCliente",

        CASE
            WHEN EQT."status" = 'A' THEN 'Ativo'
            WHEN EQT."status" = 'T' THEN 'Terminado'
            WHEN EQT."status" = 'R' THEN 'Renovado'
            WHEN EQT."status" = 'L' THEN 'Emprestado'
            WHEN EQT."status" IS NULL THEN ''
            ELSE 'Nao Definido'
        END AS "StatusCartao",

        EQT."U_ICL_Horimeter" AS "HorimetroCartao",

        ROW_NUMBER() OVER (
            PARTITION BY TH."NumeroOS"
            ORDER BY
                EQT."insID"
        ) AS "LinhaControle"

    FROM TRANSF_HEADER TH

    INNER JOIN OINS EQT
        ON UPPER(IFNULL(TH."ObservacaoInternaTransferencia", '')) LIKE
            '%' || UPPER(EQT."itemCode") || '%'
),

TRANSF_EQ_UNICO AS (
    SELECT
        E."NumeroOS",
        E."NumeroCartaoEquipamento",
        E."CodigoEquipamento",
        E."DescricaoEquipamento",
        E."SerieFabricante",
        E."CodigoCliente",
        E."NomeCliente",
        E."StatusCartao",
        E."HorimetroCartao"

    FROM TRANSF_EQ_CAND E

    WHERE
        E."LinhaControle" = 1
),

TRANSF_AGR AS (
    SELECT
        DOC."NumeroOS",
        REF."DocEntryTransferencia" AS "DocEntryTransferenciaRef",
        DOC."PedidosTransferencia",
        DOC."UltimaDataTransferencia",
        IFNULL(MAT."ValorTransferenciaEstoque", 0) AS "ValorTransferenciaEstoque",
        IFNULL(MAT."MateriaisTransferencia", '') AS "MateriaisTransferencia",
        IFNULL(CC."CentroCustoTransferencia", '') AS "CentroCustoTransferencia",
        CLI."CodigoClienteTransferencia",
        CLI."NomeClienteTransferencia"

    FROM TRANSF_DOC_AGR DOC

    LEFT JOIN TRANSF_DOC_REF REF
        ON REF."NumeroOS" = DOC."NumeroOS"

    LEFT JOIN TRANSF_MAT_AGR MAT
        ON MAT."NumeroOS" = DOC."NumeroOS"

    LEFT JOIN TRANSF_CC_AGR CC
        ON CC."NumeroOS" = DOC."NumeroOS"

    LEFT JOIN TRANSF_CLIENTE_UNICO CLI
        ON CLI."NumeroOS" = DOC."NumeroOS"
),

PV_OS_CANDIDATOS AS (
    SELECT
        OSB."NumeroOS",

        PV."DocEntry" AS "DocEntryPedidoVenda",
        PV."DocNum" AS "PedidoVenda",
        PV."DocDate" AS "DataPedidoVenda",
        PV."DocTotal" AS "ValorPedidoVenda",
        PV."CardCode" AS "CodigoClientePedidoVenda",
        PV."CardName" AS "NomeClientePedidoVenda",

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
        P."CodigoClientePedidoVenda",
        P."NomeClientePedidoVenda",

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
        P."DocEntryPedidoVenda",
        P."PedidoVenda" AS "PedidoVendaGeradoOS",
        P."DataPedidoVenda" AS "DataPedidoVendaGeradoOS",
        P."ValorPedidoVenda" AS "ValorPedidoVendaGeradoOS",
        P."CodigoClientePedidoVenda",
        P."NomeClientePedidoVenda"

    FROM PV_OS_RANK P

    WHERE
        P."LinhaControle" = 1
),

PV_ICLASS_BASE AS (
    SELECT
        S4."SrcvCallID" AS "NumeroOS",

        PV."DocEntry" AS "DocEntryPVGeradoIClass",
        PV."DocNum" AS "PVGeradoIClass",
        PV."DocDate" AS "DataPVGeradoIClass",

        PV1."ItemCode" AS "CodigoItemIClass",
        PV1."Dscription" AS "DescricaoItemIClass",
        PV1."Quantity" AS "QuantidadeMinutosIClass",
        PV1."LineTotal" AS "ValorLinhaIClass"

    FROM SCL4 S4

    INNER JOIN ORDR PV
        ON PV."DocEntry" = S4."DocAbs"
        AND PV."CANCELED" = 'N'

    INNER JOIN RDR1 PV1
        ON PV1."DocEntry" = PV."DocEntry"
        AND PV1."ItemCode" IN ('SV000045', 'SV000044')

    WHERE
        S4."Object" = '17'
),

PV_ICLASS_DOC_AGR AS (
    SELECT
        D."NumeroOS",
        STRING_AGG(D."PVGeradoIClassTexto", ', ') AS "PVsGeradosIClass",
        MAX(D."DataPVGeradoIClass") AS "UltimaDataPVGeradoIClass"

    FROM (
        SELECT DISTINCT
            B."NumeroOS",
            TO_VARCHAR(B."PVGeradoIClass") AS "PVGeradoIClassTexto",
            B."DataPVGeradoIClass"
        FROM PV_ICLASS_BASE B
    ) D

    GROUP BY
        D."NumeroOS"
),

PV_ICLASS_DOC_REF AS (
    SELECT
        X."NumeroOS",
        X."DocEntryPVGeradoIClass"

    FROM (
        SELECT
            B."NumeroOS",
            B."DocEntryPVGeradoIClass",

            ROW_NUMBER() OVER (
                PARTITION BY B."NumeroOS"
                ORDER BY
                    B."DataPVGeradoIClass" DESC,
                    B."PVGeradoIClass" DESC
            ) AS "LinhaControle"

        FROM (
            SELECT DISTINCT
                P."NumeroOS",
                P."DocEntryPVGeradoIClass",
                P."PVGeradoIClass",
                P."DataPVGeradoIClass"
            FROM PV_ICLASS_BASE P
        ) B
    ) X

    WHERE
        X."LinhaControle" = 1
),

PV_ICLASS_ITEM_AGR AS (
    SELECT
        I."NumeroOS",
        STRING_AGG(I."ItemIClassTexto", ' | ') AS "ItensPVGeradoIClass"

    FROM (
        SELECT DISTINCT
            B."NumeroOS",
            B."CodigoItemIClass"
                || ' - '
                || B."DescricaoItemIClass" AS "ItemIClassTexto"

        FROM PV_ICLASS_BASE B
    ) I

    GROUP BY
        I."NumeroOS"
),

PV_ICLASS_VALOR_AGR AS (
    SELECT
        B."NumeroOS",

        SUM(B."QuantidadeMinutosIClass") AS "QuantidadeMinutosPVGeradoIClass",

        ROUND(
            SUM(B."QuantidadeMinutosIClass") / 60.0,
            2
        ) AS "HorasPVGeradoIClass",

        ROUND(
            (SUM(B."QuantidadeMinutosIClass") / 60.0) * 35.00,
            2
        ) AS "CustoHoraHomemPVGeradoIClass",

        SUM(B."ValorLinhaIClass") AS "ValorPVGeradoIClass"

    FROM PV_ICLASS_BASE B

    GROUP BY
        B."NumeroOS"
),

PV_ICLASS_AGR AS (
    SELECT
        DOC."NumeroOS",
        REF."DocEntryPVGeradoIClass" AS "DocEntryPVGeradoIClassRef",
        DOC."PVsGeradosIClass",
        DOC."UltimaDataPVGeradoIClass",
        IFNULL(IT."ItensPVGeradoIClass", '') AS "ItensPVGeradoIClass",
        IFNULL(VAL."QuantidadeMinutosPVGeradoIClass", 0) AS "QuantidadeMinutosPVGeradoIClass",
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

RELATORIO AS (
    SELECT
        OSB."NumeroContratoLOC1",

        IFNULL(OSB."NumeroCartaoEquipamento", TEQ."NumeroCartaoEquipamento") AS "NumeroCartaoEquipamento",
        IFNULL(OSB."CodigoEquipamento", TEQ."CodigoEquipamento") AS "CodigoEquipamento",
        IFNULL(OSB."DescricaoEquipamento", TEQ."DescricaoEquipamento") AS "DescricaoEquipamento",
        IFNULL(OSB."SerieFabricante", TEQ."SerieFabricante") AS "SerieFabricante",

        IFNULL(
            IFNULL(OSB."CodigoCliente", TEQ."CodigoCliente"),
            IFNULL(TRF."CodigoClienteTransferencia", PVG."CodigoClientePedidoVenda")
        ) AS "CodigoCliente",

        IFNULL(
            IFNULL(OSB."NomeCliente", TEQ."NomeCliente"),
            IFNULL(TRF."NomeClienteTransferencia", PVG."NomeClientePedidoVenda")
        ) AS "NomeCliente",

        IFNULL(OSB."StatusCartao", TEQ."StatusCartao") AS "StatusCartao",
        IFNULL(OSB."HorimetroCartao", TEQ."HorimetroCartao") AS "HorimetroCartao",

        OSB."NumeroOS",
        OSB."DocumentoOS",
        OSB."DataCriacaoOS",
        OSB."DataFechamentoOS",

        CAST(
            CASE
                WHEN LENGTH(IFNULL(OSB."AssuntoOS", '')) > 120
                THEN SUBSTRING(OSB."AssuntoOS", 1, 120) || '...'
                ELSE IFNULL(OSB."AssuntoOS", '')
            END
            AS NVARCHAR(123)
        ) AS "AssuntoOS",

        OSB."StatusOS",

        CASE
            WHEN IFNULL(OSB."CentroCustoOS", '') <> ''
            THEN OSB."CentroCustoOS"

            WHEN IFNULL(TRF."CentroCustoTransferencia", '') <> ''
            THEN TRF."CentroCustoTransferencia"

            ELSE ''
        END AS "CentroCustoOS",

        TRF."DocEntryTransferenciaRef",
        IFNULL(TRF."PedidosTransferencia", '') AS "PedidosTransferencia",
        TRF."UltimaDataTransferencia",
        IFNULL(TRF."ValorTransferenciaEstoque", 0) AS "ValorTransferenciaEstoque",
        IFNULL(TRF."MateriaisTransferencia", '') AS "MateriaisTransferencia",

        PVG."DocEntryPedidoVenda",
        PVG."PedidoVendaGeradoOS",
        PVG."DataPedidoVendaGeradoOS",
        IFNULL(PVG."ValorPedidoVendaGeradoOS", 0) AS "ValorPedidoVendaGeradoOS",

        PVI."DocEntryPVGeradoIClassRef",
        IFNULL(PVI."PVsGeradosIClass", '') AS "PVsGeradosIClass",
        PVI."UltimaDataPVGeradoIClass",
        IFNULL(PVI."ItensPVGeradoIClass", '') AS "ItensPVGeradoIClass",
        IFNULL(PVI."QuantidadeMinutosPVGeradoIClass", 0) AS "QuantidadeMinutosPVGeradoIClass",
        IFNULL(PVI."HorasPVGeradoIClass", 0) AS "HorasPVGeradoIClass",
        IFNULL(PVI."CustoHoraHomemPVGeradoIClass", 0) AS "CustoHoraHomemPVGeradoIClass",
        IFNULL(PVI."ValorPVGeradoIClass", 0) AS "ValorPVGeradoIClass",

        (
            IFNULL(TRF."ValorTransferenciaEstoque", 0)
            +
            IFNULL(PVG."ValorPedidoVendaGeradoOS", 0)
            +
            IFNULL(PVI."CustoHoraHomemPVGeradoIClass", 0)
        ) AS "CustoTotalOS"

    FROM OS_BASE OSB

    LEFT JOIN TRANSF_AGR TRF
        ON TRF."NumeroOS" = OSB."NumeroOS"

    LEFT JOIN TRANSF_EQ_UNICO TEQ
        ON TEQ."NumeroOS" = OSB."NumeroOS"

    LEFT JOIN PV_OS_UNICO PVG
        ON PVG."NumeroOS" = OSB."NumeroOS"

    LEFT JOIN PV_ICLASS_AGR PVI
        ON PVI."NumeroOS" = OSB."NumeroOS"
)

SELECT
    CT_LINK."ContractID" AS "Numero Contrato LOC1",

    EQ_LINK."insID" AS "Numero Cartao Equipamento",
    ITEM_LINK."ItemCode" AS "Codigo Equipamento",
    ITEM_LINK."ItemName" AS "Descricao Equipamento",
    R."SerieFabricante" AS "Serie Fabricante",

    BP_LINK."CardCode" AS "Codigo Cliente",
    BP_LINK."CardName" AS "Nome Cliente",

    R."StatusCartao" AS "Status Cartao",
    R."HorimetroCartao" AS "Horimetro Cartao",

    OS_LINK."callID" AS "Numero OS",
    OS_LINK."DocNum" AS "Documento OS",
    R."DataCriacaoOS" AS "Data Criacao OS",
    R."DataFechamentoOS" AS "Data Fechamento OS",
    R."AssuntoOS" AS "Assunto OS",
    R."StatusOS" AS "Status OS",
    R."CentroCustoOS" AS "Centro Custo OS",

    TR_LINK."DocNum" AS "Pedido Transferencia Ref",
    R."PedidosTransferencia" AS "Pedidos Transferencia",
    R."UltimaDataTransferencia" AS "Ultima Data Transferencia",
    R."ValorTransferenciaEstoque" AS "Valor Transferencia Estoque",
    R."MateriaisTransferencia" AS "Materiais Transferencia",

    PV_LINK."DocNum" AS "Pedido Venda Gerado OS",
    R."DataPedidoVendaGeradoOS" AS "Data Pedido Venda Gerado OS",
    R."ValorPedidoVendaGeradoOS" AS "Valor Pedido Venda Gerado OS",

    PV_ICLASS_LINK."DocNum" AS "PV Gerado por iClass Ref",
    R."PVsGeradosIClass" AS "PVs Gerados por iClass",
    R."UltimaDataPVGeradoIClass" AS "Ultima Data PV Gerado por iClass",
    R."ItensPVGeradoIClass" AS "Itens PV Gerado por iClass",
    R."QuantidadeMinutosPVGeradoIClass" AS "Quantidade Minutos PV Gerado por iClass",
    R."HorasPVGeradoIClass" AS "Horas PV Gerado por iClass",
    R."CustoHoraHomemPVGeradoIClass" AS "Custo Hora Homem PV Gerado por iClass",
    R."ValorPVGeradoIClass" AS "Valor Comercial PV Gerado por iClass",

    R."CustoTotalOS" AS "Custo Total OS",

    CASE
        WHEN R."ValorTransferenciaEstoque" = 0
         AND R."ValorPedidoVendaGeradoOS" = 0
         AND R."CustoHoraHomemPVGeradoIClass" = 0
        THEN 'Sem custo vinculado'

        WHEN R."ValorTransferenciaEstoque" > 0
         AND R."ValorPedidoVendaGeradoOS" > 0
         AND R."CustoHoraHomemPVGeradoIClass" > 0
        THEN 'Custo por transferencia, pedido gerado por OS e PV gerado por iClass'

        WHEN R."ValorTransferenciaEstoque" > 0
         AND R."ValorPedidoVendaGeradoOS" > 0
        THEN 'Custo por transferencia e pedido gerado por OS'

        WHEN R."ValorTransferenciaEstoque" > 0
         AND R."CustoHoraHomemPVGeradoIClass" > 0
        THEN 'Custo por transferencia e PV gerado por iClass'

        WHEN R."ValorPedidoVendaGeradoOS" > 0
         AND R."CustoHoraHomemPVGeradoIClass" > 0
        THEN 'Custo por pedido gerado por OS e PV gerado por iClass'

        WHEN R."ValorTransferenciaEstoque" > 0
        THEN 'Custo por transferencia de estoque'

        WHEN R."ValorPedidoVendaGeradoOS" > 0
        THEN 'Custo por pedido de venda gerado por OS'

        WHEN R."CustoHoraHomemPVGeradoIClass" > 0
        THEN 'Custo por PV gerado por iClass'

        ELSE 'Validar'
    END AS "Origem Custo OS"

FROM RELATORIO R

LEFT JOIN OCTR CT_LINK
    ON CT_LINK."ContractID" = R."NumeroContratoLOC1"

LEFT JOIN OINS EQ_LINK
    ON EQ_LINK."insID" = R."NumeroCartaoEquipamento"

LEFT JOIN OITM ITEM_LINK
    ON ITEM_LINK."ItemCode" = R."CodigoEquipamento"

LEFT JOIN OCRD BP_LINK
    ON BP_LINK."CardCode" = R."CodigoCliente"

LEFT JOIN OSCL OS_LINK
    ON OS_LINK."callID" = R."NumeroOS"

LEFT JOIN OWTQ TR_LINK
    ON TR_LINK."DocEntry" = R."DocEntryTransferenciaRef"

LEFT JOIN ORDR PV_LINK
    ON PV_LINK."DocEntry" = R."DocEntryPedidoVenda"

LEFT JOIN ORDR PV_ICLASS_LINK
    ON PV_ICLASS_LINK."DocEntry" = R."DocEntryPVGeradoIClassRef"

ORDER BY
    BP_LINK."CardName",
    ITEM_LINK."ItemCode",
    EQ_LINK."insID",
    OS_LINK."callID";
