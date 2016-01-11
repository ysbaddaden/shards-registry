# Registry API

**Status:** the API is a work in progress and is likely to evolve, change or
break until further notice.

The API is versioned and accessible on `#PROTOCOL#://#HOSTNAME#/api/v1`. It only
accepts and responds with `application/json` serialized data.


## Authorization

While some API calls are public (eg: searching for shards), some other API calls
require an API key. The key must be specified as the `X-Api-Key` HTTP header.
When the API key is missing or invalid but required to execute the operation, a
401 HTTP status code will be returned.

Please see your profile page to retrieve the key. Alternatively you may retrieve
it using an API call with your user credentials. See below.


## Users API

### `GET /api/v1/users/api_key`

You may retrieve your API key using HTTP basic auth:

```
$ curl #PROTOCOL#://julien:secret@#HOSTNAME#/api/users/api_key
```

If credentials are wrong, a 401 HTTP status is returned. If correct, a 200 HTTP
status is returned with the following JSON:
```json
{
  "api_key": "dxYLm6pl0uHdyTLWtDTiccnr9myk9RUvJ26v3Q3d2zE"
}
```


### `POST /api/v1/users`

Create a user on the registry. Takes the following params as a JSON hash:

- `name` - the username of the user, must only contain ASCII chars, digits,
  dashes or underscores (required, must be unique);
- `email` - the email of the user, must only contain ASCII chars, digits,
  dashes or underscores (required, must be unique);
- `password` - the password of the user (required).

For example:

```
$ curl
curl "#PROTOCOL#://#HOSTNAME#/api/v1/users" \
  -H "Content-Type: application/json" \
  -d '{"name":"julien","password":"secret","email":"julien@example.org"}'
```

On success a 201 HTTP status is returned with an empty body. Otherwise a 422
HTTP status is returned along with a JSON like:

```json
[
  "name is required",
  "email conflict",
]
```


### `PATCH /api/v1/users/:name`

Updates a user on the registry. Takes any of the create user params as a JSON
hash. For example:

```
$ curl "#PROTOCOL#://#HOSTNAME#/api/v1/users/julien" \
  -H "X-Api-Key: dxYLm6pl0uHdyTLWtDTiccnr9myk9RUvJ26v3Q3d2zE" \
  -H "Content-Type: application/json" \
  -d '{"password":"sekret"}'
```

On success a 204 HTTP status is returned with an empty body. Otherwise a 422
HTTP status is returned with a JSON array of error messages.


## Shards API

### `GET /api/v1/shards/search?query=:query`

Search shards on the registry whose name starts with `:query`. Only the 50 first
matching shards will always be returned. For example:

```
$ curl "#PROTOCOL#://#HOSTNAME#/api/v1/shards/search?query=s" \
```

This will return a 200 HTTP status with the following JSON body:

```json
[
  {
    "name": "shards",
    "url":"https://github.com/ysbaddaden/shards.git"
  },
  {
    "name": "selenium-webdriver",
    "url":"https://github.com/ysbaddaden/selenium-webdriver-crystal.git"
  }
]
```


### `GET /api/v1/shards/:name`

Returns information about the shard named `:name`. For example:

```
$ curl "#PROTOCOL#://#HOSTNAME#/api/v1/shards/minitest"
```

If the shard is found, a 200 HTTP status is returned with the following JSON body:

```json
{
  "name": "minitest",
  "url":"https://github.com/ysbaddaden/minitest.cr.git"
}
```


### `GET /api/v1/shards/:name/versions`

Returns all available versions for a shard. For example:

```
$ curl "#PROTOCOL#://#HOSTNAME#/api/v1/shards/minitest/versions"
```

```json
[
  {
    "version":"0.2.0",
    "released_at":"2015-12-13T01:01:40.000Z"
  },
  {
    "version":"0.1.5",
    "released_at":"2015-09-22T00:36:37.000Z"
  },
  {
    "version":"0.1.4",
    "released_at":"2015-09-19T17:29:46.000Z"
  }
]
```


### `GET /api/v1/shards/:name/versions/latest`

Returns the latest available version for a shard.

```
$ curl "#PROTOCOL#://#HOSTNAME#/api/v1/shards/minitest/versions/latest"
```

```json
{
  "version":"0.2.0",
  "released_at":"2015-12-13T01:01:40.000Z"
}
```


### `POST /api/v1/shards`

Registers a shard on the registry. Takes a single param as a JSON hash:

- `url` - the public URL of the Git repository where the shard is hosted.

The Git repository is expected to have a valid `shard.yml` at its root. The
registry will clone the repository, extract the version tags (eg: `v0.1.0`) and
any `README.md` file found for these tags.

For example:

```
$ curl "#PROTOCOL#://#HOSTNAME#/api/v1/shards" \
  -H "X-Api-Key: dxYLm6pl0uHdyTLWtDTiccnr9myk9RUvJ26v3Q3d2zE" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://github.com/manastech/webmock.git"}'
```

On success a 201 HTTP status is returned with th following body:

```json
{
  "name": "webmock",
  "url":"https://github.com/manastech/webmock.git"
}
```

Otherwise a 422 HTTP status is returned with a JSON array of error messages.


### `DELETE /api/v1/shards/:name`

Unregisters a shard from the registry. For example:

```
$ curl "#PROTOCOL#://#HOSTNAME#/api/v1/shards/minitest" \
  -H "X-Api-Key: dxYLm6pl0uHdyTLWtDTiccnr9myk9RUvJ26v3Q3d2zE" \
  -X DELETE
```

On success a 204 HTTP status is returned with an empty body.
