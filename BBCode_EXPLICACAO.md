# 📖 Como Funciona o BBCode no Godot

## 🎯 O que é BBCode?

BBCode é um sistema de formatação de texto usado no Godot (similar ao HTML, mas mais simples). Ele permite adicionar cores, negrito, itálico, etc. ao texto em Labels.

## 🔧 Como Funciona:

### 1. **Habilitar BBCode no Label**

O Label precisa ter a propriedade `bbcode_enabled = true` habilitada. Sem isso, as tags aparecem literalmente como texto!

```
❌ SEM bbcode_enabled:
Texto: "[color=#FFD700]átomo[/color]"
Exibe: "[color=#FFD700]átomo[/color]" (mostra as tags)

✅ COM bbcode_enabled = true:
Texto: "[color=#FFD700]átomo[/color]"
Exibe: "átomo" (em dourado, tags processadas)
```

### 2. **Tags BBCode Comuns:**

- `[color=#FFD700]texto[/color]` - Cor do texto (hexadecimal)
- `[b]texto[/b]` - Negrito
- `[i]texto[/i]` - Itálico
- `[u]texto[/u]` - Sublinhado

### 3. **Como Nosso Sistema Funciona:**

1. **No JSON do diálogo:**
   ```json
   "Quando esses [k=\"atomo\"] se juntam..."
   ```

2. **O código processa:**
   - Encontra `[k="atomo"]`
   - Busca o nome "Átomo" no KnowledgeManager
   - Substitui por: `[color=#FFD700][b]Átomo[/b][/color]`

3. **O Label renderiza:**
   - Se `bbcode_enabled = true`: Mostra "Átomo" em dourado e negrito
   - Se `bbcode_enabled = false`: Mostra "[color=#FFD700][b]Átomo[/b][/color]" literalmente

## ⚠️ Por Que Não Está Funcionando?

O `bbcode_enabled = true` foi removido do arquivo `.tscn`! 

**Solução:** Adicione de volta no arquivo `npc_dialogue_box.tscn` na linha do Label:

```
[node name="Label" type="Label" parent="Control/Panel"]
...
bbcode_enabled = true  ← ESTA LINHA É ESSENCIAL!
```

## 🔍 Verificação:

1. Abra `scenes/ui/npc_dialogue_box.tscn` no Godot
2. Selecione o node "Label" dentro de "Control/Panel"
3. No Inspector, procure por "Bbcode Enabled"
4. **Deve estar marcado como `true`** ✅

Se não estiver, marque a checkbox ou adicione `bbcode_enabled = true` no arquivo.

