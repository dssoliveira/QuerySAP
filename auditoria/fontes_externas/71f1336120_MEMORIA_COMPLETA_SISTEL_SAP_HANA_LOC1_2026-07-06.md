# Memoria Completa Portatil - Sistel SAP B1 HANA + LOC1 + Power BI

Atualizacao consolidada: 2026-07-06
Responsavel operacional: Danilo Santos
Finalidade: transportar o conhecimento deste projeto para outro computador, outra sessao Codex ou outro profissional.

Este documento incorpora a memoria tecnica anterior e acrescenta todas as descobertas posteriores sobre metas, faturamento por nota fiscal, centros de custo e auditoria fiscal.

---
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

# Atualizacao Tecnica - Faturamento, Metas e Auditoria Fiscal

Data desta atualizacao: 2026-07-06

## 13. Objetivo Dos Relatorios De Faturamento

Foram construidos dois tipos de relatorio:

1. Consolidado mensal por departamento, exibindo Meta e Realizado.
2. Extratificado por nota fiscal e linha, usado para descobrir quais documentos compoem cada valor consolidado.

Regra principal validada:

- O documento oficial de faturamento deve ser a Nota Fiscal de Saida.
- A fonte base e `OINV` para o cabecalho e `INV1` para as linhas.
- O valor usado pelo consolidado e `INV1.LineTotal`.
- O departamento fiscal usado pelo consolidado e `INV1.OcrCode`.
- Dados de pedido devem enriquecer a nota, mas nao podem excluir notas apenas porque o pedido nao foi localizado.

## 14. Tabelas Adicionais Validadas Para Faturamento

### OINV - Cabecalho da Nota Fiscal de Saida

Campos importantes:

- `DocEntry`: chave interna da NF.
- `DocNum`: numero interno SAP.
- `Serial`: numero fiscal.
- `DocDate`: data de emissao/lancamento.
- `CardCode`: codigo do cliente.
- `CardName`: nome do cliente.
- `DocTotal`: total contabil do cabecalho.
- `CANCELED`: cancelamento. Considerar somente `N`.
- `BPLId`: filial emissora.

### INV1 - Linhas da Nota Fiscal de Saida

Campos importantes:

- `DocEntry`: vinculo com OINV.
- `LineNum`: linha da NF.
- `ItemCode`: item/servico.
- `Dscription`: descricao.
- `Quantity`: quantidade.
- `LineTotal`: valor da linha usado no consolidado.
- `OcrCode`: departamento/centro de custo da linha da NF.
- `BaseType`: tipo do documento base.
- `BaseEntry`: chave do documento base.
- `BaseLine`: linha do documento base.
- `Usage`: codigo da utilizacao fiscal.
- `TaxOnly`: indica linha somente de imposto.
- `CFOPCode`: CFOP da linha.

### OUSG - Utilizacao Da Nota Fiscal

Relacionamento:

```sql
LEFT JOIN OUSG U
    ON INV1."Usage" = U."ID"
```

Campos importantes:

- `ID`: codigo da utilizacao.
- `Usage`: nome curto.
- `Descr`: descricao.
- `TaxOnly`: utilizacao somente de imposto.

### Tipos de documento base validados

- `17`: pedido de venda direto.
- `15`: entrega.
- `-1`: sem documento base.

Importante: `BaseType = -1` nao significa automaticamente erro. Pode existir nota legitima criada sem pedido. A natureza fiscal precisa ser analisada.

## 15. Diferenca Entre Relatorio Baseado Em Pedido E Baseado Em NF

Query baseada em pedido:

```sql
ORDR -> RDR1 -> INV1 -> OINV
```

Com condicao:

```sql
INV1."BaseType" = 17
```

Essa query considera somente notas diretamente baseadas em pedido de venda.

Query baseada em NF:

```sql
OINV -> INV1
```

Essa query considera todas as linhas fiscais emitidas, incluindo:

- pedido direto;
- nota via entrega;
- nota sem documento base;
- remessas;
- notas complementares de imposto.

Portanto, o consolidado por NF precisa de regras fiscais para separar faturamento real de documentos sem receita.

## 16. Regra Fiscal Validada Para O Consolidado

Nao usar isoladamente:

```sql
OINV."DocTotal" > 0
```

Motivo: foram encontradas notas legitimas, vinculadas a pedidos, com `DocTotal = 0`, incluindo manutencao, instalacao, locacao e revenda.

Nao exigir isoladamente:

```sql
INV1."BaseType" = 17
```

Motivo: isso pode excluir vendas legitimas via entrega ou notas validas sem pedido.

Regra validada para excluir documentos fiscais sem receita:

```sql
LEFT JOIN OUSG U
    ON T1."Usage" = U."ID"

WHERE
    IFNULL(T1."TaxOnly", 'N') <> 'Y'
    AND IFNULL(U."TaxOnly", 'N') <> 'Y'
    AND IFNULL(T1."Usage", -1) <> 37
```

Interpretacao:

- Excluir linhas somente de imposto.
- Excluir utilizacoes configuradas somente para imposto.
- Excluir utilizacao `37 - S Remessa Comodato`.
- Manter notas legitimas mesmo quando `DocTotal = 0`.

## 17. Documentos Fiscais Sem Receita Identificados

### Notas complementares de imposto

Utilizacao:

- codigo `99`;
- descricao `S NF Compl. Imposto`;
- `INV1.TaxOnly = Y`;
- `OUSG.TaxOnly = Y`.

Valores encontrados em junho de 2026 no departamento Gerador:

- R$ 38,00;
- R$ 82,50;
- R$ 138,60;
- total: R$ 259,10.

Esses valores estavam sendo somados pelo consolidado antigo porque `LineTotal` era somado sem filtro fiscal.

### Remessa em comodato

Documento identificado:

- DocEntry NF: `2914`;
- DocNum SAP: `1759`;
- Numero fiscal: `14279`;
- cliente: FESTAR PRODUCOES ARTISTICAS LTDA;
- departamento: `LOCACAO`;
- item: `AF000347`;
- valor de linha: R$ 300.000,00;
- DocTotal: R$ 0,00;
- BaseType: `-1`;
- utilizacao: `37 - S Remessa Comodato`;
- CFOP: `5908`.

Esse documento possui valor fiscal, mas nao representa receita de faturamento.

## 18. Auditoria De Junho De 2026

### Foto ate 26/06/2026

Execucao Eletrica:

- consolidado por `INV1.LineTotal`: R$ 473.556,94;
- extratificado por pedido usando `INV1.LineTotal`: R$ 473.556,94;
- 43 notas e 43 linhas;
- nenhuma divergencia entre departamento da NF e departamento do pedido nessa amostra.

A coluna calculada abaixo nao deve ser usada para reconciliar o consolidado:

```sql
OINV."DocTotal"
+ OINV."DiscSum"
- OINV."VatSum"
- OINV."TotalExpns"
```

Ela resultou em R$ 454.952,33, diferenca de R$ 18.604,61 contra `LineTotal`.

### Foto ate 29/06/2026

Extrato baseado em pedido, por departamento:

- GERADOR: R$ 452.650,94 no arquivo mais recente geral, conforme dados copiados naquele momento.
- LOCACAO: R$ 1.258.824,90.
- EXE_ELET: R$ 498.793,10.
- NOBREAK: R$ 105.661,59.
- FOTOV: R$ 17.643,15.
- REV_DIRE: R$ 156.489,60.
- SEMINOVO: R$ 305.000,00.

Observacao: valores mudam conforme novas notas sao emitidas. Sempre registrar a data de corte.

Dashboard bruto de Locacao antes do filtro fiscal:

- R$ 1.558.824,90.

Composicao:

- faturamento vinculado/operacional: R$ 1.258.824,90;
- remessa em comodato sem receita: R$ 300.000,00.

## 19. Estrutura Do Consolidado Meta X Realizado

Departamentos e codigos:

| Ordem | Departamento | OcrCode |
|---:|---|---|
| 1 | Gerador | GERADOR |
| 2 | Nobreak | NOBREAK |
| 3 | Locacao | LOCACAO |
| 4 | Execucao Eletrica | EXE_ELET |
| 5 | Fotovoltaico | FOTOV |
| 6 | Revenda Direta | REV_DIRE |
| 7 | Seminovo | SEMINOVO |

Seminovo foi incluido com metas zeradas ate que os valores oficiais sejam informados.

O consolidado possui:

- uma linha Meta por departamento;
- uma linha Realizado por departamento;
- Somatoria EXE/FV/RVD/SN;
- Subtotal geral;
- percentual alcancado sobre a meta anual.

A Somatoria EXE/FV/RVD/SN deve considerar exclusivamente:

```sql
'EXE_ELET',
'FOTOV',
'REV_DIRE',
'SEMINOVO'
```

Nao incluir Gerador, Nobreak ou Locacao.

## 20. Retroativos Manuais Do Consolidado

Janeiro e fevereiro possuem valores retroativos manuais adicionados depois da leitura do SAP.

| Departamento | Retro Jan | Retro Fev |
|---|---:|---:|
| Gerador | 507.091,15 | 465.528,46 |
| Nobreak | 167.580,25 | 192.585,73 |
| Locacao | 999.929,41 | 1.097.137,99 |
| Execucao Eletrica | 77.793,41 | 369.339,30 |
| Fotovoltaico | 4.112,88 | 0,00 |
| Revenda Direta | 64.000,00 | 0,00 |
| Seminovo | 0,00 | 0,00 |

Total de retroativos: R$ 3.945.098,58.

Consequencia:

- Um extrato de notas do SAP nao fecha sozinho com o acumulado ajustado de janeiro e fevereiro.
- Para reconciliar, comparar primeiro com `AcumuladoSAP` antes dos retroativos.
- Depois adicionar os retroativos como ajuste gerencial separado.

## 21. Trecho Critico Da CTE De Faturamento Corrigida

```sql
A AS (
    SELECT
        T1."OcrCode",
        SUM(CASE WHEN MONTH(T0."DocDate") = 1  THEN T1."LineTotal" ELSE 0 END) AS "Jan",
        SUM(CASE WHEN MONTH(T0."DocDate") = 2  THEN T1."LineTotal" ELSE 0 END) AS "Fev",
        SUM(CASE WHEN MONTH(T0."DocDate") = 3  THEN T1."LineTotal" ELSE 0 END) AS "Mar",
        SUM(CASE WHEN MONTH(T0."DocDate") = 4  THEN T1."LineTotal" ELSE 0 END) AS "Abr",
        SUM(CASE WHEN MONTH(T0."DocDate") = 5  THEN T1."LineTotal" ELSE 0 END) AS "Mai",
        SUM(CASE WHEN MONTH(T0."DocDate") = 6  THEN T1."LineTotal" ELSE 0 END) AS "Jun",
        SUM(CASE WHEN MONTH(T0."DocDate") = 7  THEN T1."LineTotal" ELSE 0 END) AS "Jul",
        SUM(CASE WHEN MONTH(T0."DocDate") = 8  THEN T1."LineTotal" ELSE 0 END) AS "Ago",
        SUM(CASE WHEN MONTH(T0."DocDate") = 9  THEN T1."LineTotal" ELSE 0 END) AS "Set",
        SUM(CASE WHEN MONTH(T0."DocDate") = 10 THEN T1."LineTotal" ELSE 0 END) AS "Out",
        SUM(CASE WHEN MONTH(T0."DocDate") = 11 THEN T1."LineTotal" ELSE 0 END) AS "Nov",
        SUM(CASE WHEN MONTH(T0."DocDate") = 12 THEN T1."LineTotal" ELSE 0 END) AS "Dez",
        SUM(T1."LineTotal") AS "AcumuladoSAP"
    FROM OINV T0
    INNER JOIN INV1 T1
        ON T0."DocEntry" = T1."DocEntry"
    LEFT JOIN OUSG U
        ON T1."Usage" = U."ID"
    WHERE
        T0."CANCELED" = 'N'
        AND YEAR(T0."DocDate") = YEAR(CURRENT_DATE)
        AND T1."OcrCode" IN (
            'GERADOR', 'NOBREAK', 'LOCACAO', 'EXE_ELET',
            'FOTOV', 'REV_DIRE', 'SEMINOVO'
        )
        AND IFNULL(T1."TaxOnly", 'N') <> 'Y'
        AND IFNULL(U."TaxOnly", 'N') <> 'Y'
        AND IFNULL(T1."Usage", -1) <> 37
    GROUP BY
        T1."OcrCode"
)
```

## 22. Extratificado Oficial Baseado Em NF

A consulta extratificada deve sempre comecar assim:

```sql
FROM OINV NF
INNER JOIN INV1 LINHA_NF
    ON NF."DocEntry" = LINHA_NF."DocEntry"
```

Depois, pedidos podem ser buscados com `LEFT JOIN`:

- pedido direto quando `INV1.BaseType = 17`;
- entrega quando `INV1.BaseType = 15`;
- pedido que originou a entrega atraves de `DLN1` e `RDR1`.

Nunca usar `INNER JOIN ORDR/RDR1` quando a finalidade for listar todas as notas, pois isso remove documentos sem pedido direto.

Campos recomendados no extrato:

- Num_Interno_NF;
- Num_Documento_SAP;
- Numero_Nota_Fiscal;
- Data_Emissao;
- Filial_NF;
- Cod_Cliente;
- Nome_Cliente;
- Total_Cabecalho_NF;
- Tipo_Documento_Base;
- Origem_Nota;
- Pedido_Venda;
- Departamento;
- Codigo_Utilizacao;
- Utilizacao;
- TaxOnly;
- CFOP;
- Linha_NF;
- Cod_Item;
- Descricao_Item;
- Quantidade;
- Total_Linha;
- Classificacao_Auditoria.

## 23. Filial Da Nota Fiscal

Relacionamento recomendado:

```sql
LEFT JOIN OBPL FILIAL
    ON OINV."BPLId" = FILIAL."BPLId"
```

Nome curto:

```sql
CASE
    WHEN UPPER(FILIAL."BPLName") LIKE '%COMERCIO%'
        THEN 'SISTEL COMERCIO'
    WHEN UPPER(FILIAL."BPLName") LIKE '%ENGENHARIA%'
        THEN 'SISTEL ENGENHARIA'
    ELSE FILIAL."BPLName"
END
```

Foi identificada tambem a filial `LOPES & OLIVEIRA PARTICIPACOES LTDA` em uma nota. Nao presumir que existam somente duas filiais sem aplicar regra de negocio explicita.

## 24. Passagem De Bastao No Pedido

Campo validado na tabela ORDR:

```sql
ORDR."U_MM_Passagem_Bastao"
```

Mapeamento:

```sql
CASE
    WHEN ORDR."U_MM_Passagem_Bastao" = '0' THEN 'PCP'
    WHEN ORDR."U_MM_Passagem_Bastao" = '1' THEN 'PCM'
    WHEN ORDR."U_MM_Passagem_Bastao" = '2' THEN 'LOCACAO'
    WHEN ORDR."U_MM_Passagem_Bastao" = '3' THEN 'ENGENHARIA'
    ELSE 'NAO DEFINIDO'
END
```

Existe outro campo, `U_MM_PDB`, que retorna apenas Sim/Nao. Nao confundir os dois.

## 25. Regras De Auditoria E Reconciliacao

1. Definir a data de corte antes de comparar valores.
2. Comparar sempre o mesmo periodo.
3. Comparar `INV1.LineTotal` com `INV1.LineTotal`.
4. Nao comparar `LineTotal` com formula reconstruida do cabecalho.
5. Usar `INV1.OcrCode` para reproduzir o dashboard baseado em NF.
6. Mostrar `RDR1.OcrCode` somente como DE-PARA do pedido.
7. Separar documentos fiscais sem receita em uma classificacao visivel.
8. Nao excluir silenciosamente documentos antes da auditoria.
9. Para faturamento gerencial, excluir `TaxOnly` e remessa em comodato.
10. Para auditoria fiscal bruta, mostrar tudo e classificar cada linha.
11. Registrar notas de credito futuramente: o consolidado atual usa apenas OINV/INV1 e ainda nao desconta ORIN/RIN1.
12. Verificar futuramente se notas via entrega devem entrar no processo comercial e no BI.

## 26. Pontos Ainda Pendentes

- Validar metas oficiais de Seminovo.
- Decidir se outras utilizacoes de remessa, alem do codigo 37, tambem devem ser excluidas.
- Avaliar notas de credito `ORIN/RIN1` para calcular faturamento liquido.
- Validar comportamento de notas via entrega (`BaseType = 15`).
- Definir tratamento oficial para filiais diferentes de Sistel Comercio e Sistel Engenharia.
- Continuar construcao do Power BI e medidas DAX.
- Automatizar a extracao do SAP quando houver ferramenta autorizada.

## 27. Como Continuar No Outro Computador

1. Aguardar a sincronizacao do OneDrive.
2. Abrir a pasta `BI_SAP_LOC1`.
3. Anexar este arquivo ao novo chat/Codex.
4. Usar o prompt:

```text
Leia integralmente esta memoria tecnica. Ela contem o contexto validado do projeto Sistel SAP Business One HANA + LOC1 + Power BI. Continue a partir dela, preserve as regras de cardinalidade e faturamento fiscal e nao reconstrua os relacionamentos por suposicao.
```

5. Anexar tambem os CSVs ou queries especificas quando o trabalho depender de dados atuais.
6. Confirmar no novo computador se os scripts PowerShell e caminhos do OneDrive foram sincronizados.

## 28. Resumo Executivo Final

- Para equipamentos LOC1, usar `OSRN + @LOC1_SNMO` como nucleo operacional.
- Para faturamento, usar `OINV + INV1` como nucleo fiscal.
- Para enriquecer faturamento com pedido, usar `LEFT JOIN`; nao fazer o pedido controlar a existencia da NF.
- Para valor realizado, usar `INV1.LineTotal`.
- Para departamento do dashboard fiscal, usar `INV1.OcrCode`.
- Excluir do faturamento gerencial linhas `TaxOnly` e utilizacao 37 de remessa em comodato.
- Manter documentos legitimos mesmo quando `DocTotal = 0`.
- Retroativos de janeiro e fevereiro sao ajustes gerenciais separados do SAP.
- Queries detalhadas do SAP devem evitar `UNION ALL` quando as setas de navegacao forem importantes.
- Power BI recebe CSV limpo via OneDrive enquanto nao houver HANA Client/ODBC.