#!/usr/bin/env bash
# Clone the repo with a repo-scoped write DEPLOY KEY (never a personal token),
# then run the persistent worker as the PRIMARY publisher with a /health
# endpoint on $PORT. Secrets come only from the host's env vars.
set -euo pipefail
: "${GIT_DEPLOY_KEY_B64:?set GIT_DEPLOY_KEY_B64 as base64 of the deploy private key}"
REPO="${KOGOTO_REPO:-Barmms/kogoto-content-engine}"
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo "$GIT_DEPLOY_KEY_B64" | base64 -d > ~/.ssh/id_ed25519 && chmod 600 ~/.ssh/id_ed25519
# GitHub's published SSH host key (pinned; no trust-on-first-use)
echo "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl" > ~/.ssh/known_hosts
export GIT_SSH_COMMAND="ssh -i ~/.ssh/id_ed25519 -o IdentitiesOnly=yes -o StrictHostKeyChecking=yes"
rm -rf /srv/repo
git clone -q "git@github.com:${REPO}.git" /srv/repo
cd /srv/repo
git config user.name "kogoto-social-worker"
git config user.email "noreply@users.noreply.github.com"
git config pull.rebase true
pip install -q -r /srv/repo/requirements.txt   # keep deps in sync with the private repo
export PYTHONPATH=/srv/repo
exec python -m marketing_engine social-worker --git-sync --prepare --poll-seconds 45 --http-port "${PORT:-10000}"
