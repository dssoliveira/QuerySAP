import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import {fileURLToPath} from 'node:url';

const root = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const out = path.join(root, 'auditoria');
fs.mkdirSync(out, {recursive:true});
const sha = b => crypto.createHash('sha256').update(b).digest('hex').toUpperCase();
const cell = value => '"'+String(value??'').replaceAll('"','""')+'"';
const csv = rows => rows.length ? Object.keys(rows[0]).map(cell).join(',')+'\n'+rows.map(r=>Object.values(r).map(cell).join(',')).join('\n')+'\n' : '';
const save = (name,data) => fs.writeFileSync(path.join(out,name),data,'utf8');
const source = fs.readFileSync(path.join(out,'snapshot_atualizado','TRANSCRICAO.md'),'utf8');
// Split por cabecalhos exportados, sem depender de datas de negocio.
const heads = [...source.matchAll(/^## Mensagem (\d+) \| (user|assistant) \| ([^\r\n]+)\r?\n/gm)];
const msgs = heads.map((h,i)=>({id:Number(h[1]),role:h[2],timestamp:h[3],text:source.slice(h.index+h[0].length,heads[i+1]?.index??source.length).trim()}));
const episodes = [
 [1,9,'Importacao das memorias de outras estacoes'],[10,32,'Contratos: reconciliacao analitico e resumo'],
 [33,38,'Contratos e pedidos: centros e tipos'],[39,74,'Compras: fornecedor, observacoes, projetos e filial'],
 [75,83,'Pedidos: filtro de centros'],[84,199,'Contratos manutencao: granularidade, filtros e auditoria'],
 [200,218,'Pedidos avulsos: layout e status de faturamento'],[219,308,'NF: valor fiscal, vinculo e duplicacao'],
 [309,334,'DRE e pedidos: migracao para NfeValue'],[335,429,'NF entrega e DRE: reconciliacao por centro e data'],
 [430,464,'Pedidos: avulso, precor, custos e exclusoes iClass'],[465,478,'Filtros de datas e auditoria de faturamento'],
 [479,508,'Contratos: parcelas, planejamento e anos 2026/2027'],[509,520,'DE/PARA contratos e faturamento'],
 [521,551,'Competencia comercial e faturamento legado SIGEM'],[552,555,'Resumo de contratos: deduplicacao'],
 [556,619,'Equipamento: OS, cartao e custos'],[620,647,'NFSe, auditorias independentes e projeto gerencial'],
 [648,667,'Pedido transferencia: relatorio simplificado'],[668,697,'OS/iClass: minutos, custo e criador LOC1'],
 [698,703,'Erros OACT e ECM2'],[704,713,'Custos de PV: rateio igual por centro'],
 [714,722,'Locacoes: pedido pre-contrato x NF'],[723,764,'NF e DREXMETAS: CFOP e caso pedido 1569'],
 [765,773,'Memoria tecnica: primeira transferencia'],[774,820,'Bombas: entradas, saidas e limites de rastreabilidade'],
 [821,834,'DRE: FILIALSP e ENE CUBE'],[835,844,'Pesquisa materiais e referencias corrigidas'],
 [845,854,'Projeto: materiais e conciliacao contabil'],[855,872,'Transferencia -> solicitacao -> PC'],
 [873,877,'Aprovacao compra: processo, datas e recusas'],[878,100000,'Continuidade, GitHub e copia de seguranca']
];
const topic = n => episodes.find(e=>n>=e[0]&&n<=e[1])?.[2]??'Nao classificado';
const request = text => (text.match(/## My request(?: for Codex)?:\s*([\s\S]*)/)?.[1]??text).replace(/<image[\s\S]*?<\/image>/g,' [imagem] ').trim();
const compact = (text,n=1000) => text.replace(/```[\s\S]*?```/g,' [bloco de codigo] ').replace(/\s+/g,' ').slice(0,n);
const blockOccurrences = new Map();
for(const m of msgs) for(const b of m.text.matchAll(/```(?:sql|hana)\s*\r?\n([\s\S]*?)```/gi)) {
 const code=b[1].trim(), hash=sha(Buffer.from(code));
 const list=blockOccurrences.get(hash)??[]; list.push({message:m.id,role:m.role,code});blockOccurrences.set(hash,list);
}
const rejected = new Map([
 [151, 'M152: usuario informou que nao rodou'],[170,'M171: filtro vazio retornou vazio'],
 [172,'M173: resultado com colunas nao solicitadas'],[177,'M178: filtro inicial buscou campo errado'],
 [301,'M302: usuario rejeitou a solucao com itens'],[341,'M342: resultados incorretos'],
 [347,'M348: usuario apontou desestruturacao e redefiniu base'],[388,'M389: usuario informou que nao funcionou'],
 [390,'M391: usuario interrompeu por erro'],[401,'M402/M403: valor so no total, nao por centro'],
 [406,'M407: faltavam valores em relacao a auditoria'],[505,'M506: usuario rejeitou documento/base entregue'],
 [671,'M672: resultado vazio; vinculo iClass estava em documentos relacionados']
]);
const catalog=[];
const historical=path.join(root,'arquivo_chat','queries_historicas');
for(const filename of fs.readdirSync(historical).filter(f=>f.endsWith('.sql')).sort()) {
 const bytes=fs.readFileSync(path.join(historical,filename));const code=bytes.toString('utf8').trim();
 const hash=sha(Buffer.from(code)); const occ=blockOccurrences.get(hash)??[]; const first=occ[0];
 if(!first) throw new Error('Origem SQL nao localizada: '+filename);
 const next=msgs.find(m=>m.role==='user'&&m.id>first.message);
 let status='Proposta historica; homologacao nao comprovada', evidence='Ausencia de aprovacao individual explicita identificada';
 if(first.role==='user'){status='SQL fornecido pelo usuario';evidence='Origem no usuario; isso nao prova homologacao de toda a versao';}
 if(rejected.has(first.message)){status='Entrega com rejeicao ou correcao solicitada';evidence=rejected.get(first.message);}
 if(first.message===488){status='Teste parcialmente positivo';evidence='M489: planejamento mes a mes correto; previsto anual e setas com erro';}
 if(first.message===665){status='Aceitacao historica explicita; posteriormente ampliada';evidence='M666: esse finalizamos; relatorio de transferencia com item da OS, antes dos vinculos de compra';}
 if(first.message===305&&/^SELECT\b/i.test(code)){status='Aceitacao historica explicita; posteriormente revisada';evidence='M306: ok fechamos essa query; novas revisoes posteriores substituem regras';}
 if(first.message===875){status='Diagnostico com resultado fornecido';evidence='M876: anexo 1dcb3ab6...; aprovacao/data ainda pendente de integracao e validacao multi-etapas';}
 const tables=[...new Set([...code.matchAll(/\b(?:FROM|JOIN)\s+(?:"([^"\r\n]+)"|([@A-Za-z_][\w@]*))/gi)].map(x=>x[1]??x[2]))].join('; ');
 catalog.push({arquivo:'../arquivo_chat/queries_historicas/'+filename,tema:topic(first.message),mensagem_origem:first.message,ocorrencias:occ.map(o=>o.message).join('; '),autor:first.role,status,evidencia:evidence,primeiro_retorno_usuario:next?.id??'',resumo_retorno:next?compact(request(next.text),800):'',referencias_FROM_JOIN_inclui_CTE:tables,bytes:bytes.length,sha256_arquivo:sha(bytes),sha256_codigo_sem_espacos_externos:hash});
}
save('CATALOGO_421_QUERIES.csv',csv(catalog));
const msgRows=msgs.map(m=>({mensagem:m.id,autor:m.role,data_registro:m.timestamp,tema:topic(m.id),contem_SQL:/```(?:sql|hana)/i.test(m.text),contem_imagem:/<image|Image attachment/i.test(m.text),contem_anexo:/Files (?:mentioned|pasted)/i.test(m.text),texto_resumido:compact(request(m.text),600)}));
save('INDICE_MENSAGENS.csv',csv(msgRows));
save('LINHA_DO_TEMPO.md','# Linha do tempo e mapa de leitura\n\nNumeros referem-se a snapshot_atualizado/TRANSCRICAO.md. Agrupamento tematico para navegar; nao representa aprovacao.\n\n'+episodes.map(([start,end,title])=>`## ${title}\n\nMensagens ${start} a ${Math.min(end,msgs.at(-1).id)}; ${catalog.filter(q=>q.mensagem_origem>=start&&q.mensagem_origem<=end).length} blocos SQL distintos de primeira ocorrencia.\n\n`+msgs.filter(m=>m.role==='user'&&m.id>=start&&m.id<=end).map(m=>`- M${m.id}: ${compact(request(m.text),350)}`).join('\n')).join('\n\n')+'\n');
// Todas as referencias locais com extensao documental reconhecida, inclusive
// caminhos externos indisponiveis e arquivos do proprio projeto.
const memoryFiles=['MEMORIA_TECNICA_SISTEL_SAP_HANA_LOC1_POWERBI_ATUALIZADA_2026-07-19.md','MEMORIA_TECNICA_TRANSFERENCIA_CODEX_SAP_B1_HANA_LOC1_2026-09-11.md','outputs/CONTEXTO_OPERACIONAL_SISTEL_SAP_LOC1_POWERBI.md','auditoria/fontes_externas/71f1336120_MEMORIA_COMPLETA_SISTEL_SAP_HANA_LOC1_2026-07-06.md'];
const referenceCorpus=source+'\n'+memoryFiles.filter(f=>fs.existsSync(path.join(root,f))).map(f=>fs.readFileSync(path.join(root,f),'utf8')).join('\n');
const paths=[...new Set([...referenceCorpus.matchAll(/C:[\\/]Users[\\/][^\r\n<>"|]+?\.(?:txt|png|xlsx|xls|csv|pbix|jpg|jpeg|pdf|sql|docx|md|py|ps1|bat|json|toml)(?=[\s"<>`)]|$)/gi)].map(m=>m[0].replaceAll('/','\\')))];
const originalTranscript=fs.readFileSync(path.join(root,'arquivo_chat/TRANSCRICAO.md'),'utf8');
const originalPaths=new Set([...originalTranscript.matchAll(/C:[\\/]Users[\\/][^\r\n<>"|]+?\.(?:txt|png|xlsx|jpg|jpeg|pdf|sql|docx)(?=[\s"<>`)]|$)/gi)].map(m=>m[0].replaceAll('/','\\').toLowerCase()));
const additional=[];fs.mkdirSync(path.join(out,'anexos_adicionais'),{recursive:true});
for(const p of paths.filter(p=>/\\\.codex\\attachments\\|\\Temp\\codex-clipboard-/i.test(p)&&!originalPaths.has(p.toLowerCase()))){
 const row={origem:p,destino:'',estado:'Ausente na estacao',sha256:'',bytes:0};
 if(fs.existsSync(p)){
  const name=sha(Buffer.from(p)).slice(0,10).toLowerCase()+'_'+path.basename(p);const dst=path.join(out,'anexos_adicionais',name);const b=fs.readFileSync(p);
  if(fs.existsSync(dst)&&sha(fs.readFileSync(dst))!==sha(b))throw new Error('Copia adicional existente divergente');
  if(!fs.existsSync(dst))fs.copyFileSync(p,dst);
  row.destino='auditoria/anexos_adicionais/'+name;row.estado='Copiado e conferido';row.sha256=sha(b);row.bytes=b.length;
 }
 additional.push(row);
}
save('INVENTARIO_ANEXOS_ADICIONAIS.csv',csv(additional));
const external=[];const extRoot=path.join(out,'fontes_externas');fs.mkdirSync(extRoot,{recursive:true});
for(const p of paths.sort()) {
 if(/\\\.codex\\attachments\\|\\Temp\\codex-clipboard-/i.test(p))continue;
 const row={origem:p,destino:'',estado:'',sha256:'',bytes:0,observacao:''};
 if(p.toLowerCase().startsWith(root.toLowerCase()+'\\')){
  row.destino=path.relative(root,p).replaceAll('\\','/');row.estado=fs.existsSync(p)?'Ja no projeto':'Referencia interna ausente';
  if(fs.existsSync(p)){const b=fs.readFileSync(p);row.sha256=sha(b);row.bytes=b.length;}
 }else if(/\\Downloads\\Pasta45(?:6|67)?\.xlsx$/i.test(p)){
  row.estado='Coberto no inventario original';row.observacao='Consultar arquivo_chat/INVENTARIO_ANEXOS.csv';
 }else if(/\\Downloads\\MEMORIA[^\\]*\.md$|\\OneDrive\\BI_SAP_LOC1\\[^\\]+\.(?:md|docx|ps1|csv|pbix)$/i.test(p)){
  if(!fs.existsSync(p)){row.estado='Ausente na estacao';row.observacao='Nao afirmar recuperacao; pode haver conteudo incorporado nas memorias posteriores';}
  else{const name=sha(Buffer.from(p)).slice(0,10).toLowerCase()+'_'+path.basename(p);const dst=path.join(extRoot,name);const b=fs.readFileSync(p);if(fs.existsSync(dst)&&sha(fs.readFileSync(dst))!==sha(b))throw new Error('Destino existente divergente '+name);if(!fs.existsSync(dst))fs.copyFileSync(p,dst);row.destino='auditoria/fontes_externas/'+name;row.estado='Copiado e conferido';row.bytes=b.length;row.sha256=sha(b);if(sha(fs.readFileSync(dst))!==row.sha256)throw new Error('Hash divergente');}
 }else{row.estado='Referencia nao copiada automaticamente';row.observacao='Revisar escopo; nao buscar configuracoes secretas por caminho';}
 external.push(row);
}
save('INVENTARIO_REFERENCIAS_EXTERNAS.csv',csv(external));
const attachments=path.join(root,'arquivo_chat','anexos');
const attachRows=fs.readdirSync(attachments).sort().map(f=>{const p=path.join(attachments,f);const b=fs.readFileSync(p);let kind='Arquivo binario';let sql=false;if(/\.txt$/i.test(f)){const text=b.toString('utf8').replace(/^\uFEFF/,'').trim();sql=/^(?:\/\*[\s\S]*?\*\/\s*|--[^\n]*\n\s*)*(?:WITH\s|SELECT\s)/i.test(text);kind=sql?'Texto com SQL aparente; validacao nao inferida':'Texto ou export tabular';}else if(/\.(?:png|jpe?g)$/i.test(f))kind='Imagem de evidencia';else if(/\.xlsx$/i.test(f))kind='Planilha de evidencia';return{arquivo:'../arquivo_chat/anexos/'+f,tipo:kind,sql_aparente:sql,bytes:b.length,sha256:sha(b)};});
save('CATALOGO_ANEXOS.csv',csv(attachRows));
const userSql=[];
const userDir=path.join(out,'sql_usuario');fs.mkdirSync(userDir,{recursive:true});
for(const id of [15,33,37,75,221,231,250,253,306,325,335,859]){
 const m=msgs.find(m=>m.id===id&&m.role==='user');if(!m)continue;
 const text=request(m.text);const start=text.search(/^(?:SELECT\b|WITH\b)/mi);if(start<0)throw new Error('SQL usuario ausente M'+id);
 const code=text.slice(start).trim();const name='M'+String(id).padStart(4,'0')+'_fornecida_usuario.sql';
 const dst=path.join(userDir,name);fs.writeFileSync(dst,code+'\n','utf8');
 userSql.push({arquivo:'sql_usuario/'+name,mensagem:id,tema:topic(id),estado:id===306?'Base reproduzida pelo usuario apos encerramento M306; revisada depois':'Base fornecida pelo usuario; homologacao individual nao inferida',sha256:sha(fs.readFileSync(dst))});
}
save('CATALOGO_SQL_USUARIO.csv',csv(userSql));
const stats={mensagens_snapshot:msgs.length,primeira_mensagem_registro:msgs[0]?.timestamp,ultima_mensagem_registro:msgs.at(-1)?.timestamp,queries_catalogadas:catalog.length,SQL_usuario_sem_cerca_extraidas:userSql.length,ocorrencias_SQL:[...blockOccurrences.values()].reduce((s,a)=>s+a.length,0),anexos_originais_catalogados:attachRows.length,anexos_SQL_aparente:attachRows.filter(a=>a.sql_aparente).length,anexos_adicionais_recuperados:additional.filter(r=>r.estado==='Copiado e conferido').length,referencias_externas:external.length,copias_externas_novas:external.filter(r=>r.estado==='Copiado e conferido').length,referencias_ausentes:external.filter(r=>r.estado==='Ausente na estacao'||r.estado==='Referencia interna ausente').length,estados_queries:Object.fromEntries([...new Set(catalog.map(q=>q.status))].map(s=>[s,catalog.filter(q=>q.status===s).length]))};
save('ESTATISTICAS.json',JSON.stringify(stats,null,2)+'\n');console.log(JSON.stringify(stats,null,2));
