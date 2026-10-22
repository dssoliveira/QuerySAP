import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
const root=path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const tabular=file=>{
 const lines=fs.readFileSync(path.join(root,file),'utf8').replace(/^\uFEFF/,'').split(/\r?\n/).filter(l=>l.trim());
 const headers=lines.shift().split('\t');
 return lines.map(l=>{const c=l.split('\t');return Object.fromEntries(headers.map((h,i)=>[h,c[i]??'']));}).filter(r=>/^\d+$/.test(r['#']??''));
};
const source=tabular('arquivo_chat/anexos/047_Texto colado.txt');
const refs=tabular('arquivo_chat/anexos/029_Texto colado.txt');
const approvals=tabular('arquivo_chat/anexos/016_Texto colado.txt');
const group=(rows,key)=>Object.fromEntries([...new Set(rows.map(r=>r[key]))].sort().map(s=>[s,rows.filter(r=>r[key]===s).length]));
const sample=[4212,4195,4189,4188,4213].map(id=>{
 const r=approvals.find(r=>r['Codigo Processo Aprovacao']===String(id));if(!r)throw new Error('Processo ausente '+id);
 return {processo:id,PC:r['Numero Pedido Compra'],esboco:r['Chave Esboco Compra'],processo_status:r['Status Processo SAP'],solicitacao_status:r['Status Solicitacao SAP'],data_autorizacao:r['Data Autorizacao a Validar'],data_recusa:r['Data Recusa a Validar']};
});
if(source.length!==1363||new Set(source.map(r=>r['Pedido Transferencia'])).size!==423)throw new Error('Base transferencia divergiu das contagens historicas');
if(refs.length!==106)throw new Error('Contagem de referencias divergiu');
if(!refs.every(r=>r['Tipo Documento Relacionado']==='Solicitacao de compra'))throw new Error('Tipo de referencia adicional encontrado');
const findings={
 transferencia:{linhas:source.length,pedidos_distintos:new Set(source.map(r=>r['Pedido Transferencia'])).size,tipos_origem:group(source,'Tipo Documento Origem'),tipos_destino:group(source,'Tipo Documento Destino'),referencia_SC_preenchida:source.filter(r=>r['Referencia Solicitacao Compra'].trim()).length},
 referencias:{linhas:refs.length,transferencias_distintas:new Set(refs.map(r=>r['Pedido Transferencia'])).size,tipos:group(refs,'Tipo Documento Relacionado')},
 aprovacao:{linhas:approvals.length,processos_distintos:new Set(approvals.map(r=>r['Codigo Processo Aprovacao'])).size,status_processo:group(approvals,'Status Processo SAP'),finalidades:group(approvals,'Finalidade Aprovacao'),exemplos:sample},
 limite:'Contagem e conferencia de exports preservados. Nao houve execucao no SAP nem homologacao multi-etapas da data de autorizacao.'
};
fs.writeFileSync(path.join(root,'auditoria','CONFERENCIA_EVIDENCIAS.json'),JSON.stringify(findings,null,2)+'\n','utf8');
console.log(JSON.stringify(findings,null,2));
