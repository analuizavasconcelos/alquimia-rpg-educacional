# 📱 Como Gerar APK para Android - Guia Completo

Este guia explica como exportar seu jogo Godot para Android (APK).

## 📋 Pré-requisitos

### 1. **Android SDK e NDK**
Você precisa instalar:
- **Android SDK** (Software Development Kit)
- **Android NDK** (Native Development Kit) - versão recomendada: r25b ou superior
- **Java JDK** (Java Development Kit) - versão 17 ou superior

**Onde baixar:**
- **Android Studio**: Inclui SDK Manager para instalar SDK e NDK
  - Download: https://developer.android.com/studio
- **JDK**: 
  - Oracle JDK: https://www.oracle.com/java/technologies/downloads/
  - OpenJDK: https://adoptium.net/

### 2. **Instalar Componentes Necessários**

Após instalar o Android Studio:

1. Abra o **Android Studio**
2. Vá em **Tools → SDK Manager** (ou clique no ícone de SDK Manager na toolbar)
3. Na aba **SDK Platforms**, instale:
   - **Android 14.0 (API 34)** ou a versão mais recente
   - **Android 5.0 (API 21)** ou superior (mínimo recomendado)
4. Na aba **SDK Tools**, instale:
   - ✅ **Android SDK Build-Tools** (versão mais recente)
   - ✅ **Android SDK Platform-Tools**
   - ✅ **Android SDK Command-line Tools**
   - ✅ **NDK (Side by side)** - versão r25b ou superior
   - ✅ **CMake** (se necessário)
5. Clique em **Apply** e aguarde a instalação

### 3. **Configurar no Godot**

1. Abra o Godot
2. Vá em **Editor → Editor Settings** (ou `Ctrl+,`)
3. Navegue até **Export → Android**
4. Configure os caminhos:

#### **Caminhos do SDK (IMPORTANTE)**

**Android Sdk Path**: 
- Windows: `C:\Users\SeuUsuario\AppData\Local\Android\Sdk`
- Linux: `~/Android/Sdk`
- macOS: `~/Library/Android/sdk`

⚠️ **Verifique se o caminho contém:**
- Pasta `platform-tools` (com o arquivo `adb`)
- Pasta `build-tools` (com versões como `34.0.0`)
- Pasta `platforms` (com pastas como `android-34`)

**Java Sdk Path**:
- Windows: `C:\Program Files\Java\jdk-17` (ou versão instalada)
- Linux: `/usr/lib/jvm/java-17-openjdk` (ou caminho do JDK)
- macOS: `/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home`

⚠️ **Verifique se o caminho contém:**
- Pasta `bin` (com arquivos como `java.exe`, `javac.exe`)

#### **Keystore (para Debug)**

- **Debug Keystore**: Deixe em branco (será criado automaticamente) ou crie um manualmente
- **Debug Keystore User**: Seu nome (ex: "Seu Nome")
- **Debug Keystore Pass**: Uma senha (ex: "android")
- **Debug Key User Alias**: "androiddebugkey"
- **Debug Key Pass**: A mesma senha do keystore

### 4. **Verificar Instalação**

Para verificar se os caminhos estão corretos:

**Windows (PowerShell ou CMD):**
```powershell
# Verificar Android SDK
Test-Path "C:\Users\SeuUsuario\AppData\Local\Android\Sdk\platform-tools\adb.exe"
Test-Path "C:\Users\SeuUsuario\AppData\Local\Android\Sdk\build-tools"

# Verificar Java SDK
Test-Path "C:\Program Files\Java\jdk-17\bin\java.exe"
```

**Linux/macOS:**
```bash
# Verificar Android SDK
ls ~/Android/Sdk/platform-tools/adb
ls ~/Android/Sdk/build-tools

# Verificar Java SDK
ls /usr/lib/jvm/java-17-openjdk/bin/java
```

## 🔧 Passo a Passo para Exportar

### Passo 1: Instalar Templates de Exportação

1. No Godot, vá em **Editor → Manage Export Templates**
2. Baixe os templates para **Godot 4.4**
3. Aguarde o download e instalação

### Passo 2: Configurar Export para Android

1. Vá em **Project → Export**
2. Clique em **Add...** e selecione **Android**
3. Configure as opções:

#### **General**
- **Package**: `com.seunome.jogo_tcc` (use seu nome/empresa)
- **Version Name**: `1.0` (versão legível)
- **Version Code**: `1` (número da versão, incremente a cada build)
- **Min SDK**: `21` (Android 5.0 Lollipop - recomendado)
- **Target SDK**: `34` (Android 14 - ou a versão mais recente)
- **Screen Orientation**: `Landscape` ou `Portrait` (conforme seu jogo)

#### **Permissions**
- Adicione permissões se necessário:
  - `INTERNET` (se precisar de conexão)
  - `WRITE_EXTERNAL_STORAGE` (se precisar salvar arquivos externos)
  - `READ_EXTERNAL_STORAGE` (se precisar ler arquivos externos)

#### **Graphics**
- **OpenGL ES 3.0**: Habilitado (recomendado)
- **Vulkan**: Opcional (para dispositivos mais modernos)

#### **Architectures**
- Selecione as arquiteturas que deseja suportar:
  - `armeabi-v7a` (32-bit ARM - dispositivos mais antigos)
  - `arm64-v8a` (64-bit ARM - dispositivos modernos, **recomendado**)
  - `x86` (32-bit x86 - emuladores)
  - `x86_64` (64-bit x86 - emuladores)

**Recomendação**: Selecione apenas `arm64-v8a` para builds menores, ou `armeabi-v7a` + `arm64-v8a` para compatibilidade máxima.

#### **Icon**
- Configure o ícone do app (512x512 pixels recomendado)
- Pode usar o `icon.svg` do projeto

#### **Keystore**
- **Release**: Crie um keystore para builds de release
  - Clique em **Create** para gerar um novo keystore
  - **Path**: Escolha onde salvar (ex: `android_release.keystore`)
  - **Password**: Crie uma senha forte
  - **Alias**: Nome do alias (ex: "release")
  - **Password (Alias)**: Senha do alias
  - **Validity**: 20000 (anos de validade)

⚠️ **IMPORTANTE**: Guarde o keystore e as senhas! Você precisará deles para atualizar o app na Play Store.

### Passo 3: Exportar APK

1. Com o preset Android selecionado, clique em **Export Project**
2. Escolha onde salvar o APK (ex: `jogo_tcc.apk`)
3. Clique em **Save**
4. Aguarde a compilação (pode demorar alguns minutos na primeira vez)

### Passo 4: Testar o APK

1. **Instalar no dispositivo**:
   - Conecte seu dispositivo Android via USB
   - Ative **Depuração USB** nas opções de desenvolvedor
   - No Godot, você pode usar **Project → Run → Run on Device** para testar diretamente

2. **Instalar manualmente**:
   - Transfira o APK para o dispositivo
   - No dispositivo, vá em **Configurações → Segurança → Fontes Desconhecidas** (permitir instalação de apps de fontes desconhecidas)
   - Abra o APK e instale

## 🎯 Dicas e Troubleshooting

### Problemas Comuns

1. **"Invalid Java SDK path. Missing 'bin' directory!"**
   - ✅ **Solução**: Verifique se o caminho do Java SDK aponta para a pasta raiz do JDK (não para `bin`)
   - Exemplo correto: `C:\Program Files\Java\jdk-17`
   - Exemplo errado: `C:\Program Files\Java\jdk-17\bin`
   - Verifique se a pasta `bin` existe dentro do caminho especificado

2. **"Invalid Android SDK path. Missing 'platform-tools' directory!"**
   - ✅ **Solução**: 
     - Verifique se o caminho do Android SDK está correto
     - Abra o Android Studio → SDK Manager → SDK Tools
     - Certifique-se de que **Android SDK Platform-Tools** está instalado
     - O caminho deve ser: `C:\Users\SeuUsuario\AppData\Local\Android\Sdk` (sem subpastas)

3. **"Invalid Android SDK path. Missing 'build-tools' directory!"**
   - ✅ **Solução**:
     - Abra o Android Studio → SDK Manager → SDK Tools
     - Instale **Android SDK Build-Tools** (versão mais recente)
     - Verifique se a pasta `build-tools` existe em: `Sdk\build-tools\34.0.0` (ou versão instalada)

4. **"Unable to find adb command"**
   - ✅ **Solução**: 
     - Instale **Android SDK Platform-Tools** pelo SDK Manager
     - Verifique se `adb.exe` existe em: `Sdk\platform-tools\adb.exe`

5. **"Unable to find apksigner command"**
   - ✅ **Solução**:
     - Instale **Android SDK Build-Tools** pelo SDK Manager
     - Verifique se `apksigner.bat` existe em: `Sdk\build-tools\34.0.0\apksigner.bat`

6. **"NDK not found"**
   - ✅ **Solução**:
     - Instale o NDK pelo Android Studio (SDK Manager → SDK Tools → NDK (Side by side))
     - Selecione a versão r25b ou superior
     - O NDK será instalado em: `Sdk\ndk\25.1.8937393` (número da versão)

7. **"Gradle build failed"**
   - ✅ **Solução**:
     - Verifique se o JDK está instalado e configurado corretamente
     - Tente limpar o cache: Delete a pasta `android/` no projeto (se existir)
     - Verifique se há espaço em disco suficiente

8. **APK muito grande**
   - ✅ **Solução**:
     - Remova arquiteturas desnecessárias (deixe apenas `arm64-v8a`)
     - Comprima texturas e assets
     - Use **Export → Resources → Export Mode: "Export selected scenes"** para exportar apenas o necessário

### Como Encontrar os Caminhos Corretos

**Windows:**
1. Abra o **Android Studio**
2. Vá em **File → Settings** (ou `Ctrl+Alt+S`)
3. Navegue até **Appearance & Behavior → System Settings → Android SDK**
4. O caminho do SDK está em **Android SDK Location**
5. Para o Java SDK, verifique em **File → Project Structure → SDK Location → JDK location**

**Alternativa - Verificar manualmente:**
- Android SDK: Procure por `adb.exe` no Windows Explorer
- Java SDK: Procure por `java.exe` no Windows Explorer

### Otimizações

- **Reduzir tamanho do APK**:
  - Use apenas as arquiteturas necessárias
  - Comprima assets
  - Remova assets não utilizados

- **Melhorar performance**:
  - Configure **Export → Resources → Export Mode** adequadamente
  - Use **Export → Resources → Exclude Resources** para remover assets de debug

## 📦 Builds de Release vs Debug

- **Debug**: Para testes, inclui símbolos de debug, maior tamanho
- **Release**: Para distribuição, otimizado, menor tamanho

Para publicar na Play Store, use sempre **Release** com keystore próprio.

## 🔗 Links Úteis

- **Documentação oficial Godot Android**: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
- **Android Developer**: https://developer.android.com/
- **Godot Export Templates**: Disponível no próprio editor

## ✅ Checklist Antes de Exportar

- [ ] Android SDK instalado e configurado
- [ ] NDK instalado
- [ ] JDK instalado
- [ ] Templates de exportação instalados
- [ ] Caminhos configurados no Editor Settings
- [ ] Preset Android criado e configurado
- [ ] Permissões configuradas (se necessário)
- [ ] Ícone do app configurado
- [ ] Keystore criado (para release)
- [ ] Arquiteturas selecionadas
- [ ] Testado no dispositivo/emulador

---

**Boa sorte com a exportação! 🚀**

