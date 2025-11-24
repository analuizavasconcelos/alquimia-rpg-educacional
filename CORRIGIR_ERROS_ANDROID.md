# 🔧 Corrigir Erros de Exportação Android - Guia Rápido

## ❌ Erros Comuns e Soluções

### Erro 1: "Invalid Java SDK path. Missing 'bin' directory!"

**Causa**: O caminho do Java SDK está incorreto ou aponta para a pasta errada.

**Solução**:

1. **Encontrar o caminho correto do Java SDK:**
   - Abra o **Android Studio**
   - Vá em **File → Settings** (ou `Ctrl+Alt+S`)
   - Navegue até **Build, Execution, Deployment → Build Tools → Gradle**
   - Veja o campo **Gradle JDK** - esse é o caminho do JDK
   - OU procure manualmente por `java.exe` no Windows:
     - Normalmente em: `C:\Program Files\Java\jdk-17\bin\java.exe`
     - O caminho para configurar no Godot deve ser: `C:\Program Files\Java\jdk-17` (SEM o `\bin`)

2. **Configurar no Godot:**
   - **Editor → Editor Settings → Export → Android**
   - **Java Sdk Path**: Cole o caminho (ex: `C:\Program Files\Java\jdk-17`)
   - ⚠️ **NÃO inclua** a pasta `bin` no caminho!

### Erro 2: "Invalid Android SDK path. Missing 'platform-tools' directory!"

**Causa**: O Android SDK não está instalado corretamente ou o caminho está errado.

**Solução**:

1. **Instalar Platform-Tools:**
   - Abra o **Android Studio**
   - Vá em **Tools → SDK Manager**
   - Clique na aba **SDK Tools**
   - Marque ✅ **Android SDK Platform-Tools**
   - Clique em **Apply** e aguarde a instalação

2. **Verificar o caminho:**
   - O caminho padrão no Windows é: `C:\Users\SeuUsuario\AppData\Local\Android\Sdk`
   - Verifique se existe: `Sdk\platform-tools\adb.exe`

3. **Configurar no Godot:**
   - **Editor → Editor Settings → Export → Android**
   - **Android Sdk Path**: `C:\Users\SeuUsuario\AppData\Local\Android\Sdk`
   - ⚠️ **NÃO inclua** subpastas como `platform-tools` ou `build-tools` no caminho!

### Erro 3: "Invalid Android SDK path. Missing 'build-tools' directory!"

**Causa**: Android SDK Build-Tools não está instalado.

**Solução**:

1. **Instalar Build-Tools:**
   - Abra o **Android Studio**
   - Vá em **Tools → SDK Manager**
   - Clique na aba **SDK Tools**
   - Marque ✅ **Android SDK Build-Tools**
   - Clique em **Apply** e aguarde a instalação

2. **Verificar instalação:**
   - Verifique se existe: `Sdk\build-tools\34.0.0` (ou versão instalada)
   - Dentro deve ter: `apksigner.bat`

### Erro 4: "Unable to find adb command"

**Solução**: Mesma do Erro 2 - instalar Android SDK Platform-Tools.

### Erro 5: "Unable to find apksigner command"

**Solução**: Mesma do Erro 3 - instalar Android SDK Build-Tools.

## 📍 Como Encontrar os Caminhos no Windows

### Método 1: Pelo Android Studio

1. Abra o **Android Studio**
2. Vá em **File → Settings** (ou `Ctrl+Alt+S`)
3. Navegue até **Appearance & Behavior → System Settings → Android SDK**
4. O caminho do **Android SDK Location** está no topo
5. Copie esse caminho exatamente como está

### Método 2: Procurar Manualmente

**Android SDK:**
```powershell
# No PowerShell ou CMD, execute:
dir C:\Users\%USERNAME%\AppData\Local\Android\Sdk\platform-tools\adb.exe
```

**Java SDK:**
```powershell
# Procurar java.exe
dir "C:\Program Files\Java" /s /b | findstr "java.exe"
```

### Método 3: Verificar Variáveis de Ambiente

1. Abra **Painel de Controle → Sistema → Configurações Avançadas do Sistema**
2. Clique em **Variáveis de Ambiente**
3. Verifique se existe:
   - `ANDROID_HOME` ou `ANDROID_SDK_ROOT` → aponta para o Android SDK
   - `JAVA_HOME` → aponta para o Java SDK

## ✅ Checklist de Verificação

Antes de tentar exportar novamente, verifique:

- [ ] Android SDK instalado (pasta `Sdk` existe)
- [ ] Pasta `platform-tools` existe em `Sdk\platform-tools`
- [ ] Arquivo `adb.exe` existe em `Sdk\platform-tools\adb.exe`
- [ ] Pasta `build-tools` existe em `Sdk\build-tools`
- [ ] Pasta com versão existe (ex: `Sdk\build-tools\34.0.0`)
- [ ] Arquivo `apksigner.bat` existe em `Sdk\build-tools\34.0.0\apksigner.bat`
- [ ] Java JDK instalado
- [ ] Pasta `bin` existe no caminho do JDK (ex: `jdk-17\bin`)
- [ ] Arquivo `java.exe` existe em `jdk-17\bin\java.exe`
- [ ] Caminhos configurados no Godot **SEM** incluir subpastas (`bin`, `platform-tools`, etc.)

## 🔄 Após Corrigir os Caminhos

1. **Feche e reabra o Godot** (para recarregar as configurações)
2. Vá em **Project → Export**
3. Os erros devem desaparecer
4. Se ainda houver erros, verifique novamente os caminhos

## 💡 Dica Extra

Se os erros persistirem, tente:

1. **Limpar cache do Godot:**
   - Feche o Godot
   - Delete a pasta `.godot/` do projeto (se necessário)
   - Reabra o projeto

2. **Reinstalar componentes:**
   - No Android Studio, desmarque e marque novamente os componentes
   - Reinstale Platform-Tools e Build-Tools

3. **Verificar permissões:**
   - Certifique-se de que o Godot tem permissão para acessar os diretórios

---

**Se ainda tiver problemas, verifique os logs do Godot para mais detalhes!**

