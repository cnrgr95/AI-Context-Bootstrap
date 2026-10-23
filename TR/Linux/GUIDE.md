# Linux kullanım kılavuzu

## Gereksinimler

Git, Bash, Python 3.10+, curl ve ilk kurulum için internet erişimi. Hedef projeye yazma izni gerekir. Laravel Boost isteğe bağlıdır; uyumlu PHP ve Composer bağımlılıkları gerektirir.

## Kurulum ve onarım

Bu klasörde `bash INSTALL.sh /projenin/tam/yolu` çalıştırın. Kurucu tekrar çalıştırılabilir ve mevcut MCP JSON ayarlarını birleştirir. Etkileşimsiz kullanım:

```bash
bash setup-ai-context.sh /projenin/tam/yolu --profile Minimal
```

Minimal beş temel Graphify aracını etkinleştirir. Balanced mimari araçları ve varsa Laravel Boost'u ekler. Full tüm Graphify araçlarını etkinleştirir. Graf `--code-only` ile yerel oluşturulur; indeksleme için API anahtarı gerekmez.

## Dosyalar ve otomasyon

Kurucu projeye özel Codex, Cursor ve Antigravity MCP ayarları, kısa ajan kuralları, `.graphifyignore`, Git hook'ları ve kullanılabiliyorsa systemd kullanıcı servisi oluşturur. Codex Cloud için `.codex/cloud/setup.sh`, `maintenance.sh` ve `query.sh` dosyalarını da oluşturur. Bulut betiklerini hedef depoya commit edin; ardından o deponun Codex Cloud ortam ayarlarına `bash .codex/cloud/setup.sh` ve `bash .codex/cloud/maintenance.sh` komutlarını girin.

Bulut sorgu yardımcısının varsayılan çıktı bütçesi 800 tokendir. Uzak hesap ayarları Codex Cloud içinde yapılandırılmalıdır; yerel kurucu bunları değiştiremez.

## Kontrol ve sorun giderme

`bash CHECK_STATUS.sh /projenin/tam/yolu` çalıştırın. Denetleyici MCP dosyalarını, grafı ve araç erişimini gösterir. MCP araçları görünmüyorsa editörün MCP listesini yenileyin veya yeniden başlatın. Laravel Boost yoksa proje bağımlılıklarını ve uyumlu PHP'yi kurup kurucuyu yeniden çalıştırın. Graf eskiyse projede `graphify update .` çalıştırın.

Token tasarrufu göreve ve modele bağlıdır; sabit bir oran garanti edilmez. [Güvenlik notlarını](SECURITY.md) okuyun.

## MCP araç izinleri ve kapsam

Kurucu, projeye özel `.codex/graphify-mcp-proxy.py` filtresini oluşturur. Minimal (5), Balanced (7) ve Full (10) profilleri Codex, Cursor ve Antigravity/Gemini istemcilerinde MCP `tools/list` ve `tools/call` seviyesinde uygulanır. Graphify `project_path` parametresiyle başka bir proje sorgulanamaz. Filtre **işletim sistemi güvenlik sandbox'ı değildir**: Graphify süreci ve AI ajanının terminal/dosya izinleri ayrıca sınırlandırılmalıdır. Profil değiştirildiğinde kurulumu yeniden çalıştırın.
