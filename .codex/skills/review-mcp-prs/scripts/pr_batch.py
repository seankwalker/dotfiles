#!/usr/bin/env python3
"""Read-only PR evidence collection and guarded approval via gh."""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path
from typing import Any
from urllib.parse import urlparse


def gh(args: list[str]) -> Any:
    result = subprocess.run(["gh", *args], text=True, capture_output=True, check=False)
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or result.stdout.strip() or "gh failed")
    return json.loads(result.stdout) if result.stdout.strip() else None


def gh_json_on_status(args: list[str]) -> list[dict[str, Any]]:
    result = subprocess.run(["gh", *args], text=True, capture_output=True, check=False)
    try:
        data = json.loads(result.stdout)
    except json.JSONDecodeError as exc:
        raise RuntimeError(result.stderr.strip() or "gh did not return JSON") from exc
    if not isinstance(data, list):
        raise RuntimeError("gh did not return a JSON list")
    return data


def number(value: str, repo: str) -> int:
    cleaned = value.rstrip("/")
    if cleaned.isdigit():
        return int(cleaned)
    parsed = urlparse(cleaned)
    parts = parsed.path.strip("/").split("/")
    if parsed.scheme == "https" and parsed.netloc.casefold() == "github.com" and len(parts) == 4 and parts[2] == "pull" and parts[3].isdigit():
        if "/".join(parts[:2]).casefold() != repo.casefold():
            raise ValueError(f"PR URL repository does not match --repo: {value}")
        return int(parts[3])
    raise ValueError(f"PR must be a number or pull URL: {value}")


def view(repo: str, pr: int) -> dict[str, Any]:
    return gh(["pr", "view", str(pr), "--repo", repo, "--json", "number,url,title,body,state,isDraft,headRefOid,baseRefOid,baseRefName,reviewDecision,labels,reviews,statusCheckRollup,comments,author"])


def api(repo: str, path: str) -> Any:
    pages = gh(["api", f"repos/{repo}/{path}", "--paginate", "--slurp"])
    if len(pages) == 1:
        return pages[0]
    if all(isinstance(page, list) for page in pages):
        return [item for page in pages for item in page]
    return pages


def threads(repo: str, pr: int) -> list[dict[str, Any]]:
    query = "query($owner:String!,$name:String!,$number:Int!,$cursor:String){repository(owner:$owner,name:$name){pullRequest(number:$number){reviewThreads(first:100,after:$cursor){nodes{id isResolved isOutdated path line comments(first:100){nodes{url body createdAt author{login}} pageInfo{hasNextPage endCursor}}} pageInfo{hasNextPage endCursor}}}}}"
    owner, name = repo.split("/", 1)
    cursor: str | None = None
    result: list[dict[str, Any]] = []
    while True:
        args = ["api", "graphql", "-f", f"query={query}", "-F", f"owner={owner}", "-F", f"name={name}", "-F", f"number={pr}"]
        if cursor:
            args.extend(["-F", f"cursor={cursor}"])
        page = gh(args)["data"]["repository"]["pullRequest"]["reviewThreads"]
        for thread in page["nodes"]:
            comment_page = thread["comments"]
            while comment_page["pageInfo"]["hasNextPage"]:
                comments_query = "query($id:ID!,$cursor:String){node(id:$id){... on PullRequestReviewThread{comments(first:100,after:$cursor){nodes{url body createdAt author{login}} pageInfo{hasNextPage endCursor}}}}}"
                extra = gh(["api", "graphql", "-f", f"query={comments_query}", "-F", f"id={thread['id']}", "-F", f"cursor={comment_page['pageInfo']['endCursor']}"])["data"]["node"]["comments"]
                comment_page["nodes"].extend(extra["nodes"])
                comment_page["pageInfo"] = extra["pageInfo"]
            result.append(thread)
        if not page["pageInfo"]["hasNextPage"]:
            return result
        cursor = page["pageInfo"]["endCursor"]


def dump(path: Path, data: Any) -> None:
    path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")


def check_name(check: dict[str, Any]) -> str:
    return check.get("name") or check.get("context") or ""


def check_workflow(check: dict[str, Any]) -> str:
    return check.get("workflowName") or check.get("workflow") or ""


def check_result(check: dict[str, Any]) -> str | None:
    return check.get("conclusion") or check.get("state")


def check_key(check: dict[str, Any]) -> str:
    return f"{check_workflow(check)}::{check_name(check)}"


def is_mergefreeze(check: dict[str, Any]) -> bool:
    return check_name(check) == "mergefreeze"


def claude_login(login: str) -> bool:
    return login.casefold() in {"claude", "claude[bot]"}


def claude_reviews(reviews: list[dict[str, Any]], sha: str) -> list[dict[str, Any]]:
    return [review for review in reviews if claude_login(((review.get("user") or review.get("author") or {}).get("login") or "")) and review.get("commit_id") == sha and review.get("state") in {"APPROVED", "COMMENTED"}]


def required_checks(repo: str, pr: int) -> list[dict[str, Any]]:
    return gh_json_on_status(["pr", "checks", str(pr), "--repo", repo, "--required", "--json", "name,bucket,state,link,workflow"])


def labels(data: dict[str, Any]) -> set[str]:
    return {str(label.get("name", "")).casefold() for label in data.get("labels", [])}


def allowed(check: dict[str, Any]) -> bool:
    return check_result(check) in {"SUCCESS", "SKIPPED", "NEUTRAL", "success", "skipping", "neutral"}


def is_ai_code_review(check: dict[str, Any]) -> bool:
    return "AI Code Review" in {check_name(check), check_workflow(check)}


def collect(args: argparse.Namespace) -> int:
    out = Path(args.output_dir)
    out.mkdir(parents=True, exist_ok=True)
    index: dict[str, Any] = {"repo": args.repo, "complete": True, "prs": []}
    for requested in args.prs:
        entry: dict[str, Any] = {"input": requested}
        try:
            pr = number(requested, args.repo)
            evidence = view(args.repo, pr)
            evidence["files"] = api(args.repo, f"pulls/{pr}/files?per_page=100")
            evidence["reviews_api"] = api(args.repo, f"pulls/{pr}/reviews?per_page=100")
            evidence["issue_comments"] = api(args.repo, f"issues/{pr}/comments?per_page=100")
            evidence["threads"] = threads(args.repo, pr)
            evidence["unresolved_thread_urls"] = sorted({comment["url"] for thread in evidence["threads"] if not thread["isResolved"] for comment in thread["comments"]["nodes"]})
            evidence["required_checks"] = required_checks(args.repo, pr)
            evidence["expected_checks"] = sorted(check_key(item) for item in evidence["statusCheckRollup"] if not is_mergefreeze(item))
            evidence["required_check_keys"] = sorted(check_key(item) for item in evidence["required_checks"])
            evidence["collection_errors"] = []
            evidence["ai_review_evidence"] = {
                "ai_reviewed_label": "ai-reviewed" in labels(evidence),
                "claude_submitted_reviews": claude_reviews(evidence["reviews_api"], evidence["headRefOid"]),
                "successful_ai_code_review_checks": [item for item in evidence["statusCheckRollup"] if is_ai_code_review(item) and allowed(item)],
            }
            evidence["issue_comment_urls"] = sorted(comment.get("html_url") or comment.get("url") for comment in evidence["issue_comments"] if comment.get("html_url") or comment.get("url"))
            evidence["review_ids"] = sorted(str(review["id"]) for review in evidence["reviews_api"] if review.get("id") is not None)
            diff = subprocess.run(["gh", "pr", "diff", str(pr), "--repo", args.repo], text=True, capture_output=True, check=False)
            if diff.returncode:
                raise RuntimeError(diff.stderr.strip() or "unable to collect diff")
            (out / f"pr-{pr}.diff").write_text(diff.stdout)
            evidence["collection_head_refetch"] = view(args.repo, pr)["headRefOid"]
            evidence["stable"] = evidence["collection_head_refetch"] == evidence["headRefOid"]
            if not evidence["stable"]:
                evidence.setdefault("collection_errors", []).append("head SHA changed during collection")
                index["complete"] = False
            dump(out / f"pr-{pr}.json", evidence)
            entry.update({"number": pr, "sha": evidence["headRefOid"], "stable": evidence["stable"], "file": f"pr-{pr}.json"})
        except Exception as exc:
            entry["error"] = str(exc)
            index["complete"] = False
        index["prs"].append(entry)
    dump(out / "batch-index.json", index)
    return 0 if index["complete"] else 1


def live_failures(repo: str, audit: dict[str, Any]) -> tuple[list[str], list[dict[str, Any]]]:
    pr = number(str(audit["pr"]), repo)
    live = view(repo, pr)
    failures: list[str] = []
    if live["headRefOid"] != audit["audited_sha"]:
        failures.append("head SHA changed")
    if live["isDraft"] or live["state"] != "OPEN":
        failures.append("PR is draft or closed")
    if live.get("reviewDecision") == "CHANGES_REQUESTED":
        failures.append("changes requested")
    reviews = api(repo, f"pulls/{pr}/reviews?per_page=100")
    successful_ai_check = any(is_ai_code_review(item) and allowed(item) for item in live["statusCheckRollup"])
    if "ai-reviewed" not in labels(live):
        failures.append("missing ai-reviewed label")
    if not successful_ai_check and not claude_reviews(reviews, live["headRefOid"]):
        failures.append("missing successful current AI Code Review check or Claude review")
    checks = {check_key(item): item for item in live["statusCheckRollup"]}
    for item in live["statusCheckRollup"]:
        if not is_mergefreeze(item) and not allowed(item):
            failures.append(f"current check not passing: {check_key(item)}")
    live_required = required_checks(repo, pr)
    for expected in audit.get("expected_checks", []):
        check = checks.get(expected)
        if not check or not allowed(check):
            failures.append(f"required or expected check not passing: {expected}")
    required_by_key = {check_key(item): item for item in live_required}
    for required in set(audit.get("required_check_keys", [])) | set(required_by_key):
        check = required_by_key.get(required)
        if not check or check.get("bucket") not in {"pass", "skipping"}:
            failures.append(f"required check not passing: {required}")
    audited = set(audit.get("unresolved_thread_urls", []))
    current = {comment["url"] for thread in threads(repo, pr) if not thread["isResolved"] for comment in thread["comments"]["nodes"]}
    if current - audited:
        failures.append("new unresolved review thread")
    comment_urls = {comment.get("html_url") or comment.get("url") for comment in api(repo, f"issues/{pr}/comments?per_page=100") if comment.get("html_url") or comment.get("url")}
    if comment_urls - set(audit["issue_comment_urls"]):
        failures.append("new issue comment")
    review_ids = {str(review["id"]) for review in reviews if review.get("id") is not None}
    if review_ids - set(audit["review_ids"]):
        failures.append("new submitted review")
    if audit.get("collection_errors") or audit.get("collection_error"):
        failures.append("collection errors")
    mergefreeze = [{"key": check_key(item), "result": check_result(item), "status": item.get("status")} for item in live["statusCheckRollup"] if is_mergefreeze(item)]
    return failures, mergefreeze


def revalidate(args: argparse.Namespace, approving: bool) -> int:
    try:
        data = json.loads(Path(args.audit_file).read_text())
        audits = data.get("prs", data) if isinstance(data, dict) else data
        if not isinstance(audits, list):
            raise ValueError("audit JSON must be a list or an object with a prs list")
        required_keys = {"pr", "audited_sha", "verdict", "unresolved_thread_urls", "unresolved_thread_dispositions", "issue_comment_urls", "review_ids", "expected_checks", "required_check_keys", "collection_errors", "worker_evidence", "citations"}
        list_keys = {"unresolved_thread_urls", "issue_comment_urls", "review_ids", "expected_checks", "required_check_keys", "collection_errors", "citations"}
        for audit in audits:
            if not isinstance(audit, dict) or not required_keys <= audit.keys():
                raise ValueError("each audit entry requires the full coordinator audit schema")
            if any(not isinstance(audit[key], list) for key in list_keys) or not isinstance(audit["unresolved_thread_dispositions"], dict):
                raise ValueError("audit URL/check/review/citation fields and collection_errors must be lists; dispositions must be an object")
            if audit["verdict"] == "PASS":
                if audit["collection_errors"] or not audit["worker_evidence"] or not audit["citations"]:
                    raise ValueError("PASS requires no collection_errors plus worker_evidence and citations")
                for url in audit["unresolved_thread_urls"]:
                    disposition = audit["unresolved_thread_dispositions"].get(url)
                    if not isinstance(disposition, dict) or disposition.get("classification") != "non_actionable" or not str(disposition.get("justification", "")).strip():
                        raise ValueError("PASS requires a non_actionable classification and justification for every unresolved thread URL")
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        print(json.dumps({"ok": False, "audit_file_error": str(exc)}), file=sys.stderr)
        return 1
    any_failure = False
    for audit in audits:
        if audit.get("verdict") != "PASS":
            continue
        try:
            failures, mergefreeze = live_failures(args.repo, audit)
            print(json.dumps({"pr": audit["pr"], "audited_sha": audit["audited_sha"], "ok": not failures, "failures": failures, "mergefreeze": {"external_merge_gate": True, "states": mergefreeze}}, sort_keys=True))
            if failures:
                any_failure = True
                continue
            if approving:
                if not args.execute or args.confirmation != "APPROVE_PASSING_PRS":
                    print(json.dumps({"pr": audit["pr"], "approved": False, "reason": "dry-run; require --execute --confirmation APPROVE_PASSING_PRS"}))
                    if args.execute:
                        any_failure = True
                    continue
                final_failures, _ = live_failures(args.repo, audit)
                if final_failures:
                    any_failure = True
                    print(json.dumps({"pr": audit["pr"], "approved": False, "reason": "state changed before approval", "failures": final_failures}))
                    continue
                gh(["api", "--method", "POST", f"repos/{args.repo}/pulls/{number(str(audit['pr']), args.repo)}/reviews", "-f", "event=APPROVE", "-f", f"commit_id={audit['audited_sha']}"])
                print(json.dumps({"pr": audit["pr"], "approved": True}))
        except Exception as exc:
            any_failure = True
            print(json.dumps({"pr": audit.get("pr"), "ok": False, "failures": [str(exc)]}))
    return 1 if any_failure else 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Collects read-only PR evidence; approval is dry-run by default and never merges or comments.")
    commands = parser.add_subparsers(dest="command", required=True)
    collector = commands.add_parser("collect", help="Read-only except requested output directory.")
    collector.add_argument("--repo", required=True)
    collector.add_argument("--output-dir", required=True)
    collector.add_argument("prs", nargs="+")
    rechecker = commands.add_parser("revalidate", help="Read-only live safety revalidation for PASS audit entries.")
    approver = commands.add_parser("approve", help="Dry-run live revalidation; writes only after exact confirmation.")
    for command in (rechecker, approver):
        command.add_argument("--repo", required=True)
        command.add_argument("--audit-file", required=True, help="Coordinator JSON requires PR/SHA/verdict, unresolved-thread URLs and dispositions, issue-comment URLs, review IDs, composite expected/required checks, collection_errors, worker_evidence, and citations. PASS needs evidence and no collection errors.")
    approver.add_argument("--execute", action="store_true")
    approver.add_argument("--confirmation")
    args = parser.parse_args()
    if args.command == "collect":
        return collect(args)
    return revalidate(args, args.command == "approve")


if __name__ == "__main__":
    sys.exit(main())
