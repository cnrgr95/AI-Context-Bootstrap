# AI Context Bootstrap

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platforms](https://img.shields.io/badge/Windows%20%7C%20Linux%20%7C%20macOS-supported-0078D4)](#quick-start--hızlı-başlangıç)
[![CI](https://github.com/cnrgr95/AI-Context-Bootstrap/actions/workflows/ci.yml/badge.svg)](https://github.com/cnrgr95/AI-Context-Bootstrap/actions/workflows/ci.yml)

Choose your language / Dilinizi seçin:

| Language | Documentation | Windows | Linux / macOS |
|---|---|---|---|
| 🇹🇷 Türkçe | [TR/README.md](TR/README.md) | `TR\INSTALL.bat` | `bash TR/INSTALL_LINUX_MACOS.sh /proje/yolu` |
| 🇬🇧 English | [EN/README.md](EN/README.md) | `EN\INSTALL.bat` | `bash EN/INSTALL_LINUX_MACOS.sh /path/to/project` |

The shared PowerShell and Bash automation engines stays in the repository root. Both language folders provide their own README, detailed guide, agent prompt, installer, and status checker. The installer also generates Linux scripts for Codex Cloud under `.codex/cloud` in every target project.

Ortak PowerShell ve Bash otomasyon motorları depo kökünde bulunur. Her dil klasöründe ayrı README, ayrıntılı kılavuz, ajan promptu, kurucu ve durum denetleyicisi vardır. Kurucu ayrıca her hedef projede `.codex/cloud` altında Codex Cloud için Linux betikleri oluşturur.

## Quick start / Hızlı başlangıç

1. Download and extract the ZIP / ZIP dosyasını indirip çıkarın.
2. Windows: drag a project folder onto `EN\INSTALL.bat` or `TR\INSTALL.bat`. Linux/macOS: run the matching `INSTALL_LINUX_MACOS.sh` / Windows'ta proje klasörünü BAT dosyasına sürükleyin; Linux/macOS'ta ilgili SH dosyasını çalıştırın.
3. Select **Minimal** for the smallest MCP tool context / En düşük MCP araç bağlamı için **Minimal** seçin.
4. Restart the editor and run the matching status checker (`CHECK_STATUS.bat` or `CHECK_STATUS_LINUX_MACOS.sh`) / Editörü yeniden başlatıp ilgili durum denetleyicisini (`CHECK_STATUS.bat` veya `CHECK_STATUS_LINUX_MACOS.sh`) çalıştırın.

> The project reduces avoidable context usage, but no fixed token-saving percentage can be guaranteed.
>
> Proje gereksiz bağlam kullanımını azaltır; sabit bir token tasarrufu yüzdesi garanti edilemez.
