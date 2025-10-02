# MCP Servers Collection

Коллекция серверов Model Context Protocol (MCP), написанных на Ruby для различных системных операций.

## Серверы

### 1. Simple MCP Server (`simple_mcp_server.rb`)
Базовый MCP сервер с математическими вычислениями и функциями времени.

**Установка:**
```bash
gem install json
```

**Инструменты:**
- `get_current_time` - Возвращает текущее время
- `calculate` - Выполняет математические вычисления

### 2. Simple Fast MCP Server (`simple_fast_mcp.rb`)
Упрощенная версия MCP сервера с использованием `fast_mcp` gem.

**Установка:**
```bash
gem install fast_mcp
```

**Инструменты:**
- `get_current_time` - Возвращает текущее время
- `calculate` - Выполняет математические вычисления

### 3. System Monitor MCP (`system_monitor_mcp.rb`)
Мониторинг системных ресурсов и производительности с использованием `fast_mcp` gem.

**Установка:**
```bash
gem install fast_mcp
```

**Инструменты:**
- `check_disk_space` - Проверяет доступное место на диске
- `check_memory` - Проверяет использование памяти
- `check_cpu` - Проверяет загрузку CPU
- `system_info` - Показывает информацию о системе

### 4. Git MCP Server (`git_mcp.rb`)
Операции с Git репозиториями с использованием `fast_mcp` gem.

**Установка:**
```bash
gem install fast_mcp git
```

**Инструменты:**
- `git_status` - Показывает статус git репозитория
- `git_log` - Показывает историю коммитов
- `git_branches` - Список всех веток git

### 5. Task Manager MCP (`task_manager_mcp.rb`)
Управление задачами с уровнями приоритета и отслеживанием статуса с использованием `fast_mcp` gem.

**Установка:**
```bash
gem install fast_mcp json fileutils
```

**Инструменты:**
- `list_tasks` - Показывает все задачи
- `add_task` - Добавляет новую задачу
- `complete_task` - Отмечает задачу как выполненную
- `delete_task` - Удаляет задачу
- `task_stats` - Показывает статистику задач

### 6. Swagger MCP Wrapper (`swagger_mcp_wrapper.rb`)
Автоматически генерирует MCP инструменты из спецификаций Swagger/OpenAPI.

**Установка:**
```bash
gem install json net-http uri yaml
```

**Использование:**
```bash
ruby swagger_mcp_wrapper.rb <swagger_path> <api_base_url>
```


## Использование

### Запуск отдельных серверов

```bash
# Simple MCP Server (базовая версия)
ruby simple_mcp_server.rb

# Simple Fast MCP Server
ruby simple_fast_mcp.rb

# System Monitor MCP
ruby system_monitor_mcp.rb

# Git MCP Server
ruby git_mcp.rb

# Task Manager MCP
ruby task_manager_mcp.rb

# Swagger MCP Wrapper
ruby swagger_mcp_wrapper.rb ./swagger.json http://localhost:3000
```

### Интеграция с MCP клиентами

Эти серверы могут быть интегрированы с MCP-совместимыми клиентами путем их настройки в файле конфигурации MCP клиента.

Пример конфигурации для Cursor:
```json
{
  "mcpServers": {
    "simple-fast": {
      "command": "ruby",
      "args": ["/path/to/simple_fast_mcp.rb"]
    },
    "system-monitor": {
      "command": "ruby",
      "args": ["/path/to/system_monitor_mcp.rb"]
    },
    "git-ops": {
      "command": "ruby",
      "args": ["/path/to/git_mcp.rb"]
    },
    "task-manager": {
      "command": "ruby",
      "args": ["/path/to/task_manager_mcp.rb"]
    },
    "swagger-api": {
      "command": "ruby",
      "args": ["/path/to/swagger_mcp_wrapper.rb", "./swagger.json", "http://localhost:3000"]
    }
  }
}
```

## Зависимости

- Ruby 2.7+
- `fast_mcp` gem (для серверов на основе fast_mcp)
- `git` gem (для операций с Git)
- Стандартные библиотеки Ruby (json, yaml, net/http, fileutils)

## Разработка

Для добавления новых инструментов к существующим серверам:

1. Добавьте определение инструмента в соответствующий класс
2. Реализуйте соответствующий метод
3. Добавьте соответствующую обработку ошибок
4. Протестируйте с MCP клиентом

## Лицензия

MIT License

