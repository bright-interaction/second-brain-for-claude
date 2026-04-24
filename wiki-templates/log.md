# Operations Log

Append-only chronological record of every change to the wiki. Format:

```
## [YYYY-MM-DD] verb | summary
Touched: [[page-1]] [[page-2]]
Source: where the info came from (optional)
Notes: anything relevant (optional)
```

---

## [{{TODAY}}] init | {{WIKI_NAME}} scaffold created for {{PROJECT_NAME}}
Touched: [[{{PROJECT_NAME}}]] [[index]]
Source: second-brain-for-claude setup script
Notes: Initial wiki created. Entity page populated from project README and root structure.
