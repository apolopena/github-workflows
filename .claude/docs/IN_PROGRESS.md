# Git Personas Implementation - In Progress Documentation

## YubiKey PIV Setup (Human Persona)

### AUTH Key Generation (Slot 82)
```bash
# Two-step process - CRITICAL to use this method
ykman piv keys generate -a RSA2048 82 public_key_82.pem
ykman piv certificates generate -s "CN=username,O=org,OU=Engineering AUTH" 82 public_key_82.pem

# Convert to SSH format for GitHub
ssh-keygen -i -m PKCS8 -f public_key_82.pem > auth_key.pub

# Clean up
rm public_key_82.pem
```

### IMPORTANT: SSH SIGN Key NOT Created
- **PIV SSH signing is unreliable** - extensive testing with multiple PKCS#11 libraries failed
- **ssh-agent consistently refuses PKCS#11 operations** for signing
- **Use GPG signing instead** - refer to: https://github.com/apolopena/yubikey-wsl-guides

## Git Personas Script Status

### Human Persona - Working ✅
```bash
# SSH AUTH + GPG signing (recommended)
persona_human --gpg

# SSH AUTH + SSH signing (problematic)
persona_human
```

### AI Persona - Pending ⏳
**Next Steps:**
1. Create separate AUTH and SIGN SSH keys in KeePassXC
2. Label keys: `GitHub | AI | SSH | AUTH` and `GitHub | AI | SSH | SIGN`
3. Test complete git-personas workflow

## Key Decisions Made

### Hybrid Approach Adopted
- **Human AUTH**: YubiKey PIV slot 82 (transport)
- **Human SIGN**: GPG signing (reliable)
- **AI AUTH/SIGN**: KeePassXC SSH keys (pending)

### Critical Rules for Documentation
- **Two-step PIV key generation** - never use piped commands
- **Ignore ykman error messages** if management PIN is prompted
- **SSH signing via PIV is NOT supported** - document limitation clearly

## Files Modified
- `git-personas.zsh` - Updated with GPG support and key separation
- Added comprehensive header documentation
- Fixed `gpg.format openpgp` (not `gpg`)

## Testing Status
- ✅ YubiKey PIV AUTH key working
- ✅ GPG signing working
- ✅ Human persona functional
- ⏳ AI persona pending implementation
- ❌ PIV SSH signing abandoned (incompatible)

## Troubleshooting Commands

### Check SSH Keys
```bash
# YubiKey keys (via PKCS#11)
ssh-keygen -D /usr/local/lib/libykcs11.so

# KeePassXC keys (via SSH agent)
ssh-add -L
```

### Reset SSH Agent
```bash
# Kill ssh-agent processes
pkill ssh-agent
```

### Common Issues
- **No KeePassXC keys**: See below
- **"Cannot read public key from pkcs11"**: Windows may have control of YubiKey - ensure WSL has USB access
- **With WSL YubiKey workflow**: After sleep, KeePass may need to be reconnected (verify by running `SSH-add -L` in WSL), YubiKey may need to be plugged and in plugged or possibly reastart `usbpid` in Powershell (as admin). By default Windows will have control of the key. WSL may need to be restarted as well. The churn goes like this:
  - **Reopen the KeePass DB with the SSH keys you require**: Click "Close", reselect the DB, ensure "use hardware key" is selected. You can verify success by running running `SSH-add -L` in WSL, the keys you need should be displayed
  - **Give control of YubiKey to WSL**: In Powershell (as admin) run: `yk2wsl`
  - **Check if the YubiKey is responding**: In WSL run: `ykman info` *__if it hangs restart WSL__*
  - **Check if ssh-agent can show PKCS#11 SSH keys from the YubiKey**: In WSL run  `ssh-keygen -D /usr/local/lib/libykcs11.so`. If no keys are shown, kills the ssh-agent and re-add the keys (assuming you add the keys from your .zshrc or bash.rc) run: `pkill ssh-agent && source ~.zshrc`. You should be prompted to enter your YubiKey pin. Run `ssh-keygen -D /usr/local/lib/libykcs11.so` again and the keys you need should be displayed.
  - **Restarting WSL can cause reconnection issues in already open VScode instances**: Close VScode and reopen it. If using Claude Code close the empty pane where it was, reopen it run /resume, resume your conversation.

## Next Session Tasks
1. Set up AI persona AUTH and SIGN keys in KeePassXC
2. Test complete git-personas workflow
3. Create comprehensive documentation for yubikey-wsl-guides
4. Document the PIV SSH signing limitation and rationale