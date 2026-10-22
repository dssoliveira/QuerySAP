# Ambiente conhecido e roteiro de reconstrucao

Observacao em 22/10/2026. Configuracoes aqui sao registros verificaveis desta
estacao, nao requisito para reproduzir exatamente cada comportamento do modelo.

## Camadas do projeto

| Camada | O que esta protegido | O que deve ser reconfigurado |
|---|---|---|
| Conhecimento | Transcricoes, memorias, decisoes, anexos e indices | Novo chat precisa ler os arquivos pertinentes |
| Codigo | SQLs originais, propostas, fontes do usuario | Escolher a base apropriada e testar no SAP |
| Git | Historico publicado, origin e branch documentados | Autenticacao da conta e checkout novo |
| SAP/HANA | Nomes de tabelas/campos conhecidos e regras relatadas | Cliente SAP, drivers, VPN, servidor, base e permissoes |
| LOC1/iClass | Interpretacoes e exemplos preservados | Add-ons e integracoes efetivamente usados pela empresa |
| Power BI | Regras e caminhos historicos documentados | Modelo .pbix, fontes, gateway e credenciais se aplicaveis |
| Codex | AGENTS.md, preferencia operacional e arquivos de continuidade | Login, plugins e permissoes da nova estacao |

## Ferramentas observadas

- Windows, usuario danilo.santos; projeto em Documents/Codex/2026-07-02/...
- Git for Windows 2.53.0.windows.3.
- PowerShell 7.6.5 do runtime do Codex.
- Node.js disponivel no runtime do Codex; necessario para auditar_acervo.mjs.
- O comando python aponta para alias WindowsApps e falhou ao executar nesta
  sessao. Nao ensinar que Python esteja configurado com base apenas nesse alias.
- hdbsql e isql nao foram localizados no PATH. Isso nao prova ausencia de outros
  clientes instalados; comprova somente que acesso SQL direto nao foi validado.
- GitHub CLI gh nao estava disponivel. O push HTTPS pelo Git funcionou.

O arquivo local de configuracao do Codex tinha model=gpt-5.6-sol e
model_reasoning_effort=medium. Esses sao defaults observados no arquivo, nao
prova do modelo selecionado em cada chat. A escolha de modelo nao e necessaria
para recuperar o conhecimento. O arquivo completo nao foi publicado.

## O que intencionalmente nao foi copiado

auth.json, tokens, cookies, arquivos .env, chaves privadas, configuracoes com
segredos, sessoes integrais do aplicativo, bancos SQLite do Codex, cache de
plugins e dependencias. Nao transportar uma pasta .codex inteira como backup
tecnico: ela mistura credenciais e material de outros projetos.

O prompt operacional original foi copiado como evidencia, nao como instrucao
ativa superior ao pedido atual. Ele registra PCM/engenharia, SAP HANA, LOC1,
iClass, Logsis, AnyTask, Excel, Sheets, Power BI, Project e OneDrive. Isso nao
significa que todos esses produtos estejam conectados ao Codex ou licenciados
no novo ambiente.

## Passos de retomada em outra estacao

1. Entrar no GitHub e obter acesso ao repositorio dssoliveira/QuerySAP.
2. Instalar Git e PowerShell 7 se executar os scripts de verificacao no Windows.
3. Clonar a main em pasta nova; nao sobrescrever uma pasta com trabalho local.
4. Ler AGENTS.md, CONTINUIDADE.md e auditoria/LEIA_PRIMEIRO.md.
5. Executar scripts/verificar_recuperacao.ps1 para o inventario original e
   scripts/verificar_pacote.mjs com Node para a auditoria ampliada.
6. Localizar tarefa, fonte oficial declarada e evidencias antes de alterar SQL.
7. Quando necessario, configurar SAP/VPN/driver por canal seguro com a empresa.
   Este pacote nao contem endpoints nem senhas de banco.
8. Testar query em ambiente autorizado do SAP e anexar resultado. Registrar
   aprovacao, comparacao de totais e versao final no repositorio.

## Nuvem e computador

O chat Configurar QuerySAP foi observado com host remoto; QUERY SAP e local.
O onboarding remoto ocorreu quando so havia seis arquivos publicados. Ao
retomar la, atualizar o checkout preservando alteracoes e ler estes documentos.
Nao houve envio automatico de mensagem a outro chat nesta auditoria.

Arquivos locais novos exigem commit/push; outra copia precisa buscar os commits.
Conversas novas exigem registro documental. Mesmo trabalhando so na nuvem,
salvar arquivos no ambiente nao deve ser tratado como publicacao confirmada no
GitHub. Conferir commit remoto ao terminar uma etapa.

## Destino identificado

O destino confirmado e o repositorio GitHub. Nao foi identificado mecanismo de
deploy de um site/portal separado neste projeto. Nao afirmar que esta entrega
publicou uma pagina web ou alterou um portal de outro projeto.

## Prompt curto de retomada

> Leia AGENTS.md, CONTINUIDADE.md e auditoria/LEIA_PRIMEIRO.md. Estou retomando
> o QuerySAP em outra estacao. Localize a base da tarefa no catalogo e nas
> evidencias; preserve as regras aprovadas. Diferencie proposta de homologacao.
> Informe as pendencias relevantes, entregue codigo completo quando solicitado
> e registre decisoes e arquivos finais para publicacao no GitHub.
