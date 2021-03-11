# Kong access token introspection plugin

Simple kong plugin to use any custom jwt access token introspection, as API auth.
Inspired by [mogui/kong-external-oauth](https://github.com/mogui/kong-external-oauth)

## How it works

Plugin is protecting Kong API service/route with introspection of Oauth2.0 JWT access-token, added to request header. Plugin does a pre-request to oauth introspection endpoint([RFC7662](https://tools.ietf.org/html/rfc7662#section-2)).

## Configuration

| Form Parameter                  | default       | description                                                                                                            |
| ------------------------------- | ------------- | ---------------------------------------------------------------------------------------------------------------------- |
| `config.introspection_endpoint` |               | **Required**. External introspection endpoint compatible with RFC7662                                                  |
| `config.client_id`              |               | **Required**. Client ID                                                                                                |
| `config.client_secret`          |               | **Required**. Client secret                                                                                            |
| `config.token_header`           | Authorization | Name of api-request header containing access token                                                                     |
| `config.keep_token_header`      | false         | Keep the token_header in the proxied request                                                                           |
| `config.token_query`            | token         | Name of query parameter containing access token, only if `token_header` value was missing                              |
| `config.require_success`        | true          | Require a successful introspection before proxying the request, if false `token_header` existance will not be required |
| `config.token_cache_time`       | 0             | Cache TTL for every token introspection result(0 - no cache)                                                           |
| `config.introspection_map`      |               | External introspection response `body` and `headers` mapped to request headers, also `static` for fixed strings        |

## How to install

**1.1.0** `luarocks install https://raw.githubusercontent.com/medwing/kong-token-introspection/v1.1.0/access-token-introspection-1.1.0-0.rockspec`

**1.1.1** `luarocks install https://raw.githubusercontent.com/medwing/kong-token-introspection/v1.1.1/access-token-introspection-1.1.1-0.rockspec`

**1.2.0** `luarocks install https://raw.githubusercontent.com/medwing/kong-token-introspection/v1.2.0/access-token-introspection-1.2.0-0.rockspec`
