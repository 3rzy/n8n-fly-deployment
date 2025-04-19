# Zarządzanie aplikacją n8n na Fly.io

## Monitorowanie aplikacji

### Sprawdzanie statusu aplikacji

Aby sprawdzić aktualny status aplikacji:

```bash
fly status -a krzyk-n8n
```

To polecenie pokaże informacje o uruchomionych maszynach, ich regionach i statusie.

### Przeglądanie logów

Aby zobaczyć logi aplikacji w czasie rzeczywistym:

```bash
fly logs -a krzyk-n8n
```

Możesz dodać flagę `-f` aby śledzić logi na bieżąco:

```bash
fly logs -f -a krzyk-n8n
```

## Zarządzanie cyklem życia aplikacji

### Zatrzymywanie aplikacji

Jeśli potrzebujesz zatrzymać aplikację (np. aby zaoszczędzić zasoby):

```bash
fly apps stop krzyk-n8n
```

### Uruchamianie aplikacji

Aby uruchomić zatrzymaną aplikację:

```bash
fly apps start krzyk-n8n
```

### Restart aplikacji

Aby zrestartować aplikację (np. po zmianie konfiguracji):

```bash
fly apps restart krzyk-n8n
```

## Zarządzanie zasobami

### Sprawdzanie aktualnej konfiguracji zasobów

Aby sprawdzić aktualną konfigurację aplikacji:

```bash
fly vm list -a krzyk-n8n
```

### Skalowanie pamięci

N8n wymaga minimum 2GB RAM do stabilnego działania. Jeśli potrzebujesz zmienić ilość przydzielonej pamięci:

```bash
fly scale memory 2048 -a krzyk-n8n
```

### Skalowanie CPU

Aby zmienić typ maszyny wirtualnej:

```bash
fly scale vm shared-cpu-1x -a krzyk-n8n
```

Dostępne typy maszyn to m.in.:
- `shared-cpu-1x`: współdzielone CPU, najmniejsza instancja
- `dedicated-cpu-1x`: dedykowane CPU, lepsza wydajność
- `dedicated-cpu-2x`: dedykowane CPU z 2 rdzeniami, wysoka wydajność

## Zarządzanie zmiennymi środowiskowymi

### Dodawanie/aktualizowanie zmiennych

```bash
fly secrets set NAZWA_ZMIENNEJ=wartość -a krzyk-n8n
```

Możesz ustawić wiele zmiennych na raz:

```bash
fly secrets set \
  ZMIENNA_1=wartość1 \
  ZMIENNA_2=wartość2 \
  -a krzyk-n8n
```

### Usuwanie zmiennych

```bash
fly secrets unset NAZWA_ZMIENNEJ -a krzyk-n8n
```

### Wyświetlanie listy zmiennych

```bash
fly secrets list -a krzyk-n8n
```

## Zarządzanie wolumenami

### Sprawdzanie wolumenów

```bash
fly volumes list -a krzyk-n8n
```

### Tworzenie kopii zapasowej danych

Możesz utworzyć kopię zapasową danych z wolumenu korzystając z konsoli SSH:

```bash
# Połączenie SSH z maszyną
fly ssh console -a krzyk-n8n

# Wewnątrz maszyny, przejdź do katalogu z danymi
cd /home/node/.n8n

# Utwórz archiwum
tar -czvf backup.tar.gz .

# Wyjdź z maszyny
exit

# Pobierz kopię zapasową na lokalny komputer
fly ssh sftp get /home/node/.n8n/backup.tar.gz -a krzyk-n8n
```

## Aktualizacja n8n

Aby zaktualizować n8n do nowszej wersji:

1. Aktualizacja obrazu Docker:

```bash
fly deploy --image n8nio/n8n:latest -a krzyk-n8n
```

Możesz również określić konkretną wersję, np. `n8nio/n8n:0.226.0`.

## Rozwiązywanie problemów

### Dostęp do powłoki

Aby uzyskać dostęp do powłoki kontenera:

```bash
fly ssh console -a krzyk-n8n
```

### Restart po błędach

Jeśli aplikacja uległa awarii, zrestartuj ją:

```bash
fly apps restart krzyk-n8n
```

### Monitorowanie użycia zasobów

Możesz monitorować zużycie zasobów przez aplikację:

```bash
fly status -a krzyk-n8n
```

### Problemy z pamięcią

Jeśli w logach widzisz błędy "Out of Memory", zwiększ ilość przydzielonej pamięci:

```bash
fly scale memory 2048 -a krzyk-n8n
```

W przypadku intensywnego użytkowania może być potrzebne nawet 4GB pamięci:

```bash
fly scale memory 4096 -a krzyk-n8n
```

Pamiętaj, że zwiększenie zasobów może wiązać się z dodatkowymi kosztami, jeśli przekroczysz limity darmowego planu.