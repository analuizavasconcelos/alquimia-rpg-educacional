# 💬 Sistema de Diálogo

Sistema de diálogo para NPCs com suporte a arquivos JSON.

## 📁 Estrutura

Os diálogos são armazenados em arquivos JSON na pasta `data/dialogues/`. Cada NPC pode ter seu próprio arquivo de diálogo.

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

## ❓ Perguntas no diálogo (novo)

Além de texto, uma entrada de `dialogue` pode ser um **objeto** do tipo pergunta. Textos e perguntas podem ser misturados livremente na mesma lista.

```json
{
	"dialogue": [
		"Vou te testar!",
		{
			"type": "question",
			"id": "q_shorthair_solucao",
			"text": "Sal dissolvido por completo na água forma o quê?",
			"options": ["Substância pura", "Solução", "Elemento químico"],
			"correct": 1,
			"feedback_correct": "Correto! Isso é uma solução.",
			"feedback_wrong": "Quase! Pense em uma mistura uniforme.",
			"unlock": ["solucao"]
		},
		"Muito bem!"
	]
}
```

| Campo | Obrigatório | Descrição |
|---|---|---|
| `type` | sim | Sempre `"question"` |
| `text` | sim | Enunciado (aceita BBCode e tags `[k="id"]` só para destaque) |
| `options` | sim | Lista com 2 ou mais alternativas |
| `correct` | sim | Posição da alternativa certa, **começando em 0** |
| `id` | recomendado | Identificador único, usado nas métricas do save. Se faltar, é gerado automaticamente |
| `feedback_correct` | não | Explicação mostrada ao acertar |
| `feedback_wrong` | não | Dica mostrada ao errar |
| `unlock` | não | Id (ou lista de ids) de conhecimentos desbloqueados **só quando o jogador acerta** |

**Como funciona:**
- O jogador escolhe clicando na opção ou pressionando as teclas **1, 2, 3...**
- Se errar, a opção fica vermelha, aparece a dica e ele pode tentar de novo. Se acertar, o feedback aparece e **Enter/Espaço ou clique** continua a conversa.
- Enquanto a pergunta não for respondida corretamente, o diálogo não avança.
- Cada resposta é registrada no save em `quiz_stats` (tentativas, erros, se acertou de primeira).
- Se a pergunta estiver mal escrita (ex.: `correct` fora da lista), o jogo mostra um erro no painel **Output** e pula a pergunta.

## 🎮 Como Usar

### 1. Criar um arquivo de diálogo

Crie um arquivo JSON na pasta `data/dialogues/` com o nome que desejar, por exemplo:
- `data/dialogues/npc_base.json`
- `data/dialogues/npc_curlyhair.json`
- `data/dialogues/merchant.json`

### 2. Configurar o NPC

No Godot Editor:
1. Selecione o NPC na cena
2. No Inspector, encontre a propriedade **Dialogue File**
3. Digite o caminho do arquivo JSON, por exemplo: `res://data/dialogues/npc_base.json`

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

No script do NPC (`src/entities/npc.gd`), você pode ajustar:

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

