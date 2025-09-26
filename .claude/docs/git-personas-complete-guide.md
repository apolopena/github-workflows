# git-personas Complete Guide

## Overview & Purpose

The git-personas system enables transparent AI/human collaboration by maintaining separate Git identities that clearly distinguish between human-authored and AI-assisted commits. This approach makes AI involvement explicit rather than hidden, supporting development workflows that value clear provenance and honest collaboration.

### Architecture Overview

The system operates across a Windows/WSL2 boundary using:
- **AI Persona**: SSH keys stored in KeePassXC (Windows) → Pageant → wsl2-ssh-pageant bridge → WSL2
- **Human Persona**: YubiKey PIV keys via PKCS#11 for transport, GPG signing for commits
- **Attribution**: Handled through git identity (author/committer) and signing, not commit messages

For additional YubiKey and SSH configuration context, see the [yubikey-wsl-guides repository](https://github.com/apolopena/yubikey-wsl-guides) which provides complementary information that may fill any gaps not covered in this guide.

## Prerequisites & Dependencies

### Windows/WSL2 Environment
- Windows 10/11 with WSL2 enabled
- Ubuntu or compatible Linux distribution in WSL2
- YubiKey with PIV functionality
- KeePassXC installed on Windows

### Required Software
```bash
# WSL2 dependencies
sudo apt-get update && sudo apt-get install -y socat git openssh-client

# Windows dependencies (PowerShell)
# - KeePassXC: https://keepassxc.org/
# - PuTTY (for Pageant): https://www.chiark.greenend.org.uk/~sgtatham/putty/
# - wsl2-ssh-pageant: Download from GitHub releases
```

### YubiKey Libraries
```bash
# Install YubiKey PKCS#11 library
sudo apt-get install -y yubico-piv-tool libykcs11-1
```

## YubiKey PIV Setup

### Generate PIV Keys
```bash
# Generate AUTH key in slot 82
ykman piv keys generate --algorithm RSA2048 82 /tmp/82_pubkey.pem

# Create self-signed certificate
ykman piv certificates generate --subject "CN=YubiKey PIV AUTH,OU=Engineering AUTH" 82 /tmp/82_pubkey.pem

# Verify key is present
ykman piv keys list
```

### PKCS#11 Configuration
```bash
# Set environment variable for PKCS#11 library path
export YKCS11="/usr/local/lib/libykcs11.so"

# Test YubiKey access
ssh-keygen -D "$YKCS11"
```

### SSH Configuration
```bash
# Add to ~/.ssh/config
cat >> ~/.ssh/config << 'EOF'
Host github.com
  HostName github.com
  User git
  Port 22
  PKCS11Provider /usr/local/lib/libykcs11.so
  IdentityAgent ~/.ssh/ssh-agent.sock
EOF
```

## KeePassXC SSH Key Management

### Create AI SSH Keys

#### Option A: Generate in WSL (Recommended)
```bash
# Create temporary key for AI AUTH
umask 077
ssh-keygen -t ed25519 -C "GitHub | AI | SSH | AUTH" -f "$HOME/.ssh/kp_ai_auth_ed25519" -N ""

# Create temporary key for AI SIGN
ssh-keygen -t ed25519 -C "GitHub | AI | SSH | SIGN" -f "$HOME/.ssh/kp_ai_sign_ed25519" -N ""

# Copy public keys (for GitHub)
cat "$HOME/.ssh/kp_ai_auth_ed25519.pub" | /mnt/c/Windows/System32/clip.exe
cat "$HOME/.ssh/kp_ai_sign_ed25519.pub" | /mnt/c/Windows/System32/clip.exe
```

#### Option B: Generate in Windows PowerShell
```powershell
# Set accessible location (not TEMP)
$authKey = Join-Path $env:USERPROFILE "Desktop\kp_ai_auth_ed25519"
$signKey = Join-Path $env:USERPROFILE "Desktop\kp_ai_sign_ed25519"

# Generate keys
ssh-keygen.exe -t ed25519 -C "GitHub | AI | SSH | AUTH" -f $authKey
ssh-keygen.exe -t ed25519 -C "GitHub | AI | SSH | SIGN" -f $signKey

# Copy public keys to clipboard
Get-Content ($authKey + '.pub') | Set-Clipboard
Get-Content ($signKey + '.pub') | Set-Clipboard
```

### KeePassXC Configuration

#### Create SSH Key Entries
1. Create entry: `GitHub | AI | SSH | AUTH`
2. Create entry: `GitHub | AI | SSH | SIGN`

#### Attach Private Keys (Critical Steps)
1. **Advanced tab** → **Attachments** → **Add**
2. Navigate to private key file (not .pub)
3. **SSH Agent tab**:
   - ✅ Check "Add key to agent when database is unlocked"
   - ⚪ Select "Attachment" radio button
   - 🔽 **Green dropdown** → select your attached private key file
4. **Save entry**

#### Security Cleanup
```bash
# After attaching to KeePassXC, delete original files
shred -u "$HOME/.ssh/kp_ai_auth_ed25519" 2>/dev/null || rm -f "$HOME/.ssh/kp_ai_auth_ed25519"
shred -u "$HOME/.ssh/kp_ai_sign_ed25519" 2>/dev/null || rm -f "$HOME/.ssh/kp_ai_sign_ed25519"
```

#### Verify Keys Load
1. Lock/unlock KeePassXC database
2. Check Pageant (system tray) shows loaded keys
3. Test key access:
```bash
SSH_AUTH_SOCK="$HOME/.ssh/agent.sock" ssh-add -L
```

## Pageant Bridge Configuration

### Install wsl2-ssh-pageant
```powershell
# Download bridge binary
$dir = "$env:LOCALAPPDATA\wsl-ssh-pageant"
New-Item -ItemType Directory -Path $dir -Force | Out-Null
Invoke-WebRequest 'https://github.com/BlackReloaded/wsl2-ssh-pageant/releases/latest/download/wsl2-ssh-pageant.exe' -OutFile "$dir\wsl2-ssh-pageant.exe"
```

### WSL2 Setup
```bash
# Add to ~/.zshrc or ~/.bashrc
export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

# Bridge management aliases
alias kpwin-ssh-up='rm -f "$HOME/.ssh/agent.sock"; ( setsid nohup socat UNIX-LISTEN:"$HOME/.ssh/agent.sock",fork EXEC:"/mnt/c/Users/$USER/AppData/Local/wsl-ssh-pageant/wsl2-ssh-pageant.exe" ) >/dev/null 2>&1 &'
alias kpwin-ssh-down='pkill -f "socat .*agent\.sock" 2>/dev/null || true; rm -f "$HOME/.ssh/agent.sock"'
alias kpwin-ssh-test='SSH_AUTH_SOCK="$HOME/.ssh/agent.sock" ssh -F /dev/null -o IdentityAgent="$HOME/.ssh/agent.sock" -o IdentitiesOnly=no -o PKCS11Provider=none -T git@github.com'
```

### Start Services
```bash
# Reload shell configuration
source ~/.zshrc

# Start Pageant bridge
kpwin-ssh-up

# Test bridge connectivity
SSH_AUTH_SOCK="$HOME/.ssh/agent.sock" ssh-add -L
```

### Windows Pageant Management
```powershell
# Start Pageant
$pg="$env:ProgramFiles\PuTTY\pageant.exe"; if(-not (Test-Path $pg)){$pg="$env:ProgramFiles(x86)\PuTTY\pageant.exe"}; Start-Process $pg

# Stop Pageant
Stop-Process -Name pageant -Force -ErrorAction SilentlyContinue

# Verify processes
$p=@('pageant','KeePassXC'); $p|%{ $x=Get-Process $_ -EA SilentlyContinue; if($x){$x|ft Name,Id,StartTime,Path}else{"$_: NOT RUNNING"} }
```

## GitHub Configuration

### Understanding GitHub SSH Key Types

GitHub has two distinct SSH key sections:
- **SSH keys**: Used for authentication/transport (git push/pull)
- **SSH signing keys**: Used for commit signature verification

### Add AI Keys to GitHub

1. **Copy AUTH key for transport**:
```bash
SSH_AUTH_SOCK="$HOME/.ssh/agent.sock" ssh-add -L | grep "AUTH"
```
   - Go to GitHub → Settings → SSH and GPG keys → **SSH keys**
   - Add key with title: "AI AUTH - Windows/WSL2"

2. **Copy SIGN key for verification**:
```bash
SSH_AUTH_SOCK="$HOME/.ssh/agent.sock" ssh-add -L | grep "SIGN"
```
   - Go to GitHub → Settings → SSH and GPG keys → **SSH signing keys**
   - Add key with title: "AI SIGN - Windows/WSL2"

### Repository Access

1. **Add AI as collaborator**:
   - Repository → Settings → Manage access
   - Invite `apolopena-AI` (or your AI account name)

2. **Accept collaboration** (as AI account):
   - Check GitHub notifications or visit repository directly
   - Accept collaboration invitation

## git-personas Script Usage

### Installation
```bash
# Copy optimized script to home directory
cp .claude/git-personas-optimized.zsh ~/.zsh/git-personas.zsh
chmod +x ~/.zsh/git-personas.zsh
```

### Configuration Variables
```bash
# Edit these in the script as needed
KP_AGENT_SOCK="$HOME/.ssh/agent.sock"     # Pageant bridge socket
HUMAN_NAME="apolopena"                      # Your name
HUMAN_EMAIL="3060702+apolopena@users.noreply.github.com"
AI_NAME="apolopena-AI"                      # AI account name
AI_EMAIL="233522855+apolopena-AI@users.noreply.github.com"
```

### Core Functions

#### AI Persona (with Safety Timer)
```bash
# Switch to AI persona (auto-expires in 10 minutes)
source ~/.zsh/git-personas.zsh && persona_ai

# Expected output
🤖 AI persona active (expires in 10 min)
```

#### Human Persona
```bash
# Switch to human persona (removes timer)
source ~/.zsh/git-personas.zsh && persona_human

# Expected output
👤 Human persona active
```

#### Status Check
```bash
# Check current persona
source ~/.zsh/git-personas.zsh && persona_who

# Example outputs
🤖 AI: apolopena-AI <233522855+apolopena-AI@users.noreply.github.com> (ai)
👤 Human: apolopena <3060702+apolopena@users.noreply.github.com> (human)
```

### Claude Code Usage Pattern

Due to Claude Code's shell environment limitations, always use this pattern:
```bash
# Set AI persona for commit work
source ~/.zsh/git-personas.zsh && persona_ai

# ... perform git operations as AI ...

# Hand back to human
source ~/.zsh/git-personas.zsh && persona_human
```

### Safety Features

#### Auto-Expiring AI Persona
- AI persona automatically reverts to human after 10 minutes
- Prevents accidental long-term use of AI identity
- Timer is killed and reset on manual persona switches

#### Commit Confirmation (Optional)
Uncomment this line in the script to enable commit warnings:
```bash
alias git='git_commit_safe'
```

This adds confirmation prompts when committing as AI persona.

#### State Tracking
- Persona state stored in `~/.git-persona-state`
- Visual indicators (🤖 for AI, 👤 for human)
- Clear status reporting with `persona_who`

### Example Workflow
```bash
# 1. Start AI work
source ~/.zsh/git-personas.zsh && persona_ai

# 2. Make changes and commit
echo "AI enhancement" > feature.md
git add feature.md
git commit -m "Add AI-powered feature"

# 3. Push using AI AUTH key
git push

# 4. Return to human persona
source ~/.zsh/git-personas.zsh && persona_human

# 5. Verify switch
source ~/.zsh/git-personas.zsh && persona_who
```

## Troubleshooting & Common Issues

### Computer Wake/Sleep Issues

**Problem**: Services stop working after computer sleep
**Solution**: Restart services in this order:
```bash
# 1. Restart Pageant bridge
kpwin-ssh-down && kpwin-ssh-up

# 2. Restart ssh-agent with YubiKey (if needed)
pkill ssh-agent
eval $(ssh-agent -s)
ssh-add -s /usr/local/lib/libykcs11.so

# 3. Test connectivity
SSH_AUTH_SOCK="$HOME/.ssh/agent.sock" ssh-add -L
```

### Key Visibility Issues

**Problem**: `ssh-add -L` shows no keys or connection refused
**Solutions**:
```bash
# Check if services are running
ps aux | grep -E "(socat|pageant)"

# Restart Pageant bridge
kpwin-ssh-down && kpwin-ssh-up

# Verify KeePassXC database is unlocked

# Check socket exists
ls -la ~/.ssh/agent.sock
```

### GitHub Authentication Problems

**Problem**: Permission denied during git push
**Diagnostics**:
```bash
# Check current persona
source ~/.zsh/git-personas.zsh && persona_who

# Test SSH connection
ssh -T git@github.com

# For AI persona, test pageant bridge
SSH_AUTH_SOCK="$HOME/.ssh/agent.sock" ssh -T git@github.com
```

**Solutions**:
- Verify correct keys added to GitHub (AUTH for transport, SIGN for verification)
- Ensure AI user accepted collaboration invitation
- Check repository permissions

### YubiKey Access Issues

**Problem**: YubiKey not accessible from WSL
**Solution**:
```bash
# Check YubiKey connection
ykman info

# Test PKCS#11 access
ssh-keygen -D /usr/local/lib/libykcs11.so

# If needed, close Windows applications using YubiKey
# Then re-test access
```

### Pageant Bridge Connection Issues

**Problem**: Bridge socket exists but connection refused
**Solution**:
```bash
# Kill existing socat processes
pkill -f "socat.*agent.sock"

# Remove stale socket
rm -f ~/.ssh/agent.sock

# Restart bridge
kpwin-ssh-up

# Verify with verbose SSH
ssh -vvv -T git@github.com
```

## Token Efficiency & Claude Code Integration

### Why Shell Script vs MCP Server

The shell script approach is significantly more token-efficient:
- **Shell script**: ~18 tokens per persona switch (10 for command + 8 for output)
- **MCP server**: ~500-1500+ tokens per operation (including validation/diagnostics)

**Cost comparison**: Shell script is 50-100x more token efficient for basic persona switching.

### Optimal Usage Patterns

**For Claude Code**:
```bash
# Most efficient - single command with source and execution
source ~/.zsh/git-personas.zsh && persona_ai
```

**Token consumption breakdown**:
- Command string: ~10 tokens
- Script output message: ~8 tokens
- Script contents (100+ lines): **0 tokens** (not sent to Claude)
- Comments in script: **0 tokens** (not sent to Claude)

### Script Size Impact
Script size and comments do NOT affect token usage in Claude Code's bash tool. Only the source command and output are tokenized.

## Architecture Decisions

### Current Hybrid Approach

**Why this configuration works**:
- **AI keys**: Stored in KeePassXC for automated access without manual entry
- **Human keys**: YubiKey PIV for hardware security, GPG signing for compatibility
- **Transport separation**: Different SSH keys prevent cross-contamination
- **Clear attribution**: Git identity and signing provide transparent provenance

### Key Design Choices

**SSH vs GPG Signing**:
- AI persona: SSH signing (keys managed in KeePassXC)
- Human persona: GPG signing (PIV SSH signing incompatible with WSL ssh-agent)

**Token Efficiency Priority**:
- Shell script chosen over MCP server for 50-100x better token efficiency
- Optimized for Claude Code's shell environment limitations

**Safety First**:
- Auto-expiring AI persona prevents accidental long-term use
- Visual indicators and confirmation prompts
- State tracking across shell sessions

### Future Considerations

The MCP server specification (`.claude/specs/git-personas-mcp-server.md`) provides a comprehensive design for broader git persona management if:
- Multiple users adopt similar workflows
- Frequent troubleshooting becomes a burden
- Integration with other development tools is needed
- Team/enterprise deployment is required

For now, the shell script approach provides the optimal balance of functionality, token efficiency, and maintenance simplicity for this specialized Windows/WSL2/YubiKey/KeePassXC environment.

---

## Summary

This git-personas system successfully enables transparent AI/human collaboration with:
- ✅ **Clear Attribution**: Git identity and signing distinguish AI vs human commits
- ✅ **Hardware Security**: YubiKey for human keys, KeePassXC for AI keys
- ✅ **Cross-Platform**: Windows/WSL2 integration via Pageant bridge
- ✅ **Safety Features**: Auto-expiring AI persona and confirmation prompts
- ✅ **Token Efficient**: Optimized for Claude Code usage patterns
- ✅ **Production Ready**: Tested end-to-end workflow with GitHub integration

The system transforms AI collaboration from hidden assistance to transparent partnership, supporting development workflows that value honest attribution and clear provenance.