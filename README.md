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