# Często zadawane pytania (FAQ) - n8n na Fly.io

## Ogólne pytania

### Czy n8n na Fly.io będzie działać, gdy wyłączę komputer?
**Tak**, aplikacje uruchomione na Fly.io działają w chmurze, niezależnie od stanu Twojego komputera. Gdy zamkniesz przeglądarkę lub wyłączysz komputer, instancja n8n nadal będzie działać na serwerach Fly.io i wykonywać skonfigurowane workflow.

### Ile kosztuje uruchomienie n8n na Fly.io?
W ramach **darmowego planu** Fly.io możesz uruchomić n8n bez dodatkowych kosztów, korzystając z:
- 3 maszyn shared-cpu-1x z 256MB RAM
- 1 współdzielonego adresu IPv4
- 3GB wolumenu trwałego

Przy ustawieniu 2GB RAM dla maszyny n8n, nadal pozostajesz w darmowym planie, ale wykorzystujesz większość dostępnych zasobów. Jeśli przekroczysz darmowe limity, koszty są naliczane zgodnie z aktualnym cennikiem Fly.io.

### Czy muszę konfigurować bazę danych PostgreSQL dla n8n na Fly.io?
**Nie jest to wymagane**. N8n może działać z lokalną bazą SQLite, która jest przechowywana na wolumenie. To rozwiązanie jest prostsze w konfiguracji i wystarczające dla większości przypadków użycia. Baza PostgreSQL jest zalecana tylko dla większych wdrożeń z intensywnym wykorzystaniem.

### Jak często muszę aktualizować n8n na Fly.io?
Nie ma ścisłego wymogu aktualizacji, ale zaleca się regularne aktualizacje, aby korzystać z nowych funkcji i poprawek bezpieczeństwa. Aktualizacja jest prosta i polega na wdrożeniu nowego obrazu Docker:
```bash
fly deploy --image n8nio/n8n:latest -a krzyk-n8n
```

## Pytania dotyczące konfiguracji

### Czy mogę używać własnej domeny dla n8n na Fly.io?
**Tak**, możesz skonfigurować własną domenę zamiast domyślnej `nazwa-app.fly.dev`. W tym celu:
1. Dodaj swoją domenę w panelu Fly.io
2. Utwórz odpowiednie rekordy DNS wskazujące na infrastrukturę Fly.io
3. Zaktualizuj zmienne środowiskowe `WEBHOOK_URL` i `N8N_HOST` aby używały Twojej domeny

### Jak mogę zabezpieczyć dostęp do mojej instancji n8n?
Możesz zabezpieczyć dostęp na kilka sposobów:
1. Włączając uwierzytelnianie podstawowe:
```bash
fly secrets set \
  N8N_BASIC_AUTH_ACTIVE=true \
  N8N_BASIC_AUTH_USER=uzytkownik \
  N8N_BASIC_AUTH_PASSWORD=haslo \
  -a krzyk-n8n
```

2. Konfigurując zarządzanie użytkownikami w n8n:
```bash
fly secrets set N8N_USER_MANAGEMENT_DISABLED=false -a krzyk-n8n
```

### Czy mogę uruchomić n8n na Fly.io z moimi aktualnymi workflow?
**Tak**, możesz wyeksportować workflow z istniejącej instalacji n8n i zaimportować je do nowej instancji na Fly.io. Pamiętaj, że musisz również skonfigurować na nowo wszystkie dane uwierzytelniające do zewnętrznych serwisów.

### Co się stanie, jeśli wyczerpię darmowe limity Fly.io?
Jeśli przekroczysz darmowe limity, Fly.io zacznie naliczać opłaty zgodnie z cennikiem. Możesz ustawić limity wydatków w panelu Fly.io, aby uniknąć nieoczekiwanych kosztów. W przypadku wyczerpania środków lub osiągnięcia limitu wydatków, aplikacja może zostać zatrzymana.

## Pytania dotyczące użytkowania

### Jak mogę sprawdzić, czy moje workflow działają poprawnie?
Możesz monitorować działanie workflow na kilka sposobów:
1. Przeglądając historię wykonań w interfejsie n8n
2. Sprawdzając logi aplikacji:
```bash
fly logs -a krzyk-n8n | grep workflow
```
3. Konfigurując powiadomienia o błędach w Twoich workflow

### Czy mogę uruchomić n8n na Fly.io razem z innymi aplikacjami?
**Tak**, możesz uruchomić wiele aplikacji na swoim koncie Fly.io. Pamiętaj jednak, że każda aplikacja zużywa część dostępnych zasobów w ramach Twojego planu.

### Jak długo będą przechowywane moje dane na Fly.io?
Dane przechowywane na wolumenie będą dostępne tak długo, jak długo istnieje Twoja aplikacja i wolumen. Fly.io nie usuwa automatycznie danych z wolumenów, nawet jeśli aplikacja jest zatrzymana. Dane zostaną usunięte tylko w przypadku ręcznego usunięcia wolumenu lub aplikacji.

### Czy mogę używać webhooków w n8n na Fly.io do integracji z zewnętrznymi serwisami?
**Tak**, webhooki w n8n na Fly.io działają poprawnie, pod warunkiem prawidłowej konfiguracji zmiennych `WEBHOOK_URL` i `N8N_HOST`. Twoja instancja n8n będzie dostępna z internetu pod adresem `https://nazwa-app.fly.dev`, co umożliwia zewnętrznym serwisom wywoływanie webhooków.

## Pytania dotyczące rozwiązywania problemów

### Co zrobić, jeśli n8n ciągle się restartuje z powodu braku pamięci?
Jeśli n8n restartuje się z powodu błędów "Out of Memory", zwiększ przydzieloną pamięć:
```bash
fly scale memory 2048 -a krzyk-n8n
```
W przypadku bardziej złożonych workflow lub przetwarzania dużych ilości danych, może być potrzebne nawet 4GB RAM.

### Jak mogę odzyskać dostęp, jeśli zapomniałem hasła do n8n?
Jeśli zapomniałeś hasła uwierzytelnienia podstawowego, możesz je zresetować:
```bash
fly secrets set N8N_BASIC_AUTH_PASSWORD=nowe_haslo -a krzyk-n8n
fly apps restart krzyk-n8n
```

Jeśli używasz zarządzania użytkownikami n8n, możesz je tymczasowo wyłączyć, zalogować się, a następnie zresetować hasło:
```bash
fly secrets set N8N_USER_MANAGEMENT_DISABLED=true -a krzyk-n8n
fly apps restart krzyk-n8n
# Po zalogowaniu i zresetowaniu hasła
fly secrets set N8N_USER_MANAGEMENT_DISABLED=false -a krzyk-n8n
fly apps restart krzyk-n8n
```

### Co zrobić, jeśli moja aplikacja n8n przestała odpowiadać?
1. Sprawdź logi, aby zidentyfikować problem:
```bash
fly logs -a krzyk-n8n
```

2. Zrestartuj aplikację:
```bash
fly apps restart krzyk-n8n
```

3. Jeśli problem nadal występuje, skontaktuj się z pomocą techniczną Fly.io lub społecznością n8n.

### Jak mogę wykonać pełną kopię zapasową mojej instancji n8n?
Możesz wykonać kopię zapasową danych z wolumenu:
```bash
# Połącz się z konsolą
fly ssh console -a krzyk-n8n

# Utwórz archiwum z danymi n8n
cd /home/node/.n8n
tar -czvf /tmp/n8n-backup.tar.gz .

# Pobierz archiwum na lokalny komputer
exit
fly ssh sftp get /tmp/n8n-backup.tar.gz backup.tar.gz -a krzyk-n8n
```

Dodatkowo, zaleca się regularne eksportowanie workflow z interfejsu n8n.