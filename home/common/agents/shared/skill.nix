# Renders SKILL.md under `prefix/<name>` for each skill: per-tool frontmatter
# generated from `skills` plus the shared body
# (home/common/agents/shared/skills/<name>/body.md), and copies that skill's
# references/ alongside it when it has one. `claude` and `opencode` take a
# prefix and share body content without sharing frontmatter.
{ selfPath, lib }:
let
  skills = {
    "code-security" = {
      summary = "Systematic security-focused code review identifying vulnerabilities, misconfigurations, and insecure patterns";
      trigger = "user asks for a security review, vulnerability assessment, security audit, or penetration-test-style analysis of code.";
      skip = "user asks for a general code review, feature feedback, refactoring suggestions, or style/lint fixes.";
      domain = "security";
    };
    "container-security" = {
      summary = "Audit and harden Dockerfiles, container images, and Kubernetes security contexts";
      trigger = "user asks to review, audit, or harden a Dockerfile, docker-compose, container image, or Kubernetes pod/deployment security context.";
      skip = "user is writing a new Dockerfile from scratch, asking general Docker usage questions, or debugging container runtime errors.";
      domain = "security";
    };
    "iac-security" = {
      summary = "Review Terraform, Kubernetes, and infrastructure-as-code for security misconfigurations";
      trigger = "user asks to review, audit, or harden Terraform, OpenTofu, Helm charts, CloudFormation, or Kubernetes YAML for security issues.";
      skip = "user is writing new IaC from scratch, asking how to use Terraform/K8s, or debugging apply/plan errors.";
      domain = "security";
    };
    "pipeline-security" = {
      summary = "Review and harden CI/CD pipelines, workflow permissions, and secrets management";
      trigger = "user asks to review, audit, or harden GitHub Actions workflows, GitLab CI, Jenkins pipelines, or CI/CD secrets handling.";
      skip = "user is writing a new workflow from scratch, asking general CI/CD questions, or debugging build failures.";
      domain = "security";
    };
    "supply-chain-security" = {
      summary = "Audit dependency management, package provenance, and artifact integrity";
      trigger = "user asks to audit dependencies, review lockfiles, check for vulnerable packages, verify artifact provenance, or generate/verify SBOMs.";
      skip = "user is installing/updating packages normally, asking how to use a dependency, or debugging import errors.";
      domain = "security";
    };
    "technical-documentation" = {
      summary = "Create ADRs, runbooks, security advisories, postmortems, and design documents";
      trigger = "user asks to write an ADR, runbook, postmortem, security advisory, RFC, or design document.";
      skip = "user asks for inline code comments, README updates, API docs, or general prose writing.";
      domain = "documentation";
    };
    "threat-modeling" = {
      summary = "Structured STRIDE threat modeling to identify, classify, and prioritize security threats";
      trigger = "user asks for a threat model, STRIDE analysis, attack surface review, or risk assessment of a system or feature.";
      skip = "user asks general security questions, wants a code review, or is debugging a security bug.";
      domain = "security";
    };
  };

  frontmatter = {
    claude = name: s: ''
      ---
      name: ${name}
      description: |
        ${s.summary}.
        TRIGGER when: ${s.trigger}
        DO NOT TRIGGER when: ${s.skip}
      command: ${name}
      ---
    '';
    opencode = name: s: ''
      ---
      name: ${name}
      description: ${s.summary}
      license: MIT
      compatibility: opencode
      metadata:
        audience: developers
        domain: ${s.domain}
      ---
    '';
  };

  wire =
    tool: prefix:
    lib.foldlAttrs (
      acc: name: s:
      let
        skillDir = "home/common/agents/shared/skills/${name}";
        hasReferences = builtins.pathExists (selfPath "${skillDir}/references");
      in
      acc
      // {
        "${prefix}/${name}/SKILL.md".text =
          frontmatter.${tool} name s + "\n" + builtins.readFile (selfPath "${skillDir}/body.md");
      }
      // lib.optionalAttrs hasReferences {
        "${prefix}/${name}/references" = {
          source = selfPath "${skillDir}/references";
          recursive = true;
        };
      }
    ) { } skills;
in
{
  claude = wire "claude";
  opencode = wire "opencode";
}
