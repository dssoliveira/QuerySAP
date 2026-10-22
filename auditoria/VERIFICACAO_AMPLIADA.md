# Laudo de recuperacao da auditoria ampliada

Data de referencia: 22/10/2026. Escopo: pacote documental e arquivos, sem
execucao SQL no SAP. A publicacao foi autorizada por Danilo neste chat.

## Evidencia de publicacao e download

- Repositorio: https://github.com/dssoliveira/QuerySAP.
- Branch: main, com commits normais, sem force push.
- Commit do pacote auditado:
  `c41b99ad582e69f9b782ac78a9584e6f036f4210`.
- Download realizado por git clone em pasta nova:
  `C:\Users\danilo.santos\Documents\Codex\QuerySAP-auditoria-recuperacao-20261022`.
- A pasta original e a copia de recuperacao anterior nao foram substituidas.

## Verificacoes executadas na copia baixada

| Verificacao | Resultado |
|---|---|
| Manifesto de arquivos do pacote | 1.132 arquivos conferidos, sem divergencia |
| Preservacao da transcricao original | 893 mensagens coincidem com o prefixo do snapshot atualizado |
| Snapshot atualizado | 911 mensagens identificadas |
| Catalogo de blocos SQL | 421 arquivos presentes |
| Anexos originais | 238 hashes SHA-256 conferidos |
| Documentos essenciais do primeiro pacote | 6 presentes |
| Integridade de objetos Git | git fsck --full sem erro |

O manifesto identifica o modo de comparacao: bytes exatos em arquivo_chat e
auditoria, e texto com CRLF normalizado para LF nos demais arquivos. Isso permite
verificar o conteudo textual mesmo quando o checkout Windows converte fins de
linha. As evidencias originais nao passam por essa normalizacao.

## Conferencias locais adicionais

- CSVs reabertos com contagens esperadas: 421 queries, 911 mensagens, 238 anexos,
  12 bases SQL do usuario e 15 referencias externas.
- Confirmada a origem de cada bloco SQL no snapshot; indices registram retornos
  e nao atribuem homologacao automaticamente.
- Tres exports relidos por scripts/conferir_evidencias.mjs: 423 transferencias,
  106 relacoes e 3.775 processos de aprovacao, com detalhes no JSON correspondente.
- Fontes originais SQL/memorias da raiz preservadas, sem alteracao de regra.
- Busca textual por formatos comuns de tokens e chaves privadas sem ocorrencias.
  Essa busca nao e garantia absoluta de ausencia de qualquer segredo possivel.
- Nenhum arquivo de login, .env, banco do Codex ou dependencia foi incluido.

## Lacunas registradas

Seis arquivos historicos externos nao foram localizados; ver
LACUNAS_E_PENDENCIAS.md. As duas fontes externas adicionais e a imagem posterior
ao primeiro backup foram copiadas com seus hashes. O laudo nao declara que
arquivos ausentes tenham sido reconstituidos.

Nao houve homologacao funcional de todos os SQLs, OCR de todas as imagens ou
consulta ao banco empresarial. O registro local nao prova recuperar mensagens
que ja estivessem ausentes antes da exportacao.

## Repetir em outra estacao

Na pasta clonada, com Node e PowerShell 7:

```powershell
node .\scripts\verificar_pacote.mjs
.\scripts\verificar_recuperacao.ps1 -ClonePath (Get-Location).Path
```

O proprio manifesto nao inclui seu hash dentro dele. O commit Git protege a
versao publicada do manifesto. Este laudo foi incluido apos o primeiro teste
ampliado; o manifesto e regenerado para inclui-lo na entrega final.
