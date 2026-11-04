# ⚗️ Dados da Mesa de Alquimia

Os arquivos desta pasta definem **o que existe** e **o que reage** na mesa de alquimia. Para criar novas reações basta editar os JSON, sem mexer em código.

## `substancias.json`

```json
{
	"id": "acido_cloridrico",
	"name": "Ácido clorídrico",
	"formula": "HCl",
	"group": "Ácido",
	"description": "Ácido forte, presente também no suco gástrico.",
	"requires_knowledge": "acido"
}
```

| Campo | Obrigatório | Descrição |
|---|---|---|
| `id` | sim | Identificador único, sem espaços nem acentos |
| `name` | sim | Nome exibido |
| `formula` | sim | Fórmula em texto simples (`H2O`, `CH3COOH`). O jogo transforma os números em subscritos (H₂O). Deixe `""` para condições como calor |
| `group` | sim | Classificação mostrada ao jogador (Metal, Ácido, Base, Sal...) |
| `description` | sim | Texto mostrado ao clicar na substância |
| `requires_knowledge` | não | Id de um conhecimento. O reagente só fica disponível depois que o jogador aprende esse conceito |
| `product_only` | não | `true` = só aparece como produto, não como reagente na lista |

## `reacoes.json`

```json
{
	"id": "sintese_agua",
	"reagents": ["hidrogenio", "oxigenio"],
	"products": ["agua"],
	"equation": "2 H2 + O2 -> 2 H2O",
	"type": "Síntese",
	"knowledge": ["sintese"],
	"explanation": "Texto que explica a reação para o aluno."
}
```

| Campo | Obrigatório | Descrição |
|---|---|---|
| `id` | sim | Identificador único (é o que fica salvo no progresso) |
| `reagents` | sim | **Exatamente 2** ids de substâncias. A ordem não importa |
| `products` | sim | Ids das substâncias formadas |
| `equation` | sim | Equação **balanceada**, com `->` entre os lados |
| `type` | sim | Tipo da reação (Síntese, Decomposição, Combustão...) |
| `knowledge` | não | Ids de conhecimentos desbloqueados ao realizar a reação. Precisam existir em `knowledge_manager.gd` |
| `explanation` | sim | Explicação mostrada ao aluno |

## Regras
- Cada par de reagentes só pode ter **uma** reação.
- Ids em `reagents` e `products` precisam existir em `substancias.json`. Se não existirem, a reação é ignorada e um aviso aparece no painel **Output** do Godot.
- Confira o balanceamento da equação antes de adicionar: o aluno vai estudar por ela.
