SELECT
    T2."OcrCode" AS "Centro de Custo",

    T0."ContractID" AS "Numero Contrato",
    T0."CstmrCode" AS "Codigo PN",
    T0."CstmrName" AS "Nome Parceiro",

    T0."StartDate" AS "Data Inicio",
    T0."EndDate" AS "Data Termino",

    DAYS_BETWEEN(CURRENT_DATE, T0."EndDate") AS "Dias Restantes",

    CASE
        WHEN DAYS_BETWEEN(CURRENT_DATE, T0."EndDate") <= 0 THEN 'Vencido'
        WHEN DAYS_BETWEEN(CURRENT_DATE, T0."EndDate") <= 30 THEN 'Vence em 30 dias'
        WHEN DAYS_BETWEEN(CURRENT_DATE, T0."EndDate") <= 60 THEN 'Vence em 60 dias'
        ELSE 'Ativo'
    END AS "Situacao",

    ROUND(
        T2."LineTotal" / NULLIF(T2."Quantity", 0),
        2
    ) AS "Valor Mensal Contrato",

    T2."Quantity" AS "Quantidade Parcelas",

    ROUND(
        T2."LineTotal",
        2
    ) AS "Valor Total Contrato",

    ROUND(
        CASE
            WHEN YEAR(CURRENT_DATE) = 2026
            THEN
                CASE
                    WHEN TO_DATE('2026-01-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                     AND IFNULL(T2."Quantity", 0) > 0
                     AND TO_DATE('2026-01-01', 'YYYY-MM-DD')
                         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                             AND ADD_MONTHS(
                                    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                    TO_INTEGER(T2."Quantity") - 1
                                 )
                    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                    ELSE 0
                END
                +
                CASE
                    WHEN TO_DATE('2026-02-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                     AND IFNULL(T2."Quantity", 0) > 0
                     AND TO_DATE('2026-02-01', 'YYYY-MM-DD')
                         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                             AND ADD_MONTHS(
                                    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                    TO_INTEGER(T2."Quantity") - 1
                                 )
                    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                    ELSE 0
                END
                +
                CASE
                    WHEN TO_DATE('2026-03-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                     AND IFNULL(T2."Quantity", 0) > 0
                     AND TO_DATE('2026-03-01', 'YYYY-MM-DD')
                         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                             AND ADD_MONTHS(
                                    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                    TO_INTEGER(T2."Quantity") - 1
                                 )
                    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                    ELSE 0
                END
                +
                CASE
                    WHEN TO_DATE('2026-04-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                     AND IFNULL(T2."Quantity", 0) > 0
                     AND TO_DATE('2026-04-01', 'YYYY-MM-DD')
                         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                             AND ADD_MONTHS(
                                    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                    TO_INTEGER(T2."Quantity") - 1
                                 )
                    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                    ELSE 0
                END
                +
                CASE
                    WHEN TO_DATE('2026-05-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                     AND IFNULL(T2."Quantity", 0) > 0
                     AND TO_DATE('2026-05-01', 'YYYY-MM-DD')
                         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                             AND ADD_MONTHS(
                                    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                    TO_INTEGER(T2."Quantity") - 1
                                 )
                    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                    ELSE 0
                END
                +
                CASE
                    WHEN TO_DATE('2026-06-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                     AND IFNULL(T2."Quantity", 0) > 0
                     AND TO_DATE('2026-06-01', 'YYYY-MM-DD')
                         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                             AND ADD_MONTHS(
                                    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                    TO_INTEGER(T2."Quantity") - 1
                                 )
                    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                    ELSE 0
                END
                +
                CASE
                    WHEN TO_DATE('2026-07-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                     AND IFNULL(T2."Quantity", 0) > 0
                     AND TO_DATE('2026-07-01', 'YYYY-MM-DD')
                         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                             AND ADD_MONTHS(
                                    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                    TO_INTEGER(T2."Quantity") - 1
                                 )
                    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                    ELSE 0
                END
                +
                CASE
                    WHEN TO_DATE('2026-08-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                     AND IFNULL(T2."Quantity", 0) > 0
                     AND TO_DATE('2026-08-01', 'YYYY-MM-DD')
                         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                             AND ADD_MONTHS(
                                    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                    TO_INTEGER(T2."Quantity") - 1
                                 )
                    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                    ELSE 0
                END
                +
                CASE
                    WHEN TO_DATE('2026-09-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                     AND IFNULL(T2."Quantity", 0) > 0
                     AND TO_DATE('2026-09-01', 'YYYY-MM-DD')
                         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                             AND ADD_MONTHS(
                                    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                    TO_INTEGER(T2."Quantity") - 1
                                 )
                    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                    ELSE 0
                END
                +
                CASE
                    WHEN TO_DATE('2026-10-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                     AND IFNULL(T2."Quantity", 0) > 0
                     AND TO_DATE('2026-10-01', 'YYYY-MM-DD')
                         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                             AND ADD_MONTHS(
                                    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                    TO_INTEGER(T2."Quantity") - 1
                                 )
                    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                    ELSE 0
                END
                +
                CASE
                    WHEN TO_DATE('2026-11-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                     AND IFNULL(T2."Quantity", 0) > 0
                     AND TO_DATE('2026-11-01', 'YYYY-MM-DD')
                         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                             AND ADD_MONTHS(
                                    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                    TO_INTEGER(T2."Quantity") - 1
                                 )
                    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                    ELSE 0
                END
                +
                CASE
                    WHEN TO_DATE('2026-12-01', 'YYYY-MM-DD') >= ADD_DAYS(CURRENT_DATE, 1 - DAYOFMONTH(CURRENT_DATE))
                     AND IFNULL(T2."Quantity", 0) > 0
                     AND TO_DATE('2026-12-01', 'YYYY-MM-DD')
                         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                             AND ADD_MONTHS(
                                    ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                                    TO_INTEGER(T2."Quantity") - 1
                                 )
                    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
                    ELSE 0
                END

            ELSE 0
        END,
        2
    ) AS "Previsto Ate Final Ano",

    CASE
        WHEN IFNULL(T2."Quantity", 0) > 0
         AND TO_DATE('2026-01-01', 'YYYY-MM-DD')
             BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                 AND ADD_MONTHS(
                        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                        TO_INTEGER(T2."Quantity") - 1
                     )
        THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
        ELSE 0
    END AS "01/2026",

    CASE
        WHEN IFNULL(T2."Quantity", 0) > 0
         AND TO_DATE('2026-02-01', 'YYYY-MM-DD')
             BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                 AND ADD_MONTHS(
                        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                        TO_INTEGER(T2."Quantity") - 1
                     )
        THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
        ELSE 0
    END AS "02/2026",

    CASE
        WHEN IFNULL(T2."Quantity", 0) > 0
         AND TO_DATE('2026-03-01', 'YYYY-MM-DD')
             BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                 AND ADD_MONTHS(
                        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                        TO_INTEGER(T2."Quantity") - 1
                     )
        THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
        ELSE 0
    END AS "03/2026",

    CASE
        WHEN IFNULL(T2."Quantity", 0) > 0
         AND TO_DATE('2026-04-01', 'YYYY-MM-DD')
             BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                 AND ADD_MONTHS(
                        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                        TO_INTEGER(T2."Quantity") - 1
                     )
        THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
        ELSE 0
    END AS "04/2026",

    CASE
        WHEN IFNULL(T2."Quantity", 0) > 0
         AND TO_DATE('2026-05-01', 'YYYY-MM-DD')
             BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                 AND ADD_MONTHS(
                        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                        TO_INTEGER(T2."Quantity") - 1
                     )
        THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
        ELSE 0
    END AS "05/2026",

    CASE
        WHEN IFNULL(T2."Quantity", 0) > 0
         AND TO_DATE('2026-06-01', 'YYYY-MM-DD')
             BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                 AND ADD_MONTHS(
                        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                        TO_INTEGER(T2."Quantity") - 1
                     )
        THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
        ELSE 0
    END AS "06/2026",

    CASE
        WHEN IFNULL(T2."Quantity", 0) > 0
         AND TO_DATE('2026-07-01', 'YYYY-MM-DD')
             BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                 AND ADD_MONTHS(
                        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                        TO_INTEGER(T2."Quantity") - 1
                     )
        THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
        ELSE 0
    END AS "07/2026",

    CASE
        WHEN IFNULL(T2."Quantity", 0) > 0
         AND TO_DATE('2026-08-01', 'YYYY-MM-DD')
             BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                 AND ADD_MONTHS(
                        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                        TO_INTEGER(T2."Quantity") - 1
                     )
        THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
        ELSE 0
    END AS "08/2026",

    CASE
        WHEN IFNULL(T2."Quantity", 0) > 0
         AND TO_DATE('2026-09-01', 'YYYY-MM-DD')
             BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                 AND ADD_MONTHS(
                        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                        TO_INTEGER(T2."Quantity") - 1
                     )
        THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
        ELSE 0
    END AS "09/2026",

    CASE
        WHEN IFNULL(T2."Quantity", 0) > 0
         AND TO_DATE('2026-10-01', 'YYYY-MM-DD')
             BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                 AND ADD_MONTHS(
                        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                        TO_INTEGER(T2."Quantity") - 1
                     )
        THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
        ELSE 0
    END AS "10/2026",

    CASE
        WHEN IFNULL(T2."Quantity", 0) > 0
         AND TO_DATE('2026-11-01', 'YYYY-MM-DD')
             BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                 AND ADD_MONTHS(
                        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                        TO_INTEGER(T2."Quantity") - 1
                     )
        THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
        ELSE 0
    END AS "11/2026",

    CASE
        WHEN IFNULL(T2."Quantity", 0) > 0
         AND TO_DATE('2026-12-01', 'YYYY-MM-DD')
             BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
                 AND ADD_MONTHS(
                        ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate")),
                        TO_INTEGER(T2."Quantity") - 1
                     )
        THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
        ELSE 0
    END AS "12/2026",

    T1."DocNum" AS "Pedido Venda",
    T1."Project" AS "Numero Projeto",
    T5."PrjName" AS "Tipo Projeto",
    T3."SlpName" AS "Vendedor",

    CASE
        WHEN UPPER(IFNULL(T4."BPLName", '')) LIKE '%ENGENHARIA%'
        THEN 'Sistel Engenharia'

        WHEN UPPER(IFNULL(T4."BPLName", '')) LIKE '%COMERCIO%'
          OR UPPER(IFNULL(T4."BPLName", '')) LIKE '%COMÉRCIO%'
        THEN 'Sistel Comercio'

        ELSE T4."BPLName"
    END AS "Filial",

    T2."OcrCode" AS "Departamento",

    T2."ItemCode" AS "Codigo Item",
    T2."Dscription" AS "Descricao Item",

    CASE
        WHEN T0."U_MM_Tipo_Contrato" = 0 THEN 'Ampliado'
        WHEN T0."U_MM_Tipo_Contrato" = 1 THEN 'Essencial'
        WHEN T0."U_MM_Tipo_Contrato" = 2 THEN 'Service'
        ELSE 'Nao Definido'
    END AS "Tipo Contrato",

    CASE
        WHEN T0."U_MM_Tipo_Contratacao" = 0 THEN 'Manutencao'
        WHEN T0."U_MM_Tipo_Contratacao" = 1 THEN 'Locacao'
        WHEN T0."U_MM_Tipo_Contratacao" = 2 THEN 'Abastecimento'
        ELSE 'Nao Definido'
    END AS "Tipo Contratacao",

    CASE
        WHEN T0."U_MM_Tipo_Ativo" = 0 THEN 'Ativo Proprio'
        WHEN T0."U_MM_Tipo_Ativo" = 1 THEN 'Ativo Terceiro'
        ELSE 'Nao Definido'
    END AS "Tipo Ativo",

    CASE
        WHEN T0."U_MM_Modelo_Contrato" = 0 THEN 'Publico'
        WHEN T0."U_MM_Modelo_Contrato" = 1 THEN 'Privado'
        ELSE 'Nao Definido'
    END AS "Publico Privado",

    CASE
        WHEN T0."U_MM_Preve_Material" = 0 THEN 'Previsto'
        WHEN T0."U_MM_Preve_Material" = 1 THEN 'Nao Previsto'
        ELSE 'Nao Definido'
    END AS "Fornecimento Material",

    CASE
        WHEN T0."U_MM_Periodicidade" = 0 THEN 'Mensal'
        WHEN T0."U_MM_Periodicidade" = 1 THEN 'Bimestral'
        WHEN T0."U_MM_Periodicidade" = 2 THEN 'Trimestral'
        WHEN T0."U_MM_Periodicidade" = 3 THEN 'Semestral'
        WHEN T0."U_MM_Periodicidade" = 4 THEN 'Anual'
        ELSE 'Nao Definido'
    END AS "Periodicidade Preventiva",

    CASE
        WHEN T0."U_MM_Checklist" = 0 THEN 'Semanal'
        WHEN T0."U_MM_Checklist" = 1 THEN 'Quinzenal'
        WHEN T0."U_MM_Checklist" = 2 THEN 'Mensal'
        WHEN T0."U_MM_Checklist" = 3 THEN 'Bimestral'
        WHEN T0."U_MM_Checklist" = 4 THEN 'Trimestral'
        WHEN T0."U_MM_Checklist" = 5 THEN 'Semestral'
        WHEN T0."U_MM_Checklist" = 6 THEN 'Anual'
        WHEN T0."U_MM_Checklist" = 7 THEN 'Sem Checklist'
        ELSE 'Nao Definido'
    END AS "Checklist Visitas",

    T0."U_MM_Area_Rota" AS "Area Rota",
    T0."U_MM_Macro_Regiao" AS "Macro Regiao",

    CASE
        WHEN T0."U_MM_Logsis" = 0 THEN 'Nao'
        WHEN T0."U_MM_Logsis" = 1 THEN 'Sim'
        ELSE 'Nao Definido'
    END AS "Monitoramento LOGSIS",

    CASE
        WHEN T0."U_MM_Integracao" = 0 THEN 'Nao Definido'
        WHEN T0."U_MM_Integracao" = 1 THEN 'Sim'
        WHEN T0."U_MM_Integracao" = 2 THEN 'Nao'
        ELSE 'Nao Definido'
    END AS "Integracao Tecnico",

    CASE
        WHEN T1."U_MM_PDB" = '0' THEN 'Nao'
        WHEN T1."U_MM_PDB" = '1' THEN 'Sim'
        ELSE 'Nao Definido'
    END AS "Passagem Bastao",

    CASE
        WHEN T1."U_MM_Passagem_Bastao" = '0' THEN 'PCP'
        WHEN T1."U_MM_Passagem_Bastao" = '1' THEN 'PCM'
        WHEN T1."U_MM_Passagem_Bastao" = '2' THEN 'Locacao'
        WHEN T1."U_MM_Passagem_Bastao" = '3' THEN 'Engenharia'
        ELSE 'Nao Definido'
    END AS "Passagem Bastao 2",

    CASE
        WHEN T1."DocEntry" IS NULL THEN 'Validar: sem pedido de venda vinculado'
        WHEN IFNULL(T2."Quantity", 0) = 0 THEN 'Validar: linha com quantidade zerada'
        WHEN IFNULL(T2."LineTotal", 0) = 0 AND IFNULL(T2."Quantity", 0) > 1 THEN 'Validar: quantidade maior que 1 com valor zerado'
        WHEN IFNULL(T2."LineTotal", 0) = 0 THEN 'Validar: linha com valor zerado'
        ELSE ''
    END AS "Alerta Auditoria",

    TO_VARCHAR(T2."LineNum") AS "LineNum SAP",

    T2."LineNum" + 1 AS "Linha Pedido",

    TO_VARCHAR(T0."ContractID")
        || ' | PV '
        || TO_VARCHAR(T1."DocNum")
        || ' | Linha '
        || TO_VARCHAR(T2."LineNum" + 1)
        || ' | '
        || T2."OcrCode" AS "Chave Auditoria"

FROM OCTR T0

LEFT JOIN (
    SELECT
        TL."U_ContractID",
        MAX(TO_INTEGER(TL."U_DocEntry")) AS "DocEntryPV"
    FROM "@LOC1_DOC" TL
    WHERE
        TL."U_DocTypeNum" = 17
    GROUP BY
        TL."U_ContractID"
) UD
    ON UD."U_ContractID" = T0."ContractID"

LEFT JOIN ORDR T1
    ON T1."DocEntry" = UD."DocEntryPV"

INNER JOIN RDR1 T2
    ON T2."DocEntry" = T1."DocEntry"

LEFT JOIN OSLP T3
    ON T3."SlpCode" = T1."SlpCode"

LEFT JOIN OBPL T4
    ON T4."BPLId" = T1."BPLId"

LEFT JOIN OPRJ T5
    ON T5."PrjCode" = T1."Project"

WHERE
    (
        T2."OcrCode" = '[%0]'
        OR '[%0]' = ''
    )
    AND T0."Status" = 'A'

ORDER BY
    T2."OcrCode",
    T0."EndDate",
    T0."ContractID",
    T2."LineNum";
