#!/usr/bin/env bash
# Say which parts of the repository a change touches, as name=true or name=false lines for $GITHUB_OUTPUT.
#
#   .github/scripts/changed-areas.sh HEAD^1 HEAD           # in CI, on the merge commit of a pull request
#   .github/scripts/changed-areas.sh origin/main...HEAD    # locally, what this branch changes
#
# The arguments go to `git diff --name-only`. The areas:
#
#   backend   anything under backend/
#   frontend  anything under frontend/
#   api       what frontend/src/lib/api.generated.ts is generated from and with: the backend app and its dependencies,
#             the export and generator scripts, the frontend packages, and the generated file itself
#
# A change to a workflow that reads these areas, or to this script, touches all of them, so that every job runs on it.

set -euo pipefail

# Read the paths before the loop, so that a failing `git diff` stops the script instead of reporting no changes.
paths=$(git diff --name-only "$@")

backend=false
frontend=false
api=false
while IFS= read -r path; do
    case "$path" in
        .github/workflows/ci.yml | .github/workflows/postgres.yml | .github/scripts/changed-areas.sh)
            backend=true
            frontend=true
            api=true
            ;;
        backend/app/* | backend/pyproject.toml | backend/openapi-constraints.txt | backend/scripts/export_openapi.py)
            backend=true
            api=true
            ;;
        backend/*)
            backend=true
            ;;
        frontend/src/lib/api.generated.ts | frontend/scripts/generate-api-types.sh | \
            frontend/package.json | frontend/package-lock.json)
            frontend=true
            api=true
            ;;
        frontend/*)
            frontend=true
            ;;
        *)
            # The docs, the deployment and the image build: no job in these workflows reads them.
            ;;
    esac
done <<< "$paths"

echo "backend=$backend"
echo "frontend=$frontend"
echo "api=$api"
