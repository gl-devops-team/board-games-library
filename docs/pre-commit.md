# Pre-Commit

## Table of contents

- [Pre-Commit](#pre-commit)
  - [Table of contents](#table-of-contents)
  - [What is pre-commit?](#what-is-pre-commit)
  - [Pre-commit (Ruff) – local code quality checks](#pre-commit-ruff--local-code-quality-checks)
  - [Installation](#installation)
    - [Prerequisites](#prerequisites)
    - [Install dependencies](#install-dependencies)
    - [Install Git hooks](#install-git-hooks)
  - [How it works](#how-it-works)
  - [Typical workflow](#typical-workflow)
  - [Examples of Ruff output in pre-commit](#examples-of-ruff-output-in-pre-commit)
    - [Example 1: Lint error (unused import)](#example-1-lint-error-unused-import)
    - [Example 2: Formatting mismatch](#example-2-formatting-mismatch)
  - [Troubleshooting](#troubleshooting)
    - [“(no files to check) Skipped”](#no-files-to-check-skipped)
    - [Bypass hooks (not recommended)](#bypass-hooks-not-recommended)
  - [Using Ruff manually](#using-ruff-manually)
  - [Ruff linter](#ruff-linter)
    - [Concise output format](#concise-output-format)
    - [Grouped output format (default in pre-commit)](#grouped-output-format-default-in-pre-commit)
    - [Github output format (default in CI)](#github-output-format-default-in-ci)
  - [Ruff formatter](#ruff-formatter)

## What is pre-commit?

**Pre-commit** is a framework for managing Git hooks.

It allows us to automatically run code quality checks before every commit.  
This ensures that:

- improperly formatted code is not committed,
- common mistakes are caught early,
- the repository remains consistent and clean.

In this project, pre-commit runs **Ruff** (linter + formatter) locally before changes are committed.

## Pre-commit (Ruff) – local code quality checks

This repository uses **pre-commit** to run **Ruff** (linter + formatter) automatically before each commit.

If checks fail:

- the commit is blocked,
- you’ll see actionable messages with file names and line numbers.

## Installation

### Prerequisites

- `Python` installed (recommended: 3.12)
- `pip` available
- A virtual environment is recommended

### Install dependencies

Install dev dependencies (including `pre-commit` and `ruff`):

```git
pip install -r requirements-dev.txt
```

### Install Git hooks

From the repository root, run:

```git
pre-commit install
```

This creates a Git hook under `.git/hooks/pre-commit`.
From now on, every `git commit` will run the configured checks.

## How it works

On `git commit`, pre-commit runs:

1. **Ruff lint** – `ruff check` - Detects code issues (unused imports, common bugs, import sorting, etc.)
2. **Ruff formatter check** – `ruff format --check` - Verifies formatting without modifying files (commit is blocked if formatting differs)

Only staged files (`git add ...`) are checked by default.

## Typical workflow

1. Make changes
2. Stage files:

    ```git
    git add .
    ```

3. Commit:

    ```git
    git commit -m "feat: add list view"
    ```

If everything is OK, the commit will proceed normally.

## Examples of Ruff output in pre-commit

### Example 1: Lint error (unused import)

You may see something like:

```git
ruff check..........................................................Failed
app/src/games/utils.py:1:1: F401 `os` imported but unused
Found 1 error.
```

Fix: remove the unused import (or use it).

### Example 2: Formatting mismatch

If formatting is not compliant:

```git
ruff format.........................................................Failed
Would reformat: app/src/games/views.py
1 file would be reformatted.
```

Fix: run the formatter locally:

```git
ruff format .
```

or make the changes manually. Then stage and commit again:

```git
git add .
git commit -m "chore: format code"
```

## Troubleshooting

### “(no files to check) Skipped”

This usually means either:

- you didn’t stage any Python files (`git add ...`), or
- the commit contains only non-Python files (e.g., README changes)

You can confirm what is staged with:

```git
git status
```

### Bypass hooks (not recommended)

You can skip pre-commit hooks with:

```git
git commit --no-verify
```

CI will still run the same checks, so skipping hooks usually results in a failing pipeline.

----

## Using Ruff manually

Each developer can use Ruff manually by providing the specific commands with proper flags. Below you can find examples of outputs for each ones.

## Ruff linter

We can add `--fix` flag to this command to automatically fix most of the problems pointed by linter, but some of them will require developer's attention and will need to be formatted manually.

By default linter pointed part of codes that requires your attention.

Default usage:

```git
> ruff check
```

Output example:

```git
I001 [*] Import block is un-sorted or un-formatted
 --> app/src/games/admin.py:1:1
  |
1 | from django.contrib import admin
  | ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
2 |
3 | # Register your models here.
  |
help: Organize imports

F401 [*] `django.contrib.admin` imported but unused
 --> app/src/games/admin.py:1:28
  |
1 | from django.contrib import admin
  |                            ^^^^^
2 |
3 | # Register your models here.
  |
help: Remove unused import: `django.contrib.admin`

I001 [*] Import block is un-sorted or un-formatted
 --> app/src/games/urls.py:2:1
  |
1 |   # games/urls.py
2 | / from django.urls import path
3 | | from games import views
  | |_______________________^
4 |
5 |   urlpatterns = [
  |
help: Organize imports

Found 3 errors.
[*] 3 fixable with the `--fix` option.
```

### Concise output format

In this output format you will receive only information on which line the problem occures and what is type of the issue.

Command usage:

```git
> ruff check --output-format=concise
```

Output example:

```git
app/src/games/admin.py:1:28: F401 [*] `django.contrib.admin` imported but unused
app/src/games/urls.py:2:1: I001 [*] Import block is un-sorted or un-formatted
Found 2 errors.
[*] 2 fixable with the `--fix` option.
```

### Grouped output format (default in pre-commit)

In this output format Ruff will automatically grouped problems per file.

Command usage:

```git
> ruff check --output-format=grouped
```

Output example:

```git
app/src/games/admin.py:
  1:28 F401 [*] `django.contrib.admin` imported but unused

app/src/games/urls.py:
  2:1 I001 [*] Import block is un-sorted or un-formatted

Found 2 errors.
[*] 2 fixable with the `--fix` option.
```

### Github output format (default in CI)

This output is more clear on Github logs and for that purposes it is used there.

Command usage:

```git
> ruff check --output-format=github
```

Output example:

```git
::error title=ruff (F401),file=/mnt/c/Users/krzysztof.szpieg/gitdir/poc-proj/app/src/games/admin.py,line=1,col=28,endLine=1,endColumn=33::app/src/games/admin.py:1:28: F401 `django.contrib.admin` imported but unused
::error title=ruff (I001),file=/mnt/c/Users/krzysztof.szpieg/gitdir/poc-proj/app/src/games/urls.py,line=2,endLine=3::app/src/games/urls.py:2:1: I001 Import block is un-sorted or un-formatted
```

## Ruff formatter

By default in CI this command is running with `--check` flag to only pointed files that required formatting.

Command usage:

```git
> ruff format --check
```

Output example:

```git
Would reformat: app/src/games/admin.py
Would reformat: app/src/games/urls.py
2 files would be reformatted, 15 files already formatted
```
