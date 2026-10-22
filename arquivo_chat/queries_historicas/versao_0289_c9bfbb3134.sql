SELECT
    /* =========================================================
       CONTRATO / EQUIPAMENTO
       ========================================================= */

    OS0."contractID" AS "Numero Contrato LOC1",

    EQ."insID" AS "Numero Cartao Equipamento",
    EQ."itemCode" AS "Codigo Equipamento",
    EQ."itemName" AS "Descricao Equipamento",
    EQ."manufSN" AS "Serie Fabricante",
    EQ."internalSN" AS "Numero Serie Interno",

    EQ."customer" AS "Codigo Cliente",
    EQ."custmrName" AS "Nome Cliente",

    EQ."status" AS "Status Cartao Codigo",

    CASE
        WHEN EQ."status" = 'A' THEN 'Ativo'
        WHEN EQ."status" = 'T' THEN 'Terminado'
        WHEN EQ."status" = 'R' THEN 'Renovado'
        WHEN EQ."status" = 'L' THEN 'Emprestado'
        ELSE 'Nao Definido'
    END AS "Status Cartao",

    EQ."U_ICL_Horimeter" AS "Horimetro Cartao",

    /* =========================================================
       ORDEM DE SERVICO
       ========================================================= */

    OS0."callID" AS "Numero OS",
    OS0."DocNum" AS "Documento OS",
    OS0."createDate" AS "Data Criacao OS",
    OS0."closeDate" AS "Data Fechamento OS",
    OS0."subject" AS "Assunto OS",

    OS0."status" AS "Status OS Codigo",

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
    END AS "Status OS",

    OS0."U_MM_PV" AS "Pedido Venda OS",
    OS0."U_MM_CC" AS "Centro Custo OS",

    /* =========================================================
       PEDIDO DE TRANSFERENCIA DE ESTOQUE
       ========================================================= */

    TR0."DocEntry" AS "DocEntry Transferencia",
    TR0."DocNum" AS "Pedido Transferencia",
    TR0."DocDate" AS "Data Pedido Transferencia",

    CASE
        WHEN TR0."DocStatus" = 'O' THEN 'Aberto'
        WHEN TR0."DocStatus" = 'C' THEN 'Fechado'
        ELSE TR0."DocStatus"
    END AS "Status Pedido Transferencia",

    CASE
        WHEN UPPER(IFNULL(TR0."BPLName", '')) LIKE '%ENGENHARIA%'
        THEN 'Sistel Engenharia'

        WHEN UPPER(IFNULL(TR0."BPLName", '')) LIKE '%COMERCIO%'
          OR UPPER(IFNULL(TR0."BPLName", '')) LIKE '%COMÉRCIO%'
        THEN 'Sistel Comercio'

        ELSE IFNULL(TR0."BPLName", 'Nao Definido')
    END AS "Filial Transferencia",

    TR0."Filler" AS "Deposito Origem Cabecalho",
    TR0."ToWhsCode" AS "Deposito Destino Cabecalho",
    TR0."Comments" AS "Observacoes Transferencia",

    /* =========================================================
       LINHAS / MATERIAL
       ========================================================= */

    TR1."LineNum" + 1 AS "Linha Transferencia",
    TR1."ItemCode" AS "Codigo Material",
    TR1."Dscription" AS "Descricao Material",
    TR1."Quantity" AS "Quantidade Material",
    TR1."Price" AS "Preco Unitario",
    TR1."LineTotal" AS "Valor Material Linha",

    TR1."FromWhsCod" AS "Deposito Origem Linha",
    TR1."WhsCode" AS "Deposito Destino Linha",
    TR1."OcrCode" AS "Centro Custo Linha",
    TR1."Project" AS "Projeto Linha",

    /* =========================================================
       TOTAIS DE AUDITORIA
       ========================================================= */

    SUM(TR1."LineTotal") OVER (
        PARTITION BY OS0."callID"
    ) AS "Custo Total Material OS",

    SUM(TR1."LineTotal") OVER (
        PARTITION BY EQ."insID"
    ) AS "Custo Total Vida Equipamento",

    CASE
        WHEN TR0."DocEntry" IS NULL
        THEN 'Sem pedido de transferencia vinculado a OS'
        ELSE 'OK: transferencia vinculada a OS'
    END AS "Auditoria Vinculo Transferencia"

FROM OSCL OS0

INNER JOIN OINS EQ
    ON EQ."insID" = OS0."insID"

LEFT JOIN OWTQ TR0
    ON TR0."U_MM_OS" = OS0."callID"
    AND TR0."CANCELED" = 'N'

LEFT JOIN WTQ1 TR1
    ON TR1."DocEntry" = TR0."DocEntry"

WHERE
    OS0."insID" IS NOT NULL

ORDER BY
    EQ."custmrName",
    EQ."itemCode",
    EQ."insID",
    OS0."callID",
    TR0."DocNum",
    TR1."LineNum";
