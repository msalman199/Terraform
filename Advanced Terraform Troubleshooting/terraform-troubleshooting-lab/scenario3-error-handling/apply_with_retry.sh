#!/bin/bash
set -o pipefail

MAX_RETRIES=3
RETRY_DELAY=5
attempt=1

while [ $attempt -le $MAX_RETRIES ]; do
  echo "Attempt $attempt of $MAX_RETRIES"
  if terraform apply -auto-approve 2>&1 | tee -a terraform-apply.log; then
    echo "Apply succeeded on attempt $attempt"
    exit 0
  fi
  echo "Apply failed on attempt $attempt"
  attempt=$((attempt + 1))
  if [ $attempt -le $MAX_RETRIES ]; then
    echo "Waiting ${RETRY_DELAY}s before retry..."
    sleep $RETRY_DELAY
  fi
done

echo "Apply failed after $MAX_RETRIES attempts. See terraform-apply.log for details."
exit 1
