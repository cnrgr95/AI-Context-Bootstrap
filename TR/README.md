# AI Context Bootstrap

[![Lisans: MIT](https://img.shields.io/badge/Lisans-MIT-blue.svg)](../LICENSE)
[![Platformlar](https://img.shields.io/badge/Windows%20%7C%20Linux%20%7C%20macOS-destekleniyor-0078D4)](GUIDE.md#gereksinimler)

**Yerel Codex istemcileri**, **Codex Cloud**, **Cursor** ve **Google Antigravity** için tek komutla proje bağlamı kurulumu. Yerel Graphify kod grafı oluşturur, desteklenen MCP bağlantılarını kurar, gereksiz dosyaları filtreler ve grafı otomatik güncel tutar.

> Paket gereksiz bağlam tüketimini azaltır. Model, görev, sohbet geçmişi ve etkin araçlar değiştiği için sabit bir token tasarruf yüzdesi garanti etmez.

## Hızlı başlangıç

1. Son sürüm ZIP dosyasını indirip çıkarın.
2. Windows'ta proje klasörünü `INSTALL.bat` üzerine sürükleyin. Linux veya macOS'ta `bash INSTALL_LINUX_MACOS.sh /proje/yolu` çalıştırın.
3. **Minimal** profili seçin.
4. Editörü yeniden başlatın veya MCP listesini yenileyin.
5. Windows'ta proje klasörünü `CHECK_STATUS.bat` üzerine sürükleyin; Linux/macOS'ta `bash CHECK_STATUS_LINUX_MACOS.sh /proje/yolu` çalıştırın.
6. Depo Codex Cloud ile kullanılacaksa oluşturulan `.codex/cloud` klasörünü commit edin.

Codex Cloud ortamında kurulum ve bakım betikleri olarak sırasıyla şunları kullanın:

```bash
bash .codex/cloud/setup.sh
bash .codex/cloud/maintenance.sh
```

Ayrıntılar için [Codex Cloud bölümüne](GUIDE.md#codex-cloud) bakın.

## Bağlam profilleri

| Profil | Araçlar | Kullanım |
|---|---|---|
| Minimal | 5 temel Graphify aracı | En düşük MCP araç kataloğu; varsayılan ve önerilen |
| Dengeli | Mimari Graphify araçları + Laravel Boost | Laravel geliştirme ve daha geniş mimari çalışma |
| Tam | Tüm Graphify araçları + Laravel Boost | PR analizi ve tüm yeteneklere ihtiyaç duyulan oturumlar |

Cursor, araç durumlarını kendi arayüzünde sakladığı için kullanılmayan araçları `Customize → MCPs` bölümünden kapatmak ek tasarruf sağlar.

## Neleri otomatikleştirir?

- Graphify, MCP ve watcher kurulumu
- Kodun tamamen yerel AST indekslenmesi
- Codex, Cursor ve Antigravity MCP yapılandırması
- Hassas/büyük/üretilmiş dosyaların filtrelenmesi
- Git hook'ları ve platforma uygun arka plan izleyicisi
- Aynı isimli projeler için benzersiz kimlik
- Tekrar çalıştırılabilir kurulum ve onarım
- Laravel Boost ve uyumlu PHP algılama
- Codex Cloud için Linux kurulum, bakım ve 800 token bütçeli sorgu yardımcıları

## Platform desteği

- Windows 10/11: PowerShell kurucu ve Scheduled Task watcher.
- Linux: Bash kurucu ve kullanılabiliyorsa systemd kullanıcı watcher'ı.
- macOS: Bash kurucu ve LaunchAgent watcher.
- Graphify Git hook'ları tüm platformlarda yedek güncelleme yöntemi olarak kalır.

Ayrıntılar için [Türkçe kullanım kılavuzuna](GUIDE.md) bakın.
