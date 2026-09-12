```text
Bu bilgisayardaki hedef proje için Codex, Cursor ve Google Antigravity bağlam/token optimizasyonunu baştan sona kur ve doğrula.

Hedef proje: <PROJE_KLASORUNUN_TAM_YOLU>

Gereksinimler:
1. Mevcut kullanıcı değişikliklerini, MCP sunucularını ve ayarları koru; yapılandırmaları silmek yerine birleştir.
2. Resmî `graphifyy` paketini izole biçimde kur. MCP ve dosya izleme eklerini etkinleştir. Windows'ta gerekirse önce `uv` kur.
3. Projeyi `--code-only` ile yerel AST olarak indeksle. `.env`, anahtarlar, dump/SQL dosyaları, bağımlılıklar, build ve storage çıktıları grafa girmesin.
4. Graphify MCP'yi proje kapsamında Codex `.codex/config.toml`, Cursor `.cursor/mcp.json` ve Antigravity `.agents/mcp_config.json` dosyalarına ekle. Antigravity Installed MCP Servers ekranı için genel `~/.gemini/config/mcp_config.json` dosyasına proje adına özel bir sunucu adıyla da ekle.
5. Laravel projesiyse ve `boost:mcp` mevcutsa çalışan PHP sürümünü otomatik bulup Laravel Boost MCP'yi aynı istemcilere ekle. Sistem PATH'indeki uyumsuz PHP'yi körlemesine kullanma.
6. Grafın commit ve dal değişimlerinde güncellenmesi için Graphify Git hook'larını kur. Kaydetme ve git pull değişiklikleri için kullanıcı oturum açınca başlayan, bataryada da çalışan, aynı anda tek örneğe izin veren proje adına özel Windows Scheduled Task oluştur.
7. Ajan kurallarını kısa tut: açık dosya görevlerinde dar arama; modüller arası ilişkilerde önce Graphify; sonuçları kaynak kodla doğrulama; secrets/build/vendor bağlama dahil edilmemeli.
8. Graphify'ın gerçek MCP initialize, tools/list ve graph_stats çağrılarını test et. Dosya zaman damgası olayıyla watcher'ın grafı otomatik yenilediğini doğrula. Geçici test dosyalarını temizle.
9. Kurulum tekrar çalıştırılabilir ve onarım amaçlı idempotent olsun. Sabit kullanıcı adı veya proje yolu kullanma.
10. Sonuçta kurulan dosyaları, MCP araç sayısını, graf düğüm/ilişki sayısını ve watcher durumunu kısa biçimde bildir. Doğrulanmamış token tasarrufu yüzdesi vaat etme.
```
