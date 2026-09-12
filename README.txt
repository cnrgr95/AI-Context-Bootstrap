KULLANIM

1. Bu klasoru diger bilgisayara kopyalayin.
2. INSTALL_OR_REPAIR.bat dosyasina proje klasorunu surukleyip birakin.
   Alternatif: dosyaya cift tiklayip tam proje yolunu yazin.
3. Kurulum bitince Codex, Cursor ve Antigravity'yi yeniden baslatin.
4. CHECK_STATUS.bat dosyasina ayni proje klasorunu surukleyerek kurulumu kontrol edin.

Ayrintili kilavuz: KULLANIM_KILAVUZU.md
GitHub ana sayfasi: README.md

PowerShell ile secenekli kullanim:
  powershell -ExecutionPolicy Bypass -File .\setup-ai-context.ps1 -ProjectPath C:\projeler\ornek
  powershell -ExecutionPolicy Bypass -File .\setup-ai-context.ps1 -ProjectPath C:\projeler\ornek -SkipLaravelBoost
  powershell -ExecutionPolicy Bypass -File .\setup-ai-context.ps1 -ProjectPath C:\projeler\ornek -NoWatcher

INSTALL_OR_REPAIR.bat ayni projede tekrar calistirilabilir. Eksik veya bozuk kurulumu onarir.
