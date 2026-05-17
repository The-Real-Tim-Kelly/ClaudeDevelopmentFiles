---
mode: 'agent'
description: 'Review an existing instruction, prompt, or role file for quality and correctness'
---

# Review Agent Config File

> **Claude Code usage:** Reference with `@prompts/review-agent-config.prompt.md` and include the file to review, e.g. `@prompts/review-agent-config.prompt.md @instructions/csharp.instructions.md`.

Review the target agent configuration file for quality, correctness, and consistency with the conventions of this repository.

> **Scope:** The checklist below covers the _minimum_ concerns to verify. Raise any issue you find — do not limit your review to what appears here.

---

## Review Checklist

### Frontmatter (all file types)

- [ ] **Present** — does the file have YAML frontmatter?
- [ ] **Correct type** — instruction files: `applyTo` glob; prompt files: `mode` + `description`; role files: no required frontmatter
- [ ] **`applyTo` accuracy** — does the glob correctly match the files this instruction should apply to? Is it too broad (firing on irrelevant files) or too narrow (missing relevant ones)?
- [ ] **`description` quality** — is the Copilot prompt picker description a clear, one-sentence summary of what the prompt does?

### Rules & Content Quality

- [ ] **Specificity** — are rules specific and actionable? Flag any rule that is vague ("write clean code", "follow best practices", "keep it simple")
- [ ] **Non-obvious** — do the rules cover things an agent would plausibly get wrong without being told? Flag anything that just restates language documentation or obvious defaults
- [ ] **Accuracy** — are code examples and API references correct for the stated language/framework version?
- [ ] **Examples** — for any non-obvious rule, is there a code example? Add one if it would reduce ambiguity
- [ ] **Contradictions** — does any rule contradict another rule in the same file, or a rule in a closely related file in this repo?
- [ ] **Duplication** — is any rule already covered by a companion instruction file that would typically be used alongside this one?

### Structure & Formatting

- [ ] **Claude reference note** — is there a `> **Claude Code:**` note near the top explaining how to reference the file?
- [ ] **Heading levels** — are `##` used for top-level sections and `###` for subsections? No skipped levels?
- [ ] **Code blocks** — are all code examples in fenced blocks with a language identifier?
- [ ] **Completeness** — are there obvious gaps? (e.g. a C# instruction file missing async conventions, a prompt missing a "fill in before running" section)

### Token Efficiency

- [ ] **No padding** — are there introductory paragraphs, summaries, or meta-commentary that add tokens without adding signal?
- [ ] **No redundancy** — are any points made more than once in different words?
- [ ] **Appropriate length** — is the file noticeably longer or shorter than comparable files in this repo for no good reason?

### Prompt Files (additional checks)

- [ ] **Output is well-defined** — does the prompt specify file names, folder paths, class names, and what exactly gets generated?
- [ ] **Scope note present** — does the prompt make clear the task list is a minimum and the agent should go further if it spots gaps?
- [ ] **Fill-in section** — is there a "Fill in before running" section at the bottom with clear prompts for the user?
- [ ] **Instruction cross-references** — does the prompt reference the relevant instruction files the agent should also apply?

### Role Files (additional checks)

- [ ] **Mindset over rules** — does the role define a _way of thinking_, not just a checklist?
- [ ] **Concrete behaviours** — does it list specific things the persona does differently from the default agent?
- [ ] **Anti-behaviours** — does it list things the persona refuses to do or pushes back on?

---

## Output Format

For each issue found, report:

- **Severity**: Critical / Major / Minor / Suggestion
- **Location**: Section or line reference
- **Issue**: What is wrong or missing
- **Recommendation**: Specific fix or improved wording

Where a rule should be rewritten, provide the improved version directly.

---

## File to Review

Include the file alongside this prompt:

```
@prompts/review-agent-config.prompt.md @instructions/react.instructions.md
```
