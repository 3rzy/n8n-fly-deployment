# Instalacja n8n na Fly.io

## Wymagania wstępne

Przed rozpoczęciem instalacji n8n na Fly.io, upewnij się, że masz:

1. Konto na platformie Fly.io
2. Zainstalowane narzędzie `flyctl` (CLI Fly.io)
3. Wykonane logowanie do konta Fly.io (`fly auth login`)

## Proces instalacji krok po kroku

### 1. Inicjalizacja aplikacji

Możesz utworzyć nową aplikację n8n na Fly.io używając oficjalnego obrazu Docker:

```bash
fly launch --image n8nio/n8n --name krzyk-n8n
```

Zastąp `krzyk-n8n` swoją preferowaną nazwą aplikacji.

Podczas procesu inicjalizacji możesz zostać zapytany o:
- Region, w którym ma być uruchomiona aplikacja (wybierz najbliższy geograficznie)
- Utworzenie bazy PostgreSQL (możesz pominąć, jeśli planujesz używać SQLite)
- Ustawienia aplikacji (akceptuj domyślne lub dostosuj według potrzeb)

### 2. Konfiguracja trwałego przechowywania danych

N8n wymaga trwałego przechowywania danych. Utwórz wolumen na Fly.io:

```bash
fly volumes create n8n_data --size 1 --app krzyk-n8n
```

Rozmiar wolumenu (1GB) możesz dostosować do swoich potrzeb.

### 3. Konfiguracja pliku `fly.toml`

Upewnij się, że plik `fly.toml` zawiera odpowiednie konfiguracje. Szczególnie ważne są:

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

Gdzie:
- `internal_port = 5678` - domyślny port, na którym działa n8n
- `[mounts]` - konfiguracja podłączenia wolumenu do kontenera

### 4. Konfiguracja zmiennych środowiskowych

Skonfiguruj podstawowe zmienne środowiskowe:

```bash
fly secrets set \
  DB_TYPE=sqlite \
  DB_SQLITE_VACUUM_ON_STARTUP=true \
  WEBHOOK_URL=https://krzyk-n8n.fly.dev \
  N8N_HOST=krzyk-n8n.fly.dev \
  TINI_SUBREAPER=true \
  -a krzyk-n8n
```

Dodatkowo, zaleca się ustawienie klucza szyfrowania dla bezpiecznego przechowywania danych uwierzytelniających:

```bash
fly secrets set N8N_ENCRYPTION_KEY=TwojBezpiecznyKluczSzyfrujący -a krzyk-n8n
```

### 5. Konfiguracja zasobów

N8n wymaga minimum 2GB RAM do stabilnego działania:

```bash
fly scale memory 2048 -a krzyk-n8n
```

### 6. Wdrożenie aplikacji

Wreszcie, wdróż aplikację:

```bash
fly deploy -a krzyk-n8n
```

## Weryfikacja instalacji

Po zakończeniu wdrażania, twoja instancja n8n powinna być dostępna pod adresem:

```
https://krzyk-n8n.fly.dev
```

Sprawdź, czy możesz:
1. Zalogować się do interfejsu n8n
2. Utworzyć prosty workflow
3. Zapisać workflow

## Rozwiązywanie problemów podczas instalacji

### Problem: Komunikat "Out of Memory"

**Objaw**: W logach pojawia się komunikat "Out of memory: Killed process"

**Rozwiązanie**: Zwiększ ilość przydzielonej pamięci:
```bash
fly scale memory 2048 -a krzyk-n8n
```

### Problem: Aplikacja nie uruchamia się

**Objaw**: Po wdrożeniu, aplikacja nie jest dostępna

**Rozwiązanie**: Sprawdź logi aplikacji:
```bash
fly logs -a krzyk-n8n
```

I upewnij się, że:
- Wszystkie wymagane zmienne środowiskowe są ustawione
- Plik `fly.toml` ma poprawną konfigurację portów
- Wolumen jest poprawnie zamontowany