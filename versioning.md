# Versioning

## Add build

```sh
scripts/semver bump build $(date --utc +%Y%m%dT%H%M%S%Z) $(cat VERSION)
```

## Up versions

```sh
# add build info
scripts/semver bump build $(date --utc +%Y%m%dT%H%M%S%Z) $(cat VERSION)
# up a prerelease version
scripts/semver bump prerel alpha $(cat VERSION)
# release a dev version
scripts/semver bump release  $(cat VERSION)
# up a patch
scripts/semver bump patch  $(cat VERSION)
# up a minor
scripts/semver bump minor  $(cat VERSION)
# up a major
scripts/semver bump major  $(cat VERSION)
```
