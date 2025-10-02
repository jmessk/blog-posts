# Blog Posts

## API

- `GET /api/posts/tags`

    ```json
    [
        {
            "id": "tag1",
            "name": "Tag 1",
            "icon_uri": "https://example.com/icon1.png"
        },
        {
            "id": "tag2",
            "name": "Tag 2",
            "icon_uri": "https://example.com/icon2.png"
        }
    ]
    ```

- `GET /api/posts?category=<category>&tags=<tag>,<tag>`

    ```json
    {
        "tags": [ "tag1", "tag2" ],
        "posts": [
            {
                "post_id": "test-post",
                "title": "Test Post",
                "description": "This is a test post.",
                "tags": [ "tag1", "tag2" ],
                "thumbnail_uri": "https://example.com/thumbnail.jpg",
                "category": "example",
                "created_at": "2023-10-01T12:00:00Z",
                "updated_at": "2023-10-01T12:00:00Z",
                "tags": [
                    {
                        "id": "tag1",
                        "name": "Tag 1",
                        "icon_uri": "https://example.com/icon1.png"
                    },
                    {
                        "id": "tag2",
                        "name": "Tag 2",
                        "icon_uri": "https://example.com/icon2.png"
                    }
                ]
            },
            {
                "post_id": "another-post",
                "title": "Another Post",
                "description": "This is another post.",
                "tags": [ "tag3" ],
                "thumbnail_uri": "https://example.com/thumbnail.jpg",
                "category": "example",
                "created_at": "2023-10-02T12:00:00Z",
                "tags": [
                    {
                        "id": "tag3",
                        "name": "Tag 3",
                        "icon_uri": "https://example.com/icon3.png"
                    }
                ]
            }
        ]
    }
    ```

- `POST /api/posts?category=<category>`: Create new posts.

    Request:

    ```plaintext
    Content-Type: multipart/form-data; boundary=boundary

    --boundary
    Content-Disposition: form-data; name="post"
    Content-Type: application/plaintext

    # New Post
    
    This is new post.
    --boundary
    Content-Disposition: form-data; name="files"; filename="diagram.png"
    Content-Type: image/png

    (binary...)
    --boundary--
    ```

    Response:

    ```json
    {
        "id": "<UUID>", 
        "created_at": "2023-10-01T12:00:00Z",
        "registered_content": "# Test Post\n\nThis is a test post.",
    }
    ```

- `GET /api/posts/<post_id>`

    ```json
    {
        "title": "Test Post",
        "description": "This is a test post.",
        "tags": [ "tag1", "tag2" ],
        "thumbnail_uri": "https://example.com/thumbnail.jpg",
        "category": "example",
        "created_at": "2023-10-01T12:00:00Z",
        "updated_at": "2023-10-01T12:00:00Z",
        "tags": [
            {
                "id": "tag1",
                "name": "Tag 1",
                "icon_uri": "https://example.com/icon1.png"
            },
            {
                "id": "tag2",
                "name": "Tag 2",
                "icon_uri": "https://example.com/icon2.png"
            }
        ]
    }
    ```

- `GET /api/posts/<post_id>?content=true`

    ```json
    {
        "title": "Test Post",
        "description": "This is a test post.",
        "tags": [ "tag1", "tag2" ],
        "thumbnail_uri": "https://example.com/thumbnail.jpg",
        "category": "example",
        "created_at": "2023-10-01T12:00:00Z",
        "updated_at": "2023-10-01T12:00:00Z",
        "content": "# Test Post\n\nThis is a test post.",
        "tags": [
            {
                "id": "tag1",
                "name": "Tag 1",
                "icon_uri": "https://example.com/icon1.png"
            },
            {
                "id": "tag2",
                "name": "Tag 2",
                "icon_uri": "https://example.com/icon2.png"
            }
        ]
    }
    ```

- `GET /api/posts/<post_id>/markdown`

    ```plaintext
    ---
    "title": "Test Post",
    "description": "This is a test post.",
    "tags": [ "tag1", "tag2" ],
    "thumbnail": "https://example.com/thumbnail.jpg"
    "category": "example",
    "created_at": "2023-10-01T12:00:00Z",
    "updated_at": "2023-10-01T12:00:00Z",
    "tags": [ "tag1", "tag2" ]
    ---

    # Test Post

    This is a test post.
    ```

- `UPDATE /api/posts/<post_id>`

    Request:

    ```markdown
    # New Post
    
    This is new post.
    ```

    Response:

    ```json
    {
        "id": "<UUID>",
        "updated_at": "2023-10-01T12:00:00Z",
        "registered_content": "# New Post\n\nThis is new post."
    },
    ```

- `DELETE /api/posts/<post_id>?type=soft|hard`

    Response:

    ```json
    {
        "id": "<UUID>",
        "deleted_at": "2023-10-01T12:00:00Z",
        "delete_type": "soft",
        "post": {
            "id": "<UUID>",
            "title": "Test Post",
            "description": "This is a test post.",
            "tags": [ "tag1", "tag2" ],
            "thumbnail_uri": "https://example.com/thumbnail.jpg",
            "category": "example",
            "created_at": "2023-10-01T12:00:00Z",
            "updated_at": "2023-10-01T12:00:00Z",
            "deleted_at": "2023-10-01T12:00:00Z",
            "tags": [
                {
                    "id": "tag1",
                    "name": "Tag 1",
                    "icon_uri": "https://example.com/icon1.png"
                },
                {
                    "id": "tag2",
                    "name": "Tag 2",
                    "icon_uri": "https://example.com/icon2.png"
                }
            ]
        }
    }
    ```
