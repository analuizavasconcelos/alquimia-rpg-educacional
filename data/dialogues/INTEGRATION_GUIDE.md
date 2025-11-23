# 🔧 Guia de Integração - Sistema de Conhecimento

## 📋 Passos para Integrar na Cena Principal

Para que o sistema de conhecimento funcione, você precisa adicionar dois nodes na cena principal (`vilarejo.tscn`):

### 1. KnowledgeManager

1. Abra `scenes/levels/vilarejo.tscn` no Godot
2. Selecione o nó raiz (Vilarejo)
3. Adicione um novo Node (botão direito → Add Child Node → Node)
4. Renomeie para `KnowledgeManager`
5. No Inspector, adicione ao grupo `knowledge_manager`
6. No Inspector, em "Script", carregue `res://scenes/ui/knowledge_manager.gd`

### 2. KnowledgeNotification

1. Ainda na cena `vilarejo.tscn`
2. Selecione o nó raiz (Vilarejo)
3. Adicione um novo CanvasLayer (botão direito → Add Child Node → CanvasLayer)
4. Renomeie para `KnowledgeNotification`
5. No Inspector, em "Scene", carregue `res://scenes/ui/knowledge_notification.tscn` OU
6. Se preferir criar manualmente, adicione o script `res://scenes/ui/knowledge_notification.gd` e configure os nodes conforme o arquivo `.tscn`

## ✅ Verificação

Após adicionar os nodes, verifique:

- [ ] KnowledgeManager está no grupo `knowledge_manager`
- [ ] KnowledgeNotification está visível na árvore de cena
- [ ] Ambos têm seus scripts corretos atribuídos

## 🎮 Teste

1. Execute o jogo
2. Fale com o NPC base (que tem diálogo com `[k="atomo"]`)
3. Quando o diálogo mostrar "átomo", um popup deve aparecer no centro da tela
4. O texto "átomo" deve aparecer destacado em dourado no diálogo

## 🐛 Troubleshooting

**Popup não aparece:**
- Verifique se KnowledgeManager está no grupo correto
- Verifique se KnowledgeNotification está conectado ao sinal `knowledge_unlocked`

**Texto não destaca:**
- Verifique se `bbcode_enabled = true` no Label do dialogue_box
- Verifique se o conhecimento existe no `knowledge_manager.gd`

**Conhecimento não desbloqueia:**
- Verifique se a tag está correta: `[k="id"]` ou `[knowledge="id"]`
- Verifique se o ID do conhecimento existe em `available_knowledge`

