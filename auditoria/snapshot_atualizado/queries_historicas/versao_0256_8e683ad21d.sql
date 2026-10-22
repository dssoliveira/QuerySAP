SELECT
    C."TABLE_NAME",
    C."COLUMN_NAME",
    C."DATA_TYPE_NAME",
    C."LENGTH",
    C."SCALE"
FROM "SYS"."TABLE_COLUMNS" C
WHERE
    C."SCHEMA_NAME" = CURRENT_SCHEMA
    AND (
        C."TABLE_NAME" IN (
            'OSCL',
            'OINS',
            'OITM',
            'OCTR',
            'RDR1',
            'ORDR',
            'OIGE',
            'IGE1',
            'OIGN',
            'IGN1'
        )
        OR C."TABLE_NAME" LIKE 'SCL%'
        OR C."TABLE_NAME" LIKE '@LOC1%'
    )
    AND (
        UPPER(C."COLUMN_NAME") LIKE '%CUST%'
        OR UPPER(C."COLUMN_NAME") LIKE '%COST%'
        OR UPPER(C."COLUMN_NAME") LIKE '%VALOR%'
        OR UPPER(C."COLUMN_NAME") LIKE '%VALUE%'
        OR UPPER(C."COLUMN_NAME") LIKE '%DESP%'
        OR UPPER(C."COLUMN_NAME") LIKE '%MATERIAL%'
        OR UPPER(C."COLUMN_NAME") LIKE '%MO%'
        OR UPPER(C."COLUMN_NAME") LIKE '%SERV%'
        OR UPPER(C."COLUMN_NAME") LIKE '%HOR%'
    )
ORDER BY
    C."TABLE_NAME",
    C."COLUMN_NAME";
