#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

GITHUB_REPO="justacalico/job-simulator-2"
TAG="${CI_COMMIT_TAG:?tag required}"
PROJECT_DIR="${CI_PROJECT_DIR:-$PWD}"

cd "$PROJECT_DIR"

# The tag pipeline's github-sync job already watched the GitHub build to
# completion, so the release should exist. Poll briefly to tolerate races.
for _ in $(seq 1 30); do
  if gh release view "$TAG" -R "$GITHUB_REPO" >/dev/null 2>&1; then
    break
  fi
  sleep 20
done

if ! gh release view "$TAG" -R "$GITHUB_REPO" >/dev/null 2>&1; then
  echo "GitHub release $TAG not found" >&2
  exit 1
fi

rm -rf release-assets
mkdir -p release-assets
gh release download "$TAG" -R "$GITHUB_REPO" --dir release-assets
ls -la release-assets/

# Mirror to a GitLab release. glab uses CI_JOB_TOKEN when
# GLAB_ENABLE_CI_AUTOLOGIN is set; assets go through the package registry so
# they are permanent release links.
glab release delete "$TAG" -R "$CI_PROJECT_PATH" -y 2>/dev/null || true
glab release create "$TAG" \
  --name "Job Simulator 2 $TAG" \
  --notes "Job Simulator 2 $TAG. Builds for Linux, Windows and Web." \
  --ref "$CI_COMMIT_SHA" \
  --use-package-registry \
  "$PROJECT_DIR/release-assets"/*
