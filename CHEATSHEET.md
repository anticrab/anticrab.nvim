# anticrab.nvim — Cheatsheet

Лидер — `Space`. Через `dual()` почти все маппинги работают и в русской раскладке (Ф = Space, Ы = S и т.д.), переключаться не обязательно. `jk` в insert-режиме = `<Esc>`. `;` = `:`.

## Файлы / окно / выход

| Клавиша | Действие |
|---|---|
| `<leader>ww` | Сохранить файл |
| `<leader>wq` / `<leader>wqa` | Сохранить и выйти / всё |
| `<leader>qq` / `<leader>qa` | Выйти без сохранения / всё |
| `<leader>E` | `:e ` (перезагрузить буфер) |
| `<leader>yp` | Скопировать относительный путь файла в буфер обмена |
| `gx` | Открыть URL под курсором (`xdg-open`) |

Auto-save: сохраняется автоматически при `InsertLeave`, `TextChanged`, потере фокуса, выходе. Исключены git-commit, NvimTree и пр.

## Сплиты

| Клавиша | Действие |
|---|---|
| `<leader>sV` / `<leader>sH` | Вертикальный / горизонтальный сплит |
| `<leader>sx` | Закрыть сплит |
| `<leader>se` | Уравнять размеры |
| `<leader>sj` / `sk` | Уменьшить / увеличить высоту |
| `<leader>sh` / `sl` | Сузить / расширить |
| `<C-h/j/k/l>` | Между сплитами **и tmux-панелями** (vim-tmux-navigator) |

## Буферы / табы (barbar)

| Клавиша | Действие |
|---|---|
| `<leader>tn` / `<leader>tp` | Следующий / предыдущий буфер |
| `<leader>Tn` / `<leader>Tp` | Переместить буфер вправо / влево |
| `<leader>tt` | Pick — выбрать буфер по букве |
| `<leader>tx` | Закрыть буфер |
| `<leader>to` | Новый таб |

## Файловый менеджер (Neo-tree)

| Клавиша | Действие |
|---|---|
| `<leader><leader>` | Открыть Neo-tree и выделить текущий файл |
| `<leader>et` | Toggle Neo-tree (плавающий) |

Внутри Neo-tree — стандартные биндинги: `a` add, `d` delete, `r` rename, `c` copy, `m` move, `H` toggle hidden.

## Telescope (fuzzy-поиск)

| Клавиша | Действие |
|---|---|
| `<leader>ff` | Файлы |
| `<leader>fg` | Live grep по проекту |
| `<leader>fs` | Поиск в текущем буфере |
| `<leader>fb` | Открытые буферы |
| `<leader>fh` | Help tags |
| `<leader>fo` | Document symbols (LSP) |
| `<leader>fm` | Функции/методы (treesitter) |
| `<leader>fi` | Incoming calls (LSP) |
| `<leader>ft` | Grep по узлу под курсором в Neo-tree |
| `<leader>ft` (TODO) | `:TodoTelescope` — все TODO/FIXME |

## LSP

| Клавиша | Действие |
|---|---|
| `<leader>gg` | Hover (документация) |
| `<leader>gd` / `gD` | Definition / Declaration |
| `<leader>gi` | Implementation |
| `<leader>gt` | Type definition |
| `<leader>gr` | References (Telescope) |
| `<leader>gc` | Очистить подсветку references |
| `<leader>gs` | Signature help |
| `<leader>ga` | Code action |
| `<leader>rr` | Rename |
| `<leader>gf` | Format (n/v) |
| `<leader>tr` | Document symbols (через LSP) |

LSP-сервера ставятся автоматически через Mason (`:Mason` UI). Сейчас в `ensure_installed`: `lua_ls`, `lemminx`, `marksman`, `quick_lint_js`, `pyright`. Go (`gopls`) — отдельным куском.

## Диагностика / Trouble

| Клавиша | Действие |
|---|---|
| `<leader>gl` | Floating popup с ошибкой строки |
| `<leader>ee` | То же, с фокусом и rounded border |
| `<leader>ec` | Скопировать текст ошибки текущей строки |
| `<leader>gn` / `<leader>gp` | Следующая / предыдущая диагностика |
| `<leader>xx` | Trouble: диагностика по проекту |
| `<leader>xd` | Trouble: диагностика по буферу |
| `<leader>xq` | Trouble: quickfix-list |
| `<leader>xt` | Trouble: TODO-комментарии |

## Quickfix

| Клавиша | Действие |
|---|---|
| `<leader>qo` / `qc` | Открыть / закрыть |
| `<leader>qn` / `qp` | Следующий / предыдущий пункт |
| `<leader>qf` / `ql` | Первый / последний |

## Folds (UFO + treesitter)

| Клавиша | Действие |
|---|---|
| `zO` | Открыть все фолды |
| `zC` | Закрыть все фолды |
| `Z` | Заглянуть в фолд под курсором; если не на фолде — LSP hover |
| `za` / `zo` / `zc` | Стандартные toggle/open/close фолда |

## Навигация (Flash)

| Клавиша | Действие |
|---|---|
| `ss` | Прыжок Flash (n/x/o) — наберёшь 2 символа, выберешь метку |
| `S` | Прыжок по treesitter-узлам |

## Git — gitsigns

Подсветка добавленных/изменённых/удалённых строк в gutter включена. Маппингов под `<leader>` сейчас нет, всё доступно через команды:

| Команда | Действие |
|---|---|
| `:Gitsigns preview_hunk` | Превью hunk во всплывашке |
| `:Gitsigns next_hunk` / `prev_hunk` | Прыжок между hunk'ами |
| `:Gitsigns blame_line` | Кто менял строку |
| `:Gitsigns toggle_current_line_blame` | Inline-blame постоянно |
| `:Gitsigns stage_hunk` / `undo_stage_hunk` | Stage hunk |
| `:Gitsigns reset_hunk` | Откатить hunk |

## Git — diffview

| Клавиша | Действие |
|---|---|
| `<leader>do` | Diffview: незакоммиченные изменения |
| `<leader>dc` | Закрыть Diffview |
| `<leader>dh` | История текущего файла |
| `<leader>dH` | История ветки |

Можно вручную: `:DiffviewOpen origin/main...HEAD` — diff против main.

## Diff (mergetool / vimdiff)

| Клавиша | Действие |
|---|---|
| `<leader>cn` / `<leader>cp` | Следующий / предыдущий diff hunk |
| `<leader>cc` | `:diffput` |
| `<leader>cj` | `:diffget 1` (local) |
| `<leader>ck` | `:diffget 3` (remote) |

## Debugger (DAP, Go-friendly)

| Клавиша | Действие |
|---|---|
| `<leader>dc` | Continue (запуск/продолжить) |
| `<leader>db` | Toggle breakpoint |
| `<leader>B` | Условный breakpoint |
| `<leader>dso` / `dsi` / `dsout` | Step over / into / out |
| `<leader>dr` | Открыть REPL |
| `<leader>du` | Toggle DAP UI |
| `<leader>dt` / `<leader>dT` | Debug Go test (под курсором / verbose) |
| `<leader>dn` | Debug nearest Go test |
| `<leader>dl` | Debug last Go test |

UI открывается автоматически при старте сессии и закрывается при завершении.

⚠️ **Конфликт:** `<leader>dc` одновременно «DAP continue» и «Diffview close» (биндинги в разных файлах). Что сработает — определяет порядок загрузки. Стоит переименовать один из них.

## Тесты (Neotest + neotest-golang)

| Клавиша | Действие |
|---|---|
| `<leader>Tr` | Запустить тест под курсором |
| `<leader>TT` | Открыть summary |

## Редактирование

| Клавиша | Действие |
|---|---|
| `ysiw"` / `ds"` / `cs"'` | mini.surround: add / delete / change surrounding |
| `<leader>vf` | Visual выделение тела Go-функции (`va{o0`) |

Autopairs: скобки/кавычки автоматически закрываются (treesitter-aware).

## Completion (nvim-cmp) — в insert-режиме

| Клавиша | Действие |
|---|---|
| `<C-Space>` | Открыть меню |
| `<C-j>` / `<C-k>` | Следующий / предыдущий пункт |
| `<C-b>` / `<C-f>` | Скролл документации |
| `<Tab>` / `<S-Tab>` | Перебор пунктов / прыжки по аргументам сниппета |
| `<CR>` | Подтвердить |

Источники: LSP, LuaSnip, buffer, path.

## AI

| Клавиша | Действие |
|---|---|
| `<leader>om` | Переключить Ollama-модель (custom switcher) |
| `<leader>on` | Новый Avante-чат |
| `<leader>os` | Остановить Avante-чат |

## Сессии (auto-session)

Автосохранение и автовосстановление сессий по `cwd`. Команды: `:SessionSave`, `:SessionRestore`, `:SessionDelete`. Перед сохранением закрываются скрытые табы и буферы.

## Прочее (без биндингов)

- **bigfile.nvim** — отключает тяжёлые фичи в файлах >2 MiB.
- **indent-blankline** — направляющие отступа `|`.
- **barbecue** — breadcrumbs по LSP в верхней строке окна.
- **lualine** — status line, тема `catppuccin-nvim`.
- **conform.nvim** — `goimports` на сохранении для Go.
- **todo-comments** — подсветка `TODO/FIXME/HACK` (`:TodoTelescope`, `:Trouble todo`).
- **treesitter** — подсветка для `lua/go/python` + автоустановка для новых языков.

## Темы

| Команда | Действие |
|---|---|
| `:ThemeSync` | Перечитать GNOME `color-scheme` и применить |
| `:ThemeToggle` | Переключить mocha ↔ latte |
