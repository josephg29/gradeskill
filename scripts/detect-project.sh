#!/usr/bin/env bash
#
# detect-project.sh — figure out how to run / understand a project before grading.
#
# Prints a set of KEY=VALUE lines to stdout so the grader (and humans) can see
# exactly what was detected. Never fails the whole run: if something can't be
# determined it reports "unknown" and moves on.
#
# Usage:
#   scripts/detect-project.sh [project-dir]   # defaults to current directory
#
# Output keys:
#   STACK            node | python | rust | go | static | unknown
#   PACKAGE_MANAGER  npm | pnpm | yarn | bun | pip | poetry | cargo | go | none
#   DEV_COMMAND      the best-guess command to start a dev server, or "none"
#   DEV_SCRIPT       the package.json script name used (node only), or ""
#   HAS_DOCKER       yes | no
#   RUNNABLE         yes | no   (whether we found any way to start the app)

set -uo pipefail

DIR="${1:-.}"
cd "$DIR" 2>/dev/null || { echo "STACK=unknown"; echo "RUNNABLE=no"; exit 0; }

stack="unknown"
pm="none"
dev_command="none"
dev_script=""
has_docker="no"

[ -f "Dockerfile" ] || [ -f "docker-compose.yml" ] || [ -f "compose.yaml" ] && has_docker="yes"

read_json_script() {
  # $1 = script name. Echoes the script body if present in package.json.
  node -e '
    try {
      const p = require("./package.json");
      const s = (p.scripts || {})[process.argv[1]];
      if (s) process.stdout.write(s);
    } catch (e) {}
  ' "$1" 2>/dev/null
}

if [ -f "package.json" ]; then
  stack="node"
  # Package manager: prefer lockfile evidence, then packageManager field.
  if [ -f "pnpm-lock.yaml" ]; then pm="pnpm"
  elif [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then pm="bun"
  elif [ -f "yarn.lock" ]; then pm="yarn"
  elif [ -f "package-lock.json" ]; then pm="npm"
  else
    case "$(node -e 'try{process.stdout.write((require("./package.json").packageManager)||"")}catch(e){}' 2>/dev/null)" in
      pnpm*) pm="pnpm" ;; yarn*) pm="yarn" ;; bun*) pm="bun" ;; *) pm="npm" ;;
    esac
  fi

  # Pick the dev script: dev > start > serve > develop.
  for candidate in dev start serve develop; do
    if [ -n "$(read_json_script "$candidate")" ]; then
      dev_script="$candidate"
      break
    fi
  done

  if [ -n "$dev_script" ]; then
    case "$pm" in
      npm)  dev_command="npm run $dev_script" ;;
      pnpm) dev_command="pnpm $dev_script" ;;
      yarn) dev_command="yarn $dev_script" ;;
      bun)  dev_command="bun run $dev_script" ;;
    esac
  fi

elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "manage.py" ]; then
  stack="python"
  if [ -f "poetry.lock" ] || grep -q "\[tool.poetry\]" pyproject.toml 2>/dev/null; then pm="poetry"; else pm="pip"; fi
  if [ -f "manage.py" ]; then
    dev_command="python manage.py runserver"
  elif grep -rsq "fastapi" requirements.txt pyproject.toml 2>/dev/null; then
    dev_command="uvicorn main:app --reload   # adjust module:app as needed"
  elif grep -rsq "flask" requirements.txt pyproject.toml 2>/dev/null; then
    dev_command="flask run"
  fi

elif [ -f "Cargo.toml" ]; then
  stack="rust"; pm="cargo"; dev_command="cargo run"

elif [ -f "go.mod" ]; then
  stack="go"; pm="go"; dev_command="go run ."

elif [ -f "index.html" ]; then
  stack="static"; pm="none"; dev_command="npx --yes serve ."
fi

runnable="no"
[ "$dev_command" != "none" ] && runnable="yes"

echo "STACK=$stack"
echo "PACKAGE_MANAGER=$pm"
echo "DEV_COMMAND=$dev_command"
echo "DEV_SCRIPT=$dev_script"
echo "HAS_DOCKER=$has_docker"
echo "RUNNABLE=$runnable"
