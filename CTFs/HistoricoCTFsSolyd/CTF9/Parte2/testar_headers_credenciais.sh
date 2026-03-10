#!/bin/bash
# Testa headers de rede interna e credenciais da Parte 1 no alvo Parte 2
# Uso: ./testar_headers_credenciais.sh [IP]
# Se não passar IP, usa 23.21.16.51

IP="${1:-23.21.16.51}"
BASE="http://$IP"
HOST="Host: projects-blogo.sy"
SENHA="WPcmqw16ZmzO!5paSC4"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$SCRIPT_DIR/resultados_tests_headers"
mkdir -p "$OUT"

size_of() { wc -c < "$1" 2>/dev/null || echo 0; }

echo "=== Alvo: $IP (Host: projects-blogo.sy) ==="
echo ""

CURL_OPTS="-s --connect-timeout 5 --max-time 10"

# 1) Baseline (sem header extra)
echo "[1] Baseline (só Host)"
curl $CURL_OPTS -H "$HOST" "$BASE/" -o "$OUT/baseline.html"
echo "  Tamanho: $(size_of "$OUT/baseline.html") bytes"

# 2) Headers de IP interno (simular origem da rede interna)
echo "[2] X-Forwarded-For: 10.0.2.10"
curl $CURL_OPTS -H "$HOST" -H "X-Forwarded-For: 10.0.2.10" "$BASE/" -o "$OUT/x_forwarded.html"
echo "  Tamanho: $(size_of "$OUT/x_forwarded.html") bytes"

echo "[3] X-Real-IP: 10.0.2.10"
curl $CURL_OPTS -H "$HOST" -H "X-Real-IP: 10.0.2.10" "$BASE/" -o "$OUT/x_realip.html"
echo "  Tamanho: $(size_of "$OUT/x_realip.html") bytes"

echo "[4] X-Originating-IP: 10.0.2.10"
curl $CURL_OPTS -H "$HOST" -H "X-Originating-IP: 10.0.2.10" "$BASE/" -o "$OUT/x_originating.html"
echo "  Tamanho: $(size_of "$OUT/x_originating.html") bytes"

echo "[5] X-Forwarded-For: 127.0.0.1"
curl $CURL_OPTS -H "$HOST" -H "X-Forwarded-For: 127.0.0.1" "$BASE/" -o "$OUT/x_forwarded_127.html"
echo "  Tamanho: $(size_of "$OUT/x_forwarded_127.html") bytes"

# 3) Basic Auth (credenciais Parte 1)
echo "[6] Basic Auth adalberto"
curl $CURL_OPTS -H "$HOST" -u "adalberto:$SENHA" "$BASE/" -o "$OUT/basic_adalberto.html"
echo "  Tamanho: $(size_of "$OUT/basic_adalberto.html") bytes | HTTP: $(curl $CURL_OPTS -o /dev/null -w '%{http_code}' -H "$HOST" -u "adalberto:$SENHA" "$BASE/")"

echo "[7] Basic Auth blogodb"
curl $CURL_OPTS -H "$HOST" -u "blogodb:$SENHA" "$BASE/" -o "$OUT/basic_blogodb.html"
echo "  Tamanho: $(size_of "$OUT/basic_blogodb.html") bytes | HTTP: $(curl $CURL_OPTS -o /dev/null -w '%{http_code}' -H "$HOST" -u "blogodb:$SENHA" "$BASE/")"

# 4) Headers customizados (token / interno)
echo "[8] X-TI-Token (senha)"
curl $CURL_OPTS -H "$HOST" -H "X-TI-Token: $SENHA" "$BASE/" -o "$OUT/x_ti_token.html"
echo "  Tamanho: $(size_of "$OUT/x_ti_token.html") bytes"

echo "[9] X-Internal: true"
curl $CURL_OPTS -H "$HOST" -H "X-Internal: true" "$BASE/" -o "$OUT/x_internal.html"
echo "  Tamanho: $(size_of "$OUT/x_internal.html") bytes"

echo "[10] X-Blogo-Internal: 10.0.2.10"
curl $CURL_OPTS -H "$HOST" -H "X-Blogo-Internal: 10.0.2.10" "$BASE/" -o "$OUT/x_blogo_internal.html"
echo "  Tamanho: $(size_of "$OUT/x_blogo_internal.html") bytes"

echo "[11] X-Forwarded-For + X-Real-IP (10.0.2.10)"
curl $CURL_OPTS -H "$HOST" -H "X-Forwarded-For: 10.0.2.10" -H "X-Real-IP: 10.0.2.10" "$BASE/" -o "$OUT/combo_10.html"
echo "  Tamanho: $(size_of "$OUT/combo_10.html") bytes"

echo ""
BASELINE=$(size_of "$OUT/baseline.html")
echo "=== Resumo: respostas com tamanho DIFERENTE do baseline ($BASELINE bytes) ==="
for f in "$OUT"/*.html; do
  [ -f "$f" ] || continue
  n=$(size_of "$f")
  if [ "$n" -ne "$BASELINE" ] 2>/dev/null; then
    echo "  DIFERENTE: $f -> $n bytes"
  fi
done

echo ""
echo "=== Conteúdo diferente do baseline? (diff) ==="
for f in "$OUT"/x_forwarded.html "$OUT"/x_realip.html "$OUT"/basic_adalberto.html "$OUT"/basic_blogodb.html "$OUT"/x_ti_token.html "$OUT"/x_internal.html; do
  if [ -f "$f" ] && ! diff -q "$OUT/baseline.html" "$f" >/dev/null 2>&1; then
    echo "  SIM: $(basename "$f")"
  fi
done

echo ""
echo "Arquivos em: $OUT"
