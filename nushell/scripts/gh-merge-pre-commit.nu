# Merge all pre-commit PRs.
export def main [
  --dry-run (-n)  # Don’t actually merge, instead report what would be done.
] {
  #let pat: string = (keyring get github.com flying-sheep | str trim)

  # https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#list-notifications-for-the-authenticated-user
  gh api --paginate -X GET notifications -q '[.[] | select(.subject.type == "PullRequest" and (.subject.title | test("pre-commit autoupdate$|\\bbump\\b.*\\b(group|from\\b.*\\bto)\\b"; "i")))]' | from json --objects | each { |threads|
    # TODO: handle milestones

    $threads | par-each --keep-order { |thread|
      # https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#get-a-pull-request
      let pr = (gh api $thread.subject.url | from json)
      let desc = $"($pr.html_url | ansi link --text $'($pr.base.repo.full_name)#($pr.number)' ) “($pr.title)”"
      let failed_checks = (
        gh api $"repos/($pr.head.repo.full_name)/commits/($pr.head.sha)/check-runs"
        | from json
        | get check_runs
        | where { |run| $run.conclusion in ["failure", "cancelled", "timed_out", "action_required", null] }
      )
      let failed_statuses = (
        gh api $"repos/($pr.head.repo.full_name)/commits/($pr.head.sha)/status"
        | from json
        | get statuses
        | where { |status| $status.state in ["error", "failure"] }
      )
      let failed = [...($failed_checks | get name) ...($failed_statuses | get context)]
      # allow one manifest + its lockfile (e.g. package.json + pnpm-lock.yaml)
      let only_lockfile_extra = $pr.changed_files == 2 and (
        gh api $"($pr.url)/files" | from json | get filename | path basename
        | where $it =~ '(\.lockb?|-lock\.(json|ya?ml)|^go\.sum|^pylock(\.[^.]+)?\.toml)$' | length
      ) == 1
      # mergeable = null means GitHub is still computing it, so try anyway
      if not ($pr.changed_files == 1 or $only_lockfile_extra) or $pr.mergeable == false {
        return { pr: $desc, note: $"Skipped: mergeable = ($pr.mergeable), # changed files = ($pr.changed_files)" }
      } else if not ($failed | is-empty) {
        return { pr: $desc, note: $"Skipped: failing checks/statuses: ($failed)" }
      }
      # Do stuff (or not if -n is passed)
      if $dry_run {
        return { pr: $desc, note: $"Would merge and mark notification as read: “($thread.subject.title)”" }
      }
      let merge = (gh api -X PUT -F merge_method=squash $"($pr.url)/merge" | complete)
      # 405: e.g. base branch modified or mergeability not yet known
      let merged = if $merge.exit_code == 0 { "Merged" } else if ($merge.stderr | str contains "(HTTP 405)") {
        # REST has no auto-merge endpoint, gh uses GraphQL
        let auto = (gh pr merge --auto --squash $pr.html_url | complete)
        if $auto.exit_code == 0 { "Enabled auto-merge" } else { $"Failed enabling auto-merge: ($auto.stderr | str trim)" }
      } else {
        $"Failed merging: ($merge.stderr | str trim)"
      }
      let read = try { gh api -X PATCH $thread.url | ignore; "marked as read" } catch { |e| $"failed marking as read: ($e.msg)" }
      { pr: $desc, note: $"($merged), ($read)" }
    }
  } | flatten
}
