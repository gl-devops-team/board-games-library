# Board Games Library

PoC project for DevOps in GL.

## How to play with it locally

To participate in development with this repository you need to download it via git:

```git
git pull git@github.com:gl-devops-team/board-games-library.git
```

or

```git
git pull git@github.com:gl-devops-team/board-games-library.git
```

To use all current addons like PyTest or Ruff please use `requirements-dev` file as a dependencies list for `pip`:

```git
virtualenv venv
source venv/bin/activate
pip install -r requirements-dev.txt
```

The `requirements.txt` file is only for production and it's reduced to only required dependencies for running the application.

Other documentation files you can find in [docs folder](https://github.com/gl-devops-team/board-games-library/tree/main/docs).

## Repo features

This repository uses various tools to help developers contribute high-quality code. The list is below:

> - **Django** – high-level Python web framework powering the web application layer
> - **Pre-commit** – Git hook manager that automatically runs code quality checks before each commit  
> - **PyTest** – unit testing framework  
> - **Ruff** – fast Python linter and formatter

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
