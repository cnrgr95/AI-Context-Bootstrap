# Codex, Cursor ve Antigravity Otomatik Bağlam Kurulumu

Bu paket, bir yazılım projesinde Graphify kod grafını ve uygun MCP bağlantılarını otomatik kurar. Windows, Codex, Cursor ve Google Antigravity için hazırlanmıştır.

## Kurulan bileşenler

- Graphify ve gerekli `mcp`/`watch` eklentileri
- Projeye özel yerel kod grafı
- Codex, Cursor ve Antigravity Graphify MCP bağlantıları
- Laravel projesinde mevcutsa Laravel Boost MCP bağlantısı
- Kod kaydedildiğinde grafı yenileyen Windows görevi
- Commit ve dal değişimlerinde çalışan Git hook'ları
- Gizli, büyük ve üretilmiş dosyalar için bağlam filtreleri
- Kısa ve odaklı ajan kuralları

Kod grafı `--code-only` seçeneğiyle yerel olarak oluşturulur. Kaynak kodun indekslenmesi için bulut API anahtarı gerekmez.

## Gereksinimler

- Windows 10 veya Windows 11
- İnternet bağlantısı (ilk kurulum sırasında)
- Git
- Windows Package Manager (`winget`)
- Proje klasörüne yazma yetkisi
- Laravel Boost kullanılacaksa projede kurulmuş Composer bağımlılıkları

## En kolay kurulum

1. ZIP dosyasını normal bir klasöre çıkarın.
2. Proje klasörünü `INSTALL.bat` dosyasının üzerine sürükleyip bırakın.
3. Açılan terminalde işlemlerin tamamlanmasını bekleyin.
4. Codex, Cursor ve Antigravity'yi yeniden başlatın veya MCP listesini yenileyin.

## Bağlam profilleri

| Profil | İçerik | Önerilen kullanım |
|---|---|---|
| Minimal | Beş temel Graphify aracı; kurulumun yönettiği Laravel Boost kayıtlarını kaldırır | Günlük görevler ve en düşük MCP araç bağlamı |
| Dengeli | Mimari Graphify araçları, yerel topluluk haritası ve varsa Laravel Boost | Laravel geliştirme ve modüller arası çalışmalar |
| Tam | Tüm Graphify araçları, topluluk haritası ve varsa Laravel Boost | PR analizi ve bütün araçların gerektiği özel oturumlar |

Profil daha sonra değiştirilebilir. `INSTALL.bat` dosyasını yeniden çalıştırıp yeni profili seçmeniz yeterlidir.

Alternatif olarak `INSTALL.bat` dosyasına çift tıklayın ve istenen alana projenin tam yolunu yazın:

```text
C:\projeler\ornek-proje
```

## Kurulumdan sonra kontrol

### Codex

Proje klasöründe Codex'i açın ve MCP listesinden `graphify` ile, Laravel projesiyse `laravel-boost` sunucularını kontrol edin.

### Cursor

Cursor'da `Customize > MCPs` bölümünü açın. `graphify` ve varsa `laravel-boost` etkin görünmelidir.

### Antigravity

`Settings > Customizations > Installed MCP Servers` bölümünü açıp **Refresh** düğmesine basın. Proje adına göre oluşturulan Graphify kaydı görünmelidir.

## Otomatik güncelleme

Kurulum, proje adı ve yolundan türetilen benzersiz `Graphify-<proje-kimligi>-Watch` adlı bir Windows Scheduled Task oluşturur. Bu görev:

- Kullanıcı oturum açtığında başlar.
- Kod dosyaları kaydedildiğinde grafı yeniler.
- Aynı proje için birden fazla izleyici başlatmaz.
- Batarya kullanılırken çalışmaya devam eder.
- Başarısız olursa yeniden başlamayı dener.

Git hook'ları da commit ve dal değişimlerinde grafı yeniler. Güncellemeler yerel AST analiziyle yapılır.

## Codex Cloud

Kurucu hedef projeye `.codex/cloud/setup.sh`, `maintenance.sh`, `query.sh` ve kısa bir README yazar. Bu dosyaları commit ettikten sonra deponun Codex Cloud ortamında şu değerleri kullanın:

```bash
# Kurulum betiği
bash .codex/cloud/setup.sh

# Bakım betiği
bash .codex/cloud/maintenance.sh
```

Kurulum aşaması Graphify'ı yükleyip yalnızca kod içeren grafı oluşturur. Bakım aşaması önbellekteki konteyner yeniden kullanıldığında grafı günceller. Bulut görevleri Windows watcher veya Windows çalıştırılabilir dosya yollarını kullanmaz.

Yerel MCP sunucusu bulunmadığında modüller arası sorular için oluşturulan `AGENTS.md`, Codex'e şu komutu kullanmasını söyler:

```bash
bash .codex/cloud/query.sh "Kimlik doğrulamayı hangi modüller yönetiyor?"
```

Yardımcı varsayılan olarak çıktıyı 800 token ile sınırlar. Daha büyük sonuç gerektiğinde ikinci sayısal argüman verilebilir. Seçilen profil Codex Cloud ortamındaki `AI_CONTEXT_PROFILE` değişkeniyle geçersiz kılınabilir.

## Yeniden çalıştırma ve onarım

Aynı proje için `INSTALL.bat` tekrar çalıştırılabilir. Betik mevcut JSON ayarlarını silmez; ilgili MCP kayıtlarını ekler veya günceller. Eksik grafı, kuralları ve otomasyon görevini yeniden oluşturur.

Graphify dosyaları açık bir IDE tarafından kilitlenirse Codex, Cursor ve Antigravity'yi kapatıp betiği yeniden çalıştırın.

## İleri düzey seçenekler

PowerShell üzerinden doğrudan çalıştırma:

```powershell
powershell -ExecutionPolicy Bypass -File ..\setup-ai-context.ps1 -ProjectPath "C:\projeler\ornek-proje"
```

Laravel Boost kurulumunu atlamak için:

```powershell
powershell -ExecutionPolicy Bypass -File ..\setup-ai-context.ps1 -ProjectPath "C:\projeler\ornek-proje" -SkipLaravelBoost
```

Canlı Windows izleyicisini kurmadan yalnızca graf, MCP ve Git hook'larını hazırlamak için:

```powershell
powershell -ExecutionPolicy Bypass -File ..\setup-ai-context.ps1 -ProjectPath "C:\projeler\ornek-proje" -NoWatcher
```

## Oluşturulan proje dosyaları

- `.graphifyignore`
- `.cursorignore`
- `.mcp.json`
- `.cursor/mcp.json`
- `.codex/config.toml`
- `.agents/mcp_config.json`
- `.agents/rules/efficient-context.md`
- `graphify-out/graph.json`

Betik ayrıca kısa bir bölümü mevcut `AGENTS.md` dosyasına işaretli biçimde ekler. Sonraki çalıştırmalar aynı bölümü çoğaltmaz.

## Hazır ajan promptu

Betik çalıştırılamayan bir ortamda `AGENT_PROMPT.md` içindeki promptu hedef araçta kullanabilirsiniz. Prompt içindeki `<PROJE_KLASORUNUN_TAM_YOLU>` alanını gerçek proje yoluyla değiştirin.

## Sorun giderme

### Graphify Installed MCP Servers listesinde görünmüyor

- MCP listesini yenileyin.
- IDE'yi yeniden başlatın.
- Antigravity için `~/.gemini/config/mcp_config.json` dosyasının oluştuğunu kontrol edin.

### Yanlış PHP sürümü hatası

Betik Laragon altındaki PHP sürümlerini sınar ve Artisan'ı çalıştırabilen sürümü seçer. Uygun sürüm yoksa Graphify kurulumu tamamlanır, Laravel Boost atlanır. Projenin istediği PHP sürümünü kurduktan sonra betiği yeniden çalıştırın.

### Windows betiği engelliyor

`INSTALL.bat`, PowerShell'i yalnızca bu çalıştırma için `ExecutionPolicy Bypass` ile açar. Kurumsal bir politika bunu da engelliyorsa sistem yöneticisinin izin verdiği terminalden `setup-ai-context.ps1` dosyasını çalıştırın.

### Graf güncel görünmüyor

Windows Görev Zamanlayıcı'da `Graphify-<proje-kimligi>-Watch` görevinin çalıştığını kontrol edin. `CHECK_STATUS.bat` bu adı otomatik hesaplar. Manuel yenileme için proje klasöründe şunu çalıştırabilirsiniz:

```powershell
graphify update .
```

## Token kullanımı hakkında

Bu paket gereksiz dosyaların bağlama alınmasını azaltır ve modüller arası aramalarda yerel graf kullanılmasını sağlar. Gerçek token tüketimi göreve, seçilen modele, sohbet geçmişine ve etkin MCP araçlarına bağlıdır; belirli bir tasarruf yüzdesi garanti edilmez.
