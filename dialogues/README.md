# 💬 Sistema de Diálogo

Sistema de diálogo para NPCs com suporte a arquivos JSON.

## 📁 Estrutura

Os diálogos são armazenados em arquivos JSON na pasta `dialogues/`. Cada NPC pode ter seu próprio arquivo de diálogo.

### Formato do JSON

```json
{
	"dialogue": [
		"Primeira linha de diálogo",
		"Segunda linha de diálogo",
		"Terceira linha de diálogo"
	]
}
```

## 🎮 Como Usar

### 1. Criar um arquivo de diálogo

Crie um arquivo JSON na pasta `dialogues/` com o nome que desejar, por exemplo:
- `dialogues/npc_base.json`
- `dialogues/npc_curlyhair.json`
- `dialogues/merchant.json`

### 2. Configurar o NPC

No Godot Editor:
1. Selecione o NPC na cena
2. No Inspector, encontre a propriedade **Dialogue File**
3. Digite o caminho do arquivo JSON, por exemplo: `res://dialogues/npc_base.json`

### 3. Interagir com o NPC

- **Aproxime-se do NPC**: O ícone de chat aparecerá acima do NPC
- **Pressione E** ou **Clique com o mouse** no NPC para iniciar o diálogo
- **Pressione E** ou **Clique** novamente para avançar para a próxima linha
- O diálogo fecha automaticamente quando todas as linhas forem exibidas

## 📝 Exemplos

### Diálogo Simples

```json
{
	"dialogue": [
		"Olá! Bem-vindo ao vilarejo!",
		"Espero que você esteja se sentindo bem por aqui.",
		"Se precisar de algo, é só me chamar!"
	]
}
```

### Diálogo Mais Longo

```json
{
	"dialogue": [
		"Bom dia, viajante!",
		"Você parece estar perdido...",
		"Posso ajudá-lo a encontrar o que procura.",
		"Tenho algumas informações sobre a região.",
		"O que você gostaria de saber?"
	]
}
```

## ⚙️ Configurações do NPC

No script do NPC (`npc.gd`), você pode ajustar:

- **`dialogue_file`**: Caminho para o arquivo JSON de diálogo
- **`interaction_distance`**: Distância mínima para interagir (padrão: 50.0 pixels)

## 🎨 Personalização

### Alterar o Ícone de Chat

O ícone de chat está em `scenes/ui/chat_icon.tscn`. Você pode substituir a textura ou ajustar a posição.

### Alterar o Balão de Diálogo

O balão de diálogo está em `scenes/ui/dialogue_box.tscn`. Você pode:
- Ajustar o tamanho do painel
- Mudar as cores e estilos
- Alterar a fonte e tamanho do texto
- Modificar a posição na tela

## 🔧 Troubleshooting

### O ícone de chat não aparece

1. Verifique se o player está no grupo "player"
2. Verifique se a `InteractionArea` está configurada corretamente no NPC
3. Verifique se a distância de interação não está muito pequena

### O diálogo não inicia

1. Verifique se o caminho do arquivo JSON está correto no Inspector do NPC
2. Verifique se o arquivo JSON está no formato correto
3. Verifique se o `DialogueManager` está na cena

### Erro ao carregar JSON

1. Verifique se o arquivo JSON está bem formatado (use um validador JSON online)
2. Verifique se o arquivo tem a propriedade "dialogue" como um Array
3. Verifique se todas as strings estão entre aspas duplas

