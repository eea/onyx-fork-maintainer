# AgentZ: Autonomous Merge Resolution Framework

Welcome to **AgentZ**, a standalone toolkit and AI-driven orchestrator designed to manage and seamlessly upgrade the EEA (European Environment Agency) fork of the **Onyx** (formerly Danswer) project.

## Introduction
AgentZ takes the pain out of maintaining a heavily customized fork. When upstream Onyx releases a new version, AgentZ utilizes a multi-phase, self-correcting AI pipeline to automatically resolve complex merge conflicts, hunt down refactored code, and validate the resulting syntax.

Previously, these scripts and patch documents lived directly inside the EEA fork itself. To keep the fork's history clean and make maintaining it easier, they have been extracted into this dedicated maintainer repository.

## Key Features
- **Automated Merge Pipeline**: A master orchestrator that handles branch creation, git merging, and conflict resolution sequentially and automatically.
- **Agentic Resolution**: Employs an autonomous AI agent capable of using shell tools to locate refactored upstream code and appropriately apply EEA-specific customizations.
- **Compiler Feedback Loop**: Generated code is rigorously checked against linters (`ruff`, `tsc`). If errors occur, the LLM receives the stack trace and retries until it produces valid syntax.
- **Programmatic Configuration**: Deterministically merges dependencies and configurations without relying on error-prone AI generations for `package.json` and `pyproject.toml`.

## Documentation Architecture
AgentZ is divided into documentation, patch artifacts, and the active scripts. Start exploring here:

- ⚙️ **[The Merge Scripts & Architecture (`scripts/README.md`)](scripts/README.md)**: Deep dive into the mechanics of the automated merge phases, how to bootstrap the environment, and how to run the master orchestrator.
- 🧠 **[Conflict Resolution Strategy (`conflict_resolution.md`)](conflict_resolution.md)**: Details on how the AI pipeline classifies conflicts, mitigates hallucinations, and handles different file types.
- 📝 **[Patches Overview (`patches-overview.md`)](patches-overview.md)**: The central registry of all EEA-specific customizations. Before modifying code, consult this file to understand the intent behind our deviations from upstream Onyx.

## Getting Started

Because the scripts in this repository need to interact with the Onyx codebase, you must first bootstrap a workspace. We provide a script that clones the EEA fork, sets up the upstream remotes, and configures everything correctly in a subdirectory named `danswer-eea/`.

To set up the environment, run:

```bash
./scripts/eea_bootstrap.sh [target_tag]
```

If you don't provide a `target_tag`, the script will prompt you to select one from the latest upstream releases.

Once bootstrapped, change to the cloned directory and run the master script, pointing back to the orchestrator:

```bash
cd danswer-eea
python3 ../scripts/eea_merge_master.py <tag>
```

For full details on the workflow, how to debug, or how to resume a paused pipeline, refer to the [Scripts Documentation](scripts/README.md).

---

## Guidelines for AI Assistants / Contributors

When you (a human contributor or AI assistant) are tasked with creating a feature, modifying code, or resolving conflicts manually for the EEA fork, you must:

1. **Read `patches-overview.md`** first to get a high-level view of existing customizations.
2. **Consult Patch Artifacts:** For detailed architectural intent and files modified by specific patches, read the corresponding `patches/EEA-XXX.md` file.
3. **Prioritize Upstream Compatibility**: Avoid massive structural refactors of upstream Onyx files. Instead, use hooks, subclassing, overriding, or isolated components wherever the language/framework permits.
4. **Document Your Patches**: If you introduce a new deviation from the upstream codebase:
   - Create a new `EEA-XXX.md` file in `patches/` detailing the files modified, your intent, and how to migrate the changes during upstream updates.
   - Update `patches-overview.md` with a bullet point linking to your new patch file.
   - Keep comments in the code (e.g., `// EEA CUSTOMIZATION: ...`) to link back to the patch ID where appropriate.
5. **Keep it Clean**: Write clear, standard, and highly readable code. Do not introduce messy dependencies that conflict with Onyx's primary package management files unless strictly necessary.
