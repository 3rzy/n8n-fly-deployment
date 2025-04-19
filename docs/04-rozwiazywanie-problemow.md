# Rozwiązywanie problemów z n8n na Fly.io

## Typowe problemy i ich rozwiązania

### Problem: Aplikacja n8n kończy działanie z błędem "Out of Memory"

**Symptomy:**
- W logach widoczny komunikat "Out of memory: Killed process"
- Aplikacja jest automatycznie restartowana
- Interfejs n8n jest czasami niedostępny

**Rozwiązanie:**
```bash
# Zwiększenie przydzielonej pamięci do 2GB
fly scale memory 2048 -a krzyk-n8n

# Jeśli problem nadal występuje, można zwiększyć do 4GB
fly scale memory 4096 -a krzyk-n8n
```

**Wyjaśnienie:**
N8n jest aplikacją wymagającą znacznych zasobów pamięci, szczególnie przy uruchamianiu złożonych workflow. Domyślna ilość pamięci w darmowym planie Fly.io (256MB) jest niewystarczająca dla n8n.

### Problem: Webhooki nie działają poprawnie

**Symptomy:**
- Webhook triggers w n8n nie otrzymują żądań
- Zewnętrzne systemy zgłaszają błędy przy próbie wywołania webhooka

**Rozwiązanie:**
```bash
# Ustawienie poprawnych adresów URL dla webhooków
fly secrets set \
  WEBHOOK_URL=https://krzyk-n8n.fly.dev \
  N8N_HOST=krzyk-n8n.fly.dev \
  -a krzyk-n8n

# Restart aplikacji
fly apps restart krzyk-n8n
```

**Weryfikacja:**
Utwórz prosty workflow z węzłem Webhook i przetestuj go używając narzędzia takiego jak curl:
```bash
curl -X POST https://krzyk-n8n.fly.dev/webhook/path-to-your-webhook
```

### Problem: Problemy z bazą danych SQLite

**Symptomy:**
- Błędy w logach związane z dostępem do bazy danych
- Utrata danych po restartach

**Rozwiązanie:**
```bash
# Upewnij się, że wolumen jest poprawnie skonfigurowany
fly volumes list -a krzyk-n8n

# Sprawdź konfigurację bazy danych
fly secrets set \
  DB_TYPE=sqlite \
  DB_SQLITE_VACUUM_ON_STARTUP=true \
  -a krzyk-n8n
```

**Sprawdzenie wolumenu:**
```bash
# Połącz się z konsolą
fly ssh console -a krzyk-n8n

# Sprawdź czy katalog .n8n istnieje i ma odpowiednie uprawnienia
ls -la /home/node/.n8n
```

### Problem: Aplikacja nie uruchamia się po wdrożeniu

**Symptomy:**
- Status aplikacji pokazuje, że nie jest uruchomiona
- W logach widoczne błędy podczas uruchamiania

**Rozwiązanie:**
1. Sprawdź logi, aby zidentyfikować konkretny problem:
```bash
fly logs -a krzyk-n8n
```

2. Sprawdź konfigurację aplikacji w pliku fly.toml:
```bash
cat fly.toml
```

3. Upewnij się, że port wewnętrzny jest ustawiony poprawnie:
```toml
[http_service]
  internal_port = 5678
```

4. Sprawdź, czy wolumen jest poprawnie zamontowany:
```toml
[mounts]
  source = "n8n_data"
  destination = "/home/node/.n8n"
```

5. Zrestartuj aplikację po wprowadzeniu zmian:
```bash
fly apps restart krzyk-n8n
```

### Problem: Problemy z połączeniem do zewnętrznych usług

**Symptomy:**
- Workflow nie mogą połączyć się z zewnętrznymi API
- Błędy połączenia w logach workflow

**Rozwiązanie:**
1. Sprawdź, czy zewnętrzne usługi są dostępne z poziomu aplikacji:
```bash
# Połącz się z konsolą
fly ssh console -a krzyk-n8n

# Sprawdź połączenie do zewnętrznego serwisu
curl -v https://external-service.com/api
```

2. Upewnij się, że masz poprawnie skonfigurowane dane uwierzytelniające w n8n dla zewnętrznych usług

3. Sprawdź, czy n8n ma ustawiony klucz szyfrowania dla bezpiecznego przechowywania kredencjałów:
```bash
fly secrets set N8N_ENCRYPTION_KEY=TwojBezpiecznyKluczSzyfrujący -a krzyk-n8n
```

### Problem: Wolne działanie aplikacji n8n

**Symptomy:**
- Interfejs n8n działa wolno
- Wykonanie workflow zajmuje dużo czasu

**Rozwiązanie:**
1. Zwiększ zasoby maszyny:
```bash
# Zwiększ ilość pamięci
fly scale memory 2048 -a krzyk-n8n

# Przejdź na dedykowane CPU (zamiast współdzielonego)
fly scale vm dedicated-cpu-1x -a krzyk-n8n
```

2. Zoptymalizuj swoje workflow:
- Ogranicz liczbę węzłów w workflow
- Zredukuj ilość danych przetwarzanych jednocześnie
- Używaj cachowania gdzie to możliwe

### Problem: Problemy po aktualizacji n8n

**Symptomy:**
- Aplikacja nie uruchamia się po aktualizacji do nowszej wersji
- Workflow przestały działać po aktualizacji

**Rozwiązanie:**
1. Sprawdź logi, aby zidentyfikować problemy:
```bash
fly logs -a krzyk-n8n
```

2. Jeśli problemy są poważne, możesz wycofać się do poprzedniej wersji:
```bash
# Sprawdź jakie wersje n8n są dostępne
# https://hub.docker.com/r/n8nio/n8n/tags

# Wdróż konkretną poprzednią wersję
fly deploy --image n8nio/n8n:0.214.0 -a krzyk-n8n
```

3. Po aktualizacji sprawdź, czy wszystkie workflow działają poprawnie

## Narzędzia diagnostyczne

### Sprawdzanie logów aplikacji

```bash
# Standardowe logi
fly logs -a krzyk-n8n

# Śledzenie logów na bieżąco
fly logs -f -a krzyk-n8n
```

### Dostęp do powłoki kontenera

```bash
fly ssh console -a krzyk-n8n
```

### Monitorowanie zasobów

```bash
# Status aplikacji i maszyn
fly status -a krzyk-n8n

# Lista maszyn i ich konfiguracja
fly vm list -a krzyk-n8n
```

### Sprawdzanie zmiennych środowiskowych

```bash
fly secrets list -a krzyk-n8n
```

## Kiedy skontaktować się z pomocą techniczną

Jeśli po wypróbowaniu powyższych rozwiązań problem nadal występuje, warto:

1. Sprawdzić [oficjalną dokumentację n8n](https://docs.n8n.io/)
2. Zajrzeć na [forum społeczności n8n](https://community.n8n.io/)
3. Sprawdzić [status Fly.io](https://status.fly.io/) w przypadku problemów z infrastrukturą
4. Skontaktować się z [pomocą techniczną Fly.io](https://fly.io/docs/about/support/)

## Przydatne porady

- Regularnie twórz kopie zapasowe swoich workflow i danych
- Testuj aktualizacje n8n najpierw w środowisku testowym
- Monitoruj zużycie zasobów przez aplikację, aby przewidzieć potrzebę skalowania
- Ustaw powiadomienia o błędach w krytycznych workflow, aby szybko reagować na problemy