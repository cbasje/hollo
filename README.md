<picture>
  <source srcset="logo-white.svg" media="(prefers-color-scheme: dark)">
  <img src="logo.svg" width="50" height="50">
</picture>

# Hollo

[![Official Hollo][Official Hollo badge]][Official Hollo]

> [!NOTE]
> This project is still in the early stage of development. It is not ready for
> production use yet.

Hollo is a federated single-user microblogging software powered by [Fedify].
Although it is for single-user, it is designed to be federated through
[ActivityPub], which means that you can follow and be followed by other users
from other instances, even from other software that supports ActivityPub like
Mastodon, Misskey, and so on.

Hollo does not have its own web interface. Instead, it implements
Mastodon-compatible APIs so that you can integrate it with the most of
the [existing Mastodon clients](#tested-clients).

[Official Hollo]: https://hollo.social/@hollo
[Official Hollo badge]: https://fedi-badge.deno.dev/@hollo@hollo.social/followers.svg
[Fedify]: https://fedify.dev/
[ActivityPub]: https://www.w3.org/TR/activitypub/

## How to deploy

### Docker

The official Docker images are available on [GitHub Packages]:
`ghcr.io/dahlia/hollo`. Besides this image, you need to set up a PostgreSQL
database, Redis and Meilisearch. You can use the following environment variables to configure Hollo:

-   `DATABASE_URL`: The URL of the PostgreSQL database.
-   `REDIS_URL`: The URL of the Redis server.
-   `MEILI_URL`: The host URL of the Meilisearch server.
-   `MEILI_MASTER_KEY`: The API key for the Meilisearch server.
-   `SECRET_KEY`: The secret key for securing the session.
-   `LOG_LEVEL`: The log level for the application. `debug`, `info`, `warning`,
    `error`, and `fatal` are available.
-   `BEHIND_PROXY`: Set this to `true` if Hollo is behind a reverse proxy.

The image exposes the port 3000, so you can run it like this:

```sh
docker run -d -p 3000:3000 \
  -e DATABASE_URL=postgres://user:password@host:port/database \
  -e REDIS_URL=redis://host:port/0 \
  -e MEILI_URL=http://host:7700 \
  -e MEILI_MASTER_KEY=your-master-key \
  -e SECRET_KEY=your-secret-key \
  -e LOG_LEVEL=info \
  -e BEHIND_PROXY=true \
  ghcr.io/dahlia/hollo:latest
```

[GitHub Packages]: https://github.com/dahlia/hollo/pkgs/container/hollo

## Current features and roadmap

-   [x] Logging in
-   [x] Composing a post
-   [x] Editing a post
-   [x] Deleting a post
-   [x] Writing a reply
-   [x] View posts
-   [x] Post visibility
-   [x] Post language
-   [x] Pinned posts
-   [x] Mentions
-   [x] Hashtags
-   [ ] Media attachments
-   [ ] Polls
-   [x] Likes (favorites)
-   [x] Shares (reblogs)
-   [x] Editing profile
-   [x] Deleting account
-   [x] Public timeline
-   [x] Local timeline
-   [ ] Lists
-   [ ] Trends
-   [x] Search
-   [x] Following/unfollowing accounts
-   [x] Following/unfollowing hashtags
-   [ ] Blocking accounts
-   [ ] Blocking domains
-   [ ] Muting accounts
-   [x] Notifications
-   [x] Bookmarks
-   [x] Markers
-   [x] Featured hashtags
-   [ ] Featured accounts

## Tested clients

-   [Elk]
-   [Phanpy] (recommended)
-   [Woolly]

[Elk]: https://elk.zone/
[Phanpy]: https://phanpy.social/
[Woolly]: https://apps.apple.com/us/app/woolly-for-mastodon/id6444360628

## Etymology

The name _Hollo_ is a Korean word _홀로_, which means _alone_ or _solitary_ in
English. It is named so because it is designed to be a single-user software.

<!-- cSpell: ignore Misskey -->
