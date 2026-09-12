# AI Context Bootstrap

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4)](https://www.microsoft.com/windows)
[![CI](https://github.com/cnrgr95/AI-Context-Bootstrap/actions/workflows/ci.yml/badge.svg)](https://github.com/cnrgr95/AI-Context-Bootstrap/actions/workflows/ci.yml)

Choose your language / Dilinizi seçin:

| Language | Documentation | One-click installer |
|---|---|---|
| 🇹🇷 Türkçe | [TR/README.md](TR/README.md) | `TR\INSTALL.bat` |
| 🇬🇧 English | [EN/README.md](EN/README.md) | `EN\INSTALL.bat` |

The shared PowerShell automation engine stays in the repository root. Both language folders provide their own README, detailed guide, agent prompt, installer, and status checker. The installer also generates Linux scripts for Codex Cloud under `.codex/cloud` in every target project.

Ortak PowerShell otomasyon motoru depo kökünde bulunur. Her dil klasöründe ayrı README, ayrıntılı kılavuz, ajan promptu, kurucu ve durum denetleyicisi vardır. Kurucu ayrıca her hedef projede `.codex/cloud` altında Codex Cloud için Linux betikleri oluşturur.

## Quick start / Hızlı başlangıç

1. Download and extract the ZIP / ZIP dosyasını indirip çıkarın.
2. Drag a project folder onto `EN\INSTALL.bat` or `TR\INSTALL.bat` / Proje klasörünü ilgili kurucuya sürükleyin.
3. Select **Minimal** for the smallest MCP tool context / En düşük MCP araç bağlamı için **Minimal** seçin.
4. Restart the editor and run the matching `CHECK_STATUS.bat` / Editörü yeniden başlatıp ilgili durum denetleyicisini çalıştırın.

> The project reduces avoidable context usage, but no fixed token-saving percentage can be guaranteed.
>
> Proje gereksiz bağlam kullanımını azaltır; sabit bir token tasarrufu yüzdesi garanti edilemez.
