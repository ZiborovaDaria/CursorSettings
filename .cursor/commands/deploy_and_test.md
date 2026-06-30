# deploy_and_test — загрузка/проверка в 1С

Используй после CFE/EPF/ERF/metadata изменений или по просьбе пользователя.

1. Прочитай `.dev.env`.
2. Подключи `project-esti-single-1c-launch-agent.mdc`.
3. Проверь, нет ли активных `1cv8/1cv8c` конфликтов.
4. Определи тип проверки:
   - загрузка расширения;
   - UpdateDBCfg;
   - syntax check;
   - Enterprise smoke test;
   - YAxUnit.
5. Не выполнять destructive/data-changing сценарии без утверждения.
6. Записать логи в `.logs/`.
7. При ошибке сразу перейти к `capture-error`.
8. В отчете указать: команда, цель ИБ без секретов, лог, результат, что не проверено.
