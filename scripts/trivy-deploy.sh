#!/bin/bash

ECR_REPO="$1"
IMAGE_TAG="$2"
REPO_URL="$3"
REGION="$4"
FUNCTION_NAME="$5"
SCAN_ID="$6"

IMAGE_NAME="${ECR_REPO}:${IMAGE_TAG}"

echo "🛠️ Docker 이미지 빌드 및 태깅 중..."
docker build -t webgoat:$IMAGE_TAG .
docker tag webgoat:$IMAGE_TAG $IMAGE_NAME

echo "🔐 ECR 로그인 중..."
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$ECR_REPO"

echo "📤 Docker 이미지 푸시 중..."
docker push $IMAGE_NAME

echo "📡 Lambda 호출 JSON 생성 중..."
jq -n \
  --arg image "$IMAGE_NAME" \
  --arg repo "$REPO_URL" \
  --arg scan_id "$SCAN_ID" \
  '{image: $image, repo: $repo, scan_id: $scan_id}' > lambda-payload.json

echo "🚀 Lambda 호출 시작..."
aws lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --region "$REGION" \
  --cli-binary-format raw-in-base64-out \
  --payload file://lambda-payload.json \
  lambda-response.json

echo "✅ Lambda 호출 완료: scan_id=$SCAN_ID"
