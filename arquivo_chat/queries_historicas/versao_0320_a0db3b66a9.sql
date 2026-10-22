SELECT
    T0."DocEntry" AS "Chave Interna do Documento",
    T0."DocNum"   AS "Numero Pedido Transferencia",

    CASE
        WHEN T0."DocStatus" = 'O' THEN 'Aberto'
        WHEN T0."DocStatus" = 'C' THEN 'Fechado'
        ELSE T0."DocStatus"
    END AS "Status Documento",

    CASE
        WHEN T0."CANCELED" = 'Y' THEN 'Sim'
        ELSE 'Nao'
    END AS "Cancelado",

    T0."DocDate"    AS "Data Lancamento",
    T0."DocDueDate" AS "Data Vencimento",
    T0."TaxDate"    AS "Data Documento",

    T0."CardCode" AS "Codigo Parceiro Negocio",
    T0."CardName" AS "Nome Parceiro Negocio",

    T0."BPLId"   AS "Codigo Filial",
    T0."BPLName" AS "Empresa / Filial",

    T0."U_MM_OS" AS "Numero OS",
    OS."DocNum"  AS "Documento OS",
    OS."subject" AS "Assunto OS",

    CASE
        WHEN OS."status" = -3 THEN 'Aberto'
        WHEN OS."status" = -2 THEN 'Pendente'
        WHEN OS."status" = -1 THEN 'Fechado'
        ELSE TO_NVARCHAR(OS."status")
    END AS "Status OS",

    T0."Filler"    AS "Do Deposito",
    WHS_ORIG."WhsName" AS "Nome Do Deposito",

    T0."ToWhsCode" AS "Para Deposito",
    WHS_DEST."WhsName" AS "Nome Para Deposito",

    T1."LineNum" + 1 AS "Linha",
    T1."ItemCode"    AS "Codigo Item",
    T1."Dscription"  AS "Descricao Item",
    T1."Quantity"    AS "Qtd Necessidade",
    T1."Price"       AS "Info Preco",
    T1."LineTotal"   AS "Total Linha",

    T1."Project" AS "Projeto",
    PRJ."PrjName" AS "Nome Projeto",

    T1."OcrCode" AS "Departamento",
    CC."OcrName" AS "Nome Departamento",

    T0."Comments" AS "Observacoes",
    T0."JrnlMemo" AS "Observacoes Diario",

    CAST(SUBSTRING(T0."U_MM_OBS_INTERNO", 1, 254) AS NVARCHAR(254)) AS "Observacoes Internas",

    T0."CreateDate" AS "Data Criacao",
    T0."CreateTS"   AS "Hora Criacao",

    USR_CRIADOR."USER_CODE" AS "Criado por - Codigo Usuario",
    USR_CRIADOR."U_NAME"    AS "Criado por - Nome Usuario",

    T0."UpdateDate" AS "Data Atualizacao",
    T0."UpdateTS"   AS "Hora Atualizacao",

    USR_ATUALIZADOR."USER_CODE" AS "Atualizado por - Codigo Usuario",
    USR_ATUALIZADOR."U_NAME"    AS "Atualizado por - Nome Usuario"

FROM OWTQ T0

INNER JOIN WTQ1 T1
    ON T1."DocEntry" = T0."DocEntry"

LEFT JOIN OSCL OS
    ON OS."callID" = T0."U_MM_OS"

LEFT JOIN OWHS WHS_ORIG
    ON WHS_ORIG."WhsCode" = T0."Filler"

LEFT JOIN OWHS WHS_DEST
    ON WHS_DEST."WhsCode" = T0."ToWhsCode"

LEFT JOIN OPRJ PRJ
    ON PRJ."PrjCode" = T1."Project"

LEFT JOIN OOCR CC
    ON CC."OcrCode" = T1."OcrCode"

LEFT JOIN OUSR USR_CRIADOR
    ON USR_CRIADOR."USERID" = T0."UserSign"

LEFT JOIN OUSR USR_ATUALIZADOR
    ON USR_ATUALIZADOR."USERID" = T0."UserSign2"

WHERE
    T0."DocStatus" = 'O'

ORDER BY
    T0."DocDueDate",
    T0."DocNum",
    T1."LineNum";
