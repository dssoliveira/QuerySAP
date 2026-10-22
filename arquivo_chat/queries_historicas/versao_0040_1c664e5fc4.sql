SELECT
    "AliasID",
    "Descr",
    "TableID"
FROM CUFD
WHERE
    "TableID" = 'OPOR'
    AND (
        UPPER("Descr") LIKE '%OBS%'
        OR UPPER("Descr") LIKE '%INTERNA%'
        OR UPPER("AliasID") LIKE '%OBS%'
    );
