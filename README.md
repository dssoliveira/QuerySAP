# QuerySAP

Consultas SQL e memoria tecnica do projeto Sistel para SAP Business One HANA,
LOC1 e Power BI.

## Arquivos do projeto

- `FATURAMENTO_DREX_METAS_ATUALIZADA.sql`: consulta de faturamento e metas.
- `MEMORIA_TECNICA_SISTEL_SAP_HANA_LOC1_POWERBI_ATUALIZADA_2026-07-19.md`:
  contexto tecnico e regras de negocio.
- `MEMORIA_TECNICA_TRANSFERENCIA_CODEX_SAP_B1_HANA_LOC1_2026-09-11.md`:
  memoria de transferencia de conhecimento.
- `outputs/CONTEXTO_OPERACIONAL_SISTEL_SAP_LOC1_POWERBI.md`:
  referencia operacional compacta, mantida por seu valor documental.

## Trabalho com as consultas

As consultas usam o dialeto SAP HANA e incluem campos personalizados do ambiente.
Validar alteracoes em consulta de teste no SAP antes de substituir relatorios
aprovados. Preservar regras de negocio, cardinalidade, filtros e estrutura dos
relatorios existentes.

Os documentos registram conhecimento historico: verificar a data e as pendencias
de cada arquivo antes de tratar uma regra como validacao atual.

## Uso em outra estacao ou no Codex online

Depois da publicacao, clonar este repositorio em outra estacao ou selecionar
`dssoliveira/QuerySAP` no ambiente conectado ao GitHub do Codex online.
O repositorio transporta os arquivos versionados; o historico deste chat,
anexos externos e acessos ao SAP nao sao transferidos automaticamente.

## Dados internos

Este projeto contem informacoes empresariais, metas e exemplos operacionais.
Manter o acesso ao repositorio restrito aos usuarios autorizados.
Nao versionar credenciais, arquivos `.env`, certificados ou dependencias geradas.
