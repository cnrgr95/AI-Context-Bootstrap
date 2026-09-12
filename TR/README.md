# Windows için AI Context Bootstrap

[![Lisans: MIT](https://img.shields.io/badge/Lisans-MIT-blue.svg)](../LICENSE)
[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4)](https://www.microsoft.com/windows)

**Codex**, **Cursor** ve **Google Antigravity** için tek komutla proje bağlamı kurulumu. Yerel Graphify kod grafı oluşturur, MCP bağlantılarını kurar, gereksiz dosyaları filtreler ve grafı otomatik güncel tutar.

> Paket gereksiz bağlam tüketimini azaltır. Model, görev, sohbet geçmişi ve etkin araçlar değiştiği için sabit bir token tasarruf yüzdesi garanti etmez.

## Hızlı başlangıç

1. Son sürüm ZIP dosyasını indirip çıkarın.
2. Proje klasörünü `INSTALL.bat` üzerine sürükleyin.
3. **Minimal** profili seçin.
4. Editörü yeniden başlatın veya MCP listesini yenileyin.
5. Proje klasörünü `CHECK_STATUS.bat` üzerine sürükleyerek kurulumu doğrulayın.

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
- Git hook'ları ve Windows başlangıç görevi
- Aynı isimli projeler için benzersiz kimlik
- Tekrar çalıştırılabilir kurulum ve onarım
- Laravel Boost ve uyumlu PHP algılama

Ayrıntılar için [Türkçe kullanım kılavuzuna](GUIDE.md) bakın.
