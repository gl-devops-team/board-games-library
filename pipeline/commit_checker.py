#!/usr/bin/env python3

import re
import subprocess
import sys

ALLOWED_TYPES = [
    "feat",
    "fix",
    "chore",
    "docs",
    "refactor",
    "perf",
    "test",
    "build",
    "ci",
    "style",
    "revert",
    "hotfix",
]

# Issue-ID formats we accept in text:
# - "Issue-ID: gh-1234"
# - "issue id: GH-1234"
# - "Issue_ID: gh-1234"
ISSUE_ID_REGEX = re.compile(
    r"^issue[\s_-]*id\s*:\s*(gh-\d+)\s*$",
    re.IGNORECASE,
)


def throw_gh_error_msg(message: str) -> None:
    print(f"Error: {message}")
    sys.exit(1)


def normalize_issue_id(raw: str) -> str:
    raw = raw.strip().lower()
    return raw


def extract_issue_id(text: str | None, where: str) -> str:
    if not text:
        throw_gh_error_msg(f"Missing {where}. Issue-ID is required.")

    lines = text.strip().splitlines()

    while lines and not lines[-1].strip():
        lines.pop()  # Remove trailing empty lines

    if not lines:
        throw_gh_error_msg(f"{where} is empty. Issue-ID is required.")

    last_line = lines[-1]

    match = ISSUE_ID_REGEX.match(last_line)
    if not match:
        throw_gh_error_msg(
            f"Failed to extract Issue-ID from {where}. \n"
            f"Last line of {where}: '{last_line}' \n"
            f"Expected format: 'Issue-ID: gh-1234'"
        )

    return match.group(1).lower()


def get_commit_message(sha: str) -> str:
    try:
        # %B = raw body (subject + blank + body)
        out = subprocess.check_output(
            ["git", "show", "-s", "--format=%B", sha],
            text=True,
        )
        return out.strip()
    except subprocess.CalledProcessError as e:
        throw_gh_error_msg(f"Failed to get commit message for SHA {sha}: {e}")
    except FileNotFoundError:
        throw_gh_error_msg(
            "Git command not found. Make sure git is installed and in PATH."
        )

    return ""  # Should never reach here


def validate_branch_name(branch: str) -> str:
    pattern = rf"^({'|'.join(ALLOWED_TYPES)})/gh-[0-9]+/[a-z0-9]+([._-][a-z0-9]+)*$"
    match = re.match(pattern, branch)

    if not match:
        throw_gh_error_msg(
            "Invalid branch name. \n"
            "Branch name must follow the format: <type>/<issue_id>/<description> \n"
            "Example: feat/1234/add-login-feature"
        )

    return match.group(1).lower()


def validate_pr_title(message: str) -> str:
    pattern = rf"^({'|'.join(ALLOWED_TYPES)}): [A-Za-z0-9].+$"
    pr_title = message.lower()
    match = re.match(pattern, pr_title)

    if not match:
        throw_gh_error_msg(
            "Invalid PR title. \n"
            "PR title must follow the format: <type>: <description> \n"
            "Example: feat: add login feature"
        )

    return match.group(1).lower()


def main():
    if len(sys.argv) != 5:
        throw_gh_error_msg(
            "Usage: commit_checker.py <branch_name> <pr_title> <_pr_body> <head_sha>"
        )

    branch_name = sys.argv[1]
    pr_title = sys.argv[2]
    pr_body = sys.argv[3]
    head_sha = sys.argv[4]

    if branch_name == "develop":
        print("Branch is 'develop', skipping commit checks.")
        sys.exit(0)

    print(f"Branch name: {branch_name}")
    print(f"PR title: {pr_title}")
    print(f"Head commit SHA: {head_sha}")

    branch_type = validate_branch_name(branch_name)
    pr_type = validate_pr_title(pr_title)

    if branch_type != pr_type:
        throw_gh_error_msg("Branch type and PR type must match")

    pr_issue_id = extract_issue_id(pr_body, "PR description")

    head_commit_msg = get_commit_message(head_sha)
    commit_issue_id = extract_issue_id(head_commit_msg, "Head commit message")

    print(f"Extracted Issue-ID from PR description: {pr_issue_id}")
    print(f"Extracted Issue-ID from head commit message: {commit_issue_id}")

    # check issue_id between PR description and head commit message
    if pr_issue_id != commit_issue_id:
        throw_gh_error_msg(
            f"Issue-ID mismatch between PR description and head commit message: \n"
            f"PR description Issue-ID: {pr_issue_id} \n"
            f"Head commit message Issue-ID: {commit_issue_id}"
        )

    print("✅ PR conventions OK!")


if __name__ == "__main__":
    main()
