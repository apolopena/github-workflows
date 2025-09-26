# Session Primer: Git Personas and YubiKey PIV Setup

## Current Work Overview

This session focused on developing a **Git persona management system** for transparent AI collaboration, where separate identities distinguish human vs AI-assisted commits. We successfully created and tested a shell script (`git-personas.zsh`) that switches between AI and human Git identities, each using dedicated SSH keys for authentication and signing to provide clear attribution and audit trails.

## Key Accomplishments and Decisions

**YubiKey PIV Configuration:** We implemented a two-step process for generating YubiKey PIV keys using `ykman` commands, successfully creating an AUTH key in slot 82 with proper certificate naming (`OU=Engineering AUTH`). However, after extensive testing of PIV SSH signing (slots 82/83, various PKCS#11 libraries, ssh-agent configurations), we discovered that **PIV SSH signing is fundamentally incompatible** with ssh-agent across multiple OpenSSH and PKCS#11 library combinations. The consistent "agent refused operation" errors led us to adopt a **hybrid approach**: PIV AUTH key for transport, GPG signing for commits (referencing the user's existing complex but reliable GPG setup guide).

**Script Architecture:** The git-personas script was refined to support both SSH and GPG signing modes for the human persona (`persona_human` vs `persona_human --gpg`), with proper error handling, management key authentication, and a planned AI persona using KeePassXC-managed SSH keys. We removed "already configured" checks to ensure consistent state and implemented proper key separation concepts, though the SSH SIGN key ultimately proved unusable for the intended purpose.

## Next Steps

The immediate next task is **setting up the AI persona with KeePassXC SSH keys**, creating separate AUTH and SIGN keys labeled `GitHub | AI | SSH | AUTH` and `GitHub | AI | SSH | SIGN` in KeePassXC, then testing the complete git-personas workflow. Following that, comprehensive documentation needs to be created for the yubikey-wsl-guides repository covering the distilled YubiKey PIV setup process (AUTH key only), script installation/usage, and the decision rationale for the hybrid PIV/GPG approach. The session also established critical backup procedures and confirmed that GPG signing provides the most reliable hardware-backed commit signing solution despite its complex initial setup.