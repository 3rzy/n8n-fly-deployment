# Konfiguracja n8n na Fly.io

## Konfiguracja bazy danych

N8n może korzystać z różnych systemów baz danych. Na Fly.io najczęściej używane są:

### SQLite (zalecane dla prostych instalacji)

Konfiguracja SQLite jest najprostsza i wymaga minimalnych zasobów:

```bash
fly secrets set \
  DB_TYPE=sqlite \
  DB_SQLITE_VACUUM_ON_STARTUP=true \
  -a krzyk-n8n
```

Dane SQLite są przechowywane na wolumenie, który został utworzony podczas instalacji.

### PostgreSQL (dla zaawansowanych instalacji)

Jeśli potrzebujesz większej skalowalności:

1. Utwórz bazę danych PostgreSQL na Fly.io:
```bash
fly postgres create --name krzyk-n8n-db
```

2. Połącz aplikację z bazą danych:
```bash
fly postgres attach --postgres-app krzyk-n8n-db --app krzyk-n8n
```

3. Skonfiguruj zmienne środowiskowe:
```bash
fly secrets set \
  DB_TYPE=postgresdb \
  DB_POSTGRESDB_DATABASE=krzyk_n8n \
  DB_POSTGRESDB_HOST=krzyk-n8n-db.internal \
  DB_POSTGRESDB_PORT=5432 \
  DB_POSTGRESDB_USER=postgres \
  -a krzyk-n8n
```

4. Ustaw hasło do bazy danych (wartość uzyskasz po utworzeniu bazy PostgreSQL):
```bash
fly secrets set DB_POSTGRESDB_PASSWORD=twoje_haslo -a krzyk-n8n
```

## Konfiguracja webhooków

Aby webhooki w n8n działały poprawnie, musisz ustawić dwie zmienne środowiskowe:

```bash
fly secrets set \
  WEBHOOK_URL=https://krzyk-n8n.fly.dev \
  N8N_HOST=krzyk-n8n.fly.dev \
  -a krzyk-n8n
```

Gdzie:
- `WEBHOOK_URL` - pełny URL bazowy, który będzie używany dla webhooków
- `N8N_HOST` - nazwa hosta aplikacji

## Konfiguracja bezpieczeństwa

### Klucz szyfrowania

Dla bezpiecznego przechowywania danych uwierzytelniających, ustaw klucz szyfrowania:

```bash
fly secrets set N8N_ENCRYPTION_KEY=TwojBezpiecznyKluczSzyfrujący -a krzyk-n8n
```

Ważne: Zapamiętaj lub bezpiecznie przechowaj ten klucz, ponieważ będziesz go potrzebować w przypadku migracji danych.

### Uwierzytelnianie podstawowe

Jeśli chcesz zabezpieczyć dostęp do n8n hasłem:

```bash
fly secrets set \
  N8N_BASIC_AUTH_ACTIVE=true \
  N8N_BASIC_AUTH_USER=twoj_uzytkownik \
  N8N_BASIC_AUTH_PASSWORD=twoje_haslo \
  -a krzyk-n8n
```

### Zarządzanie użytkownikami

Aby włączyć zarządzanie użytkownikami w n8n:

```bash
fly secrets set N8N_USER_MANAGEMENT_DISABLED=false -a krzyk-n8n
```

## Konfiguracja strefy czasowej

Ustaw odpowiednią strefę czasową dla swojej instancji n8n:

```bash
fly secrets set \
  GENERIC_TIMEZONE="Europe/Warsaw" \
  TZ="Europe/Warsaw" \
  -a krzyk-n8n
```

## Konfiguracja logowania

Aby dostosować poziom logowania:

```bash
fly secrets set N8N_LOG_LEVEL=info -a krzyk-n8n
```

Dostępne poziomy: `debug`, `info`, `warn`, `error`.

## Inne przydatne ustawienia

### Wyłączenie diagnostyki

```bash
fly secrets set N8N_DIAGNOSTICS_ENABLED=false -a krzyk-n8n
```

### Wyłączenie bannera rekrutacyjnego

```bash
fly secrets set N8N_HIRING_BANNER_ENABLED=false -a krzyk-n8n
```

### Ustawienia TINI (zarządzanie procesami)

```bash
fly secrets set TINI_SUBREAPER=true -a krzyk-n8n
```

## Zastosowanie zmian konfiguracji

Po wprowadzeniu zmian w konfiguracji, zrestartuj aplikację aby zmiany zostały zastosowane:

```bash
fly apps restart krzyk-n8n
```

## Weryfikacja konfiguracji

Możesz sprawdzić wszystkie ustawione zmienne środowiskowe:

```bash
fly secrets list -a krzyk-n8n
```

## Monitorowanie po zmianach konfiguracji

Po wprowadzeniu zmian w konfiguracji, monitoruj logi aplikacji, aby upewnić się, że wszystko działa poprawnie:

```bash
fly logs -a krzyk-n8n
```