PV_ICLASS_VALOR_AGR AS (
    SELECT
        B."NumeroOS",

        SUM(B."QuantidadeIClass") AS "QuantidadePVGeradoIClass",

        ROUND(
            SUM(B."QuantidadeIClass") / 60.0,
            2
        ) AS "HorasPVGeradoIClass",

        ROUND(
            (SUM(B."QuantidadeIClass") / 60.0) * 35.00,
            2
        ) AS "CustoHoraHomemPVGeradoIClass",

        SUM(B."ValorLinhaIClass") AS "ValorPVGeradoIClass"

    FROM PV_ICLASS_BASE B

    GROUP BY
        B."NumeroOS"
),
