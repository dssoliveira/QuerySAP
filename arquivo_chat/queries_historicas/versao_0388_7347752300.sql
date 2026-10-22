SELECT
    M."ItemCode"      AS "Codigo_Item",
    I."ItemName"      AS "Descricao_Item",
    M."DocDate"       AS "Data_Lancamento",
    M."TransType"     AS "Tipo_Tecnico",
    M."CreatedBy"     AS "Chave_Interna_Origem",
    M."DocLineNum"    AS "Linha_Documento",
    M."Warehouse"     AS "Deposito",
    M."InQty"         AS "Quantidade_Entrada",
    M."OutQty"        AS "Quantidade_Saida",
    M."TransValue"    AS "Valor_Movimento",
    M."CalcPrice"     AS "Custo_Unitario",
    M."Balance"       AS "Saldo_Apos_Movimento",
    M."TransNum"      AS "Numero_Transacao_Estoque"
FROM OINM M
INNER JOIN OITM I
    ON I."ItemCode" = M."ItemCode"
WHERE M."ItemCode" IN ('MA003838', 'MA004404', 'MA003628')
ORDER BY
    M."ItemCode",
    M."DocDate",
    M."TransNum",
    M."DocLineNum";
