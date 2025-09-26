# git-personas MCP Server Specification

## Overview
An MCP (Model Context Protocol) server for managing git personas, SSH keys, and development identity across multiple projects and accounts.

## Target Use Cases
- Transparent AI/human collaboration attribution
- Multi-account git identity management
- Hardware security key integration (YubiKey, etc.)
- Enterprise environments requiring key isolation
- Cross-platform development workflows

## Core API Functions

### Persona Management
```javascript
// Basic persona switching
mcp__gitpersonas__setPersona(persona: string, options?: PersonaOptions)
mcp__gitpersonas__getCurrentPersona(project?: string): PersonaInfo
mcp__gitpersonas__resetPersona(project?: string): void

// Multi-account support
mcp__gitpersonas__listAccounts(): AccountInfo[]
mcp__gitpersonas__setDefaultAccount(type: "ai" | "human", account: string): void
```

### Service Management
```javascript
// SSH/Agent services
mcp__gitpersonas__startServices(): ServiceStatus
mcp__gitpersonas__stopServices(): ServiceStatus
mcp__gitpersonas__restartServices(): ServiceStatus
mcp__gitpersonas__getServiceStatus(): ServiceStatus[]

// Platform-specific bridges
mcp__gitpersonas__startPageantBridge(): BridgeStatus
mcp__gitpersonas__validateBridge(): BridgeValidation
```

### Diagnostics & Validation
```javascript
// System validation
mcp__gitpersonas__validateSetup(): SetupValidation
mcp__gitpersonas__checkDependencies(): DependencyStatus[]
mcp__gitpersonas__testGitHubConnection(persona: string): ConnectionTest

// Key management
mcp__gitpersonas__listKeys(source?: KeySource): KeyInfo[]
mcp__gitpersonas__validateKeys(persona: string): KeyValidation
mcp__gitpersonas__testSigning(persona: string): SigningTest
```

### Setup & Documentation
```javascript
// Interactive setup
mcp__gitpersonas__setup(): SetupWizard
mcp__gitpersonas__doctor(): DiagnosticReport
mcp__gitpersonas__getSetupGuide(component: string): DocumentationBlock

// Auto-configuration
mcp__gitpersonas__detectEnvironment(): EnvironmentInfo
mcp__gitpersonas__autoFix(issue: string): FixResult
```

## Configuration Schema

### Account Configuration
```json
{
  "accounts": {
    "ai": {
      "primary": {
        "name": "apolopena-AI",
        "email": "233522855+apolopena-AI@users.noreply.github.com",
        "keystore": "keepassxc",
        "authKeyLabel": "GitHub | AI | SSH | AUTH",
        "signKeyLabel": "GitHub | AI | SSH | SIGN"
      },
      "work": {
        "name": "company-AI",
        "email": "ai@company.com",
        "keystore": "vault",
        "sshConfig": "work-profile"
      }
    },
    "human": {
      "personal": {
        "name": "apolopena",
        "email": "3060702+apolopena@users.noreply.github.com",
        "keystore": "yubikey",
        "signingMethod": "gpg"
      },
      "work": {
        "name": "Alex Smith",
        "email": "alex.smith@company.com",
        "keystore": "yubikey",
        "signingMethod": "ssh"
      }
    }
  }
}
```

### Platform Configuration
```json
{
  "platform": {
    "type": "wsl2",
    "services": {
      "pageantBridge": {
        "enabled": true,
        "socketPath": "~/.ssh/agent.sock",
        "bridgeCommand": "/mnt/c/Users/user/AppData/Local/wsl-ssh-pageant/wsl2-ssh-pageant.exe"
      },
      "yubikey": {
        "enabled": true,
        "pkcs11Path": "/usr/local/lib/libykcs11.so",
        "usbPassthrough": true
      }
    }
  }
}
```

## Response Types

### PersonaInfo
```typescript
interface PersonaInfo {
  type: "ai" | "human"
  account: string
  name: string
  email: string
  signingMethod: "ssh" | "gpg"
  active: boolean
  project?: string
}
```

### ServiceStatus
```typescript
interface ServiceStatus {
  name: string
  running: boolean
  pid?: number
  issues?: string[]
  autostart: boolean
}
```

### SetupValidation
```typescript
interface SetupValidation {
  overall: "pass" | "warn" | "fail"
  components: ComponentStatus[]
  recommendations: string[]
  autoFixAvailable: boolean
}

interface ComponentStatus {
  name: string
  status: "pass" | "warn" | "fail"
  message: string
  required: boolean
}
```

## Token Cost Analysis

### Function Call Overhead
- Basic persona switch: ~50-100 tokens
- Service management: ~100-200 tokens
- Validation functions: ~200-500 tokens
- Setup/diagnostic functions: ~500-2000+ tokens

### Comparison with Shell Script
- Shell script: `source ~/.zsh/git-personas.zsh && persona_ai` = ~10-20 tokens
- MCP equivalent: `mcp__gitpersonas__setPersona("ai")` = ~100+ tokens
- **Shell script is 5-10x more token efficient for basic operations**

### When MCP Server Justifies Cost
- Frequent troubleshooting/diagnostics needed
- Multi-user onboarding scenarios
- Complex multi-platform environments
- Enterprise deployment with support requirements
- Integration with other development tools

## Implementation Considerations

### Architecture
- Node.js/TypeScript implementation
- Platform-specific service adapters
- Plugin system for different keystores
- Configuration validation and migration

### Distribution
- npm package for easy installation
- Standalone executable for air-gapped environments
- Docker container for consistent deployments
- Claude Code marketplace integration

### Security
- No private key storage in MCP server
- Secure communication with external services
- Audit logging for all persona changes
- Rate limiting for security operations

## Development Phases

### Phase 1: Core Functionality (MVP)
- Basic persona switching
- Simple multi-account support
- Git config management
- Basic validation

### Phase 2: Service Management
- SSH agent lifecycle management
- Platform-specific bridge handling
- Service health monitoring
- Auto-restart capabilities

### Phase 3: Enterprise Features
- Advanced validation and diagnostics
- Interactive setup wizard
- Documentation generation
- CI/CD integration

### Phase 4: Ecosystem Integration
- IDE plugins
- Terminal integrations
- Cloud deployment options
- Monitoring and analytics

## Future Considerations

### Broader Appeal
- Simplify for users without hardware security requirements
- Support cloud-based key management (AWS KMS, Azure Key Vault)
- Integration with popular development workflows
- Community plugins for different environments

### Scaling
- Multi-organization support
- Team persona management
- Compliance reporting
- Integration with identity providers

---

## Decision: Shelf for Now

**Reasons to postpone MCP server development:**
1. **Niche use case**: Very specific to Windows/WSL2/YubiKey/KeePassXC workflow
2. **Token inefficiency**: 5-10x more expensive than shell script for basic operations
3. **Complexity**: Significant development and maintenance overhead
4. **Working solution**: Current shell script approach is functional

**When to revisit:**
- Multiple users adopt similar workflows
- Frequent troubleshooting becomes burden
- Need for integration with other development tools
- Requirements for team/enterprise deployment

**Current approach: Optimize shell script for token efficiency and add safety guards**