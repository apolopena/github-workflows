#!/usr/bin/env zsh
#
# git-personas: Optimized AI/Human git identity management
#
# SAFETY: Prevents accidental commits as wrong persona
# TOKEN EFFICIENT: Minimal overhead for Claude Code usage
#

# ==========================================
# USER CONFIGURATION
# ==========================================
# REQUIRED: Set GP_HUMAN_SESSION=1 in shell profile (.zshrc/.bashrc/.profile)
# RECOMMENDED: Set all variables in shell profile - survives script updates
# Works with GitHub, GitLab, Bitbucket, or any git host
# Copy this block to your shell profile:
#   export GP_HUMAN_SESSION=1
#   export GP_HUMAN_NAME="Your Name"
#   export GP_HUMAN_EMAIL="your@email.com"
#   export GP_HUMAN_GPG_KEY="YOUR_16_CHAR_GPG_KEY"
#   export GP_AI_NAME="Your-AI"
#   export GP_AI_EMAIL="your-ai@email.com"

# Fallback values (overridden by environment)
GP_HUMAN_NAME="${GP_HUMAN_NAME:-}"
GP_HUMAN_EMAIL="${GP_HUMAN_EMAIL:-}"
GP_HUMAN_GPG_KEY="${GP_HUMAN_GPG_KEY:-}"
GP_AI_NAME="${GP_AI_NAME:-}"
GP_AI_EMAIL="${GP_AI_EMAIL:-}"

# KeePass users - pageant bridge SSH socket path
KP_SSH_AGENT_SOCK="$HOME/.ssh/agent.sock"


# ==========================================


# Helper: Git repo check
_git_here() { git rev-parse --is-inside-work-tree >/dev/null 2>&1; }


# AI Persona (with safety timer)
persona_ai() {
  _git_here || { echo "Not in a git repo."; return 1; }

  # Get keys from pageant bridge
  AI_AUTH_KEY="$(SSH_AUTH_SOCK="$KP_SSH_AGENT_SOCK" ssh-add -L | grep -F 'GitHub | AI | SSH | AUTH' | head -n1 2>/dev/null)"
  AI_SIGN_KEY="$(SSH_AUTH_SOCK="$KP_SSH_AGENT_SOCK" ssh-add -L | grep -F 'GitHub | AI | SSH | SIGN' | head -n1 2>/dev/null)"

  # Validate keys
  [ -z "$AI_AUTH_KEY" ] && { echo "❌ AI AUTH key not found. Check KeePassXC."; return 1; }
  [ -z "$AI_SIGN_KEY" ] && { echo "❌ AI SIGN key not found. Check KeePassXC."; return 1; }

  # Configure git
  git config core.sshCommand "ssh -F /dev/null -o IdentityAgent=$KP_SSH_AGENT_SOCK -o IdentitiesOnly=no -o PKCS11Provider=none"
  git config user.name "$GP_AI_NAME"
  git config user.email "$GP_AI_EMAIL"
  git config commit.gpgsign false


  echo "🤖 AI persona active"
}

# Human Persona (removes safety timer)
persona_human() {
  _git_here || { echo "Not in a git repo."; return 1; }

  # Configure for human SSH keys - use current SSH agent socket
  git config core.sshCommand "ssh -F /dev/null -o IdentityAgent=$SSH_AUTH_SOCK -o IdentitiesOnly=yes -o PKCS11Provider=/usr/local/lib/libykcs11.so"
  git config user.name "$GP_HUMAN_NAME"
  git config user.email "$GP_HUMAN_EMAIL"
  git config gpg.format openpgp
  # Handle human GPG signing key
  if [[ -z "${GP_HUMAN_GPG_KEY:-}" ]]; then
    echo "⚠️  GP_HUMAN_GPG_KEY not set. Find your key with:"
    echo "   gpg --list-secret-keys --keyid-format=long --with-colons | awk -F: '/^sec/ {print \$5}'"
    echo "   Then set it in .zshrc or script"
  else
    git config user.signingkey "$GP_HUMAN_GPG_KEY"
  fi
  git config commit.gpgsign true

  echo "👤 Human persona active"
}


# Quick status check
persona_who() {
  USER="$(git config --get user.name 2>/dev/null || echo "not set")"
  EMAIL="$(git config --get user.email 2>/dev/null || echo "not set")"
  SSH_CMD="$(git config --get core.sshCommand 2>/dev/null || echo "not set")"
  GPG_FORMAT="$(git config --get gpg.format 2>/dev/null || echo "not set")"
  SIGNING_KEY="$(git config --get user.signingkey 2>/dev/null || echo "not set")"
  COMMIT_SIGN="$(git config --get commit.gpgsign 2>/dev/null || echo "not set")"

  if [[ "$EMAIL" == *"AI"* ]]; then
    echo "🤖 AI: $USER <$EMAIL>"
  elif [[ "$EMAIL" == "not set" ]]; then
    echo "❓ No git identity configured"
  else
    echo "👤 Human: $USER <$EMAIL>"
  fi

  echo "  SSH Command: $SSH_CMD"
  echo "  GPG Format: $GPG_FORMAT"
  echo "  Signing Key: $SIGNING_KEY"
  echo "  Commit Sign: $COMMIT_SIGN"
}

# Test AI persona SSH connection
persona_test_ai() {
  echo "Testing AI persona SSH connection..."
  ssh -F /dev/null -o IdentityAgent=$KP_SSH_AGENT_SOCK -o IdentitiesOnly=no -o PKCS11Provider=none -T git@github.com
}

# Test human persona SSH connection
persona_test_human() {
  echo "Testing human persona SSH connection..."
  ssh -F /dev/null -o IdentityAgent=$SSH_AUTH_SOCK -o IdentitiesOnly=no -o PKCS11Provider=/usr/local/lib/libykcs11.so -T git@github.com
}