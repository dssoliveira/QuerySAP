# Lacunas e pendencias auditadas

## Arquivos historicos nao localizados

Foram conferidos os caminhos citados e pesquisados os nomes exatos em Documents,
Downloads e OneDrive desta estacao. Os seis arquivos abaixo nao foram localizados:

1. MEMORIA_TECNICA_SISTEL_SAP_HANA_LOC1_POWERBI.md (nome original sem data).
2. atualizar_base_sap.ps1.
3. atualizar_contratos_manutencao.ps1.
4. codex_handoff_sistel_sap_loc1.md.
5. contratos_manutencao.csv.
6. equipamentos_loc1.csv.

As memorias posteriores e a memoria portatil de julho contem contexto e
descricoes de parte desses materiais; isso nao e prova de copia integral dos
arquivos originais. Os scripts nao foram reconstruidos por suposicao. Uma copia
antiga em outra estacao, backup ou historico do OneDrive pode preencher a lacuna.

O inventario externo registra 15 referencias: quatro arquivos ja no projeto,
tres planilhas ja cobertas no inventario original, duas novas copias e seis
ausencias. Nao confundir essas seis com os 238 anexos originalmente copiados.

## Limites da transcricao

O snapshot desta auditoria recuperou 911 mensagens visiveis do registro local,
com 473 ocorrencias de 421 blocos SQL distintos. O primeiro arquivo de 893 mensagens
foi preservado. O registro pode refletir importacoes e nao comprova recuperar
mensagens que ja estavam ausentes do arquivo da sessao. Datas de registro nao
substituem datas dos documentos SAP.

Nao foi exportada a interface original do aplicativo. Ferramentas, raciocinio
interno e autenticacoes nao fazem parte do pacote. Uma transcricao pode conter
referencias a imagens; as imagens recuperadas ficam nos anexos, sem OCR integral.

## Pendencias funcionais que afetam continuidade

| Pendencia | Evidencia e proximo teste |
|---|---|
| Integrar aprovacao e data ao relatorio de transferencias | M875/M876; validar processos de criacao/alteracao, multiplas etapas e nao duplicar transferencias |
| Confirmar data efetiva de autorizacao | MAX(WDD1.UpdateDate) e ultimo voto registrado; confrontar com um processo conhecido e sequencia de etapas |
| Setas do projeto gerencial | M641: seta ainda no financeiro; chave e objeto gerencial precisam de prova |
| Contratos 2026/2027 e coluna anual | M489,M501,M506: planejamento parcial correto, base rejeitada depois; usar anexo071 e validar previsto anual |
| Homologacao total de competencia/legado | M547: somente38 pedidos efetivos no export novo; nao compara a base701 inteira |
| Valor legado PV166 | M548 texto sem valor; M551 converteu para0. Nao tratar0 como fato validado |
| Elegibilidade no rateio de custos | M710 questiona revenda para MO/alimentacao/hospedagem; documentar regra por centro antes de produzir resultado oficial |
| Campo interno de observacoes em OPOR | M70-74: Header,Footer,PickRmrk foram hipoteses; nao confirmado por retorno |
| Destino das seis bombas | BaseType=-1 e sem serie/lote; vinculo a OS precisa de evidencia independente |
| Bruto x liquido contabil | Reconciliar impostos/contas/parcelas; nao chamar toda diferenca de credito tributario |
| Classificacao curto prazo de locacao | M721 questionou criterio; limite nao foi acordado |
| Homologacao das candidatas de NF/DRE | Exemplos confirmam regras locais, nao cobertura de todos os cenarios e CFOPs |

## Aprovacao que nao pode ser fabricada

Os 395 blocos sem homologacao individual permanecem nesse estado. A auditoria
encontra origens e retornos, mas nao pode transformar silencio, novo assunto ou
frase do assistente em aprovacao do usuario. Esses blocos podem estar corretos;
o proximo teste deve ser orientado pela tarefa, nao por executar todos em lote.

## Dependencias desta estacao

O conhecimento e os arquivos efetivamente publicados podem ser recuperados sem
esta estacao. Acessos SAP, VPN, integracoes, plugins, drivers e arquivos ausentes
continuam fora do pacote. Nao existe sincronizacao automatica de novas conversas
ou dos Downloads. O uso na nuvem reduz dependencia do computador, mas nao
substitui registro, commit/push e uma segunda copia independente do backup.
