# 🔧 Configuração do Sistema de Conhecimento - PASSO A PASSO

## ⚠️ IMPORTANTE: Você precisa adicionar manualmente 2 nodes na cena!

### Passo 1: Adicionar KnowledgeManager

1. **Abra o Godot Editor**
2. **Abra a cena principal**: `scenes/levels/vilarejo.tscn`
3. **Selecione o nó raiz** "Vilarejo" na árvore de cena (lado esquerdo)
4. **Clique com botão direito** no nó "Vilarejo"
5. **Escolha**: "Add Child Node" (ou pressione Ctrl+A)
6. **Procure por**: `Node` (não CanvasLayer, não Node2D, apenas `Node`)
7. **Clique em "Create"**
8. **Renomeie o node** para `KnowledgeManager` (clique direito → Rename, ou F2)
9. **No Inspector** (lado direito):
   - Vá até a seção **"Groups"** (ou "Node" → "Groups")
   - Clique em **"Add to Group"**
   - Digite: `knowledge_manager` (minúsculas, sem espaços)
   - Pressione Enter
10. **No Inspector**, vá até **"Script"**:
    - Clique no ícone de pasta ao lado de "Script"
    - Navegue até: `res://scenes/ui/knowledge_manager.gd`
    - Selecione o arquivo
    - Clique em "Open"

### Passo 2: Adicionar KnowledgeNotification

1. **Ainda na cena** `vilarejo.tscn`
2. **Selecione o nó raiz** "Vilarejo" novamente
3. **Clique com botão direito** → "Add Child Node"
4. **Procure por**: `CanvasLayer`
5. **Clique em "Create"**
6. **Renomeie** para `KnowledgeNotification`
7. **No Inspector**, em **"Scene"** (ou "Node" → "Instance"):
   - Clique no ícone de pasta ao lado de "Scene"
   - Navegue até: `res://scenes/ui/knowledge_notification.tscn`
   - Selecione o arquivo
   - Clique em "Open"

### Passo 3: Verificar

Sua árvore de cena deve ter algo assim:

```
Vilarejo (Node2D)
├── ... (outros nodes)
├── DialogueManager (Node)
├── KnowledgeManager (Node) ← NOVO
└── KnowledgeNotification (CanvasLayer) ← NOVO
```

### Passo 4: Testar

1. **Salve a cena** (Ctrl+S)
2. **Execute o jogo** (F5)
3. **Fale com o NPC base** (que tem o diálogo com `[k="atomo"]`)
4. **Quando aparecer "átomo" no diálogo**, deve aparecer:
   - ✅ A palavra "átomo" destacada em **dourado/amarelo** e **negrito**
   - ✅ Um popup no centro da tela mostrando o conhecimento desbloqueado

## 🐛 Se ainda não funcionar:

### Verificar KnowledgeManager:
- [ ] Está no grupo `knowledge_manager`? (verifique em Node → Groups)
- [ ] Tem o script `knowledge_manager.gd` atribuído?
- [ ] Está como filho do nó raiz "Vilarejo"?

### Verificar KnowledgeNotification:
- [ ] Está instanciado da cena `knowledge_notification.tscn`?
- [ ] Está como filho do nó raiz "Vilarejo"?

### Verificar Dialogue Box:
- [ ] O Label tem `bbcode_enabled = true`? (verifique em `npc_dialogue_box.tscn`)

### Debug:
Adicione este código temporário em `npc_dialogue_box.gd` na função `_process_knowledge_tags()` para ver o que está acontecendo:

```gdscript
func _process_knowledge_tags(line: String) -> String:
	var processed = line
	var knowledge_manager = get_tree().get_first_node_in_group("knowledge_manager")
	
	if not knowledge_manager:
		print("ERRO: KnowledgeManager não encontrado!")
		return line
	
	print("Processando linha: ", line)
	# ... resto do código
```

## ✅ Checklist Final

- [ ] KnowledgeManager adicionado na cena
- [ ] KnowledgeManager no grupo `knowledge_manager`
- [ ] KnowledgeManager com script `knowledge_manager.gd`
- [ ] KnowledgeNotification adicionado na cena
- [ ] KnowledgeNotification instanciado de `knowledge_notification.tscn`
- [ ] `bbcode_enabled = true` no Label do dialogue_box
- [ ] Cena salva
- [ ] Jogo testado

