# Reusable GitHub Workflows

Collection of reusable GitHub Actions workflows for automation across repositories.

## Available Workflows

- **[provenance.yml](docs/provenance.md)** - GitHub App-authenticated actions with transparent AI attribution

## Git Personas

Script locations and name can  vary based on your setup and shell - for example:

**zsh:**
```bash
cp scripts/git-personas.zsh ~/.zsh/git-personas.zsh
echo 'source ~/.zsh/git-personas.zsh' >> ~/.zshrc
```

**bash:**
```bash
cp scripts/git-personas.zsh ~/git-personas.sh
echo 'source ~/git-personas.sh' >> ~/.bashrc
```

### Usage
- `persona_ai` - Switch to AI identity for commits
- `persona_human` - Switch to human identity
- `persona_who` - Check current persona

### Human Safety (Optional)
The script includes an optional safety check controlled by `ENABLE_SAFETY_CHECK=true` in the configuration section. When enabled, it prevents humans from accidentally committing as AI persona.

**Important:** Source git-personas **after** any existing git aliases in your shell configuration, as the safety check will override them.

### AI Setup (Claude Code)
Add to `.claude/CLAUDE.md`:
```
Start git work: `source scripts/git-personas.zsh && persona_ai`
Stay as AI for entire git workflow (commits/pushes/pulls, Etc.)
End git work: `source scripts/git-personas.zsh && persona_human`
```

### Benefits
- **Clear Attribution**: Git metadata distinguishes AI vs human contributions
- **Token Efficient**: ~18 tokens per persona switch
- **Safety Guards**: Interactive prompts prevent mistakes
- **Shell Integration**: Works with existing git workflows

## License

[MIT](LICENSE)