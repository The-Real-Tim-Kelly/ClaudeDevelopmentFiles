---
mode: 'agent'
description: 'Generate a new instruction file, prompt file, or role file for this agent config repo'
---

# Generate Agent Config File

> **Claude Code usage:** Reference with `@prompts/generate-agent-config.prompt.md` and describe what you need at the bottom.
> Optionally include an existing file to use as a style reference: `@prompts/generate-agent-config.prompt.md @instructions/csharp.instructions.md`.

Generate a new agent configuration file for this repository that follows its established conventions and is compatible with both Claude Code and GitHub Copilot.

> **Scope:** The guidelines below are the _minimum_ quality bar. If you spot additional improvements or missing sections, include them — don't limit output to what's explicitly listed.

---

## File Types in This Repo

### `instructions/*.instructions.md` — Domain coding standards

Applied automatically by Copilot (via `applyTo` frontmatter) and referenced on-demand by Claude. Each file covers one domain: a language, framework, or infrastructure service.

**Required frontmatter:**

```yaml
---
applyTo:
  '**/*.ext' # glob matching the files this should apply to
  # omit applyTo for broad/infrastructure topics (aws, dynamodb, mongodb)
  # use applyTo: "**" only for meta-instructions (observe-first)
---
```

**Quality bar for instruction files:**

- Every rule must be **specific and actionable** — "use `async/await` correctly" is useless; "never call `.Result` or `.Wait()` on a Task" is not
- Rules must be things an agent would plausibly get wrong without being told — don't restate language documentation
- Prefer examples over prose for anything non-obvious
- Group into logical sections with `##` headings
- No duplication across sections
- Token-efficient: no padding, no summaries, no meta-commentary about what the file does

**Anti-patterns to avoid:**

- Vague rules: "write clean code", "follow best practices", "keep methods small"
- Restating obvious language defaults that the agent already knows
- Over-specifying things that are purely stylistic with no correctness implication
- Long introductory paragraphs before the actual rules

---

### `prompts/*.prompt.md` — Reusable task prompts

One prompt per recurring task. The agent fills in the task details and executes. Works with both Claude (`@prompts/...`) and Copilot (prompt picker).

**Required frontmatter:**

```yaml
---
mode: 'agent'
description: 'One sentence shown in the Copilot prompt picker'
---
```

**Quality bar for prompt files:**

- Describe the _output_ precisely: file names, folder paths, class names, what gets generated
- Include a code or structure template where it reduces ambiguity
- Cross-reference relevant instruction files the agent should also apply
- End with a **"Fill in before running"** section the user completes before sending
- Scope note: make clear the task list is a minimum — the agent should go further if it spots gaps

---

### `roles/*.role.md` — Expert persona files

Activate a mindset, not a task. Combined with an instruction file, a role file shifts _how_ the agent thinks about the work.

**Quality bar for role files:**

- Define the persona's **mindset and priorities** — what do they care about that a default agent doesn't?
- List concrete **behaviours**: things the persona does that differ from default agent behaviour
- List concrete **anti-behaviours**: things the persona refuses to do or actively pushes back on
- Keep it short — roles are about attitude, not exhaustive rules

---

## Conventions Across All File Types

- Claude Code reference note at the top (below frontmatter), e.g.:
  ```
  > **Claude Code:** Reference with `@instructions/my-file.instructions.md`
  ```
- Use `##` for top-level sections, `###` for subsections
- Code examples in fenced blocks with the language identifier
- No emoji, no marketing language, no conversational filler

---

## What to Generate

**Fill in before running:**

- **File type:** `instructions` / `prompt` / `role`
- **Topic / domain:** e.g. "Terraform", "GraphQL", "API security review"
- **Target stack / file types:** e.g. "`.tf` files", "any language", "`.cs` files"
- **Key rules / behaviours to capture:** bullet-point the things you want the file to enforce
- **Reference files to align with:** include any existing files in this repo that the new one should be consistent with
