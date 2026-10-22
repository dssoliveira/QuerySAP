WITH LINHAS AS (
    SELECT
        L."DocEntry",

        CASE
            WHEN COUNT(DISTINCT IFNULL(L."Project", '')) <= 1 THEN MAX(L."Project")
            ELSE 'MULTIPLOS'
        END AS "Projeto",

        CASE
            WHEN COUNT(DISTINCT IFNULL(L."OcrCode", '')) <= 1 THEN MAX(L."OcrCode")
            ELSE 'MULTIPLOS'
        END AS "Departamento"

    FROM WTQ1 L
    GROUP BY
        L."DocEntry"
)

SELECT
    USR_CRIADOR."U_NAME" AS "Criado por - Nome Usuario",

    T0."DocNum" AS "Numero Pedido Transferencia",

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

    CASE
        WHEN UPPER(T0."BPLName") LIKE '%ENGENHARIA%' THEN 'Sistel Engenharia'
        WHEN UPPER(T0."BPLName") LIKE '%COMERCIO%' THEN 'Sistel Comercio'
        ELSE T0."BPLName"
    END AS "Empresa",

    OS."callID" AS "Numero OS",
    OS."itemCode" AS "Codigo Item OS",
    OS."itemName" AS "Descricao Item OS",
    OS."subject" AS "Assunto OS",

    CASE
        WHEN OS."status" = -3 THEN 'Aberto'
        WHEN OS."status" = -2 THEN 'Pendente'
        WHEN OS."status" = -1 THEN 'Fechado'
        ELSE TO_NVARCHAR(OS."status")
    END AS "Status OS",

    LINHAS."Projeto",
    PRJ."PrjName" AS "Nome Projeto",

    LINHAS."Departamento",
    CC."OcrName" AS "Nome Departamento",

    T0."DocTotal" AS "Valor Total Pedido Transferencia",

    T0."Comments" AS "Observacoes",
    T0."JrnlMemo" AS "Observacoes Diario",

    CAST(SUBSTRING(T0."U_MM_OBS_INTERNO", 1, 254) AS NVARCHAR(254)) AS "Observacoes Internas",

    T0."CreateDate" AS "Data Criacao",
    T0."CreateTS"   AS "Hora Criacao"

FROM OWTQ T0

LEFT JOIN LINHAS
    ON LINHAS."DocEntry" = T0."DocEntry"

LEFT JOIN OSCL OS
    ON OS."callID" = T0."U_MM_OS"

LEFT JOIN OPRJ PRJ
    ON PRJ."PrjCode" = LINHAS."Projeto"

LEFT JOIN OOCR CC
    ON CC."OcrCode" = LINHAS."Departamento"

LEFT JOIN OUSR USR_CRIADOR
    ON USR_CRIADOR."USERID" = T0."UserSign"

WHERE
    T0."DocStatus" = 'O'

ORDER BY
    T0."DocDueDate",
    T0."DocNum";
