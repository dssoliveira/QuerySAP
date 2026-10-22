SELECT
    T0."DocEntry" AS "Chave interna do documento",
    T0."DocNum" AS "Nº do documento",

    CASE
        WHEN T0."DocStatus" = 'O' THEN 'Aberto'
        WHEN T0."DocStatus" = 'C' THEN 'Fechado'
        ELSE T0."DocStatus"
    END AS "Status Documento",

    T0."DocDate" AS "Data de lançamento",
    T0."DocDueDate" AS "Data de vencimento",
    T0."TaxDate" AS "Data do documento",

    CASE
        WHEN UPPER(IFNULL(BPL."BPLName", '')) LIKE '%ENGENHARIA%'
        THEN 'Sistel Engenharia'

        WHEN UPPER(IFNULL(BPL."BPLName", '')) LIKE '%COMERCIO%'
          OR UPPER(IFNULL(BPL."BPLName", '')) LIKE '%COMÉRCIO%'
        THEN 'Sistel Comercio'

        ELSE IFNULL(BPL."BPLName", 'Nao Definido')
    END AS "Filial",

    T0."CardCode" AS "Código PN",
    T0."CardName" AS "Nome PN",

    T0."Filler" AS "Código depósito origem",
    DPO."WhsName" AS "Depósito origem",

    T0."ToWhsCode" AS "Código depósito destino",
    DPD."WhsName" AS "Depósito destino",

    T0."U_MM_OS" AS "Ordem de Serviço",

    OS."subject" AS "Assunto OS",

    CASE
        WHEN OS."status" = -3 THEN 'Aberto'
        WHEN OS."status" = -2 THEN 'Pendente'
        WHEN OS."status" = -1 THEN 'Fechado'
        WHEN OS."status" = 1 THEN 'Aguardando Pecas'
        WHEN OS."status" = 2 THEN 'Encerrado IClass'
        WHEN OS."status" = 3 THEN 'Enviar IClass'
        WHEN OS."status" = 4 THEN 'Enviado IClass'
        WHEN OS."status" = 5 THEN 'Equipamento Parado'
        WHEN OS."status" IS NULL THEN ''
        ELSE 'Nao Definido'
    END AS "Status OS",

    T0."DocTotal" AS "Valor total transferência",

    T1."USER_CODE" AS "Código usuário",
    T1."U_NAME" AS "Nome usuário",

    T0."Comments" AS "Observações",
    CAST(SUBSTRING(T0."U_MM_OBS_INTERNO", 1, 254) AS NVARCHAR(254)) AS "Observações internas"

FROM OWTQ T0

INNER JOIN OUSR T1
    ON T0."UserSign" = T1."USERID"

LEFT JOIN OWHS DPO
    ON DPO."WhsCode" = T0."Filler"

LEFT JOIN OWHS DPD
    ON DPD."WhsCode" = T0."ToWhsCode"

LEFT JOIN OBPL BPL
    ON BPL."BPLId" = T0."BPLId"

LEFT JOIN OSCL OS
    ON OS."callID" = T0."U_MM_OS"

WHERE
    T0."DocStatus" = 'O'
    AND T1."USERID" = 11

ORDER BY
    T0."DocDueDate",
    T0."DocNum";
