#!/usr/bin/env zsh
# Tokenator / Claude Code session switcher for Skaro
# Usage: source tokenator-session.sh

echo ""
echo "╔══════════════════════════════════════╗"
echo "║        Skaro Session Setup           ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "Выберите режим:"
echo "  1) Tokenator (API ключ)"
echo "  2) Claude Code (аккаунт)"
echo ""
print -n "Режим [1/2]: "
read -r MODE < /dev/tty

if [[ "$MODE" == "2" ]]; then
  unset ANTHROPIC_API_KEY
  unset ANTHROPIC_AUTH_TOKEN
  unset ANTHROPIC_BASE_URL
  unset OPENAI_API_KEY
  unset OPENAI_BASE_URL
  unset ANTHROPIC_MODEL
  unset ANTHROPIC_DEFAULT_OPUS_MODEL
  unset ANTHROPIC_DEFAULT_SONNET_MODEL
  unset ANTHROPIC_DEFAULT_HAIKU_MODEL
  unset CLAUDE_CODE_SUBAGENT_MODEL
  unset CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC
  echo ""
  echo "✅ Переключено на Claude Code аккаунт (OAuth)"
  echo ""
  return 0 2>/dev/null || exit 0
fi

if [[ "$MODE" != "1" ]]; then
  echo "❌ Неверный выбор. Выход."
  return 1 2>/dev/null || exit 1
fi

echo ""
echo "Вставьте ваш Tokenator API ключ и нажмите Enter:"
print -n "> "
stty -echo < /dev/tty
read -r TOKENATOR_KEY < /dev/tty
stty echo < /dev/tty
echo ""

TOKENATOR_KEY="${TOKENATOR_KEY//[[:space:]]/}"

if [[ -z "$TOKENATOR_KEY" ]]; then
  echo "❌ Ключ не введён. Выход."
  return 1 2>/dev/null || exit 1
fi

echo "  Ключ: ${TOKENATOR_KEY:0:10}...${TOKENATOR_KEY: -4} (${#TOKENATOR_KEY} символов)"

export ANTHROPIC_API_KEY="$TOKENATOR_KEY"
export ANTHROPIC_AUTH_TOKEN="$TOKENATOR_KEY"
export ANTHROPIC_BASE_URL="https://api.tokenator.top/anthropic"
export OPENAI_API_KEY="$TOKENATOR_KEY"
export OPENAI_BASE_URL="https://api.tokenator.top/v1"
export ANTHROPIC_MODEL="claude-opus-4-7"
export ANTHROPIC_DEFAULT_OPUS_MODEL="claude-opus-4-7"
export ANTHROPIC_DEFAULT_SONNET_MODEL="claude-sonnet-4-6"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="claude-haiku-4-5"
export CLAUDE_CODE_SUBAGENT_MODEL="claude-sonnet-4-6"
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC="0"

SKARO_CONFIG="/Volumes/AI-DevTools/01_projects/VReader/.skaro/config.yaml"
if [[ -f "$SKARO_CONFIG" ]]; then
  sed -i '' "s|api_key_env:.*|api_key_env: ANTHROPIC_API_KEY|g" "$SKARO_CONFIG"
  if grep -q "base_url:" "$SKARO_CONFIG"; then
    sed -i '' "s|base_url:.*|base_url: https://api.tokenator.top/anthropic|g" "$SKARO_CONFIG"
  else
    echo "base_url: https://api.tokenator.top/anthropic" >> "$SKARO_CONFIG"
  fi
  echo "  Skaro config обновлён"
fi

echo "✅ Tokenator активирован"
echo "   Anthropic → https://api.tokenator.top/anthropic"
echo "   OpenAI    → https://api.tokenator.top/v1"
echo ""
echo "🚀 Запускаю skaro ui..."
echo ""
skaro ui