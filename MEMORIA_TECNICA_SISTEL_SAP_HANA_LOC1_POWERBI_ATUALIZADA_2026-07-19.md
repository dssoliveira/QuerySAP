# Memoria Tecnica - Sistel SAP B1 HANA + LOC1 + Power BI

Data: 2026-05-27
Projeto: Base operacional e analitica de equipamentos, contratos LOC1 e contratos de manutencao
Responsavel operacional: Danilo Santos
Ambiente: SAP Business One HANA com addon LOC1 e IClass Field Service

---

## 1. Objetivo Desta Memoria

Este arquivo existe para transportar para outro Codex, outra maquina ou outra sessao todo o conhecimento tecnico e operacional construido durante o trabalho.

Nao e apenas um resumo. Ele deve funcionar como memoria persistente do projeto contendo:

- conceitos descobertos;
- tabelas SAP B1 HANA usadas;
- tabelas especificas LOC1 validadas;
- relacionamentos confiaveis;
- erros evitados;
- decisoes tecnicas;
- queries e padroes usados;
- estrategia de exportacao para Power BI;
- proximos passos.

---

## 2. Contexto Operacional

Empresa: Sistel Energia Confiavel

ERP: SAP Business One HANA

Addons envolvidos:

- LOC1
- IClass Field Service

Area operacional principal:

- Geradores
- Nobreaks
- Contratos de manutencao preventiva e corretiva
- Ativos de terceiros
- Locacao/manutencao de equipamentos

Objetivo analitico:

- Construir relatorios confiaveis para equipamentos e contratos.
- Saber quais maquinas existem.
- Saber caracteristicas tecnicas das maquinas.
- Saber cliente, TAG, status LOC1, contrato e filial.
- Levar dados brutos para Power BI.
- Evitar joins que multipliquem linhas ou distorcam totais.

---

## 3. Principio Mais Importante Descoberto

O nucleo operacional real do LOC1 nao e o contrato SAP (`OCTR`) e sim a combinacao de:

- `OSRN`
- `@LOC1_SNMO`

`OSRN` contem o status LOC1/TAG do item serializado.

`@LOC1_SNMO` contem o vinculo LOC1 entre:

- item;
- numero de sistema/serie;
- status LOC1;
- contrato LOC1;
- documento SAP relacionado.

Portanto, para descobrir se uma maquina esta em contrato, nao se deve comecar pelo cliente ou por `OCTR.CstmrCode`. Deve-se usar o status e relacionamento operacional do LOC1.

---

## 4. Tabelas SAP B1 / LOC1 Mapeadas

### 4.1 OITM - Cadastro de Item / Equipamento

Funcao:

Cadastro principal da maquina/equipamento.

Campos usados:

- `ItemCode`: codigo da maquina. Exemplo: `T0000546`.
- `ItemName`: descricao da maquina.
- `ItmsGrpCod`: grupo do item.
- `CreateDate`: data de cadastro.
- `validFor`: ativo/inativo no cadastro.
- `U_MM_Horimetro`: horimetro no cadastro.
- `U_MM_PotencialKVA`: potencia.
- `U_MM_ModelodoMotor`: modelo do motor.
- `U_MM_MarcadoMotor`: marca do motor.
- `U_MM_Num_SerieMotor`: serie do motor.
- `U_MM_Tensao`: tensao.
- `U_MM_CARENAGEM`: tipo de carenagem.
- `U_MM_Serie_Item`: serie item.
- `U_TpEquip`: tipo de equipamento.

Regra para ativos de terceiros:

```sql
T0."ItemCode" LIKE 'T%'
```

---

### 4.2 OITB - Grupo de Item

Funcao:

Tabela de grupos de itens.

Relacionamento:

```sql
OITM."ItmsGrpCod" = OITB."ItmsGrpCod"
```

Filtro homologado:

```sql
OITB."ItmsGrpNam" = 'ATIVO TERCEIRO'
```

---

### 4.3 OINS - Cartao de Equipamento

Funcao:

Cartao de equipamento. Representa vinculo operacional do equipamento com cliente.

Relacionamento homologado:

```sql
OITM."ItemCode" = OINS."itemCode"
```

Campos usados:

- `insID`: numero do cartao do equipamento.
- `customer`: codigo do cliente.
- `custmrName`: nome do cliente.
- `itemCode`: codigo do equipamento.
- `U_ICL_Horimeter`: horimetro no cartao.

Observacao:

Nem todo equipamento tem cartao/cliente preenchido. Por isso, normalmente usar `LEFT JOIN`.

---

### 4.4 IGN1 - Linhas de Entrada de Mercadoria

Funcao:

Usada para buscar departamento operacional e deposito de entrada.

Relacionamento inicial:

```sql
OITM."ItemCode" = IGN1."ItemCode"
```

Campos importantes:

- `ItemCode`: item.
- `DocEntry`: documento de entrada.
- `OcrCode`: regra de distribuicao/departamento principal.
- `OcrCode2` a `OcrCode5`: outras dimensoes de regra de distribuicao.
- `WhsCode`: deposito.

Descoberta:

`IGN1` pode ter varias linhas para o mesmo item. Fazer `JOIN` direto pode multiplicar linhas.

Para o relatorio bruto final, foi decidido nao filtrar por parametro `[%0]`, e tratar departamento no BI depois.

Foi tambem removido o uso de `OcrCode2` a `OcrCode5` do relatorio final porque eram campos desnecessarios visualmente.

---

### 4.5 OIGN - Cabecalho da Entrada de Mercadoria

Funcao:

Cabecalho da entrada de mercadoria.

Relacionamento:

```sql
IGN1."DocEntry" = OIGN."DocEntry"
```

Campos usados:

- `DocNum`: numero do documento de entrada.
- `DocDate`: data da entrada.

Observacao importante:

Quando `DocNum` era calculado com `MAX(T5."DocNum")`, o SAP perdia a seta/atalho para abrir o documento. Para manter chance de seta, e melhor trazer `T5."DocNum"` diretamente, evitando agregacao.

---

### 4.6 OSRN - Seriais / TAG / Status LOC1

Funcao:

Tabela mais importante para status operacional LOC1.

Relacionamento homologado:

```sql
OITM."ItemCode" = OSRN."ItemCode"
```

Campos usados:

- `ItemCode`: codigo do item.
- `SysNumber`: numero interno do serial no SAP.
- `DistNumber`: TAG / numero de serie operacional.
- `MnfSerial`: serie fabricante.
- `U_LOC1_Status`: status operacional LOC1.

Status LOC1 validado:

| Codigo | Significado |
|---|---|
| C | Em contrato |
| A | Disponivel |
| D | Disponivel/desmobilizado |
| M | Em manutencao |
| T | Em transito |

Traducao usada:

```sql
CASE
    WHEN T3."U_LOC1_Status" = 'C' THEN 'EM CONTRATO'
    WHEN T3."U_LOC1_Status" = 'A' THEN 'DISPONIVEL'
    WHEN T3."U_LOC1_Status" = 'D' THEN 'DISPONIVEL'
    WHEN T3."U_LOC1_Status" = 'M' THEN 'EM MANUTENCAO'
    WHEN T3."U_LOC1_Status" = 'T' THEN 'EM TRANSITO'
    ELSE 'NAO DEFINIDO'
END
```

---

### 4.7 @LOC1_SNMO - Movimento/Status LOC1 do Serial

Funcao:

Tabela especifica LOC1 que vincula item, serial/SysNumber, status, contrato e documento.

Foi a descoberta-chave para trazer o numero do contrato certo da tela LOC1.

Campos validados:

- `Code`
- `Name`
- `U_ContractID`
- `U_ItemCode`
- `U_SysNumber`
- `U_LOC1_Status`
- `U_DocEntry`
- `U_DocTypeNum`

Consulta de validacao:

```sql
SELECT
    L1."Code",
    L1."Name",
    L1."U_ContractID",
    L1."U_ItemCode",
    L1."U_SysNumber",
    L1."U_LOC1_Status",
    L1."U_DocEntry",
    L1."U_DocTypeNum"
FROM "@LOC1_SNMO" L1
WHERE L1."U_ItemCode" = 'T0000546'
```

Resultado para `T0000546`:

- `U_ContractID = 134`
- `U_ItemCode = T0000546`
- `U_SysNumber = 1`
- `U_LOC1_Status = C`
- `U_DocEntry = 121`
- `U_DocTypeNum = 191`

Relacionamento com `OSRN`:

```sql
LEFT JOIN "@LOC1_SNMO" L1
    ON L1."U_ItemCode" = T0."ItemCode"
    AND L1."U_SysNumber" = T3."SysNumber"
```

---

### 4.8 OCTR - Contratos SAP / Contrato de Servico

Funcao:

Contrato SAP. Usado para permitir seta/atalho para abrir contrato no SAP.

Campo-chave:

- `ContractID`

Relacionamento correto com LOC1:

```sql
LEFT JOIN OCTR CT
    ON CT."ContractID" = L1."U_ContractID"
```

Importante:

Nao usar simplesmente:

```sql
OCTR."CstmrCode" = ORDR."CardCode"
```

Isso multiplica pedidos/contratos do cliente e distorce o relatorio.

---

### 4.9 ORDR / RDR1 - Pedido de Venda

Funcao:

Usadas na query de contratos de manutencao para puxar pedido, projeto, vendedor e linhas financeiras.

Relacionamento usado nos contratos:

O pedido original esta referenciado na descricao do contrato, como `Pedido de Venda` / `Venda`.

Join usado:

```sql
LEFT JOIN ORDR T1
ON T1."DocEntry" = TO_INTEGER(
    REPLACE(
        SUBSTRING(
            T0."Descriptio",
            LOCATE(T0."Descriptio", 'Venda ')
        ),
        'Venda ',
        ''
    )
)
```

Linha de pedido:

```sql
LEFT JOIN RDR1 T2
ON T1."DocEntry" = T2."DocEntry"
AND T2."LineNum" = 0
```

Observacao:

A query considera linha `0`. Se futuramente houver contratos com valores em outras linhas, revisar.

---

### 4.10 OBPL - Filial

Funcao:

Tabela de filiais.

Campos:

- `BPLId`
- `BPLName`

Para contratos LOC1, tentou-se `OCTR.BPLId`, mas este campo nao existe no ambiente.

A filial do contrato LOC1 apareceu em estrutura LOC1, especialmente `@LOC1_CTR3.U_BPLId`.

Mapa identificado por metadados:

- `@LOC1_CTR3.U_BPLId`
- `@LOC1_CTR3.U_ContractID`

Join tentado:

```sql
LEFT JOIN "@LOC1_CTR3" LC3
    ON LC3."U_ContractID" = L1."U_ContractID"

LEFT JOIN OBPL BPL
    ON BPL."BPLId" = LC3."U_BPLId"
```

Observacao:

Houve erro antigo por trecho residual `CT."BPLId"`. Confirmar que a query final nao contem `CT."BPLId"`.

---

## 5. Armadilhas e Erros Que Ja Foram Encontrados

### 5.1 Parametro `[%0]` no SAP Query Manager

Quando usamos:

```sql
'[%0]' AS "Departamento"
```

ou parametros em lugares inadequados, o SAP abriu uma janela com rotulo errado, como `Nome do parceiro de negocios`.

O parametro deve ser usado somente no filtro, exemplo:

```sql
T2."OcrCode" = '[%0]'
```

Depois foi decidido remover o filtro de departamento e tratar no BI.

---

### 5.2 Subquery Correlacionada com TOP / ORDER BY

Erro encontrado:

`correlated subquery cannot have TOP or ORDER BY`

Isso ocorreu ao tentar buscar ultima entrada com `TOP 1` dentro de subquery correlacionada.

Solucao parcial:

Usar derived table com `MAX(DocEntry)` ou simplificar para trazer documento diretamente.

---

### 5.3 UNION ALL Remove Setas do SAP

Foi testado criar linha `TOTAL GERAL` no mesmo relatorio de contratos com `UNION ALL`.

Funcionou para totalizar, mas removeu todas as setas de atalho do SAP.

Decisao:

- Relatorio principal detalhado deve ficar sem subtotal para preservar setas.
- Criar relatorio separado apenas para resumo/subtotal.

---

### 5.4 MAX em Campo de Documento Remove Navegabilidade

Quando `UltDocEntrada` foi trazido como:

```sql
MAX(T5."DocNum") AS "UltDocEntrada"
```

o SAP nao mostrou seta de atalho.

Para ter chance de seta, trazer diretamente:

```sql
T5."DocNum" AS "UltDocEntrada"
```

---

### 5.5 Campos Numericos no Power BI Somam Sozinhos

Power BI identifica campos como contrato, pedido e projeto como numeros e tenta somar.

Regra decidida:

- Codigo, contrato, pedido, projeto, PN, TAG = Texto.
- Valor, quantidade, dias, potencia, horimetro = Numero.

No Power BI: para campos identificadores, definir tipo Texto e/ou `Nao resumir`.

---

## 6. Estrategia de Exportacao Para Power BI

Nao foi possivel instalar SAP HANA Client/ODBC na maquina do usuario.

Portanto, conexao direta Power BI -> HANA ficou bloqueada.

Estrategia adotada:

```text
SAP Query Manager -> Copiar dados -> PowerShell -> CSV limpo no OneDrive -> Power BI
```

Pasta padrao:

```text
C:\Users\danilo.santos\OneDrive\BI_SAP_LOC1
```

Arquivos:

- `equipamentos_loc1.csv`
- `contratos_manutencao.csv`
- `atualizar_base_sap.ps1`
- `atualizar_contratos_manutencao.ps1`
- `backup\`

Formato CSV escolhido:

- delimitador `;`
- UTF-8 com BOM
- sem coluna `#`
- sem colunas vazias sem cabecalho

---

## 7. Scripts Criados

### 7.1 atualizar_base_sap.ps1

Caminho:

```text
C:\Users\danilo.santos\OneDrive\BI_SAP_LOC1\atualizar_base_sap.ps1
```

Gera:

```text
C:\Users\danilo.santos\OneDrive\BI_SAP_LOC1\equipamentos_loc1.csv
```

Uso:

1. Executar query de equipamentos no SAP.
2. Clicar `Copiar dados`.
3. Rodar `atualizar_base_sap.ps1`.

---

### 7.2 atualizar_contratos_manutencao.ps1

Caminho:

```text
C:\Users\danilo.santos\OneDrive\BI_SAP_LOC1\atualizar_contratos_manutencao.ps1
```

Gera:

```text
C:\Users\danilo.santos\OneDrive\BI_SAP_LOC1\contratos_manutencao.csv
```

Uso:

1. Executar query `MM - LISTA CONTRATOS DE MANUTENCAO` no SAP.
2. Clicar `Copiar dados`.
3. Rodar `atualizar_contratos_manutencao.ps1`.

---

## 8. Power BI - Estado Atual

O usuario carregou:

- `contratos_manutencao`
- `equipamentos_loc1`

No Power Query:

- apagar etapa automatica ruim `Tipo Alterado` quando necessario;
- definir tipos manualmente;
- usar localidade Portugues (Brasil) para decimal/data quando necessario.

Relacionamento futuro sugerido:

```text
Equipamentos_LOC1[NumeroContratoLOC1]
Contratos_Manutencao[Numero Contrato]
```

Ambos como Texto.

---

## 9. Query Resumo - Contratos de Manutencao

Decisao: criar relatorio separado no SAP para subtotal, preservando setas no relatorio detalhado.

Nome sugerido:

```text
MM - LISTA CONTRATOS DE MANUTENCAO - RESUMO
```

Query:

```sql
SELECT

    COUNT(DISTINCT T0."ContractID")          AS "Quantidade Contratos",

    ROUND(
        SUM(
            T2."LineTotal" / NULLIF(T2."Quantity",0)
        ),
        2
    )                                        AS "Valor Mensal Total",

    ROUND(
        SUM(T2."LineTotal"),
        2
    )                                        AS "Valor Total Contratos",

    ROUND(
        SUM(
            CASE

                WHEN T0."EndDate" < CURRENT_DATE
                THEN 0

                WHEN T2."Quantity" = 1
                THEN T2."LineTotal"

                ELSE
                    (
                        T2."LineTotal"
                        /
                        NULLIF(T2."Quantity",0)
                    )
                    *
                    CASE

                        WHEN YEAR(T0."EndDate") = YEAR(CURRENT_DATE)
                        THEN
                            CASE
                                WHEN
                                    (
                                        MONTH(T0."EndDate")
                                        - MONTH(CURRENT_DATE)
                                    ) <= 0
                                THEN 1

                                ELSE
                                    (
                                        MONTH(T0."EndDate")
                                        - MONTH(CURRENT_DATE)
                                    )
                            END

                        ELSE
                            (
                                12 - MONTH(CURRENT_DATE)
                            )
                    END
            END
        ),
        2
    )                                        AS "Previsto Ate Final Ano"

FROM OCTR T0

LEFT JOIN ORDR T1
ON T1."DocEntry" = TO_INTEGER(
    REPLACE(
        SUBSTRING(
            T0."Descriptio",
            LOCATE(T0."Descriptio", 'Venda ')
        ),
        'Venda ',
        ''
    )
)

LEFT JOIN RDR1 T2
ON T1."DocEntry" = T2."DocEntry"
AND T2."LineNum" = 0

WHERE
    T0."Status" = 'A'
    AND T0."Descriptio" LIKE '%Pedido de Venda%'
    AND T2."OcrCode" = '[%0]'
```

---

## 10. Regras de Decisao Para Continuar

1. Evitar joins por cliente quando o objetivo for contrato de item/equipamento.
2. Preferir `OSRN + @LOC1_SNMO` para status e contrato real LOC1.
3. Usar `OCTR.ContractID` para tentar manter seta do contrato no SAP.
4. Evitar `UNION ALL` no relatorio detalhado se as setas forem importantes.
5. Evitar `MAX` em documento quando for importante manter seta de atalho.
6. No Power BI, manter CSV sem linha total. Totais devem ser DAX.
7. No SAP, se quiser subtotal, criar consulta resumo separada.
8. Sempre cuidar de cardinalidade: `IGN1`, `RDR1`, `@LOC1_CTR*` podem multiplicar linhas.

---

## 11. Como Levar Para Outra Maquina / Outro Codex

Na outra maquina:

1. Abrir este arquivo:

```text
C:\Users\danilo.santos\OneDrive\BI_SAP_LOC1\MEMORIA_TECNICA_SISTEL_SAP_HANA_LOC1_POWERBI.md
```

2. Anexar ou colar no Codex.
3. Pedir:

```text
Leia esta memoria tecnica e continue o projeto SAP B1 HANA + LOC1 + Power BI a partir dela.
```

4. Se necessario, anexar tambem:

```text
C:\Users\danilo.santos\OneDrive\BI_SAP_LOC1\codex_handoff_sistel_sap_loc1.md
```

---

## 12. Estado Mental Do Projeto

O projeto saiu de consultas exploratorias no SAP para uma arquitetura operacional mais madura:

- SAP Query Manager continua sendo fonte primaria de extracao.
- LOC1 foi entendido em pontos-chave.
- A tabela `@LOC1_SNMO` foi descoberta e validada como origem do contrato LOC1 por item/serial.
- Power BI sera alimentado por CSV limpo no OneDrive enquanto nao houver driver HANA/gateway.
- Queries detalhadas devem priorizar navegabilidade/setas no SAP.
- Agregacoes, subtotais e KPIs devem ser feitos em relatorios separados ou no Power BI.

---

# Atualizacao Tecnica - Julho/2026

Data da atualizacao: 2026-07-19

Objetivo desta atualizacao:

Registrar os aprendizados tecnicos e operacionais das ultimas queries desenvolvidas no SAP Business One HANA, especialmente:

- contratos de manutencao com previsao mensal ate 2027;
- filtros opcionais no Query Manager;
- auditoria por centro de custo e linha do pedido;
- relatorio analitico de compras por fornecedor;
- relatorio de pedidos avulsos de venda;
- boas praticas para evitar erros de sintaxe, cardinalidade e colunas duplicadas.

Esta atualizacao deve ser lida junto com a memoria original acima. Quando houver conflito entre uma regra antiga e uma regra desta atualizacao, considerar como vigente a regra mais nova registrada aqui.

---

## 13. Atualizacao Importante Sobre Contratos de Manutencao

### 13.1 Regra antiga superada

Na memoria original havia uma observacao de que a query de contratos usava:

```sql
AND T2."LineNum" = 0
```

Essa regra foi util inicialmente, mas foi superada.

Motivo:

Nem sempre o valor relevante do contrato esta apenas na linha 0 do pedido. Alem disso, um mesmo pedido/contrato pode ter mais de uma linha, inclusive com centros de custo diferentes.

### 13.2 Nova regra homologada

A granularidade correta para o relatorio analitico de contratos de manutencao passou a ser:

```text
1 linha do relatorio = 1 linha do pedido de venda = 1 centro de custo
```

Portanto:

- nao filtrar mais `RDR1.LineNum = 0`;
- trazer cada linha do pedido separadamente;
- se o contrato tiver duas linhas do mesmo centro de custo, trazer duas linhas;
- se o contrato tiver centros de custo diferentes, cada centro deve aparecer na sua propria linha;
- quando o relatorio for filtrado por centro de custo, trazer somente as linhas daquele centro.

Racional operacional:

O objetivo e auditar por centro de custo. Portanto nao faz sentido juntar linhas de centros diferentes nem agregar o contrato inteiro em uma unica linha quando a separacao operacional esta na linha do pedido.

---

## 14. Relatorio Avancado de Contratos de Manutencao

### 14.1 Fonte principal

Tabelas principais usadas:

- `OCTR` - contrato de servico;
- `@LOC1_DOC` - vinculo LOC1 entre contrato e documento SAP;
- `ORDR` - pedido de venda;
- `RDR1` - linhas do pedido de venda;
- `OSLP` - vendedor;
- `OBPL` - filial;
- `OPRJ` - projeto.

Relacionamento validado para localizar o pedido de venda do contrato:

```sql
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
```

Observacao:

Este relacionamento substitui, quando possivel, a tecnica antiga de extrair o `DocEntry` de dentro da descricao do contrato (`OCTR.Descriptio`). A extracao por texto e mais fragil.

### 14.2 Join de linhas do pedido

Regra atual:

```sql
INNER JOIN RDR1 T2
    ON T2."DocEntry" = T1."DocEntry"
```

Nao usar:

```sql
AND T2."LineNum" = 0
```

### 14.3 Centro de custo

Na versao final do relatorio de contratos, a coluna inicial deve ser apenas:

```sql
T2."OcrCode" AS "Centro de Custo"
```

Nao trazer duas colunas como:

- `Centro de Custo` com descricao;
- `Codigo Centro Custo` com codigo.

O usuario decidiu que a coluna deve mostrar somente o codigo do centro de custo, com o nome da coluna:

```text
Centro de Custo
```

Centros auditados no relatorio:

- `EXE_ELET`
- `GERADOR`
- `LOCACAO`
- `NOBREAK`

Tambem foram tratados em outras queries:

- `FOTOV`
- `REV_DIRE`

### 14.4 Filtro opcional por centro de custo no Query Manager

Regra homologada para permitir:

- se preencher o parametro, filtra um centro de custo;
- se deixar em branco, traz todos.

Usar no `WHERE`:

```sql
WHERE
    (
        T2."OcrCode" = '[%0]'
        OR '[%0]' = ''
    )
    AND T0."Status" = 'A'
```

Ponto critico:

O primeiro uso do parametro `[%0]` deve estar diretamente associado ao campo que se deseja que o SAP reconheca na caixa de selecao. Neste caso:

```sql
T2."OcrCode" = '[%0]'
```

Evitar como primeira ocorrencia:

```sql
LENGTH(TRIM('[%0]')) = 0
```

ou:

```sql
'[%0]' = ''
```

Motivo:

O SAP Query Manager pode inferir o campo errado na caixa de criterio. Em teste, ele chegou a abrir a caixa como `Status contrato` em vez de centro de custo.

### 14.5 Evitar CTE `WITH` no Query Manager

Foi testado usar `WITH` em query de contratos, mas o SAP Business One Query Manager retornou erro de sintaxe na linha 1:

```text
Syntax error or access violation;257 sql syntax error: line 1 col 8
```

Regra operacional:

Evitar CTEs (`WITH`) nas queries do SAP B1 Query Manager deste ambiente.

Preferir subconsultas derivadas:

```sql
LEFT JOIN (
    SELECT ...
) X
    ON ...
```

### 14.6 Filial simplificada

Para relatorios gerenciais, nao trazer o nome completo da filial. Usar nome simplificado:

```sql
CASE
    WHEN UPPER(IFNULL(T4."BPLName", '')) LIKE '%ENGENHARIA%' THEN 'Sistel Engenharia'
    WHEN UPPER(IFNULL(T4."BPLName", '')) LIKE '%COMERCIO%' THEN 'Sistel Comercio'
    ELSE T4."BPLName"
END AS "Filial"
```

### 14.7 Colunas removidas por nao existirem no SAP

As colunas abaixo existiam na planilha online, mas nao existem ainda como campos sistemicos no SAP:

- `Periodicidade de faturamento`
- `Inicio de faturamento`

Decisao:

Nao trazer essas colunas na query ate que sejam criados campos oficiais no SAP.

### 14.8 Colunas removidas por duplicidade

Foram removidas do relatorio final:

- `Preco Unitario Linha`
- `Total Linha Pedido`

Motivo:

Ja existem as colunas principais:

- `Valor Mensal Contrato`
- `Quantidade Parcelas`
- `Valor Total Contrato`

As colunas de preco/total da linha estavam duplicando a informacao e poluindo a visualizacao.

### 14.9 Auditoria por linha

Apesar de remover preco e total da linha, a rastreabilidade foi preservada com as colunas finais:

- `Alerta Auditoria`
- `LineNum SAP`
- `Linha Pedido`
- `Chave Auditoria`

Padrao:

```sql
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
```

### 14.10 Resultado homologado do relatorio de contratos sem filtro

Resultado validado em 2026-07:

| Centro de Custo | Linhas | Contratos | Valor Mensal | Valor Total | Previsto Ano | Alertas |
|---|---:|---:|---:|---:|---:|---:|
| EXE_ELET | 30 | 30 | 59.310,02 | 879.465,06 | 205.908,68 | 1 |
| GERADOR | 179 | 177 | 479.563,66 | 6.325.535,53 | 1.218.871,58 | 1 |
| LOCACAO | 259 | 169 | 2.432.801,17 | 18.883.060,81 | 4.074.854,76 | 1 |
| NOBREAK | 9 | 9 | 35.095,26 | 462.733,68 | 103.541,67 | 0 |

Totais gerais:

| Metrica | Total |
|---|---:|
| Linhas | 477 |
| Contratos distintos | 385 |
| Valor mensal total | 3.006.770,11 |
| Valor total contratos | 26.550.795,08 |
| Previsto ate final do ano | 5.603.176,69 |
| Alertas | 3 |

### 14.11 Alertas de auditoria conhecidos e interpretacao

Alertas encontrados:

| Centro | Contrato | Parceiro | PV | Linha | Alerta | Interpretacao operacional |
|---|---:|---|---:|---:|---|---|
| GERADOR | 129 | SUPER MERCADO SAO ROQUE LTDA. | 11 | 1 | quantidade maior que 1 com valor zerado | erro real a validar |
| EXE_ELET | 212 | ACCO BRANDS BRASIL LTDA. | 583 | 1 | linha com valor zerado | contrato guarda-chuva / sem valor monetario, validado pelo usuario |
| LOCACAO | 517 | CALI CLUB EVENTOS LTDA | 6584 | 2 | linha com valor zerado | excecao sem cobranca, validada pelo usuario |

### 14.12 Linha do tempo mensal de previsao

Foi criada previsao mensal de faturamento de `01/2026` ate `12/2027`.

Regra adotada:

Para cada mes, se o primeiro dia do mes estiver dentro da vigencia mensal do contrato, trazer o valor mensal:

```sql
ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
```

Caso contrario, trazer zero.

Padrao usado:

```sql
CASE
    WHEN TO_DATE('2026-01-01', 'YYYY-MM-DD')
         BETWEEN ADD_DAYS(T0."StartDate", 1 - DAYOFMONTH(T0."StartDate"))
             AND ADD_DAYS(T0."EndDate", 1 - DAYOFMONTH(T0."EndDate"))
    THEN ROUND(T2."LineTotal" / NULLIF(T2."Quantity", 0), 2)
    ELSE 0
END AS "01/2026"
```

Observacao importante:

Essa regra e uma aproximacao sistemica mensal. Ela nao considera ainda periodicidade real de faturamento quando esta informacao existe apenas em planilha externa.

---

## 15. Relatorio de Pedidos Avulsos de Venda

### 15.1 Objetivo do relatorio

Relatorio de pedidos avulsos lancados no SAP.

Base:

- `ORDR` - pedido de venda;
- `RDR1` - linhas do pedido;
- `OINV` / `INV1` - notas fiscais geradas a partir do pedido;
- `OSCL` - chamados/OS vinculadas ao pedido;
- `OSLP` - vendedor.

Filtro principal:

```sql
WHERE
    T0."CANCELED" = 'N'
    AND T0."Confirmed" = 'Y'
    AND T0."U_MM_Tipo" = '5'
```

`U_MM_Tipo = '5'` representa:

```text
Venda (Avulsa)
```

Centros de custo considerados:

```sql
R1."OcrCode" IN (
    'GERADOR',
    'NOBREAK',
    'EXE_ELET',
    'FOTOV',
    'REV_DIRE'
)
```

### 15.2 Ordem final de colunas

Ordem revisada:

1. `Dt. Criacao Pedido`
2. `Numero`
3. `Tipo`
4. `Centro Custo`
5. `Nome do Cliente`
6. `Liberar Faturamento?`
7. `Status Pedido`
8. `Dt. Entrega`
9. `Vl. Total`
10. `Valor Faturado`
11. `A Faturar`
12. `Num. NF`
13. `Dt. Faturamento`
14. `NumOS`
15. `Status Vinculo OS`
16. `Status OS`
17. `Assunto OS`
18. `Dt. Criacao OS`
19. `NumProjeto`
20. `Nome do Repr.`

### 15.3 Colunas removidas

Foram removidas:

- `Fin?`
- `Aprv?`
- `Status OS Codigo`
- `Dt. Lancamento Pedido`
- `Dt. Documento`

Motivos:

- `Fin?` era redundante, pois `Num. NF`, `Valor Faturado` e `Status Pedido` ja informam a situacao.
- `Aprv?` ficou desnecessario porque o `WHERE` ja filtra pedidos confirmados (`T0.Confirmed = 'Y'`).
- `Status OS Codigo` poluia o relatorio; foi mantida apenas a traducao textual em `Status OS`.
- `Dt. Lancamento Pedido` e `Dt. Documento` foram removidas para simplificar a visao.

### 15.4 Novo significado de Status Pedido

A coluna `Status Pedido` deixou de representar `DocStatus` (`Aberto` / `Fechado`) e passou a representar o status de faturamento:

```sql
CASE
    WHEN IFNULL(NF."ValorFaturado", 0) = 0 THEN 'A Faturar'
    WHEN IFNULL(NF."ValorFaturado", 0) >= CC."ValorPedidoCentroCusto" THEN 'Faturado'
    ELSE 'Parcial'
END AS "Status Pedido"
```

Racional:

Para o relatorio de pedidos avulsos, a informacao operacional mais importante e saber se o pedido foi faturado, parcialmente faturado ou ainda esta a faturar.

### 15.5 Data do ultimo faturamento

Quando houver mais de uma NF, trazer a data do ultimo faturamento:

```sql
MAX(Z."DocDate") AS "DtFaturamento"
```

### 15.6 Valor faturado por centro de custo

O valor faturado e calculado por:

- pedido (`BaseEntry`);
- centro de custo (`OcrCode`);
- linhas de NF vinculadas ao pedido (`INV1.BaseType = 17`).

Padrao:

```sql
SELECT
    Z."PedidoDocEntry",
    Z."CentroCusto",
    STRING_AGG(Z."NFTexto", ', ') AS "NumNF",
    MAX(Z."DocDate") AS "DtFaturamento",
    SUM(Z."ValorLinhaFaturada") AS "ValorFaturado"
FROM (
    SELECT
        I1."BaseEntry" AS "PedidoDocEntry",
        I1."OcrCode" AS "CentroCusto",
        TO_VARCHAR(NF0."Serial") AS "NFTexto",
        NF0."DocDate",
        I1."LineTotal" AS "ValorLinhaFaturada"
    FROM INV1 I1
    INNER JOIN OINV NF0
        ON NF0."DocEntry" = I1."DocEntry"
        AND NF0."CANCELED" = 'N'
    WHERE
        I1."BaseType" = 17
) Z
GROUP BY
    Z."PedidoDocEntry",
    Z."CentroCusto"
```

### 15.7 Assunto OS muito grande

O campo `Assunto OS`, vindo de `OSCL.subject`, pode gerar uma coluna enorme no SAP.

Solucao adotada:

Limitar visualmente a coluna a 120 caracteres:

```sql
CAST(
    CASE
        WHEN LENGTH(IFNULL(OS."AssuntoOS", '')) > 120
        THEN SUBSTRING(OS."AssuntoOS", 1, 120) || '...'
        ELSE OS."AssuntoOS"
    END
    AS NVARCHAR(123)
) AS "Assunto OS"
```

Se a coluna ainda ficar grande, reduzir para 100 ou 80 caracteres.

### 15.8 Status OS traduzido

Mapeamento usado para `OSCL.status`:

```sql
CASE
    WHEN S."status" = -3 THEN 'Aberto'
    WHEN S."status" = -2 THEN 'Pendente'
    WHEN S."status" = -1 THEN 'Fechado'
    WHEN S."status" = 1 THEN 'Aguardando Pecas'
    WHEN S."status" = 2 THEN 'Encerrado IClass'
    WHEN S."status" = 3 THEN 'Enviar IClass'
    WHEN S."status" = 4 THEN 'Enviado IClass'
    WHEN S."status" = 5 THEN 'Equipamento Parado'
    WHEN S."status" IS NULL THEN NULL
    ELSE 'Nao Definido'
END
```

### 15.9 Varios chamados para um pedido

Quando houver varias OS vinculadas ao mesmo pedido (`OSCL.U_MM_PV`), usar `STRING_AGG`:

```sql
STRING_AGG(X."NumOSTexto", ', ') AS "NumOS",
STRING_AGG(X."StatusTexto", ', ') AS "StatusOS",
STRING_AGG(X."AssuntoTexto", ' | ') AS "AssuntoOS",
MAX(X."DataCriacao") AS "DtCriacaoOS"
```

---

## 16. Relatorio Analitico de Compras por Fornecedor

### 16.1 Objetivo

Criar relatorio analitico de compras de um determinado fornecedor, trazendo os vinculos gerados a partir do pedido de compra.

Objetivo operacional:

- auditar pedidos de compra;
- identificar fornecedor;
- trazer filial;
- trazer projeto, etapa, titular e departamento por linha;
- trazer observacoes internas e externas;
- visualizar documentos posteriores quando houver.

### 16.2 Tabelas principais

Base:

- `OPOR` - cabecalho do pedido de compra;
- `POR1` - linhas do pedido de compra;
- `OBPL` - filial;
- tabelas de documentos de compras posteriores, conforme necessidade:
  - entrada de mercadoria;
  - nota fiscal de entrada;
  - adiantamentos;
  - etc.

Campos validados na tela do pedido de compra:

- cabecalho:
  - `OPOR.Project` - codigo do projeto financeiro no cabecalho;
  - observacoes externas;
  - observacoes internas;
  - filial;
  - titular;
- linhas:
  - `POR1.Project` - projeto da linha;
  - etapa;
  - titular;
  - departamento / centro de custo.

### 16.3 Observacoes internas e externas

Foi identificado que alguns pedidos possuem observacao em um campo e nao no outro.

Decisao final:

Trazer os dois campos separados quando o objetivo for auditoria completa.

Motivo:

Em testes, havia pedido com observacao interna preenchida e observacao externa vazia, e o relatorio nao mostrava a informacao esperada quando buscava apenas uma delas.

Importante:

Ao comparar campos de observacao no SAP HANA, cuidado com campos `LOB` / texto longo. Foi encontrado erro:

```text
General error;266 inconsistent datatype: lob type comparison
```

Regra:

Nao comparar diretamente campo LOB em `CASE`, `WHERE` ou `IFNULL` sem converter/limitar adequadamente.

Preferir trazer os campos diretamente, ou converter com cuidado para `NVARCHAR` quando necessario.

### 16.4 Filtros desejados

Na caixa de selecao inicial, o usuario desejava apenas:

- primeira data de lancamento;
- codigo do fornecedor.

Evitar criar filtros duplicados para data inicial/final se o relatorio for pontual.

### 16.5 Campos de linha solicitados

No pedido de compra, trazer da linha:

- projeto;
- etapa;
- titular;
- departamento;
- filial.

Ponto importante:

Campos de linha podem ter `StrUID` e nomes internos diferentes. Sempre validar pela barra inferior do SAP quando houver duvida.

---

## 17. Query de Faturamento de Parcelas Contratuais LOC1

### 17.1 Query criada por fornecedor ManyMinds

Foi analisada query baseada em:

- `@LOC1_CTR`
- `@LOC1_BILL`
- `@LOC1_BILL1`
- `ORDR`
- `RDR1`
- `INV1`
- `OINV`

Objetivo interpretado:

Identificar pedidos de venda de faturamento de parcelas contratuais gerados no mes e conferir se todos os contratos que deveriam ser faturados foram realmente faturados.

### 17.2 Ponto tecnico importante

Na query original, havia:

```sql
T6."GrosProfit" AS "VALOR NOTA FISCAL"
```

Alerta:

`GrosProfit` e lucro bruto, nao valor da NF.

Para valor de nota fiscal, avaliar:

- `OINV.DocTotal` para total do documento;
- `INV1.LineTotal` para valor por linha;
- somatorio de `INV1` quando a analise precisar respeitar centro de custo/linha.

---

## 18. Padroes Gerais Validados Para SAP HANA / SAP B1 Query Manager

### 18.1 Usar aspas duplas em campos e tabelas

Padrao SAP HANA:

```sql
T0."DocNum"
T1."DocEntry"
```

### 18.2 Evitar `WITH`

Como registrado, usar subconsultas derivadas no lugar de CTEs.

### 18.3 Cuidado com campos que perdem seta

Campos com `MAX`, `TO_VARCHAR`, concatenacao ou agregacao podem perder a seta de navegacao no SAP.

Para relatórios onde a seta e importante:

- trazer `DocNum` direto quando possivel;
- evitar `UNION ALL`;
- evitar transformar documentos em texto sem necessidade.

Para relatorios gerenciais/exportacao, pode-se priorizar clareza e auditoria em vez de seta.

### 18.4 Filtros opcionais no SAP

Padrao preferido:

```sql
WHERE
    (
        T2."OcrCode" = '[%0]'
        OR '[%0]' = ''
    )
```

Evitar que a primeira ocorrencia do parametro seja solta ou funcao sobre string.

### 18.5 `STRING_AGG`

Usado quando ha varias NFs ou varias OS vinculadas ao mesmo pedido.

Exemplos:

```sql
STRING_AGG(Z."NFTexto", ', ') AS "NumNF"
STRING_AGG(X."AssuntoTexto", ' | ') AS "AssuntoOS"
```

### 18.6 `MAX` para ultima data

Usar:

```sql
MAX(Z."DocDate") AS "DtFaturamento"
```

quando houver mais de um documento e o objetivo for trazer a ultima data.

### 18.7 Campos texto muito longos

Para evitar colunas enormes:

```sql
CAST(
    CASE
        WHEN LENGTH(IFNULL(CAMPO, '')) > 120
        THEN SUBSTRING(CAMPO, 1, 120) || '...'
        ELSE CAMPO
    END
    AS NVARCHAR(123)
) AS "Campo"
```

### 18.8 Evitar comparacao direta de LOB

Erro conhecido:

```text
inconsistent datatype: lob type comparison
```

Ocorre quando se compara campo de texto longo/LOB diretamente.

---

## 19. Regras de Auditoria e Homologacao

### 19.1 Sempre comparar relatorio filtrado contra consolidado

Metodo validado:

1. Rodar sem filtro.
2. Rodar um relatorio por centro de custo.
3. Somar os extratificados.
4. Conferir se soma bate com o consolidado.

Foi usado com sucesso nos centros:

- `EXE_ELET`
- `GERADOR`
- `LOCACAO`
- `NOBREAK`

### 19.2 Manter alertas explicitos no relatorio

Sempre que possivel, criar coluna de alerta para dados suspeitos:

- linha com valor zerado;
- quantidade zerada;
- quantidade maior que 1 com valor zerado;
- sem pedido vinculado;
- sem linha do centro de custo selecionado.

### 19.3 Separar erro real de excecao operacional

Exemplos:

- Sao Roque: erro real a validar.
- Acco Brands: contrato guarda-chuva / excecao operacional.
- Cali Club: excecao sem cobranca.

Regra:

Nao tratar todo alerta como erro automaticamente. O relatorio deve apontar, e o usuario valida a interpretacao operacional.

---

## 20. Prompt Recomendado Para Outro Chat Codex

Ao levar esta memoria para outro chat, usar:

```text
Leia integralmente esta memoria tecnica atualizada.

Contexto:
Trabalho com SAP Business One HANA, addon LOC1, contratos de manutencao, pedidos avulsos, compras, faturamento e Power BI.

Regras importantes:
- Nao usar WITH no SAP Query Manager deste ambiente.
- Evitar T2.LineNum = 0 em contratos de manutencao; a granularidade atual e linha do pedido por centro de custo.
- Para filtro opcional no Query Manager, usar primeiro o campo real: T2."OcrCode" = '[%0]' OR '[%0]' = ''.
- Nao juntar centros de custo diferentes em uma linha quando o objetivo for auditoria por centro.
- Evitar colunas duplicadas e campos que nao existem no SAP.
- Quando houver dados zerados, criar alerta de auditoria, mas nao assumir erro sem validacao operacional.

Continue a partir desta memoria e preserve as decisoes ja homologadas.
```

---

## 21. Estado Atual Apos Atualizacao

O projeto agora possui tres frentes maduras:

1. Equipamentos / LOC1 / Power BI:
   - base original com `OSRN + @LOC1_SNMO`;
   - estrategia CSV via OneDrive.

2. Contratos de manutencao:
   - relatorio denso por linha e centro de custo;
   - filtro opcional por centro;
   - previsao mensal 2026-2027;
   - auditoria por linha;
   - totais homologados com consolidado e extratificados.

3. Pedidos avulsos e compras:
   - pedidos avulsos com status de faturamento;
   - NFs agregadas por pedido/centro;
   - OS agregadas por pedido;
   - compras com foco em fornecedor, filial, projeto, etapa, titular, departamento e observacoes.

Diretriz geral:

Toda nova query deve ser construida em camadas:

1. entender objetivo de negocio;
2. criar versao simples;
3. testar no SAP;
4. auditar linhas e totais;
5. enriquecer colunas;
6. remover duplicidades;
7. documentar regras homologadas nesta memoria.
