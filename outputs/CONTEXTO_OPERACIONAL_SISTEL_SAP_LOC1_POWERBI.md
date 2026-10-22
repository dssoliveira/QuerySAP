# Contexto Operacional — Sistel SAP B1 HANA + LOC1 + Power BI

Atualizado em: 2026-07-02  
Fonte canônica: `C:\Users\danilo.santos\OneDrive\BI_SAP_LOC1\MEMORIA_TECNICA_SISTEL_SAP_HANA_LOC1_POWERBI.md`

## Finalidade

Esta referência compacta orienta as próximas atividades do projeto. Ela não substitui a memória técnica original; resume os fatos já validados, as regras de decisão e os pontos que ainda exigem confirmação.

## Modelo mental principal

O núcleo operacional para localizar o contrato real de um equipamento LOC1 é:

```text
OITM (item/equipamento)
  └─ OSRN (serial, TAG e status LOC1)
       └─ @LOC1_SNMO (movimento e contrato LOC1 por item + SysNumber)
            └─ OCTR (contrato SAP, ligado por ContractID)
```

Não partir do cliente para descobrir o contrato do equipamento. Joins entre contrato e pedido por código do cliente podem associar vários contratos/pedidos e multiplicar linhas.

## Relações validadas

```sql
-- Grupo do item
OITM."ItmsGrpCod" = OITB."ItmsGrpCod"

-- Cartão do equipamento
OITM."ItemCode" = OINS."itemCode"

-- Serial, TAG e status
OITM."ItemCode" = OSRN."ItemCode"

-- Vínculo operacional LOC1
@LOC1_SNMO."U_ItemCode" = OITM."ItemCode"
AND @LOC1_SNMO."U_SysNumber" = OSRN."SysNumber"

-- Contrato SAP correspondente
OCTR."ContractID" = @LOC1_SNMO."U_ContractID"

-- Grupo homologado para ativos de terceiros
OITB."ItmsGrpNam" = 'ATIVO TERCEIRO'

-- Regra alternativa pelo código
OITM."ItemCode" LIKE 'T%'
```

## Fontes e papéis

| Tabela | Papel confiável no projeto |
|---|---|
| `OITM` | Cadastro e características técnicas do equipamento |
| `OITB` | Grupo do item; identifica `ATIVO TERCEIRO` |
| `OINS` | Cartão do equipamento e vínculo operacional com cliente |
| `OSRN` | Serial, TAG e status operacional LOC1 |
| `@LOC1_SNMO` | Vínculo entre item, `SysNumber`, status, contrato e documento LOC1 |
| `OCTR` | Contrato SAP e navegação/atalho no cliente SAP |
| `IGN1` / `OIGN` | Entrada de mercadoria, departamento, depósito e documento |
| `ORDR` / `RDR1` | Pedido de venda, projeto, vendedor e valores de contratos de manutenção |
| `@LOC1_CTR3` / `OBPL` | Caminho provável para filial do contrato LOC1 |

## Status LOC1

| Código | Apresentação |
|---|---|
| `C` | EM CONTRATO |
| `A` | DISPONÍVEL |
| `D` | DISPONÍVEL |
| `M` | EM MANUTENÇÃO |
| `T` | EM TRÂNSITO |
| outro/nulo | NÃO DEFINIDO |

## Regras para construir consultas

1. Preservar a granularidade declarada da consulta, preferencialmente uma linha por equipamento/serial quando esse for o objetivo.
2. Verificar cardinalidade antes de adicionar `IGN1`, `RDR1` ou tabelas `@LOC1_CTR*`; todas podem multiplicar linhas.
3. Para contrato real por equipamento, usar `OSRN + @LOC1_SNMO`.
4. Usar `OCTR.ContractID` quando a seta de navegação do SAP for necessária.
5. Evitar `UNION ALL` no relatório detalhado quando as setas do SAP forem importantes.
6. Evitar agregar campos de documento com `MAX` quando a navegação pelo documento precisar ser preservada.
7. Manter subtotais fora da consulta detalhada: usar consulta-resumo separada no SAP ou medidas DAX.
8. Usar `LEFT JOIN` para dados opcionais, como cartão de equipamento/cliente.
9. Parâmetros `[%0]` devem aparecer no filtro apropriado; não usá-los como coluna literal.
10. O campo `OCTR.BPLId` não existe neste ambiente.

## Power BI e extração

Fluxo atual:

```text
SAP Query Manager
  → Copiar dados
  → script PowerShell
  → CSV limpo no OneDrive
  → Power BI
```

Pasta operacional:

```text
C:\Users\danilo.santos\OneDrive\BI_SAP_LOC1
```

Bases:

- `equipamentos_loc1.csv`
- `contratos_manutencao.csv`

Padrão dos CSVs:

- delimitador `;`;
- UTF-8 com BOM;
- sem coluna `#`;
- sem colunas vazias sem cabeçalho.

No Power BI:

- contrato, pedido, projeto, PN, TAG e demais identificadores devem ser **Texto** e **Não resumir**;
- valor, quantidade, dias, potência e horímetro devem ser numéricos;
- datas e decimais podem exigir localidade `Português (Brasil)`;
- remover a etapa automática `Tipo Alterado` quando ela inferir tipos incorretos;
- relacionamento sugerido: `Equipamentos_LOC1[NumeroContratoLOC1]` → `Contratos_Manutencao[Numero Contrato]`, ambos como texto.

## Validação conhecida

Para o item `T0000546`, `@LOC1_SNMO` retornou:

- contrato LOC1 `134`;
- `SysNumber = 1`;
- status `C`;
- `U_DocEntry = 121`;
- `U_DocTypeNum = 191`.

Esse caso pode ser usado como teste de regressão para novas consultas.

## Pendências que não devem ser tratadas como fatos confirmados

- Confirmar em dados reais se `@LOC1_CTR3.U_ContractID → @LOC1_CTR3.U_BPLId → OBPL.BPLId` resolve a filial sem duplicação.
- Confirmar se todo contrato de manutenção relevante referencia o pedido em `OCTR.Descriptio` no padrão contendo `Venda `.
- Revisar o uso exclusivo de `RDR1.LineNum = 0` caso existam contratos cujo valor esteja em outras linhas.
- Definir uma regra determinística para escolher a entrada de mercadoria quando houver várias linhas em `IGN1` por item.
- Validar cardinalidade e direção do relacionamento entre as duas bases no modelo Power BI antes de publicar indicadores.

## Critério de qualidade para trabalhos futuros

Antes de considerar uma nova query ou modelo pronto:

- declarar a granularidade esperada;
- comparar contagem de itens/seriais antes e depois dos joins;
- testar o item conhecido `T0000546`;
- verificar nulos e duplicidades de contrato;
- conferir se identificadores não estão sendo somados no Power BI;
- preservar setas do SAP somente quando isso fizer parte do requisito;
- separar claramente fatos validados de hipóteses ainda em teste.

