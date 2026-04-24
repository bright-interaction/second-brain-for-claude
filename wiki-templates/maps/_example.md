---
title: Infrastructure Overview
type: map
updated: YYYY-MM-DD
links:
---

# Infrastructure Overview

*Example map page. Delete and replace with a real one once you have more than one entity worth mapping.*

The big-picture view of how our services fit together.

## The picture

```
Internet
    |
    v
Reverse proxy (Caddy / Nginx / whatever)
    |
    +--> Web frontend ([[web-frontend]])
    +--> API ([[api-service]])
    |        |
    |        +--> PostgreSQL
    |        +--> Redis
    +--> Background workers ([[workers]])
```

## What changed recently

- YYYY-MM-DD: migrated from X to Y, see [[entity-that-changed]]
