#!/usr/bin/env bash
# ============================================================
# update-rules.sh —— 从上游 blackmatrix7 重新拉取规则集，
#   镜像到本仓库 rules/<分类>/<分类>.list（自托管，避免上游改名/删库）。
# 用法: bash scripts/update-rules.sh
# 更新后需手动: git add rules && git commit -m "update rules" && git push
#   （jsdelivr 缓存有 TTL，推送后最长约 24h 生效，可在 jsdelivr 官网 purge 加速）
# ============================================================
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULES_DIR="$REPO_DIR/rules"
UP="https://cdn.jsdelivr.net/gh/blackmatrix7/ios_rule_script@master/rule/Shadowrocket"

# 需要镜像的分类（与 config/shcode.conf 中引用保持一致）
CATS=(Lan Netflix Disney HBO Spotify Twitter Instagram Facebook Threads \
      GitHub Microsoft Docker TikTok Privacy AdvertisingLite Telegram \
      Global ChinaMax YouTube)

mkdir -p "$RULES_DIR"

if command -v aria2c >/dev/null 2>&1; then
  tmp="$(mktemp)"
  for c in "${CATS[@]}"; do
    mkdir -p "$RULES_DIR/$c"
    {
      echo "$UP/$c/$c.list"
      echo "  dir=$RULES_DIR/$c"
      echo "  out=$c.list"
    } >> "$tmp"
  done
  aria2c -i "$tmp" --allow-overwrite=true --auto-file-renaming=false \
    -j8 -x4 --max-tries=3 --connect-timeout=20 --timeout=30 \
    --console-log-level=warn --summary-interval=0
  rm -f "$tmp"
else
  # 回退: curl 逐个下载
  for c in "${CATS[@]}"; do
    mkdir -p "$RULES_DIR/$c"
    echo "下载 $c ..."
    curl -fsSL "$UP/$c/$c.list" -o "$RULES_DIR/$c/$c.list"
  done
fi

echo "完成。共 ${#CATS[@]} 个规则集已更新到 $RULES_DIR"
echo "下一步: git add rules && git commit -m 'update rules' && git push"
