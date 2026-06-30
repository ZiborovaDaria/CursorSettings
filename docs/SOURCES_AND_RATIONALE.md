# Sources and rationale

This overlay is based on these principles:

1. Cursor Project Rules are `.mdc` files under `.cursor/rules/` with frontmatter such as `description`, `globs`, and `alwaysApply`.
2. Always-on rules should be short; detailed rules should be task-specific/on-demand.
3. Cursor Agent Skills are reusable `SKILL.md` packages and must physically exist if the router references them.
4. For this project, local `.mdc` files are safer than relying only on remote GitHub-imported rules.
5. 1C code changes must follow locate → understand → edit → verify.
6. 1C standards require discipline around module structure, form modules, query performance, transactions and locks.
7. Memory Bank remains the default process; OpenSpec is optional-only.

The external references used during design are summarized in the final ChatGPT answer.
