# 🔍 Como Habilitar BBCode no Label - Guia Visual

## 📍 Onde Encontrar "Bbcode Enabled"

No Inspector do Godot, quando você seleciona o **Label**, a propriedade `bbcode_enabled` pode estar em diferentes lugares dependendo da versão:

### Opção 1: Na seção "Label Settings"
1. Selecione o node **Label** (dentro de `Control/Panel`)
2. No Inspector, procure a seção **"Label Settings"** ou **"Text"**
3. Procure por **"Bbcode Enabled"** ou **"BBCode Enabled"**
4. Marque a checkbox ✅

### Opção 2: Na seção "Displayed Text"
1. Selecione o Label
2. No Inspector, expanda a seção **"> Displayed Text"** (clique no `>`)
3. Procure por **"Bbcode Enabled"**
4. Marque a checkbox ✅

### Opção 3: Usar o filtro
1. Selecione o Label
2. No campo **"Filter Properties"** (barra de busca no topo do Inspector)
3. Digite: `bbcode` ou `bbc`
4. A propriedade deve aparecer filtrada
5. Marque a checkbox ✅

## 🔧 Se Não Encontrar a Propriedade

Se a propriedade não aparecer no Inspector, você pode adicionar manualmente no arquivo `.tscn`:

1. Abra `scenes/ui/npc_dialogue_box.tscn` em um editor de texto
2. Encontre a seção do Label (procure por `[node name="Label"`)
3. Adicione a linha: `bbcode_enabled = true`
4. Deve ficar assim:

```
[node name="Label" type="Label" parent="Control/Panel"]
...
autowrap_mode = 3
bbcode_enabled = true  ← ADICIONE ESTA LINHA
metadata/_edit_use_anchors_ = true
```

## ✅ Verificação

Após habilitar, teste:
1. Execute o jogo (F5)
2. Fale com o NPC base
3. As palavras "Átomo" e "Molécula" devem aparecer em **dourado/amarelo** e **negrito**

Se ainda aparecer `[color=#FFD700]...` literalmente, o BBCode não está habilitado.

