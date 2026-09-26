# Muak release catalogs.
#
# Prerequisites: podman/docker, git
# Run `just --list` for available recipes

set shell := ["bash", "-euo", "pipefail", "-c"]
set script-interpreter := ["bash", "-euo", "pipefail"]
set positional-arguments

# ─────────────────────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────────────────────

# Global settings

registry := env_var_or_default("REGISTRY", "ghcr.io/muak-os")
tools := env_var_or_default("TOOLS", "ghcr.io/muak-os/tools@sha256:74883141d2f857c327a6278a2cd12a5494376b9973bb1c62a025f349f4e2ed91")

# Container runtime

container_runtime := env_var_or_default("CONTAINER_RUNTIME", "podman")

# ─────────────────────────────────────────────────────────────────────────────
# Main Recipes
# ─────────────────────────────────────────────────────────────────────────────

# Add or update a catalog entry.
[script]
add *args:
    just _kata add "$@"

# Remove an entry from a release line.
[script]
remove *args:
    just _kata remove "$@"

# Compose a release line.
[script]
compose *args:
    just _kata compose "$@"

# HEAD-verify every pinned entry of a line (or every line).
[script]
verify release="":
    release_arg=""
    if [ -n "{{ release }}" ]; then release_arg="--release {{ release }}"; fi
    just _kata verify ${release_arg}

# Build and push a catalog image for a release line.
[script]
publish release kind="":
    kind_arg=""
    if [ -n "{{ kind }}" ]; then kind_arg="--kind {{ kind }}"; fi
    just _kata publish --release "{{ release }}" ${kind_arg}

# ─────────────────────────────────────────────────────────────────────────────
# Private Helpers
# ─────────────────────────────────────────────────────────────────────────────

[private]
[script]
_kata *args:
    {{ container_runtime }} run --rm --network=host \
        -e KOCI_REGISTRY_USERNAME -e KOCI_REGISTRY_PASSWORD \
        -e REGISTRY="{{ registry }}" \
        -v "$PWD":/data -w /data \
        {{ tools }} \
        /kata "${@}"
