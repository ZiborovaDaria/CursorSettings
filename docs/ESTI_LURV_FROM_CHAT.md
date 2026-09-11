# Инструкция: создание ЛУРВ из чата Cursor (пакет CursorSettings)

Обезличенная копия для git. **Рабочие URL/логин/пароль** — только в локальном ESTI:
`Extent/ЛУРВ_HTTP/ИНСТРУКЦИЯ-создание-ЛУРВ-из-чата.md` и/или `.dev.env`
(`ESTI_HTTP_PUBLISH`, `ESTI_LURV_BASE`, `ESTI_HTTP_USER`, `ESTI_HTTP_PASSWORD`).

Технический API: [`ESTI_POST_lurv.md`](./ESTI_POST_lurv.md).  
Правило агента: `.cursor/rules/project-esti-lurv-agent.mdc`.

---

## Жёсткие правила

1. Не создавать ЛУРВ без явного OK пользователя.
2. Resolve/черновик — да; `POST /lurv` / `create_lurv` — только после OK.
3. Не пересоздавать пакет без явной просьбы (update API нет).
4. Прикреплять delivery-файл `.cfe`/`.epf`/`.erf` из `Desktop\расширения\<Контрагент>\`, если есть.
5. `ambiguous` → спросить, не угадывать.
6. Не передавать `comment`. Описание — одно короткое предложение.
7. Не проводить документ. Пароли не писать в Memory Bank / git.

## Оркестрация

```text
resolve_lurv_contractor → resolve_lurv_work_type → resolve_lurv_employee?
→ черновик на утверждение → OK → create_lurv (+ files[]) → номер в tasks.md
```

Timeout create: **120 с**. RootURL сервиса: `mcp-lurv`.

## Дефолты working (если не сказано иное)

| Поле | Правило |
|---|---|
| Контрагент | СОПРОВОЖДЕНИЕ ООО |
| Организация | Сопровождение (`organization_ref` из локальной инструкции) |
| Сотрудник | Зиборова |
| Вид работ | «Разработка внешних отчетов и обработок» |

UUID и Basic Auth — **не** в этом файле; брать из локальной инструкции ESTI / `.dev.env`.

## Карточка Memory Bank

```markdown
### ЛУРВ из чата — <заголовок>
| Поле | Значение |
| Контур | working |
| Контрагент | … |
| Дата | YYYY-MM-DD |
| Работы | вид; с–по; описание |
| Файлы | путь к .cfe/.epf |
| Статус | draft → ready → created |
```
