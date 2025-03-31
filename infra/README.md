# Infrastructure Code Standards Manifest

## Core Principles

1. **Self-Documenting Code**: Use descriptive names and clear structure. Comments explain WHY, not WHAT.

2. **Modular Design**: Create reusable components with clear interfaces.

3. **Explicit over Implicit**: Declare intentions clearly rather than relying on defaults.

4. **Immutable Infrastructure**: Design for rebuilding rather than in-place updates.

5. **Infrastructure as Code**: Manage all static infrastructure with Terraform in a declarative style where possible.

## Ansible Guidelines

1. **Role Organization**: Follow standard directory structure (tasks, handlers, templates, defaults).

2. **Descriptive Task Names**: Make task purpose clear from its name.

3. **Tagged Tasks**: Tag all tasks for selective execution.

4. **Handlers**: Use for actions that should only run on changes.

5. **Idempotency**: Playbooks must produce identical results when run multiple times.

## Terraform Guidelines

1. **State Management**: Document backend configuration in comments.

2. **Standard Files**: Organize code in main.tf, variables.tf, outputs.tf, versions.tf.

3. **Resource Naming**: Use pattern `<provider>_<resource_type>_<n>`.

4. **Complete Variable Declarations**: Include type, description, and default where appropriate.

5. **Version Pinning**: Pin providers and modules to specific versions.

6. **Explicit Dependencies**: Use depends_on where relationships aren't automatically inferred.

7. **Kubernetes Resources**: Define all static Kubernetes resources directly as Terraform resources rather than using kubectl or Helm where possible.

## Kubernetes Configuration

1. **Resource Labels**: Apply consistent labeling for organization and selection.

2. **ConfigMaps/Secrets**: Externalize configuration instead of hardcoding.

3. **Resource Limits**: Specify requests and limits for all containers.

4. **Health Probes**: Configure appropriate liveness and readiness checks.

## Working with AI Tools

1. **Complete Artifacts**: Generate complete file content for multi-line changes rather than inline code blocks.

2. **Update Over Recreate**: Update existing artifacts when possible instead of generating new ones.

3. **Specific Requirements**: When requesting code, specify purpose, inputs/outputs, and integration points.

4. **Code Review**: Always review AI-generated code before committing.

## Security Practices

1. **Secret Management**: Store secrets in appropriate vaults, never in version control.

2. **Least Privilege**: Apply minimum necessary permissions for all resources.
