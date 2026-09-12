# Windows kullanım kılavuzu

## Gereksinimler

Git, PowerShell 5.1+, WinGet ve ilk kurulum için internet erişimi. Hedef projeye yazma izni gerekir. Laravel Boost isteğe bağlıdır; uyumlu PHP ve Composer bağımlılıkları gerektirir.

## Kurulum ve onarım

Proje klasörünü `INSTALL.bat` üzerine sürükleyin veya çift tıklayıp tam yolunu girin. Kurucu tekrar çalıştırılabilir ve mevcut MCP JSON ayarlarını birleştirir. Etkileşimsiz kullanım:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-ai-context.ps1 -ProjectPath "C:\projeler\ornek-proje" -ContextProfile Minimal
```

Minimal beş temel Graphify aracını etkinleştirir. Balanced mimari araçları ve varsa Laravel Boost'u ekler. Full tüm Graphify araçlarını etkinleştirir. Graf `--code-only` ile yerel oluşturulur; indeksleme için API anahtarı gerekmez.

## Dosyalar ve otomasyon

Kurucu projeye özel Codex, Cursor ve Antigravity MCP ayarları, kısa ajan kuralları, `.graphifyignore`, Git hook'ları ve Windows Zamanlanmış Görevi oluşturur. Codex Cloud için `.codex/cloud/setup.sh`, `maintenance.sh` ve `query.sh` dosyalarını da oluşturur. Bulut betiklerini hedef depoya commit edin; ardından o deponun Codex Cloud ortam ayarlarına `bash .codex/cloud/setup.sh` ve `bash .codex/cloud/maintenance.sh` komutlarını girin.

Bulut sorgu yardımcısının varsayılan çıktı bütçesi 800 tokendir. Uzak hesap ayarları Codex Cloud içinde yapılandırılmalıdır; yerel kurucu bunları değiştiremez.

## Kontrol ve sorun giderme

Proje klasörünü `CHECK_STATUS.bat` üzerine sürükleyin. Denetleyici MCP dosyalarını, grafı ve araç erişimini gösterir. MCP araçları görünmüyorsa editörün MCP listesini yenileyin veya yeniden başlatın. Laravel Boost yoksa proje bağımlılıklarını ve uyumlu PHP'yi kurup kurucuyu yeniden çalıştırın. Graf eskiyse projede `graphify update .` çalıştırın.

Token tasarrufu göreve ve modele bağlıdır; sabit bir oran garanti edilmez. [Güvenlik notlarını](SECURITY.md) okuyun.
