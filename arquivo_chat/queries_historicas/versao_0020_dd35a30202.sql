SELECT
    T0."DocNum"                         AS "Pedido Compra",
    T0."DocEntry"                       AS "DocEntry PC",
    T0."BPLId"                          AS "Codigo Filial",
    BPL."BPLName"                       AS "Nome Filial",
    T0."DocDate"                        AS "Data Lancamento PC",
    T0."TaxDate"                        AS "Data Documento PC",
    T0."DocDueDate"                     AS "Data Entrega PC",

    T0."CardCode"                       AS "Cod. Fornecedor",
    T0."CardName"                       AS "Nome Fornecedor",
