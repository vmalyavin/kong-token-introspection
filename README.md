# Kong access token introspection plugin
Simple kong plugin to use any custom jwt access token introspection, as API auth.
Inspired by [mogui/kong-external-oauth](https://github.com/mogui/kong-external-oauth)

# How it works
Plugin is protecting Kong API service/route with introspection of Oauth2.0 JWT access-token, added to request header. Plugin does a pre-request to oauth introspection endpoint([RFC7662](https://tools.ietf.org/html/rfc7662#section-2)).

# Configuration


| Form Parameter | default | description |
| --- 						| --- | --- |
| `config.introspection_endpoint`   | | External introspection endpoint compatible with RFC7662 |
| `config.token_header`             | Authorization | Name of api-request header containing access token |
| `config.token_cache_time`             | 0 | Cache TTL for every token introspection result(0 - no cache) |
| `config.scope`             |  | Scope that token need to get allowed to this method. For example 'manage-profile'. Allow any scope if empty |