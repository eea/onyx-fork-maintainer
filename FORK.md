# EEA Fork Maintainer

## Introduction

This repository (`onyx-fork-maintainer`) is a standalone toolkit designed to manage the EEA (European Environment Agency) fork of the **Onyx** (formerly Danswer) project. It contains the merge automation scripts, conflict resolution templates, and the complete documentation of all EEA-specific patches.

Previously, these scripts and patch documents lived in a folder named `eea-artifacts/` directly inside the EEA fork itself. To keep the fork's history clean and make maintaining the fork easier, they have been extracted into this dedicated maintainer repository.

## Architecture

The system consists of two parts:
1. **The EEA Fork (`eea/danswer`):** The actual codebase, where the `eea` branch serves as the main branch of development and the source of truth for deployments.
2. **The Maintainer Repo (This Repo):** Contains the automated AI-driven scripts required to seamlessly merge upstream Onyx updates into the EEA fork while preserving customizations.

---

## Bootstrapping the Environment

Because the scripts in this repository need to interact with the Onyx codebase, you must first bootstrap a workspace. We provide a script that clones the EEA fork, sets up the upstream remotes, and configures everything correctly in a subdirectory named `danswer-eea/`.

To set up the environment, run:

```bash
./scripts/eea_bootstrap.sh [target_tag]
```

If you don't provide a `target_tag`, the script will prompt you to select one from the latest upstream releases.

### What the Bootstrap Script Does:
1. Clones the `eea` branch of our fork into `./danswer-eea/`.
2. Adds the upstream Onyx repository as a remote named `onyx`.
3. Fetches **only** the specified target tag from the upstream remote to keep the workspace lean.

---

## Update & Patch Strategy

To ensure seamless integration of upstream Onyx releases, we adhere to the following workflow:

1. **Targeting a Release**: We periodically identify a stable Onyx release (e.g., `v2.12.1`) as our target to merge into our fork.
2. **Patch Documentation**: Every customization or deviation from upstream Onyx **must** be documented in `patches-overview.md`. This allows us to track exactly what we changed, why we changed it, and where the changes live.
3. **Isolating Customizations**: When writing new features or modifying existing Onyx code in the fork:
   - Try to isolate EEA features by placing them in separate, newly created files or modules whenever possible.
   - If modifying an existing upstream file is unavoidable, clearly delineate the change with concise comments (e.g., `// EEA CUSTOMIZATION: ...`) so it is trivial to identify during a merge conflict.
4. **Merge Process**:
   - Bootstrap the workspace using `./scripts/eea_bootstrap.sh <tag>`.
   - Change directory to the newly created clone: `cd danswer-eea`.
   - Run the master merge script, pointing back to the scripts in the parent directory:
     ```bash
     python3 ../scripts/eea_merge_master.py <tag>
     ```
   - The master script will automatically create an upgrade branch, initiate the merge, and loop through the AI-driven conflict resolution process (see `conflict_resolution.md` for details).

---

## Guidelines for AI Assistants

When you (the AI assistant) are tasked with creating a feature, modifying code, or resolving conflicts for the EEA fork, you must:

1. **Read `patches-overview.md`** first to get a high-level view of existing customizations.
2. **Consult Patch Artifacts:** For detailed architectural intent and files modified by specific patches, read the corresponding `patches/EEA-XXX.md` file.
3. **Prioritize Upstream Compatibility**: Avoid massive structural refactors of upstream Onyx files. Instead, use hooks, subclassing, overriding, or isolated components wherever the language/framework permits.
4. **Document Your Patches**: If you introduce a new deviation from the upstream codebase:
   - Create a new `EEA-XXX.md` file in `patches/` detailing the files modified, your intent, and how to migrate the changes during upstream updates.
   - Update `patches-overview.md` with a bullet point linking to your new patch file.
   - Keep comments in the code (e.g., `// EEA CUSTOMIZATION: ...`) to link back to the patch ID where appropriate.
5. **Keep it Clean**: Write clear, standard, and highly readable code. Do not introduce messy dependencies that conflict with Onyx's primary package management files unless strictly necessary for EEA.

By following this strategy, we can leverage the powerful features developed by the Onyx community while securely and reliably serving EEA's specific organizational and user needs.
