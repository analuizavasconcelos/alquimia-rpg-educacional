# 🔍 Onde Encontrar "Bbcode Enabled" no Inspector

## 📍 Localização no Godot 4

A propriedade **"Bbcode Enabled"** pode estar em diferentes lugares dependendo da versão do Godot:

### Opção 1: Na seção "Displayed Text" (mais comum)
1. Selecione o **Label** no Godot
2. No Inspector, expanda a seção **"> Displayed Text"** (clique no `>` para expandir)
3. Procure por **"Bbcode Enabled"** ou **"BBCode Enabled"**
4. Marque a checkbox ✅

### Opção 2: Usar o Filtro (mais fácil!)
1. Selecione o **Label**
2. No campo **"Filter Properties"** (barra de busca no topo do Inspector)
3. Digite: `bbcode` ou `bbc`
4. A propriedade deve aparecer filtrada
5. Marque a checkbox ✅

### Opção 3: Na seção "Text" ou "Label Settings"
1. Selecione o **Label**
2. Procure por uma seção chamada **"Text"** ou **"Label Settings"**
3. Expanda se necessário
4. Procure por **"Bbcode Enabled"**

## ✅ Já Está Configurado!

**Boa notícia:** O arquivo `npc_dialogue_box.tscn` já tem `bbcode_enabled = true` configurado!

Mesmo que você não veja no Inspector, o arquivo já está correto. O código também tenta habilitar automaticamente como backup.

## 🧪 Teste Agora:

1. Execute o jogo (F5)
2. Fale com o NPC base
3. Verifique o console - deve aparecer: `🔧 BBCode habilitado no Label: true`
4. As palavras "Átomo" e "Molécula" devem aparecer em **dourado/amarelo** e **negrito**

Se ainda não funcionar, use o filtro no Inspector e procure por `bbcode`.

