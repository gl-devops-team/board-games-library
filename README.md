# Board Games Library

PoC project for DevOps in GL.

## Features

TODO

## Commit message syntax

Commit message plays pivotal role in Build, Version and Release strategy

DEV's who contribute to this code needs to follow certain syntax while commiting the code.

Syntax for commit:

```git
<type>: short summary in present tense

(optional body: explains motivation for the change)

Issue-ID: gh-<issue id>
```

Ref: <https://py-pkgs.org/07-releasing-versioning.html#automatic-version-bumping>

- "type" - Mandatory
- "Issue-ID" - Mandatory

**type** refers to the kind of change made and is usually one of:

> - feat: A new feature.
> - fix: A bug fix.
> - docs: Documentation changes.
> - style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc).
> - refactor: A code change that neither fixes a bug nor adds a feature.
> - perf: A code change that improves performance.
> - test: Changes to the test framework.
> - build: Changes to the build process or tools.


## Workflow

We are working with Gitflow currently, so we have the following branches:

- **main** - our baseline that is reflected on prod environment
- **develop** - test environment when we merge all newer features, test them properly and then merge to **main**

To add new feature please create a pull request by creating a **feature branch** from **develop** in the following convence:

```git
<feat/fix>/gh-<issue_id>/<optional-short-desc>
```

So it goes like this:

```git
feat/gh-1/repo-structure
```

After proper review and green light from the CI you will be able to merge it into **develop**.
