---
title: How Auth Works
type: concept
updated: YYYY-MM-DD
links: [[relevant-entity]]
---

# How Auth Works

*Example concept page. Delete and replace with a real one.*

One-sentence version: Users log in via OAuth2 with our identity provider. Sessions are JWT-signed and stored in an HTTP-only cookie.

## The flow

1. User hits `/login`, gets redirected to identity provider
2. Identity provider returns with an authorization code
3. Backend exchanges code for tokens
4. Backend sets session cookie, redirects user to app

## Why this way

Single sign-on for employees. JWT because we wanted stateless sessions without a central session store.

## Gotchas

- Token refresh is handled client-side. If your PR touches the refresh flow, read the entity page for the auth service first.
- The `X-Forwarded-For` header is only trusted from the reverse proxy. Direct hits from the internet will fail validation.
