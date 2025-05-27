export READY_MSG="Application startup complete"
export GENERATE_LOG="vllm_generate.log"

while [ ! -f "$GENERATE_LOG" ]; do
  echo "Waiting for vLLM generate server to start..."
  sleep 1
done

# Continuously check the log for the ready message
while ! grep -q "$READY_MSG" "$GENERATE_LOG"; do
  echo "Waiting for vLLM generate server to be ready..."
  cat "$GENERATE_LOG"
  sleep 1
done

echo finished!