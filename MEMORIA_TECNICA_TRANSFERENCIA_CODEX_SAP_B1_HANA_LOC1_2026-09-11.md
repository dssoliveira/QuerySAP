# Memória Técnica de Transferência — SAP B1 HANA / LOC1 / Queries Gerenciais

Documento criado para transportar o aprendizado deste chat para outra estação/Codex, mantendo contexto técnico, regras de negócio validadas, vínculos entre tabelas e decisões tomadas durante a construção das queries.

Data de referência: 11/09/2026  
Ambiente: SAP Business One HANA / LOC1 / Sistel  
Usuário solicitante: Danilo Santos

---

## 1. Objetivo deste documento

Este arquivo resume o conhecimento construído durante a conversa sobre relatórios SAP B1 HANA, principalmente:

- relatório oficial de notas fiscais/faturamento;
- tratamento entre NF de saída, NF de entrega e NF de venda futura;
- relatório `FATURAMENTO DREXMETAS`;
- relatório de custos por OS/equipamento;
- pedidos de transferência de estoque;
- pedidos de venda gerados por OS / iClass / LOC1;
- regras de preservação de estrutura e setas amarelas no SAP B1.

Use este documento como briefing inicial em um novo chat do Codex.

---

## 2. Princípios importantes usados durante o trabalho

1. Queries já aprovadas pela diretoria não devem ter a estrutura alterada sem necessidade.
2. Alterações devem ser cirúrgicas: manter colunas, nomes, filtros e ordenações sempre que possível.
3. Quando houver risco de duplicação por linhas de documento, consolidar por documento antes de somar valores.
4. Em SAP B1, preservar setas amarelas de acesso quando possível:
   - `ORDR."DocNum"` costuma abrir Pedido de Venda.
   - `OINV."DocNum"` / `OINV."DocEntry"` pode abrir Nota Fiscal dependendo da coluna/objeto.
   - `OSCL."callID"` abre Chamado de Serviço.
   - `OWTQ."DocNum"` abre Pedido de Transferência de Estoque.
5. Para análises de faturamento, usar data de entrega vinculada quando a NF futura foi convertida/atendida por entrega real.
6. NF de venda futura pura não deve compor faturamento/meta.
7. NF de saída real deve compor faturamento/meta.
8. NF de entrega deve compor faturamento/meta quando representar entrega real vinculada.

---

## 3. Relatório oficial de NF / faturamento

### 3.1 Query base aprovada

A query oficial de NF usa como base:

- `OINV T0` — cabeçalho da NF;
- `INV1 I1` — linhas da NF;
- `ORDR PV` — pedido de venda vinculado;
- `RDR1 R1` — linha do pedido de venda;
- `OUSG U` — utilização;
- `OBPL FIL` — filial;
- `ODLN E0` / `DLN1 D1` — entregas vinculadas à NF.

Campos principais:

- `T0."DocEntry"` como `Num_Interno_NF`;
- `T0."DocNum"` como `Num_Documento_SAP`;
- `T0."Serial"` como `Numero_Nota_Fiscal`;
- `T0."DocDate"` como `Data_Emissao`;
- `T0."NfeValue"` como valor oficial da NF;
- `PV."DocNum"` como `Pedido_Venda`;
- `PV."U_MM_Tipo"` como tipo do pedido;
- `IFNULL(I1."OcrCode", R1."OcrCode")` como departamento;
- `U."Usage"` como utilização.

### 3.2 Classificação final validada para Tipo_Nota_Fiscal

A classificação anterior estava errada porque tratava tudo que não tivesse entrega vinculada como `Nota Fiscal de Saida`.

Exemplo encontrado:

- NF interna: `5865`
- Documento SAP: `3587`
- Número NF: `14869`
- CFOP: `5922`
- Utilização: `S Venda Produção`
- Resultado antigo: `Nota Fiscal de Saida`
- Resultado correto: `Nota Fiscal de Venda Futura`

Regra validada:

```sql
CASE
    WHEN ENT."Num_Documento_Entrega" IS NOT NULL
    THEN 'Nota Fiscal de Entrega'

    WHEN LIN."FlagEntregaCFOP" = 1
    THEN 'Nota Fiscal de Entrega'

    WHEN LIN."FlagVendaFutura" = 1
    THEN 'Nota Fiscal de Venda Futura'

    ELSE 'Nota Fiscal de Saida'
END AS "Tipo_Nota_Fiscal"
```

### 3.3 CFOPs validados

Foi feito levantamento de CFOPs para tornar a query mais resiliente.

Regras confirmadas:

- `5922` = venda futura.
- `6922` = venda futura interestadual, manter como regra preventiva.
- `5908` = entrega/remessa, incluir como entrega.
- `6908` = entrega/remessa interestadual, manter como regra preventiva.

Importante: a utilização sozinha não é confiável, porque CFOP `5922` apareceu com utilizações diferentes:

- `S Venda Entr. Futura`;
- `S Venda Produção`;
- `S Revenda`.

Portanto, para excluir venda futura pura, a regra correta é por CFOP + ausência de entrega vinculada.

### 3.4 Filtro final para excluir NF de venda futura pura

Filtro final aprovado:

```sql
AND NOT (
    LIN."FlagVendaFutura" = 1
    AND ENT."Num_Documento_Entrega" IS NULL
)
```

Interpretação:

- se CFOP é `5922`/`6922` e não tem entrega vinculada, sai do relatório;
- se tem entrega vinculada, permanece no relatório como entrega;
- outras NFs do mesmo pedido continuam entrando normalmente.

### 3.5 Caso validado — Pedido 1569

O pedido `1569` possuía três documentos relacionados:

| Num Interno NF | Doc SAP | Nota Fiscal | Data | CFOP | Valor | Ação |
|---:|---:|---:|---|---:|---:|---|
| 1098 | 643 | 14023 | 17/04/2026 | 5922 | 103.898,62 | Sair do relatório |
| 2358 | 1409 | 4850 | 21/05/2026 | 5949 | 1.979,53 | Compor relatório |
| 3668 | 2208 | 18608 | 29/06/2026 | 5933 | 27.272,91 | Compor relatório |

Conclusão:

- não remover o pedido inteiro;
- remover apenas a NF de venda futura pura;
- manter as NFs reais de saída do mesmo pedido.

---

## 4. Query oficial de NF — bloco crítico final

Na query oficial de NF, a subquery `LIN` deve trazer `CFOP`, `FlagVendaFutura` e `FlagEntregaCFOP`.

Bloco essencial dentro da subquery:

```sql
TO_VARCHAR(I1."CFOPCode") AS "CFOP",

MAX(
    CASE
        WHEN TO_VARCHAR(I1."CFOPCode") IN ('5922', '6922')
        THEN 1
        ELSE 0
    END
) OVER (PARTITION BY I1."DocEntry") AS "FlagVendaFutura",

MAX(
    CASE
        WHEN TO_VARCHAR(I1."CFOPCode") IN ('5908', '6908')
        THEN 1
        ELSE 0
    END
) OVER (PARTITION BY I1."DocEntry") AS "FlagEntregaCFOP"
```

Filtro final no `WHERE` principal:

```sql
AND NOT (
    LIN."FlagVendaFutura" = 1
    AND ENT."Num_Documento_Entrega" IS NULL
)
```

---

## 5. FATURAMENTO DREXMETAS

### 5.1 Por que a DREXMETAS não atualizou automaticamente?

A query `FATURAMENTO DREXMETAS` não depende da query oficial de NF.

Ela possui sua própria base fiscal dentro da CTE:

```sql
NF_BASE AS (...)
```

Por isso, atualizar a query oficial de NF não atualiza automaticamente a `FATURAMENTO DREXMETAS`.

### 5.2 Regra antiga que ainda estava na DREXMETAS

A DREXMETAS ainda usava apenas texto da utilização:

```sql
AND (
    ENT."Num_Documento_Entrega" IS NOT NULL
    OR (
        UPPER(IFNULL(U."Usage", '')) NOT LIKE '%ENTR. FUTURA%'
        AND UPPER(IFNULL(U."Usage", '')) NOT LIKE '%ENTREGA FUTURA%'
    )
)
```

Esse critério falha quando a NF de venda futura tem CFOP `5922`, mas utilização como `S Venda Produção`.

### 5.3 Regra final a replicar na DREXMETAS

Na CTE `NF_BASE`, incluir:

```sql
MAX(
    CASE
        WHEN TO_VARCHAR(T1."CFOPCode") IN ('5922', '6922')
        THEN 1
        ELSE 0
    END
) OVER (PARTITION BY T0."DocEntry") AS "FlagVendaFutura"
```

E no filtro externo da `NF_BASE`:

```sql
AND NOT (
    X."FlagVendaFutura" = 1
    AND X."Num_Documento_Entrega" IS NULL
)
```

### 5.4 Resultado esperado da DREXMETAS

Depois da correção:

- NFs futuras puras deixam de compor realizado/meta;
- NFs de saída continuam compondo;
- NFs futuras com entrega vinculada entram pela data e valor da entrega;
- valores ficam alinhados ao relatório oficial de NF.

---

## 6. Auditoria entre query antiga e query revisada de NF

Foi feita comparação entre:

- query antiga aprovada;
- query revisada com CFOP.

Resultado:

| Comparação | Query antiga | Query revisada | Diferença |
|---|---:|---:|---:|
| Quantidade de linhas | 2.625 | 2.623 | -2 |
| Valor total | 23.462.560,98 | 21.017.106,53 | -2.445.454,45 |
| NFs adicionadas | — | 0 | OK |
| Valores alterados em NFs iguais | — | 0 | OK |

NFs removidas:

| Num Interno NF | Doc SAP | Nota Fiscal | Cliente | Pedido | Valor |
|---:|---:|---:|---|---:|---:|
| 1098 | 643 | 14023 | VILA NOVA MAX SUPERMERCADOS LTDA. | 1569 | 103.898,62 |
| 5865 | 3587 | 14869 | POLIFRIGOR IND. E COM. DE ALIMENTOS LTDA | 8791 | 2.341.555,83 |

Ambas removidas por serem venda futura pura, com CFOP `5922` e sem entrega vinculada.

Seis NFs foram apenas reclassificadas:

- antes: `Nota Fiscal de Entrega Futura com Entrega Vinculada`;
- depois: `Nota Fiscal de Entrega`.

Essas continuaram no relatório porque possuem entrega vinculada.

---

## 7. Relatório de custos por OS / equipamento

### 7.1 Objetivo

Construir relatório para rastrear todos os custos de material/serviço por OS e por equipamento, cruzando:

- contrato de serviço;
- cartão de equipamento;
- relatório do cartão de equipamento;
- pedidos de transferência de estoque;
- pedidos de venda gerados por OS;
- pedidos de venda gerados pelo iClass/LOC1.

Objetivo final:

- saber tudo que foi gasto de material por OS;
- calcular custo consolidado por máquina/equipamento;
- acompanhar custo de vida do equipamento.

### 7.2 Tabelas principais

- `OSCL` — Chamado de Serviço / OS;
- `OINS` — Cartão de Equipamento;
- `OCTR` — Contrato de Serviço;
- `OWTQ` — Cabeçalho do pedido de transferência de estoque;
- `WTQ1` — Linhas do pedido de transferência;
- `ORDR` — Pedido de venda;
- `RDR1` — Linhas do pedido de venda;
- `SCL4` — Documentos relacionados do chamado de serviço;
- `@LOC1_CHLO` — Log LOC1.

### 7.3 Pedido de transferência de estoque vinculado à OS

O campo de vínculo confirmado:

```sql
OWTQ."U_MM_OS" = OSCL."callID"
```

Pontos de regra:

- uma OS pode ter vários pedidos de transferência;
- o relatório deve consolidar os pedidos por OS;
- não multiplicar o número do pedido de transferência por linha de item;
- somar o valor total do pedido de transferência.

### 7.4 Pedido de venda gerado por OS

Pedidos de venda gerados por OS:

- são geralmente 1 para 1 com a OS;
- tipo de pedido: `Gerado por OS (Pré-Consumo)`;
- podem estar ligados por campo específico do LOC1 ou por texto padrão no pedido.

Regra importante aprendida:

- quando a OS está no texto padrão, o número correto costuma estar no final do texto;
- não confiar apenas no começo da observação.

### 7.5 Pedido de venda gerado pelo iClass

Quando a OS é finalizada, a integração iClass pode emitir pedido de venda vinculado à OS com itens:

- `SV000045` — mão de obra;
- `SV000044` — deslocamento.

Esses itens aparecem na aba `Documentos relacionados` do chamado de serviço.

Vínculo correto:

```sql
SCL4."SrcvCallID" = OSCL."callID"
SCL4."Object" = '17'
SCL4."DocAbs" = ORDR."DocEntry"
```

Depois cruzar:

```sql
ORDR."DocEntry" = SCL4."DocAbs"
RDR1."DocEntry" = ORDR."DocEntry"
RDR1."ItemCode" IN ('SV000045', 'SV000044')
```

### 7.6 Custo hora homem iClass

Os itens `SV000045` e `SV000044` vêm em minutos.

Valor médio validado para apresentar custo:

```text
R$ 35,00 por hora
```

Fórmula:

```sql
(SUM(RDR1."Quantity") / 60) * 35.00
```

### 7.7 Criador da OS no LOC1

O usuário pediu para trazer quem criou a OS no LOC1.

Tabela confirmada:

```sql
"@LOC1_CHLO"
```

Campos úteis:

- `U_LogDate` — data do log;
- `U_User` — usuário LOC1;
- `U_Operation` — operação;
- `U_DataCode` — código do dado, neste caso número da OS;
- `U_DataTable` — tabela, neste caso `OSCL`;
- `U_Log` — texto do log.

Exemplo encontrado:

```text
Data Log: 04/09/2026
Usuário LOC1: MARIANA ANDREOLLI
Operação: Add
Código Dados: 9290
Tabela Dados: OSCL
Log LOC1: Chamado de Serviço adicionado: 9290 Dados LOC1 processados
```

CTE recomendada:

```sql
LOC1_CRIADOR_OS_RANK AS (
    SELECT
        L."U_DataCode" AS "NumeroOSTexto",
        L."U_User" AS "CriadoPorLOC1",
        L."U_LogDate" AS "DataCriacaoLOC1",
        ROW_NUMBER() OVER (
            PARTITION BY L."U_DataCode"
            ORDER BY L."U_LogDate" ASC
        ) AS "LinhaControle"
    FROM "@LOC1_CHLO" L
    WHERE
        UPPER(IFNULL(L."U_Operation", '')) = 'ADD'
        AND UPPER(IFNULL(L."U_DataTable", '')) = 'OSCL'
        AND IFNULL(L."U_DataCode", '') <> ''
),
LOC1_CRIADOR_OS AS (
    SELECT
        L."NumeroOSTexto",
        L."CriadoPorLOC1",
        L."DataCriacaoLOC1"
    FROM LOC1_CRIADOR_OS_RANK L
    WHERE L."LinhaControle" = 1
)
```

---

## 8. Relatório de pedidos de transferência de estoque

### 8.1 Query padrão original

Query padrão do SAP:

```sql
SELECT
    T0."DocEntry" AS "Chave interna do documento",
    T0."DocNum" AS "Nº do documento",
    T0."DocDate" AS "Data de lançamento",
    T0."DocDueDate" AS "Data de vencimento",
    (SELECT TT0."WhsCode" FROM OWHS TT0 WHERE TT0."WhsCode" = T0."Filler") AS "Do depósito",
    (SELECT TT0."WhsCode" FROM OWHS TT0 WHERE TT0."WhsCode" = T0."ToWhsCode") AS "Para depósito"
FROM OWTQ T0
INNER JOIN OUSR T1
    ON T0."UserSign" = T1."USERID"
WHERE
    T0."DocStatus" = 'O'
    AND T1."USERID" = 11
ORDER BY
    T0."DocDueDate",
    T0."DocNum"
```

### 8.2 Melhorias solicitadas

O usuário pediu:

- não limitar a um usuário;
- trazer todos os dados importantes;
- trazer número da OS com seta de acesso;
- parceiro de negócio;
- empresa/filial como `Sistel Engenharia` ou `Sistel Comercio`;
- projeto;
- departamento;
- criado por via log de modificações;
- remover colunas desnecessárias:
  - chave interna do documento;
  - código filial;
  - documento OS;
  - do depósito;
  - nome do depósito;
  - para depósito;
  - nome para depósito;
  - itens detalhados que duplicavam linha;
  - criado por código usuário;
  - data/hora atualização;
  - atualizado por nome usuário.

Também pediu posteriormente incluir código do item da OS:

```sql
OSCL."itemCode"
```

Campo da tela confirmado no print:

```text
OSCL.itemCode
```

---

## 9. Erros SAP encontrados

### 9.1 Erro OACT

Mensagem:

```text
Nenhum registro concordante encontrado 'Contas do Razão' (OACT) (ODBC -2028)
```

Interpretação:

- há conta contábil ausente/inválida na determinação contábil;
- erro ocorre antes da emissão efetiva;
- revisar conta razão em item, depósito, grupo de item, filial, imposto ou determinação contábil.

### 9.2 Erro ECM2

Mensagem:

```text
Nenhum registro concordante encontrado '' (ECM2) (ODBC -2028)
```

Interpretação:

- problema de configuração fiscal/eletrônica;
- não é erro de transmissão em si;
- revisar mapeamento/regra fiscal eletrônica, modelo, sequência, filial, CFOP/imposto ou configuração relacionada ao add-on fiscal.

---

## 10. Query de Pedido de Venda aprovada com custos

### 10.1 Campos de custo do pedido de venda

Campos de custo identificados no pedido de venda:

- `PV."U_MM_Material"` — Material;
- `PV."U_MM_MO_DIRETA"` — MO Direta;
- `PV."U_MM_MO_INDIRETA"` — MO Indireta;
- `PV."U_MM_Alimentacao"` — Alimentação;
- `PV."U_MM_Hospedagem"` — Hospedagem;
- `PV."U_MM_Equipamento"` — Equipamento/Locação;
- `PV."U_MM_Deslocamento"` — Deslocamento;
- `PV."U_MM_Frete"` — Frete;
- `PV."U_MM_Servicos"` — Serviços;
- `PV."U_MM_Pedagio"` — Pedágios.

### 10.2 Regra de divisão dos custos

Inicialmente foi cogitado rateio proporcional por valor, mas o usuário rejeitou.

Regra definida:

- dividir custos pela quantidade de centros de custo distintos no pedido;
- se tiver 2 centros de custo, dividir 50% / 50%;
- se tiver 3, dividir 33,33% / 33,33% / 33,33%.

Motivo:

- certos centros de custo como revenda não possuem atribuição natural para MO direta/indireta/alimentação/hospedagem;
- divisão igual por quantidade de centros ficou mais coerente para análise gerencial.

Exemplo de fórmula:

```sql
ROUND(IFNULL(PV."U_MM_Material", 0) / NULLIF(CC."QtdCentrosCusto", 0), 2) AS "Material"
```

---

## 11. Projeto gerencial vs projeto financeiro

Em query de NF foi adicionada coluna de projeto após `Pedido_Venda`.

Problema encontrado:

- seta amarela estava abrindo o projeto financeiro, não o projeto gerencial.

Tela desejada:

```text
Gerenciamento de projetos > Projeto
```

O projeto gerencial é do módulo de gerenciamento de projetos, exemplo `6185`.

Atenção:

- `OPMG.FIPROJECT` representa vínculo com projeto financeiro e pode duplicar documentos;
- se usar `OPMG`, usar ranking/controle para evitar duplicidade;
- para seta correta no SAP B1, o campo precisa corresponder ao objeto/tabela do módulo de projeto gerencial, não apenas ao projeto financeiro.

---

## 12. Recomendações para continuar em outro Codex

Ao iniciar outro chat, informar:

1. “Estou trabalhando com SAP Business One HANA e LOC1.”
2. “Tenho queries já aprovadas pela diretoria, então não quero mudanças estruturais desnecessárias.”
3. “Preciso preservar setas amarelas de acesso quando possível.”
4. “NF de venda futura pura não compõe faturamento/meta.”
5. “Venda futura pura é identificada por CFOP `5922/6922` sem entrega vinculada.”
6. “NF com entrega vinculada via `ODLN/DLN1` deve continuar entrando como entrega.”
7. “A query `FATURAMENTO DREXMETAS` tem sua própria CTE `NF_BASE`, então precisa receber a mesma regra da query oficial de NF.”
8. “Para OS/equipamento, pedidos de transferência vêm de `OWTQ/WTQ1`, pedidos de venda iClass vêm de `SCL4` + `ORDR/RDR1`.”
9. “Criador da OS no LOC1 vem da tabela `@LOC1_CHLO`, operação `Add`, tabela `OSCL`.”

---

## 13. Prompt sugerido para novo chat do Codex

Copiar e colar no novo chat:

```text
Estou migrando um trabalho de queries SAP Business One HANA / LOC1.

Use o arquivo MEMORIA_TECNICA_TRANSFERENCIA_CODEX_SAP_B1_HANA_LOC1_2026-09-11.md como contexto técnico principal.

Pontos críticos:
- não alterar estrutura de queries aprovadas sem necessidade;
- preservar setas amarelas de acesso do SAP B1;
- NF de venda futura pura, CFOP 5922/6922 sem entrega vinculada, não deve compor faturamento/meta;
- NF com entrega vinculada via ODLN/DLN1 deve continuar entrando como Nota Fiscal de Entrega;
- NF de saída normal continua entrando;
- DREXMETAS possui CTE própria NF_BASE e precisa replicar a mesma lógica do relatório oficial de NF;
- em relatório de OS/equipamento, custos vêm de pedido de transferência, pedido de venda gerado por OS e pedido de venda iClass relacionado via SCL4.

Quero continuar a partir desse conhecimento, sem recomeçar do zero.
```

---

## 14. Checklist rápido de validação

Quando alterar uma query de faturamento:

- [ ] Conferir se a NF futura pura com CFOP `5922` saiu.
- [ ] Conferir se NFs reais do mesmo pedido continuam.
- [ ] Conferir se valores de NFs que permaneceram não mudaram.
- [ ] Conferir se não houve duplicação por linhas.
- [ ] Conferir se período/data de referência está correto.
- [ ] Conferir se a DREXMETAS recebeu a mesma regra da query analítica.
- [ ] Conferir se `TaxOnly` continua filtrado.
- [ ] Conferir se departamentos oficiais continuam no filtro:
  - `GERADOR`
  - `NOBREAK`
  - `LOCACAO`
  - `EXE_ELET`
  - `FOTOV`
  - `REV_DIRE`
  - `SEMINOVO`

---

## 15. Observações finais

O ponto mais importante aprendido é que o tipo visual da tela do SAP nem sempre aparece diretamente como campo simples na query.

Para diferenciar corretamente as NFs:

- não confiar apenas em `Utilizacao`;
- não confiar apenas no tipo exibido na tela;
- usar CFOP para venda futura;
- usar vínculo `ODLN/DLN1` para entrega;
- manter a análise por documento de NF, não por pedido, para não remover faturamentos reais do mesmo pedido.

---

## 16. Linha do tempo dos principais aprendizados

Esta seção registra a evolução do raciocínio, pois algumas conclusões importantes só ficaram claras depois de testes e auditorias.

### 16.1 Início: query oficial de NF validada pela diretoria

Havia uma query oficial de NF já validada pela diretoria. Por esse motivo, toda alteração posterior teve que respeitar a regra:

- não trocar a base principal sem necessidade;
- não remover colunas relevantes;
- não mudar nomes já utilizados por relatórios;
- não alterar filtros validados sem evidência;
- criar melhorias incrementais.

A query original tratava apenas duas situações:

```sql
CASE
    WHEN ENT."Num_Documento_Entrega" IS NOT NULL
    THEN 'Nota Fiscal de Entrega Futura com Entrega Vinculada'
    ELSE 'Nota Fiscal de Saida'
END AS "Tipo_Nota_Fiscal"
```

Problema:

- tudo que não possuía entrega vinculada caía como `Nota Fiscal de Saida`;
- isso classificava venda futura pura como saída;
- consequentemente, inflava faturamento/meta.

### 16.2 Descoberta do erro com a NF 5865

O usuário apontou que a NF interna `5865`, documento SAP `3587`, não era NF de saída.

Dados identificados no relatório:

```text
Num_Interno_NF: 5865
Num_Documento_SAP: 3587
Numero_Nota_Fiscal: 14869
Data_Emissao: 10/09/2026
Cliente: POLIFRIGOR INDUSTRIA E COMERCIO DE ALIMENTOS LTDA
Pedido_Venda: 8791
Tipo_Pedido: Venda (Avulsa)
Departamento: EXE_ELET
Utilizacao: S Venda Produção
Valor_NFe_ML: 2.341.555,83
```

Mesmo com utilização `S Venda Produção`, o documento era `NF de entrega futura`.

Conclusão:

- `Utilizacao` não é suficiente para identificar venda futura.

### 16.3 Levantamento de CFOPs

Foi criado um SELECT para listar todos os CFOPs, códigos de imposto, departamentos, utilizações, quantidade de NFs e valores.

Objetivo:

- descobrir se a classificação por CFOP seria mais confiável;
- evitar depender apenas da descrição da utilização;
- tornar a query mais resiliente.

Resultado importante:

- CFOP `5922` apareceu com várias utilizações diferentes:
  - `S Venda Entr. Futura`;
  - `S Venda Produção`;
  - `S Revenda`.

Conclusão:

- CFOP deve ser a regra principal para venda futura;
- utilização pode ser usada apenas como apoio, não como critério principal.

### 16.4 Validação do pedido 1569

O pedido `1569` foi usado como caso crítico, porque tinha mais de uma NF relacionada.

Mapa de relações do SAP:

- Cotação de vendas `607`;
- Pedido de venda `1569`;
- NF de entrega futura `643`;
- NF de saída `1409`;
- NF de saída `2208`;
- contas a receber vinculadas.

Auditoria por query:

| Num Interno NF | Doc SAP | Nota Fiscal | Data | Pedido | CFOP | Utilização | Valor | Ação |
|---:|---:|---:|---|---:|---:|---|---:|---|
| 1098 | 643 | 14023 | 17/04/2026 | 1569 | 5922 | S Revenda | 103.898,62 | Sair |
| 2358 | 1409 | 4850 | 21/05/2026 | 1569 | 5949 | S Locação | 1.979,53 | Entrar |
| 3668 | 2208 | 18608 | 29/06/2026 | 1569 | 5933 | S P.S. Inst.Eletrica | 27.272,91 | Entrar |

Conclusão crítica:

- nunca remover o pedido de venda inteiro;
- remover apenas a NF futura pura;
- outras NFs reais do mesmo pedido devem continuar compondo o relatório.

### 16.5 Auditoria entre query antiga e query revisada

Comparação realizada com arquivos exportados do SAP:

- query antiga aprovada;
- query revisada com regra de CFOP.

Resultado:

| Métrica | Query antiga | Query revisada | Diferença |
|---|---:|---:|---:|
| Linhas | 2.625 | 2.623 | -2 |
| Valor total | 23.462.560,98 | 21.017.106,53 | -2.445.454,45 |
| NFs adicionadas | 0 | 0 | 0 |
| Valores alterados nas NFs em comum | 0 | 0 | 0 |

NFs removidas:

| Num Interno NF | Doc SAP | Nota Fiscal | Cliente | Pedido | Valor |
|---:|---:|---:|---|---:|---:|
| 1098 | 643 | 14023 | VILA NOVA MAX SUPERMERCADOS LTDA. | 1569 | 103.898,62 |
| 5865 | 3587 | 14869 | POLIFRIGOR IND. E COM. DE ALIMENTOS LTDA | 8791 | 2.341.555,83 |

Resultado aceito:

- a NF `1098` deve sair mesmo;
- a NF `5865` também deve sair;
- as NFs `1409` e `2208` do pedido `1569` devem permanecer.

---

## 17. Query de auditoria dos CFOPs

Esta query foi usada para entender todos os CFOPs existentes no período e deve ser preservada para futuras auditorias.

```sql
SELECT
    TO_VARCHAR(I1."CFOPCode") AS "CFOP",

    I1."TaxCode" AS "Codigo_Imposto",

    IFNULL(I1."OcrCode", R1."OcrCode") AS "Departamento",

    U."Usage" AS "Utilizacao",

    COUNT(DISTINCT T0."DocEntry") AS "Qtd_NFs",

    COUNT(*) AS "Qtd_Linhas",

    SUM(I1."LineTotal") AS "Valor_Linhas",

    SUM(
        CASE
            WHEN RNF."LinhaControle" = 1
            THEN T0."NfeValue"
            ELSE 0
        END
    ) AS "Valor_NFe_ML",

    MIN(T0."DocDate") AS "Primeira_Data_Emissao",

    MAX(T0."DocDate") AS "Ultima_Data_Emissao"

FROM OINV T0

INNER JOIN INV1 I1
    ON I1."DocEntry" = T0."DocEntry"

LEFT JOIN RDR1 R1
    ON I1."BaseType" = 17
    AND I1."BaseEntry" = R1."DocEntry"
    AND I1."BaseLine" = R1."LineNum"

LEFT JOIN OUSG U
    ON U."ID" = I1."Usage"

INNER JOIN (
    SELECT
        I1_RNF."DocEntry",
        I1_RNF."LineNum",

        ROW_NUMBER() OVER (
            PARTITION BY I1_RNF."DocEntry"
            ORDER BY I1_RNF."LineNum"
        ) AS "LinhaControle"

    FROM INV1 I1_RNF
) RNF
    ON RNF."DocEntry" = I1."DocEntry"
    AND RNF."LineNum" = I1."LineNum"

WHERE
    T0."DocDate" BETWEEN '[%0]' AND '[%1]'

    AND T0."CANCELED" = 'N'

    AND IFNULL(I1."TaxOnly", 'N') <> 'Y'
    AND IFNULL(U."TaxOnly", 'N') <> 'Y'

GROUP BY
    TO_VARCHAR(I1."CFOPCode"),
    I1."TaxCode",
    IFNULL(I1."OcrCode", R1."OcrCode"),
    U."Usage"

ORDER BY
    TO_VARCHAR(I1."CFOPCode"),
    I1."TaxCode",
    IFNULL(I1."OcrCode", R1."OcrCode"),
    U."Usage";
```

Uso recomendado:

- rodar antes de alterar regra fiscal;
- verificar se surgiram novos CFOPs de venda futura;
- verificar se surgiram novos CFOPs de remessa/entrega;
- conferir divergências entre utilização e CFOP.

---

## 18. Query de auditoria por pedido de venda específico

Foi usada para auditar o pedido `1569`, mas serve para qualquer pedido.

Alterar:

```sql
PV."DocNum" = 1569
```

para o pedido desejado.

```sql
SELECT
    T0."DocEntry" AS "Num_Interno_NF",
    T0."DocNum" AS "Num_Documento_SAP",
    T0."Serial" AS "Numero_Nota_Fiscal",
    T0."DocDate" AS "Data_Emissao",

    PV."DocNum" AS "Pedido_Venda",

    TO_VARCHAR(I1."CFOPCode") AS "CFOP",
    I1."TaxCode" AS "Codigo_Imposto",

    IFNULL(I1."OcrCode", R1."OcrCode") AS "Departamento",
    U."Usage" AS "Utilizacao",

    T0."NfeValue" AS "Valor_NFe_ML",

    CASE
        WHEN TO_VARCHAR(I1."CFOPCode") IN ('5922', '6922')
        THEN 'Sair do relatorio: NF de venda futura'

        ELSE 'Compor relatorio: NF de saida'
    END AS "Auditoria_Relatorio"

FROM OINV T0

INNER JOIN INV1 I1
    ON I1."DocEntry" = T0."DocEntry"

LEFT JOIN RDR1 R1
    ON I1."BaseType" = 17
    AND I1."BaseEntry" = R1."DocEntry"
    AND I1."BaseLine" = R1."LineNum"

LEFT JOIN ORDR PV
    ON PV."DocEntry" = I1."BaseEntry"
    AND I1."BaseType" = 17

LEFT JOIN OUSG U
    ON U."ID" = I1."Usage"

WHERE
    PV."DocNum" = 1569
    AND T0."CANCELED" = 'N'

ORDER BY
    T0."DocDate",
    T0."DocNum";
```

Observação:

- esta query não substitui o relatório oficial;
- ela serve para explicar, NF por NF, o que está compondo ou saindo.

---

## 19. Query oficial de NF — versão final consolidada

Esta é a versão final consolidada que foi entregue para atualizar a query oficial aprovada.

Pontos de controle:

- mantém estrutura base da query aprovada;
- adiciona `CFOP`;
- adiciona flags internas para classificação;
- remove venda futura pura;
- mantém saída normal;
- mantém entrega vinculada.

```sql
SELECT
    T0."DocEntry" AS "Num_Interno_NF",
    T0."DocNum" AS "Num_Documento_SAP",
    T0."Serial" AS "Numero_Nota_Fiscal",

    T0."DocDate" AS "Data_Emissao",

    CASE
        WHEN ENT."Data_Entrega" IS NOT NULL
        THEN ENT."Data_Entrega"
        ELSE T0."DocDate"
    END AS "Data_Referencia_Faturamento",

    T0."CardCode" AS "Cod_Cliente",
    T0."CardName" AS "Nome_Cliente",

    CASE
        WHEN UPPER(IFNULL(FIL."BPLName", '')) LIKE '%ENGENHARIA%'
        THEN 'Sistel Engenharia'

        WHEN UPPER(IFNULL(FIL."BPLName", '')) LIKE '%COMERCIO%'
          OR UPPER(IFNULL(FIL."BPLName", '')) LIKE '%COMÉRCIO%'
        THEN 'Sistel Comercio'

        ELSE IFNULL(FIL."BPLName", 'Nao Definido')
    END AS "Filial",

    CASE
        WHEN ENT."Num_Documento_Entrega" IS NOT NULL
        THEN 'Nota Fiscal de Entrega'

        WHEN LIN."FlagEntregaCFOP" = 1
        THEN 'Nota Fiscal de Entrega'

        WHEN LIN."FlagVendaFutura" = 1
        THEN 'Nota Fiscal de Venda Futura'

        ELSE 'Nota Fiscal de Saida'
    END AS "Tipo_Nota_Fiscal",

    LIN."CFOP" AS "CFOP",

    PV."DocNum" AS "Pedido_Venda",

    CASE
        WHEN PV."U_MM_Tipo" = '0' THEN 'Nao Definido'
        WHEN PV."U_MM_Tipo" = '2' THEN 'Aditivo'
        WHEN PV."U_MM_Tipo" = '3' THEN 'Pre-Contrato'
        WHEN PV."U_MM_Tipo" = '4' THEN 'Gerado por OS (Pre-Consumo)'
        WHEN PV."U_MM_Tipo" = '5' THEN 'Venda (Avulsa)'
        WHEN PV."U_MM_Tipo" = '6' THEN 'Faturamento LOC1'
        WHEN PV."U_MM_Tipo" = '9' THEN 'Precor'
        WHEN PV."U_MM_Tipo" = '10' THEN 'Integrado por Iclass'
        WHEN PV."U_MM_Tipo" = '7' THEN 'Ajuste interno'
        WHEN PV."U_MM_Tipo" = '8' THEN 'Duplicado'
        WHEN PV."U_MM_Tipo" = '11' THEN 'Cancelado'
        WHEN PV."U_MM_Tipo" IS NULL THEN 'Sem Pedido de Venda'
        ELSE 'Nao Definido'
    END AS "Tipo_Pedido",

    LIN."Departamento" AS "Departamento",

    LIN."Utilizacao" AS "Utilizacao",

    CASE
        WHEN ENT."Valor_Entrega" IS NOT NULL
        THEN ENT."Valor_Entrega"
        ELSE T0."NfeValue"
    END AS "Valor_NFe_ML",

    ENT."Num_Interno_Entrega" AS "Num_Interno_Entrega",
    ENT."Num_Documento_Entrega" AS "Num_Documento_Entrega",
    ENT."Data_Entrega" AS "Data_Entrega",

    CASE
        WHEN PV."DocNum" IS NULL
        THEN 'Validar: NF sem vinculo com Pedido de Venda'

        WHEN ENT."Num_Documento_Entrega" IS NOT NULL
        THEN 'OK: NF de entrega vinculada'

        ELSE 'OK: NF vinculada ao Pedido de Venda'
    END AS "Status_Vinculo_Pedido"

FROM OINV T0

LEFT JOIN OBPL FIL
    ON FIL."BPLId" = T0."BPLId"

INNER JOIN (
    SELECT
        X."DocEntryNF",
        X."DocEntryPV",
        X."Departamento",
        X."Utilizacao",
        X."CFOP",
        X."FlagVendaFutura",
        X."FlagEntregaCFOP"

    FROM (
        SELECT
            I1."DocEntry" AS "DocEntryNF",

            CASE
                WHEN I1."BaseType" = 17
                THEN I1."BaseEntry"
                ELSE NULL
            END AS "DocEntryPV",

            IFNULL(I1."OcrCode", R1."OcrCode") AS "Departamento",

            U."Usage" AS "Utilizacao",

            TO_VARCHAR(I1."CFOPCode") AS "CFOP",

            MAX(
                CASE
                    WHEN TO_VARCHAR(I1."CFOPCode") IN ('5922', '6922')
                    THEN 1
                    ELSE 0
                END
            ) OVER (PARTITION BY I1."DocEntry") AS "FlagVendaFutura",

            MAX(
                CASE
                    WHEN TO_VARCHAR(I1."CFOPCode") IN ('5908', '6908')
                    THEN 1
                    ELSE 0
                END
            ) OVER (PARTITION BY I1."DocEntry") AS "FlagEntregaCFOP",

            ROW_NUMBER() OVER (
                PARTITION BY I1."DocEntry"
                ORDER BY
                    I1."LineNum"
            ) AS "LinhaControle"

        FROM INV1 I1

        LEFT JOIN RDR1 R1
            ON I1."BaseType" = 17
            AND I1."BaseEntry" = R1."DocEntry"
            AND I1."BaseLine" = R1."LineNum"

        LEFT JOIN OUSG U
            ON U."ID" = I1."Usage"

        WHERE
            IFNULL(I1."OcrCode", R1."OcrCode") IN (
                'GERADOR',
                'NOBREAK',
                'LOCACAO',
                'EXE_ELET',
                'FOTOV',
                'REV_DIRE',
                'SEMINOVO'
            )

            AND IFNULL(I1."TaxOnly", 'N') <> 'Y'
            AND IFNULL(U."TaxOnly", 'N') <> 'Y'
    ) X

    WHERE
        X."LinhaControle" = 1
) LIN
    ON LIN."DocEntryNF" = T0."DocEntry"

LEFT JOIN ORDR PV
    ON PV."DocEntry" = LIN."DocEntryPV"

LEFT JOIN (
    SELECT
        X."DocEntryNFOrigem",
        X."Num_Interno_Entrega",
        X."Num_Documento_Entrega",
        X."Data_Entrega",
        X."Valor_Entrega"

    FROM (
        SELECT
            D1."BaseEntry" AS "DocEntryNFOrigem",
            E0."DocEntry" AS "Num_Interno_Entrega",
            E0."DocNum" AS "Num_Documento_Entrega",
            E0."DocDate" AS "Data_Entrega",
            E0."DocTotal" AS "Valor_Entrega",

            ROW_NUMBER() OVER (
                PARTITION BY D1."BaseEntry"
                ORDER BY
                    E0."DocDate" DESC,
                    E0."DocNum" DESC
            ) AS "LinhaControle"

        FROM ODLN E0

        INNER JOIN DLN1 D1
            ON D1."DocEntry" = E0."DocEntry"

        WHERE
            D1."BaseType" = 13
            AND E0."CANCELED" = 'N'
    ) X

    WHERE
        X."LinhaControle" = 1
) ENT
    ON ENT."DocEntryNFOrigem" = T0."DocEntry"

WHERE
    CASE
        WHEN ENT."Data_Entrega" IS NOT NULL
        THEN ENT."Data_Entrega"
        ELSE T0."DocDate"
    END BETWEEN '[%0]' AND '[%1]'

    AND T0."CANCELED" = 'N'

    AND NOT (
        LIN."FlagVendaFutura" = 1
        AND ENT."Num_Documento_Entrega" IS NULL
    )

ORDER BY
    "Data_Referencia_Faturamento" DESC,
    T0."DocNum";
```

---

## 20. DREXMETAS — bloco NF_BASE final e regra de alinhamento

Na query `FATURAMENTO DREXMETAS`, não basta atualizar a query oficial de NF. É necessário replicar a regra dentro da CTE `NF_BASE`.

### 20.1 Estrutura da DREXMETAS

A query possui estas CTEs:

- `M`: metas e retroativos por departamento;
- `ENT`: entregas vinculadas a NF futura;
- `NF_BASE`: base fiscal usada no realizado;
- `A`: consolidação mensal por centro de custo;
- `R`: linhas de meta e realizado por departamento;
- `S`: somatória EXE/FV/RVD/SN;
- `T`: subtotal geral;
- SELECT final.

### 20.2 Regra crítica da NF_BASE

Dentro da subquery `X` da `NF_BASE`, incluir:

```sql
MAX(
    CASE
        WHEN TO_VARCHAR(T1."CFOPCode") IN ('5922', '6922')
        THEN 1
        ELSE 0
    END
) OVER (PARTITION BY T0."DocEntry") AS "FlagVendaFutura"
```

E fora da subquery `X`, no filtro final da `NF_BASE`, usar:

```sql
WHERE
    X."LinhaControle" = 1

    AND NOT (
        X."FlagVendaFutura" = 1
        AND X."Num_Documento_Entrega" IS NULL
    )
```

### 20.3 Por que a regra fica na NF_BASE?

Porque a DREXMETAS soma o realizado a partir de:

```sql
SUM(NF."NfeValue") AS "AcumuladoSAP"
```

Se a NF futura pura entrar na `NF_BASE`, ela entra no realizado/meta. Por isso o filtro precisa acontecer antes da CTE `A`.

### 20.4 Atenção aos retroativos

A DREXMETAS soma retroativos manualmente em janeiro e fevereiro:

```sql
IFNULL(A."Jan", 0) + M."RetroJan" AS "Jan",
IFNULL(A."Fev", 0) + M."RetroFev" AS "Fev"
```

Esses valores não vêm da NF_BASE. Portanto:

- a regra de CFOP afeta apenas o faturamento vindo do SAP no ano corrente;
- os retroativos continuam iguais;
- se houver erro nos retroativos, precisa ajustar manualmente na CTE `M`.

---

## 21. Regras por tipo de documento fiscal

### 21.1 Nota Fiscal de Saída

Conceito de negócio:

- nota fiscal que efetivamente compõe faturamento;
- entra no fechamento mensal;
- entra na meta;
- normalmente usa `OINV."NfeValue"`;
- data de referência normalmente é `OINV."DocDate"`.

Regra SQL:

```sql
ELSE 'Nota Fiscal de Saida'
```

Desde que:

- não seja CFOP `5922/6922` sem entrega vinculada;
- não seja identificada como entrega/remessa;
- não esteja cancelada.

### 21.2 Nota Fiscal de Venda Futura

Conceito de negócio:

- não tem valor contábil para faturamento/meta;
- usada para cliente pagar entrada ou iniciar processo interno;
- não deve compor realizado;
- pode estar baseada em pedido de venda ou proposta;
- pode ter contas a receber, mas não representa faturamento realizado para meta.

Regra SQL:

```sql
LIN."FlagVendaFutura" = 1
AND ENT."Num_Documento_Entrega" IS NULL
```

CFOPs:

- `5922`;
- `6922`.

Tratamento:

- sair da query oficial de faturamento;
- sair da DREXMETAS;
- permanecer apenas em relatórios de auditoria se necessário.

### 21.3 Nota Fiscal de Entrega

Conceito de negócio:

- documento de entrega/remessa real;
- normalmente representa a entrega posterior a uma NF futura;
- deve compor o faturamento quando vinculada corretamente;
- data de referência deve ser data da entrega;
- valor deve usar a entrega quando existir.

Regra principal:

```sql
ENT."Num_Documento_Entrega" IS NOT NULL
```

Vínculo:

```sql
ODLN E0
DLN1 D1
D1."BaseType" = 13
D1."BaseEntry" = OINV."DocEntry"
```

Regra auxiliar por CFOP:

```sql
TO_VARCHAR(CFOP) IN ('5908', '6908')
```

---

## 22. Riscos conhecidos e armadilhas

### 22.1 Não remover pedido inteiro

Erro possível:

- filtrar `ORDR`/pedido quando encontrar venda futura.

Por que é errado:

- um mesmo pedido pode ter NF futura e NFs de saída reais;
- exemplo: pedido `1569`.

Forma correta:

- filtrar documento de NF individualmente.

### 22.2 Não depender somente da utilização

Erro possível:

```sql
UPPER(U."Usage") LIKE '%ENTREGA FUTURA%'
```

Por que é frágil:

- CFOP `5922` apareceu com utilização `S Venda Produção`;
- CFOP `5922` apareceu com utilização `S Revenda`;
- a descrição depende do cadastro/uso operacional.

Forma correta:

- usar CFOP para venda futura;
- usar vínculo `ODLN/DLN1` para entrega.

### 22.3 Cuidado com duplicidade por linha de NF

`OINV` é cabeçalho, `INV1` são linhas.

Se somar `OINV."NfeValue"` depois de juntar com `INV1`, pode duplicar valor.

Forma usada:

```sql
ROW_NUMBER() OVER (
    PARTITION BY I1."DocEntry"
    ORDER BY I1."LineNum"
) AS "LinhaControle"
```

Depois filtrar:

```sql
WHERE X."LinhaControle" = 1
```

### 22.4 Cuidado com centros de custo

Departamento pode vir de:

```sql
I1."OcrCode"
R1."OcrCode"
D1."OcrCode"
R1F."OcrCode"
```

Na DREXMETAS foi usado:

```sql
IFNULL(
    T1."OcrCode",
    IFNULL(
        R1."OcrCode",
        IFNULL(D1."OcrCode", R1F."OcrCode")
    )
) AS "OcrCode"
```

Essa regra preserva o centro de custo pela cadeia:

- NF direta;
- pedido de venda;
- entrega;
- NF futura original;
- pedido original da NF futura.

### 22.5 Cuidado com `TaxOnly`

A regra atual remove linhas apenas fiscais:

```sql
AND IFNULL(I1."TaxOnly", 'N') <> 'Y'
AND IFNULL(U."TaxOnly", 'N') <> 'Y'
```

Não remover sem validação, pois pode alterar o valor do relatório.

---

## 23. Glossário rápido dos principais campos SAP B1 usados

### 23.1 OINV — Notas fiscais de saída

| Campo | Uso |
|---|---|
| `DocEntry` | chave interna da NF |
| `DocNum` | número do documento SAP |
| `Serial` | número da nota fiscal |
| `DocDate` | data de emissão |
| `CardCode` | código do cliente |
| `CardName` | nome do cliente |
| `BPLId` | filial |
| `NfeValue` | valor da NF |
| `CANCELED` | cancelamento |

### 23.2 INV1 — Linhas da NF

| Campo | Uso |
|---|---|
| `DocEntry` | vínculo com OINV |
| `LineNum` | linha da NF |
| `BaseType` | tipo do documento origem |
| `BaseEntry` | chave do documento origem |
| `BaseLine` | linha do documento origem |
| `OcrCode` | centro de custo/departamento |
| `Usage` | utilização |
| `TaxOnly` | linha apenas fiscal |
| `CFOPCode` | CFOP |
| `TaxCode` | código de imposto |

### 23.3 ORDR — Pedido de venda

| Campo | Uso |
|---|---|
| `DocEntry` | chave interna do pedido |
| `DocNum` | número do pedido |
| `U_MM_Tipo` | tipo do pedido |
| `U_MM_Faturamento` | liberar faturamento |
| `DocTotal` | total do pedido |
| `Project` | projeto financeiro/gerencial dependendo contexto |

Tipos de pedido usados:

| Código | Descrição |
|---:|---|
| 0 | Nao Definido |
| 2 | Aditivo |
| 3 | Pre-Contrato |
| 4 | Gerado por OS (Pre-Consumo) |
| 5 | Venda (Avulsa) |
| 6 | Faturamento LOC1 |
| 7 | Ajuste interno |
| 8 | Duplicado |
| 9 | Precor |
| 10 | Integrado por Iclass |
| 11 | Cancelado |

### 23.4 RDR1 — Linhas do pedido de venda

| Campo | Uso |
|---|---|
| `DocEntry` | vínculo com ORDR |
| `LineNum` | linha do pedido |
| `ItemCode` | código do item |
| `Dscription` | descrição do item |
| `OcrCode` | centro de custo |
| `LineTotal` | valor da linha |
| `Quantity` | quantidade |

### 23.5 ODLN / DLN1 — Entregas

| Campo | Uso |
|---|---|
| `ODLN.DocEntry` | chave interna da entrega |
| `ODLN.DocNum` | número da entrega |
| `ODLN.DocDate` | data da entrega |
| `ODLN.DocTotal` | valor da entrega |
| `DLN1.BaseType` | tipo do documento origem |
| `DLN1.BaseEntry` | chave do documento origem |
| `DLN1.BaseLine` | linha do documento origem |

Regra para entrega baseada em NF:

```sql
DLN1."BaseType" = 13
DLN1."BaseEntry" = OINV."DocEntry"
```

### 23.6 OUSG — Utilização

| Campo | Uso |
|---|---|
| `ID` | chave da utilização |
| `Usage` | descrição da utilização |
| `TaxOnly` | indicador fiscal |

### 23.7 OBPL — Filial

| Campo | Uso |
|---|---|
| `BPLId` | chave da filial |
| `BPLName` | nome da filial |

Regra de padronização:

```sql
CASE
    WHEN UPPER(IFNULL(FIL."BPLName", '')) LIKE '%ENGENHARIA%'
    THEN 'Sistel Engenharia'

    WHEN UPPER(IFNULL(FIL."BPLName", '')) LIKE '%COMERCIO%'
      OR UPPER(IFNULL(FIL."BPLName", '')) LIKE '%COMÉRCIO%'
    THEN 'Sistel Comercio'

    ELSE IFNULL(FIL."BPLName", 'Nao Definido')
END
```

---

## 24. Relatório DE/PARA Pedido de Venda x NF para locação

Foi solicitado criar um relatório novo para cruzar:

- pedido de venda;
- tipo pré-contrato;
- item relacionado à locação;
- emissão de NF.

Objetivo:

- saber quando o faturamento foi realizado;
- acompanhar locações avulsas de curto prazo;
- identificar pedidos de locação que deveriam estar como `Pré-Contrato`;
- cruzar pedido de venda com NF emitida.

Regra inicial criada:

- base por `ORDR`/`RDR1`;
- filtrar linhas de locação por:
  - `RDR1."OcrCode" = 'LOCACAO'`;
  - ou utilização contendo `LOCACAO`/`LOCAÇÃO`;
  - ou descrição contendo `LOCACAO`/`LOCAÇÃO`.

Classificação de prazo inicialmente sugerida:

```sql
CASE
    WHEN DAYS_BETWEEN(PV."DocDate", PV."DocDueDate") <= 31
    THEN 'Locacao Curto Prazo'
    ELSE 'Locacao Prazo Maior'
END AS "Classificacao_Prazo"
```

Mas foi explicado que esse critério era inferência, não regra oficial. Caso exista regra real no LOC1/SAP, substituir.

---

## 25. Regras de OS/equipamento em mais detalhes

### 25.1 Problema inicial

O caminho inicial estava errado porque tentava relacionar documentos de forma genérica sem partir da OS/equipamento.

O usuário corrigiu a direção:

> começar mapeando código do equipamento e todas as OS abertas que relacionam esse equipamento com as informações vindas do cartão de equipamento.

### 25.2 Entidades do relatório

O relatório desejado conecta:

1. Contrato de serviço;
2. Cartão de equipamento;
3. Relatório do cartão de equipamento;
4. Pedido de transferência de estoque;
5. Pedido de venda gerado por OS;
6. Pedido de venda gerado pelo iClass;
7. Custos de materiais e mão de obra.

### 25.3 Colunas removidas por decisão do usuário

O usuário pediu remover:

- `Status Cartao Codigo`;
- `Status OS Codigo`;
- `Numero Serie Interno`;
- `Custo Total Vida Equipamento`;
- não repetir número de OS;
- consolidar valor por OS;
- não multiplicar pedidos de transferência por linha.

### 25.4 Centro de custo da OS

O usuário pediu:

- `Centro Custo OS` deve aparecer por extenso, não apenas número/código.

Exemplo de tradução:

```sql
CASE
    WHEN OS."OcrCode" = 'GERADOR' THEN 'Gerador'
    WHEN OS."OcrCode" = 'NOBREAK' THEN 'Nobreak'
    WHEN OS."OcrCode" = 'LOCACAO' THEN 'Locacao'
    WHEN OS."OcrCode" = 'EXE_ELET' THEN 'Execucao Eletrica'
    WHEN OS."OcrCode" = 'FOTOV' THEN 'Fotovoltaico'
    WHEN OS."OcrCode" = 'REV_DIRE' THEN 'Revenda Direta'
    WHEN OS."OcrCode" = 'SEMINOVO' THEN 'Seminovo'
    ELSE OS."OcrCode"
END
```

### 25.5 Pedido de venda gerado por OS

Aprendizado:

- pedido de venda gerado por OS é 1 para 1;
- pedido atende uma única OS;
- não pode repetir em várias linhas;
- custo total da OS deve ser consolidado.

### 25.6 Pedido de transferência

Aprendizado:

- pode haver vários pedidos de transferência para uma única OS;
- exemplo citado: pedidos `676`, `671`, `670`, `669` pertenciam ao cliente e não apareciam inicialmente;
- vínculo correto é por `OWTQ."U_MM_OS"`.

### 25.7 Pedido de venda iClass

Primeira tentativa retornou vazio porque buscou vínculo no lugar errado.

Correção:

- documentos ficam na aba `Documentos relacionados` do chamado de serviço;
- usar `SCL4`.

Vínculo:

```sql
SCL4."SrcvCallID" = OSCL."callID"
SCL4."Object" = '17'
SCL4."DocAbs" = ORDR."DocEntry"
```

Itens:

```sql
RDR1."ItemCode" IN ('SV000045', 'SV000044')
```

Campos desejados:

- um campo com os dois itens concatenados, se houver;
- quantidade somada;
- custo calculado a R$ 35,00/hora;
- quantidade vem em minutos.

Fórmula:

```sql
ROUND((SUM(RDR1."Quantity") / 60) * 35.00, 2)
```

---

## 26. LOC1 — log de criação da OS

### 26.1 Objetivo

Trazer no relatório quem criou a OS no LOC1.

### 26.2 Descoberta

O log da OS no LOC1 está na tabela:

```sql
"@LOC1_CHLO"
```

Filtros:

```sql
UPPER(IFNULL(L."U_Operation", '')) = 'ADD'
AND UPPER(IFNULL(L."U_DataTable", '')) = 'OSCL'
AND IFNULL(L."U_DataCode", '') <> ''
```

O campo `U_DataCode` guarda a OS.

### 26.3 Exemplo validado

```text
Data Log: 04/09/2026
Usuario LOC1: MARIANA ANDREOLLI
Operacao: Add
Codigo Dados: 9290
Tabela Dados: OSCL
Log LOC1: Chamado de Serviço adicionado: 9290 Dados LOC1 processados
```

### 26.4 CTE final recomendada

```sql
LOC1_CRIADOR_OS_RANK AS (
    SELECT
        L."U_DataCode" AS "NumeroOSTexto",
        L."U_User" AS "CriadoPorLOC1",
        L."U_LogDate" AS "DataCriacaoLOC1",
        ROW_NUMBER() OVER (
            PARTITION BY L."U_DataCode"
            ORDER BY L."U_LogDate" ASC
        ) AS "LinhaControle"
    FROM "@LOC1_CHLO" L
    WHERE
        UPPER(IFNULL(L."U_Operation", '')) = 'ADD'
        AND UPPER(IFNULL(L."U_DataTable", '')) = 'OSCL'
        AND IFNULL(L."U_DataCode", '') <> ''
),
LOC1_CRIADOR_OS AS (
    SELECT
        L."NumeroOSTexto",
        L."CriadoPorLOC1",
        L."DataCriacaoLOC1"
    FROM LOC1_CRIADOR_OS_RANK L
    WHERE L."LinhaControle" = 1
)
```

---

## 27. Query padrão de pedidos de transferência — regras aprendidas

### 27.1 Base original do SAP

Objeto:

- `OWTQ`: cabeçalho do pedido de transferência de estoque;
- `WTQ1`: linhas do pedido.

Campo da OS na tela:

```text
OWTQ.U_MM_OS
```

Confirmado no print:

```text
Ordem de Serviço
Variable = 117 OWTQ.U_MM_OS
```

### 27.2 Criado por

O usuário pediu o `Criado por` vindo do log de modificações.

No SAP B1, o log de modificações pode mostrar:

- atualizado por;
- criado por;
- data/hora.

Na query final desejada:

- `Criado por - Nome Usuario` deve ser a primeira coluna;
- remover código do usuário;
- remover data/hora de atualização;
- remover atualizado por.

### 27.3 Campos removidos

Remover:

- chave interna do documento;
- código filial;
- documento OS;
- do depósito;
- nome do depósito;
- para depósito;
- nome para depósito;
- itens detalhados, quando duplicarem pedido;
- criado por código usuário;
- data atualização;
- hora atualização;
- atualizado por nome usuário.

### 27.4 Campos desejados

Manter/trazer:

- criado por nome do usuário;
- número do pedido de transferência;
- data de lançamento;
- data de vencimento;
- status;
- número da OS com seta de acesso;
- código do item da OS;
- parceiro de negócio;
- nome do parceiro;
- filial padronizada;
- projeto;
- departamento;
- valor total do pedido.

---

## 28. Setas amarelas no SAP B1 — aprendizados

As setas amarelas dependem de como o SAP interpreta o campo no resultado.

Aprendizados práticos:

- `ORDR."DocNum"` costuma abrir pedido de venda;
- `OWTQ."DocNum"` costuma abrir pedido de transferência;
- `OSCL."callID"` costuma abrir chamado de serviço;
- `OPMG`/projeto pode abrir projeto financeiro ou gerencial dependendo do campo usado;
- nem sempre uma coluna calculada mantém seta amarela;
- concatenar ou converter demais pode quebrar seta;
- aliases podem influenciar, mas o principal é o campo base retornado.

Para preservar seta:

- retornar o campo direto sempre que possível;
- evitar `TO_VARCHAR` na coluna que precisa abrir documento;
- se precisar de texto, criar coluna adicional separada;
- não concatenar campo de acesso.

---

## 29. Projeto gerencial — cuidado especial

O usuário precisava que a seta abrisse a tela:

```text
Gerenciamento de projetos > Projeto
```

Problema encontrado:

- a seta estava abrindo campo de nome/projeto financeiro.

Exemplo:

- projeto `6185`;
- tela desejada: `Projeto - 6185 - IBB - CONTRATO GMG`.

Aprendizado:

- projeto financeiro e projeto gerencial não são a mesma coisa;
- `OPMG.FIPROJECT` pode estar relacionado a projeto financeiro;
- join incorreto com `OPMG` pode duplicar NF;
- se usar `OPMG`, fazer ranking por projeto para evitar duplicidade.

---

## 30. Prompt mestre enriquecido para novo Codex

Este é o prompt recomendado para iniciar outro chat, junto com este arquivo anexado.

```text
Estou migrando um trabalho técnico de queries SAP Business One HANA / LOC1.

Leia o arquivo MEMORIA_TECNICA_TRANSFERENCIA_CODEX_SAP_B1_HANA_LOC1_2026-09-11.md antes de sugerir qualquer query.

Contexto:
- Trabalho com SAP Business One HANA na Sistel.
- Muitas queries já foram aprovadas pela diretoria.
- Não quero reconstrução desnecessária: quero alterações cirúrgicas, com preservação da estrutura aprovada.
- Sempre que possível, preservar as setas amarelas de acesso do SAP B1.

Regras fiscais finais:
- NF de saída normal compõe faturamento/meta.
- NF de venda futura pura NÃO compõe faturamento/meta.
- Venda futura pura é identificada por CFOP 5922/6922 sem entrega vinculada.
- NF com entrega vinculada via ODLN/DLN1 deve continuar entrando como Nota Fiscal de Entrega.
- O vínculo da entrega é DLN1.BaseType = 13 e DLN1.BaseEntry = OINV.DocEntry.
- Não remover pedido de venda inteiro quando houver NF futura; remover apenas a NF futura pura.
- Exemplo crítico: pedido 1569 tinha NF futura 643, mas também NFs de saída 1409 e 2208 que devem continuar.

Query oficial de NF:
- Base em OINV/INV1.
- Valor principal: OINV.NfeValue.
- Campo CFOP: INV1.CFOPCode.
- Usar flags por DocEntry para detectar CFOP 5922/6922.
- Filtrar venda futura pura com:
  AND NOT (
      LIN.FlagVendaFutura = 1
      AND ENT.Num_Documento_Entrega IS NULL
  )

DREXMETAS:
- A query FATURAMENTO DREXMETAS não depende da query oficial de NF.
- Ela tem uma CTE própria NF_BASE.
- A regra de CFOP/venda futura precisa ser replicada dentro da NF_BASE.
- Os retroativos Jan/Fev estão manuais na CTE M e não vêm da NF_BASE.

OS/equipamento:
- OS está em OSCL.
- Cartão de equipamento está em OINS.
- Pedido de transferência está em OWTQ/WTQ1.
- Pedido de transferência vincula OS por OWTQ.U_MM_OS = OSCL.callID.
- Pedido de venda gerado por iClass aparece em documentos relacionados do chamado via SCL4.
- Vínculo iClass:
  SCL4.SrcvCallID = OSCL.callID
  SCL4.Object = '17'
  SCL4.DocAbs = ORDR.DocEntry
- Itens iClass:
  SV000045 = mão de obra
  SV000044 = deslocamento
- Quantidade vem em minutos.
- Custo hora homem usado: R$ 35,00/hora.
- Fórmula: (SUM(Quantity)/60)*35.

LOC1:
- Criador da OS no LOC1 vem da tabela @LOC1_CHLO.
- Filtros:
  U_Operation = 'Add'
  U_DataTable = 'OSCL'
  U_DataCode = número da OS.

Forma de trabalhar:
- Antes de modificar query validada, explique exatamente o que vai mudar.
- Ao auditar diferença, comparar quantidade de linhas, soma de valores, NFs removidas, NFs adicionadas e valores alterados.
- Se houver duplicação por linhas, consolidar por documento antes de somar.
```

---

## 31. Checklist de transferência para outra estação

Antes de devolver este notebook, salvar ou copiar:

- [ ] Este arquivo Markdown.
- [ ] Query oficial de NF atualizada.
- [ ] Query FATURAMENTO DREXMETAS atualizada.
- [ ] Query de auditoria de CFOP.
- [ ] Query de auditoria por pedido específico.
- [ ] Queries de OS/equipamento, se existirem em arquivo separado.
- [ ] Prints críticos:
  - NF 5865 / documento 3587;
  - mapa de relações do pedido 1569;
  - documentos relacionados da OS/iClass;
  - log LOC1 da OS;
  - tela do projeto gerencial.

---

## 32. Frases curtas para orientar o novo Codex

Se o novo Codex começar a sugerir refazer tudo, usar estas frases:

```text
Não quero reconstruir do zero. Quero preservar a query validada e aplicar somente a melhoria solicitada.
```

```text
Não filtre pelo pedido inteiro. A regra deve ser por documento de NF, porque o mesmo pedido pode ter NF futura e NF de saída real.
```

```text
Não use somente Utilização para identificar venda futura. A regra validada é CFOP 5922/6922 sem entrega vinculada.
```

```text
Na DREXMETAS, aplique a regra dentro da CTE NF_BASE, porque ela não depende da query oficial de NF.
```

```text
Preserve setas amarelas de acesso retornando o campo original, sem converter ou concatenar, quando possível.
```

