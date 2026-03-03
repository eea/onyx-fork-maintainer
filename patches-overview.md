# EEA Customizations & Patches Overview

This document records the overarching customizations and patches made in the `eea` branch of our fork of the Onyx (formerly Danswer) repository.

**Target Upstream Version:** `v2.12.1`

> [!IMPORTANT]
> **For AI Assistants:** We use a **Patch Artifacts** architecture.
> Detailed documentation, intent, and structural details for each patch are kept in individual Markdown files in the `patches/` directory.
> When modifying code or resolving conflicts, you **MUST** read the corresponding `EEA-XXX.md` file to understand the full architectural intent.
> If you are creating a new patch, you must create a new `EEA-XXX.md` file in that directory and add a brief summary here.

---

## Documented Patches

- **[EEA-001] Custom Jenkins & Git CI/CD** (See `patches/EEA-001.md`)
- **[EEA-002] Playwright & Scraping Customizations** (See `patches/EEA-002.md`)
- **[EEA-003] EEA Config & Admin Pages** (See `patches/EEA-003.md`)
- **[EEA-004] Frontend Customizations (Logos, UI, Disclaimer, Chat)** (See `patches/EEA-004.md`)
- **[EEA-005] Custom Background Tasks & Celery Tweaks** (See `patches/EEA-005.md`)
- **[EEA-006] Helm Chart Customizations for EEA Infrastructure** (See `patches/EEA-006.md`)
- **[EEA-007] Connector Healthchecks & Workarounds** (See `patches/EEA-007.md`)
- **[EEA-008] LLM & Auth Minor Tweaks** (See `patches/EEA-008.md`)
- **[EEA-009] Upstream Backports & Hotfixes** (See `patches/EEA-009.md`)

