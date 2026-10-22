SELECT
    CT."ContractID" AS "NumeroContratoLOC1",

    BPL."BPLName" AS "FilialContrato",

    T0."ItemCode" AS "CodigoEquipamento",
    T0."ItemName" AS "DescricaoEquipamento",

    T1."insID" AS "NumeroCartaoEquipamento",
    T1."customer" AS "CodigoCliente",
    T1."custmrName" AS "NomeCliente",

    T2."OcrCode" AS "Departamento",

    T3."DistNumber" AS "TAG",
    T3."MnfSerial" AS "SerieFabricante",
    T3."U_LOC1_Status" AS "StatusLOC1_Codigo",

    CASE
        WHEN T3."U_LOC1_Status" = 'C' THEN 'EM CONTRATO'
        WHEN T3."U_LOC1_Status" = 'A' THEN 'DISPONIVEL'
        WHEN T3."U_LOC1_Status" = 'D' THEN 'DISPONIVEL'
        WHEN T3."U_LOC1_Status" = 'M' THEN 'EM MANUTENCAO'
        WHEN T3."U_LOC1_Status" = 'T' THEN 'EM TRANSITO'
        ELSE 'NAO DEFINIDO'
    END AS "StatusLOC1",

    OS0."callID" AS "NumeroOS",
    OS0."DocNum" AS "DocumentoOS",
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

    OS0."U_MM_CC" AS "CentroCustoOS",
    OS0."U_MM_PV" AS "PedidoVendaOS",

    CUSTO."QtdDocumentosSaida" AS "QtdDocumentosSaida",
    CUSTO."QtdItensConsumidos" AS "QtdItensConsumidos",

    ROUND(IFNULL(CUSTO."CustoMaterial", 0), 2) AS "CustoMaterial",

    ROUND(IFNULL(LOC1C."CustoIncidente", 0), 2) AS "CustoIncidenteLOC1",
    ROUND(IFNULL(LOC1C."CustoOpcaoCompra", 0), 2) AS "CustoOpcaoCompraLOC1",
    ROUND(IFNULL(LOC1C."CustoCombustivel", 0), 2) AS "CustoCombustivelLOC1",

    ROUND(
        IFNULL(CUSTO."CustoMaterial", 0)
        + IFNULL(LOC1C."CustoIncidente", 0)
        + IFNULL(LOC1C."CustoOpcaoCompra", 0)
        + IFNULL(LOC1C."CustoCombustivel", 0),
        2
    ) AS "CustoTotalOS",

    T0."U_MM_PotencialKVA" AS "PotenciaKVA",
    T0."U_MM_ModelodoMotor" AS "ModeloMotor",
    T0."U_MM_MarcadoMotor" AS "MarcaMotor",
    T0."U_MM_Num_SerieMotor" AS "SerieMotor",
    T0."U_MM_Tensao" AS "Tensao",
    T0."U_MM_Horimetro" AS "HorimetroCadastro",
    T1."U_ICL_Horimeter" AS "HorimetroCartao",
    T0."U_MM_Serie_Item" AS "SerieItem",

    T0."CreateDate" AS "DataCadastro",

    CASE
        WHEN T0."validFor" = 'Y' THEN 'Ativo'
        ELSE 'Inativo'
    END AS "StatusCadastro"

FROM OITM T0

INNER JOIN OITB T4
    ON T0."ItmsGrpCod" = T4."ItmsGrpCod"

LEFT JOIN OINS T1
    ON T0."ItemCode" = T1."itemCode"

LEFT JOIN (
    SELECT
        E1."ItemCode",
        MAX(E1."DocEntry") AS "UltDocEntry"
    FROM IGN1 E1
    GROUP BY
        E1."ItemCode"
) ULT
    ON T0."ItemCode" = ULT."ItemCode"

LEFT JOIN IGN1 T2
    ON ULT."UltDocEntry" = T2."DocEntry"
    AND T0."ItemCode" = T2."ItemCode"

LEFT JOIN OSRN T3
    ON T0."ItemCode" = T3."ItemCode"

LEFT JOIN "@LOC1_SNMO" L1
    ON L1."U_ItemCode" = T0."ItemCode"
    AND L1."U_SysNumber" = T3."SysNumber"

LEFT JOIN OCTR CT
    ON CT."ContractID" = L1."U_ContractID"

LEFT JOIN "@LOC1_CTR3" LC3
    ON LC3."U_ContractID" = L1."U_ContractID"

LEFT JOIN OBPL BPL
    ON BPL."BPLId" = LC3."U_BPLId"

LEFT JOIN OSCL OS0
    ON OS0."insID" = T1."insID"

LEFT JOIN (
    SELECT
        S4."SrcvCallID" AS "NumeroOS",

        COUNT(DISTINCT S4."DocAbs") AS "QtdDocumentosSaida",
        COUNT(I1."LineNum") AS "QtdItensConsumidos",

        SUM(
            CASE
                WHEN IFNULL(I1."StockValue", 0) <> 0
                THEN IFNULL(I1."StockValue", 0)
                ELSE IFNULL(I1."LineTotal", 0)
            END
        ) AS "CustoMaterial"

    FROM SCL4 S4

    INNER JOIN OIGE G0
        ON G0."DocEntry" = S4."DocAbs"
        AND G0."CANCELED" = 'N'

    INNER JOIN IGE1 I1
        ON I1."DocEntry" = G0."DocEntry"

    WHERE
        S4."Object" = '60'

    GROUP BY
        S4."SrcvCallID"
) CUSTO
    ON CUSTO."NumeroOS" = OS0."callID"

LEFT JOIN (
    SELECT
        X."NumeroOS",

        SUM(X."CustoIncidente") AS "CustoIncidente",
        SUM(X."CustoOpcaoCompra") AS "CustoOpcaoCompra",
        SUM(X."CustoCombustivel") AS "CustoCombustivel"

    FROM (
        SELECT
            S5."U_callID" AS "NumeroOS",

            CASE
                WHEN IFNULL(S5."U_IncidentTotal", 0) <> 0
                THEN IFNULL(S5."U_IncidentTotal", 0)
                ELSE IFNULL(S5."U_IncidentAmount", 0) + IFNULL(S5."U_IncidentFine", 0)
            END AS "CustoIncidente",

            0 AS "CustoOpcaoCompra",
            0 AS "CustoCombustivel"

        FROM "@LOC1_SCL5" S5

        UNION ALL

        SELECT
            S6."U_callID" AS "NumeroOS",

            0 AS "CustoIncidente",

            CASE
                WHEN IFNULL(S6."U_PurOptTotal", 0) <> 0
                THEN IFNULL(S6."U_PurOptTotal", 0)
                ELSE
                    IFNULL(S6."U_PurOptValue", 0)
                    - IFNULL(S6."U_PurOptDiscount", 0)
                    + IFNULL(S6."U_PurOptFine", 0)
            END AS "CustoOpcaoCompra",

            0 AS "CustoCombustivel"

        FROM "@LOC1_SCL6" S6

        UNION ALL

        SELECT
            S3."U_callID" AS "NumeroOS",

            0 AS "CustoIncidente",
            0 AS "CustoOpcaoCompra",
            IFNULL(S3."U_FuelAmount", 0) AS "CustoCombustivel"

        FROM "@LOC1_SCL3" S3
    ) X

    GROUP BY
        X."NumeroOS"
) LOC1C
    ON LOC1C."NumeroOS" = OS0."callID"

WHERE
    T4."ItmsGrpNam" = 'ATIVO TERCEIRO'
    AND T0."ItemCode" LIKE 'T%'

ORDER BY
    T1."custmrName",
    CT."ContractID",
    T0."ItemCode",
    OS0."createDate";
