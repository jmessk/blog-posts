#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
env_file="${script_dir}/.env"

if [[ -f "$env_file" ]]; then
	set -a
	# shellcheck disable=SC1090
	source "$env_file"
	set +a
fi

if [[ $# -lt 2 || $# -gt 3 ]]; then
	echo "Usage: publish_post.bash <post-directory> <category> [token]" >&2
	exit 1
fi

if [[ -z "${BLOG_API_BASE_URL:-}" ]]; then
	echo "BLOG_API_BASE_URL is required." >&2
	exit 1
fi

post_path="$1"
category="$2"
auth_token="${3:-${BLOG_API_TOKEN:-}}"

if [[ ! -d "$post_path" ]]; then
	echo "Directory not found: $post_path" >&2
	exit 1
fi

markdown_file="$(find "$post_path" -maxdepth 1 -type f -name '*.md' -print -quit)"

if [[ -z "$markdown_file" ]]; then
	echo "Markdown file not found in $post_path" >&2
	exit 1
fi

if [[ -f "$post_path/id" ]]; then
	echo "id file already exists in $post_path. Use update script instead." >&2
	exit 1
fi

api_base="${BLOG_API_BASE_URL%/}"
endpoint="${api_base}/api/posts?category=${category}"

declare -a curl_args
curl_args+=(--silent --show-error)
curl_args+=(--request POST)
curl_args+=(--header "Accept: application/json")
curl_args+=(--form "content=<${markdown_file};type=text/markdown;filename=$(basename "$markdown_file")")

if [[ -n "$auth_token" ]]; then
	curl_args+=(--header "Authorization: Bearer ${auth_token}")
fi

while IFS= read -r -d '' asset; do
	filename="${asset##*/}"
	if [[ "$filename" == "id" ]]; then
		continue
	fi

	rel_path="${asset#$post_path/}"
	curl_args+=(--form "files=@${asset};filename=${rel_path}")
done < <(find "$post_path" -maxdepth 1 -type f ! -name '*.md' ! -name 'id' -print0)

response_with_status="$(curl "${curl_args[@]}" --write-out 'HTTPSTATUS:%{http_code}' "$endpoint")"

http_status="${response_with_status##*HTTPSTATUS:}"
response_body="${response_with_status%HTTPSTATUS:*}"

if [[ "$http_status" -lt 200 || "$http_status" -ge 300 ]]; then
	echo "Request failed (status $http_status)" >&2
	if [[ -n "$response_body" ]]; then
		echo "$response_body" >&2
	fi
	exit 1
fi

post_id="$(jq -r '.id // empty' <<<"$response_body")"

if [[ -z "$post_id" ]]; then
	echo "Failed to get post id." >&2
	echo "$response_body" >&2
	exit 1
fi

printf '%s\n' "$post_id" >"$post_path/id"
echo "Post created with id: $post_id"
