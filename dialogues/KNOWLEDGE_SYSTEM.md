# 📚 Sistema de Conhecimento

Sistema que permite desbloquear conhecimentos através de diálogos com NPCs.

## 🎯 Como Funciona

Quando o jogador conversa com NPCs, palavras ou frases marcadas como conhecimento são destacadas em **dourado/amarelo** no diálogo. Ao aparecerem, o conhecimento é automaticamente desbloqueado e um popup aparece mostrando o novo conhecimento adquirido.

## ✍️ Como Usar nos Diálogos JSON

Use tags `[k="id"]` ou `[knowledge="id"]` para marcar conhecimento nos diálogos:

```json
{
	"dialogue": [
		"Olá! Você sabia que tudo é feito de [k=\"atomo\"]?",
		"Quando átomos se juntam, formam [k=\"molecula\"]!",
		"E quando moléculas reagem, temos uma [k=\"reacao_quimica\"]!"
	]
}
```

### Formato das Tags

- **Tag simples**: `[k="id"]` - A tag será substituída pelo nome do conhecimento destacado
- **Tag com texto**: `[k="id"]texto personalizado[/k]` - Use o texto personalizado destacado

## 🔧 Adicionar Novos Conhecimentos

Edite `scenes/ui/knowledge_manager.gd` e adicione novos conhecimentos no dicionário `available_knowledge`:

```gdscript
var available_knowledge: Dictionary = {
	"seu_id": {
		"name": "Nome do Conhecimento",
		"description": "Descrição detalhada do conhecimento.",
		"category": "quimica"
	}
}
```

Ou use a função `add_knowledge()` em runtime:

```gdscript
knowledge_manager.add_knowledge("novo_id", "Novo Conhecimento", "Descrição...", "quimica")
```

## 🎨 Visualização

- **No diálogo**: Conhecimentos aparecem em **dourado/amarelo** e **negrito**
- **Popup**: Aparece no centro da tela quando um conhecimento é desbloqueado
- **Duração**: O popup desaparece automaticamente após 3 segundos

## 📋 Exemplo Completo

```json
{
	"dialogue": [
		"Olá! Bem-vindo ao vilarejo!",
		"Você sabia que tudo ao nosso redor é feito de [k=\"atomo\"]?",
		"Quando esses [k=\"atomo\"] se juntam, formam [k=\"molecula\"]!",
		"E quando moléculas reagem, temos uma [k=\"reacao_quimica\"]!"
	]
}
```

## 🚀 Integração na Cena

Certifique-se de que a cena principal (`vilarejo.tscn`) tenha:

1. **KnowledgeManager** (Node) - Gerencia conhecimentos
2. **KnowledgeNotification** (CanvasLayer) - Mostra popups de notificação

Ambos devem estar no grupo correto para funcionarem automaticamente.

