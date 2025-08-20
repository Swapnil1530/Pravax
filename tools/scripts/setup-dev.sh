#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
cd "$ROOT_DIR"

echo "[Pravax] Dev setup starting..."

command -v docker >/dev/null 2>&1 || { echo "Docker is required. Install Docker and retry."; exit 1; }
if ! docker info >/dev/null 2>&1; then
  echo "Docker daemon not running. Please start Docker and retry."
  exit 1
fi

if ! command -v docker compose >/dev/null 2>&1 && ! command -v docker-compose >/dev/null 2>&1; then
  echo "Docker Compose is required (plugin or standalone). Install and retry."
  exit 1
fi

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm not found; installing locally (corepack)..."
  if command -v corepack >/dev/null 2>&1; then
    corepack enable || true
    corepack prepare pnpm@8.15.5 --activate
  else
    echo "Corepack not available. Install pnpm from https://pnpm.io/installation";
    exit 1
  fi
fi

ENV_FILE=".env"
EXAMPLE_FILE="env.example"
if [[ ! -f "$ENV_FILE" ]]; then
  if [[ -f "$EXAMPLE_FILE" ]]; then
    cp "$EXAMPLE_FILE" "$ENV_FILE"
    echo "Created $ENV_FILE from $EXAMPLE_FILE"
  elif [[ -f ".env.example" ]]; then
    cp .env.example "$ENV_FILE"
    echo "Created $ENV_FILE from .env.example"
  else
    echo "No env example file found; skipping .env creation"
  fi
fi

echo "[Pravax] Installing workspace dependencies with pnpm..."
pnpm install --frozen-lockfile || pnpm install

echo "[Pravax] Starting infrastructure (Postgres, Redis) via Docker Compose..."
if command -v docker compose >/dev/null 2>&1; then
  docker compose up -d
else
  docker-compose up -d
fi

echo "[Pravax] Verifying services..."
sleep 2
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo "[Pravax] Building packages (if needed)..."
pnpm run build || true

echo "[Pravax] Done. You can now run: pnpm run start"
echo "- Web:    http://localhost:${WEB_PORT:-3000}"
echo "- API:    http://localhost:${API_PORT:-3001}"

