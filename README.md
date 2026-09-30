# Домашнее задание: Управление процессами

## Вариант 1. Реализация аналога `ps ax`

## 1. Стенд

| Параметр | Значение |
|---|---|
| Гипервизор | Proxmox VE |
| ВМ | 4 vCPU / 6 GB RAM |
| ОС | Ubuntu 24.04 LTS, systemd |

## 2. Решение

`myps.sh` — скрипт, который получает список процессов напрямую из файловой системы `/proc`:

- обходит `/proc/[0-9]*`;
- из `/proc/PID/stat` (формат: `pid (comm) state ppid …`) `sed`-ом извлекает `comm`, `ppid`, `state` — шаблон `^[0-9]+ \(([^)]*)\) ([A-Z]) ([0-9]+)`, где `([^)]*)` не даёт «съесть» имя процесса со скобками;
- имя/команду берёт из `/proc/PID/cmdline` (байты `\0` → пробелы через `tr`);
- у ядровых потоков `cmdline` пустой — выводится имя в скобках: `[kthreadd]`;
- вывод сортируется по PID.

Запуск:

```bash
./myps.sh
```

## 3. Пример результата работы

Полный лог — в `example-output.txt`. Фрагменты:

```
PID    PPID STAT COMMAND
      1       0 S    /usr/lib/systemd/systemd --system --deserialize=70
      2       0 S    [kthreadd]
      3       2 S    [pool_workqueue_release]
      4       2 I    [kworker/R-rcu_g]
      5       2 I    [kworker/R-rcu_p]
     ...
  40336       1 S    sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
  95325       1 S    nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx-first.conf -g daemon on; master_process on;
  95326   95325 S    nginx: worker process
  95327   95325 S    nginx: worker process
```

Проверка корректности: скрипт выводит **185 строк** (заголовок + 184 процесса), штатный `ps ax` на той же ВМ — **184 процесса**. Списки совпадают.

Выведены все требуемые поля: **PID, PPID, состояние (S/I/R/D/Z…), имя или команда запуска**; для сервисов показана полная команда, для ядровых потоков — `[имя]`.

## 4. Ручная проверка

```bash
./myps.sh                       # список всех процессов
./myps.sh | grep sshd           # фильтр как у ps ax | grep
./myps.sh | wc -l               # строк = процессов + заголовок
ps ax | wc -l                   # сравнение с эталоном
```
