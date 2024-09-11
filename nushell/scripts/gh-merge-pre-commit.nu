# Merge all pre-commit PRs.
export def main [
  --dry-run (-n)  # Don’t actually merge, instead report what would be done.
] {
  #let pat: string = (keyring get github.com flying-sheep | str trim)

  # https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#list-notifications-for-the-authenticated-user
  gh api --paginate -X GET notifications -q '[.[] | select(.subject.type == "PullRequest" and .subject.title == "[pre-commit.ci] pre-commit autoupdate")]' | from json --objects | each { |threads|
    # TODO: handle milestones

    $threads | par-each { |thread|
      # https://docs.github.com/en/rest/pulls/pulls?apiVersion=2022-11-28#get-a-pull-request
      let pr = (gh api $thread.subject.url | from json)
      let desc = $"($pr.html_url | ansi link --text $'($pr.base.repo.full_name)#($pr.number)' ) “($pr.title)”"
      let failed_checks = (
        gh api $"repos/($pr.head.repo.full_name)/commits/($pr.head.sha)/check-runs"
        | from json
        | get check_runs
        | where { |run| $run.conclusion in ["failure", "cancelled", "skipped", "timed_out", "action_required", null] }
      )
      mut skip_resp = { pr: $"Skipped ($desc)", note: $"Skipped notification “($thread.subject.title)”" }

      if $pr.changed_files != 1 or not ($pr.mergeable | default false) {
        return $skip_resp
      } else if not ($failed_checks | is-empty) {
        $skip_resp.pr = $"Skipped ($desc) because of failing statuses: ($failed_checks | get name)"
        return $skip_resp
      }
      # Do stuff (or not if -n is passed)
      let pr = if $dry_run {
        $"Would merge ($desc)"
      } else {
        gh api -X PUT -F merge_method=squash $"($pr.url)/merge" | from json
      }
      let note = if $dry_run {
        $"Would mark notification as read: “($thread.subject.title)”"
      } else {
        gh api -X PATCH $thread.url | from json
      }
      { pr: $pr, note: $note }
    }
  }
}
