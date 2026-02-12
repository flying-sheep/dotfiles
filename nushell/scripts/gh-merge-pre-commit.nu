# Merge all pre-commit PRs.
export def main [
  --dry-run (-n)  # Don’t actually merge, instead report what would be done.
] {
  #let pat: string = (keyring get github.com flying-sheep | str trim)

  # https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#list-notifications-for-the-authenticated-user
  gh api --paginate -X GET notifications -q '[.[] | select(.subject.type == "PullRequest" and (.subject.title | contains("pre-commit autoupdate")))]' | from json --objects | each { |threads|
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
      mut skip_resp = { pr: $"Skipped ($desc)", note: $"Skipped notification “($thread.subject.title)”" }

      if $pr.changed_files != 1 or not ($pr.mergeable | default false) {
        $skip_resp.pr = $"Skipped ($desc) because mergeable = ($pr.mergeable) and # changed files = ($pr.changed_files)"
        return $skip_resp
      } else if not ($failed | is-empty) {
        $skip_resp.pr = $"Skipped ($desc) because of failing checks/statuses: ($failed)"
        return $skip_resp
      }
      # Do stuff (or not if -n is passed)
      if not $dry_run {
        gh api -X PUT -F merge_method=squash $"($pr.url)/merge" | from json
      }
      let note = if $dry_run {
        $"Would mark notification as read: “($thread.subject.title)”"
      } else {
        gh api -X PATCH $thread.url | from json
      }
      { pr: $desc, note: $note }
    }
  } | flatten
}
