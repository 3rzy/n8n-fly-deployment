<!-- HYDRA_IDENTITY_CARD_START -->
# n8n-fly-deployment

## 🆔 Karta Tożsamości Repozytorium (Hydra Ecosystem)

| Pole | Wartość |
| :--- | :--- |
| **Status repozytorium** | `LIBRARY` |
| **Status komponentów** | `REUSABLE_DEVOPS` |
| **Cel** | Zestaw skryptów, konfiguracji fly.toml oraz bazy wiedzy CSV do niezawodnego wdrażania n8n na platformie Fly.io. |
| **Rola w ekosystemie** | Gotowy wzorzec infrastrukturalny DevOps dla środowiska automatyzacji n8n w chmurze PaaS. |
| **CURRENT (Stan bieżący)** | Pushed: 2025-04-19T08:48:58Z, HEAD SHA: c25512fe5f2716617e30b73d771eb7059581600c (commit date: 2025-04-19T08:48:58Z), root files count: 4. Weryfikacja: 2026-11-24 via GitHub REST API. |
| **TARGET (Stan docelowy)** | Włączenie sprawdzonych procedur do infrastruktura serwerowa VPS / rdzeń ekosystemu Hydra lub zachowanie jako samodzielna biblioteka wdrożeniowa. |
| **Zależności** | Flyctl, Fly.io PaaS, Docker, n8n. |
| **Supersedes (Zastępuje)** | n8n-on-fly, n8n-on-fly-docs. |
| **Superseded by (Zastąpione przez)** | Brak. |
| **Źródło prawdy** | Repozytorium GitHub: 3rzy/n8n-fly-deployment. |
| **Owner** | Krzy (3rzy) |
| **Ostatnia weryfikacja** | 2026-11-24 |

### Klocki do ponownego wykorzystania (Reusable Blocks)
Baza wiedzy konfiguracji zmiennych n8n (n8n_fly_wiedza.csv), skrypty fly.toml, procedury montowania wolumenów i certyfikatów SSL.

### Rekomendacja porządkowa
PROPOSE_KEEP_AS_LIBRARY: Sprawdzone i kompletne procedury deploymentu n8n.

---
<!-- HYDRA_IDENTITY_CARD_END -->

# Wdrożenie n8n na platformie Fly.io

## Wprowadzenie

Ten dokument zawiera kompletną instrukcję wdrożenia aplikacji n8n na platformie Fly.io. N8n to narzędzie do automatyzacji przepływów pracy (workflow), które pozwala na integrację różnych aplikacji i serwisów bez konieczności pisania kodu.

Fly.io to platforma PaaS (Platform as a Service), która umożliwia proste wdrażanie aplikacji kontenerowych z globalnym zasięgiem.

## Spis treści

- [Wymagania wstępne](#wymagania-wstępne)
- [Instalacja i konfiguracja](#instalacja-i-konfiguracja)
- [Konfiguracja zasobów](#konfiguracja-zasobów)
- [Zmienne środowiskowe](#zmienne-środowiskowe)
- [Zarządzanie aplikacją](#zarządzanie-aplikacją)
- [Rozwiązywanie problemów](#rozwiązywanie-problemów)
- [Koszty i limity](#koszty-i-limity)

## Wymagania wstępne

Aby wdrożyć n8n na Fly.io, potrzebujesz:

1. Konta na platformie Fly.io
2. Zainstalowanego narzędzia `flyctl` (instrukcja: https://fly.io/docs/hands-on/install-flyctl/)
3. Wykonanego logowania do Fly.io (`fly auth login`)

## Instalacja i konfiguracja

### Krok 1: Utworzenie aplikacji

```bash
# Utworzenie aplikacji z obrazu n8n
fly launch --image n8nio/n8n --name [twoja-nazwa-n8n]
```

### Krok 2: Utworzenie wolumenu dla danych

```bash
# Utworzenie wolumenu dla przechowywania danych n8n
fly volumes create n8n_data --size 1 --app [twoja-nazwa-n8n]
```

### Krok 3: Konfiguracja pliku fly.toml

Upewnij się, że plik `fly.toml` zawiera poprawne ustawienia:

```toml
[http_service]
  internal_port = 5678
  force_https = true
  auto_stop_machines = false
  auto_start_machines = true

[mounts]
  source = "n8n_data"
  destination = "/home/node/.n8n"
```

## Konfiguracja zasobów

N8n wymaga minimum 2GB RAM do stabilnego działania:

```bash
# Zwiększenie przydzielonej pamięci
fly scale memory 2048 -a [twoja-nazwa-n8n]
```

## Zmienne środowiskowe

Konfiguracja podstawowych zmiennych środowiskowych:

```bash
# Konfiguracja dla bazy SQLite
fly secrets set \
  DB_TYPE=sqlite \
  DB_SQLITE_VACUUM_ON_STARTUP=true \
  -a [twoja-nazwa-n8n]

# Konfiguracja URL dla webhooków
fly secrets set \
  WEBHOOK_URL=https://[twoja-nazwa-n8n].fly.dev \
  N8N_HOST=[twoja-nazwa-n8n].fly.dev \
  -a [twoja-nazwa-n8n]

# Konfiguracja bezpieczeństwa
fly secrets set \
  N8N_ENCRYPTION_KEY=TwojBezpiecznyKluczSzyfrowania \
  TINI_SUBREAPER=true \
  -a [twoja-nazwa-n8n]
```

## Zarządzanie aplikacją

### Monitorowanie

```bash
# Sprawdzenie statusu aplikacji
fly status -a [twoja-nazwa-n8n]

# Sprawdzenie logów
fly logs -a [twoja-nazwa-n8n]
```

### Zatrzymywanie i uruchamianie

```bash
# Zatrzymanie aplikacji
fly apps stop [twoja-nazwa-n8n]

# Uruchomienie aplikacji
fly apps start [twoja-nazwa-n8n]

# Restart aplikacji
fly apps restart [twoja-nazwa-n8n]
```

## Rozwiązywanie problemów

### Problem: Out of Memory

**Symptom**: W logach pojawia się komunikat "Out of memory: Killed process"

**Rozwiązanie**: Zwiększ ilość przydzielonej pamięci:
```bash
fly scale memory 2048 -a [twoja-nazwa-n8n]
```

### Problem: Niedostępne webhooki

**Symptom**: Webhook skonfigurowany w n8n nie jest dostępny z zewnątrz

**Rozwiązanie**: Upewnij się, że zmienne WEBHOOK_URL i N8N_HOST są prawidłowo ustawione:
```bash
fly secrets set \
  WEBHOOK_URL=https://[twoja-nazwa-n8n].fly.dev \
  N8N_HOST=[twoja-nazwa-n8n].fly.dev \
  -a [twoja-nazwa-n8n]
```

## Koszty i limity

- Darmowy plan Fly.io obejmuje 3 maszyny shared-cpu-1x z 256MB RAM
- Jedna maszyna w darmowym planie może być skalowana do 2GB RAM
- Po przekroczeniu limitów darmowych naliczane są opłaty
- Aktualny cennik: https://fly.io/docs/about/pricing

---

Więcej szczegółów znajdziesz w dokumentacji [n8n](https://docs.n8n.io/) oraz [Fly.io](https://fly.io/docs/).