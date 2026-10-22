WITH M AS
(
    SELECT
        1 AS "OrdemDepto",
        'Gerador' AS "Departamento",
        'GERADOR' AS "OcrCode",
        712000 AS "MetaJan", 712000 AS "MetaFev", 712000 AS "MetaMar",
        753000 AS "MetaAbr", 753000 AS "MetaMai", 753000 AS "MetaJun",
        838000 AS "MetaJul", 838000 AS "MetaAgo", 838000 AS "MetaSet",
        1029000 AS "MetaOut", 1031000 AS "MetaNov", 1031000 AS "MetaDez",
        10034000 AS "MetaAno",
        507091.15 AS "RetroJan",
        465528.46 AS "RetroFev"
    FROM DUMMY

    UNION ALL

    SELECT
        2, 'Nobreak', 'NOBREAK',
        135000, 135000, 135000,
        175000, 175000, 175000,
        228000, 228000, 228000,
        295000, 295000, 296000,
        2496000,
        167580.25,
        192585.73
    FROM DUMMY

    UNION ALL

    SELECT
        3, 'Locacao', 'LOCACAO',
        1318000, 1318000, 1318000,
        1396000, 1396000, 1396000,
        1554000, 1554000, 1554000,
        2121000, 2121000, 2121000,
        19167000,
        999929.41,
        1097137.99
    FROM DUMMY

    UNION ALL

    SELECT
        4, 'Execucao Eletrica', 'EXE_ELET',
        870000, 870000, 870000,
        972000, 972000, 972000,
        1364000, 1369000, 1369000,
        1624000, 1624000, 1624000,
        14500000,
        77793.41,
        369339.30
    FROM DUMMY

    UNION ALL

    SELECT
        5, 'Fotovoltaico', 'FOTOV',
        192000, 192000, 192000,
        220000, 220000, 220000,
        246500, 246500, 246500,
        308000, 308000, 308500,
        2900000,
        4112.88,
        0
    FROM DUMMY

    UNION ALL

    SELECT
        6, 'Revenda Direta', 'REV_DIRE',
        557000, 557000, 557000,
        591000, 591000, 591000,
        657000, 657000, 657000,
        823000, 825000, 825000,
        7888000,
        64000,
        0
    FROM DUMMY

    UNION ALL

    SELECT
        7, 'Seminovo', 'SEMINOVO',
        0, 0, 0,
        0, 0, 0,
        0, 0, 0,
        0, 0, 0,
        0,
        0,
        0
    FROM DUMMY

    UNION ALL

    SELECT
        8, 'FILIAL - SP', 'FILIALSP',
        NULL, NULL, NULL,
        NULL, NULL, NULL,
        NULL, NULL, NULL,
        NULL, NULL, NULL,
        NULL,
        NULL,
        NULL
    FROM DUMMY

    UNION ALL

    SELECT
        9, 'ENERGY CUBE', 'ENE_CUBE',
        NULL, NULL, NULL,
        NULL, NULL, NULL,
        NULL, NULL, NULL,
        NULL, NULL, NULL,
        NULL,
        NULL,
        NULL
    FROM DUMMY
),
