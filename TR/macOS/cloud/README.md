# Codex Cloud ortamı

Hedef projede oluşturulan `.codex/cloud` klasörünü commit edin. Codex Cloud ortam ayarlarında şu betikleri kullanın:

```bash
# Kurulum betiği
bash .codex/cloud/setup.sh

# Bakım betiği
bash .codex/cloud/maintenance.sh
```

Kurulum Graphify'ı ağ erişimi olan aşamada yükleyip yalnızca kod içeren yerel graf oluşturur. Bakım betiği önbellekteki ortam yeniden kullanıldığında grafı günceller. Sorgu yardımcısının varsayılan çıktı bütçesi 800 tokendir:

```bash
bash .codex/cloud/query.sh "Kimlik doğrulamayı hangi modüller yönetiyor?"
```

Profil için Codex Cloud ortamında `AI_CONTEXT_PROFILE` değerini `Minimal`, `Balanced` veya `Full` olarak ayarlayabilirsiniz. Yalnızca kod içeren indeksleme için API anahtarı gerekmez. Bulut ortamında Windows yolları veya kalıcı watcher kullanılmaz.

Kaynak: [Codex Cloud ortamları](https://learn.chatgpt.com/docs/environments/cloud-environment).