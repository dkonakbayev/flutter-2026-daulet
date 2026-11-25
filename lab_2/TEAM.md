# Team

Lab 2 is done by one person: **Daulet** (GitHub `dkonakbayev`). There is no
partner, so every area has one owner and no second reviewer.

## Owners

| Area | Owner | Reviewer |
| --- | --- | --- |
| `lib/features/countries/` (catalogue: model, repositories, notifier, screens) | Daulet | — (solo) |
| `lib/features/trips/` (collection: model, repositories, notifier, form, screens) | Daulet | — (solo) |
| `lib/features/account/` (login, settings, profile photo, about) | Daulet | — (solo) |
| `lib/core/api/` (ApiClient, sealed ApiException) | Daulet | — (solo) |
| `lib/core/storage/`, `lib/core/env.dart` | Daulet | — (solo) |
| `lib/core/routes/`, `lib/core/widgets/`, `lib/core/format/` | Daulet | — (solo) |
| `test/` (mirrors `lib/`) | Daulet | — (solo) |
| Release (signing, icon, splash, APK, GitHub Releases) | Daulet | — (solo) |

## Backend

- **Catalogue:** REST Countries v5 — `https://api.restcountries.com/countries/v5` (free API key, kept in the gitignored `env/keys.json`)
- **Collection:** MockAPI.io, resource `trips` — `https://<project-id>.mockapi.io/api/v1/trips`
  (the host is `HOST` in `env/prod.json`, passed with `--dart-define-from-file`)

## Workflow

- Branches are named `feature/<name>`; each one goes to `main` through a pull request.
- Working alone, I open and merge my own pull requests; the PR list is still the history.
- Commit messages name the change (`add offline cache for countries`), never `fix`, `wip`, `final`.

## Contributions

Paste the output of `git shortlog -sn` here on the day of the defence:

```
(git shortlog -sn -- lab_2)
```

## Decisions

1. One `ApiClient` per host (REST Countries, MockAPI), both built in `main.dart`. — Daulet
2. Only the MockAPI client gets the `SecureStore`, so the token never goes to a public API. — Daulet
3. `ApiClient` returns decoded JSON, so `package:http` stays in `core/api`. — Daulet
4. Sealed `ApiException` with six subclasses in `part` files, one class per file. — Daulet
5. After every create / update / delete the trips list is reloaded from the server. — Daulet
6. REST Countries' 404 on a name search is shown as the empty state, not an error. — Daulet
7. The offline cache lives in the documents directory, never in the temporary one. — Daulet
8. REST Countries v3.1 was shut down; the catalogue uses v5 with an API key that never goes into git. — Daulet
9. Sign-in is fake (`FakeAuthRepository`, demo password `travel123`): the course has no auth server. — Daulet
