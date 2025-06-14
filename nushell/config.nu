# Nushell Config File

use scripts/gh-merge-pre-commit.nu
use scripts/task.nu

module completions {
  def "nu-complete qdbus6 servicenames" [] {
    ^qdbus6 | lines | where $it !~ '^:' | each { |line| $line | str trim } | sort
  }

  def "nu-complete qdbus6 path" [line: string, pos: int] {
    let args = ($line | str trim | split row ' ' | skip 1)
    ^qdbus6 $args.0 | lines | each { |line| $line | str trim } | sort
  }

  def "nu-complete qdbus6 method" [line: string, pos: int] {
    let args = ($line | str trim | split row ' ' | skip 1)
    ^qdbus6 $args.0 $args.1 | lines | str trim |
      parse -r '(?P<kind>\w+) (?P<rtype>[\w\s]+) (?P<name>[\w.]+)(\((?P<args>[\w\s,]*)\))?' |
      each { |sig|
        # method [Q_NOREPLY] void org.freedesktop.DBus.Properties.Set(QString interface_name, QString property_name, QDBusVariant value)
        { value: $sig.name, description: $"($sig.rtype) \(($sig.kind)\)" }
      }
  }

  export extern qdbus6 [
    servicename?: string@"nu-complete qdbus6 servicenames"
    path?: string@"nu-complete qdbus6 path"
    method?: string@"nu-complete qdbus6 method"
    ...args: string
    --system
    --bus: string
    --literal
  ]
}
use completions *

# for more information on themes see
# https://www.nushell.sh/book/coloring_and_theming.html
let dark_theme = {
    # color for nushell primitives
    separator: white
    leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
    header: green_bold
    empty: blue
    bool: white
    int: white
    filesize: white
    duration: white
    date: white
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cellpath: white
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray

    # shapes are used to change the cli syntax highlighting
    shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: b}
    shape_binary: purple_bold
    shape_bool: light_cyan
    shape_int: purple_bold
    shape_float: purple_bold
    shape_range: yellow_bold
    shape_internalcall: cyan_bold
    shape_external: cyan
    shape_externalarg: green_bold
    shape_literal: blue
    shape_operator: yellow
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_datetime: cyan_bold
    shape_list: cyan_bold
    shape_table: blue_bold
    shape_record: cyan_bold
    shape_block: blue_bold
    shape_filepath: cyan
    shape_directory: cyan
    shape_globpattern: cyan_bold
    shape_variable: purple
    shape_flag: blue_bold
    shape_custom: green
    shape_nothing: light_cyan
    shape_matching_brackets: { attr: u }
}

let light_theme = {
    # color for nushell primitives
    separator: dark_gray
    leading_trailing_space_bg: { attr: n } # no fg, no bg, attr none effectively turns this off
    header: green_bold
    empty: blue
    bool: dark_gray
    int: dark_gray
    filesize: dark_gray
    duration: dark_gray
    date: dark_gray
    range: dark_gray
    float: dark_gray
    string: dark_gray
    nothing: dark_gray
    binary: dark_gray
    cellpath: dark_gray
    row_index: green_bold
    record: white
    list: white
    block: white
    hints: dark_gray

    # shapes are used to change the cli syntax highlighting
    shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: b}
    shape_binary: purple_bold
    shape_bool: light_cyan
    shape_int: purple_bold
    shape_float: purple_bold
    shape_range: yellow_bold
    shape_internalcall: cyan_bold
    shape_external: cyan
    shape_externalarg: green_bold
    shape_literal: blue
    shape_operator: yellow
    shape_signature: green_bold
    shape_string: green
    shape_string_interpolation: cyan_bold
    shape_datetime: cyan_bold
    shape_list: cyan_bold
    shape_table: blue_bold
    shape_record: cyan_bold
    shape_block: blue_bold
    shape_filepath: cyan
    shape_directory: cyan
    shape_globpattern: cyan_bold
    shape_variable: purple
    shape_flag: blue_bold
    shape_custom: green
    shape_nothing: light_cyan
    shape_matching_brackets: { attr: u }
}

# Check if the system should be dark
def should-be-dark [] {
  # TODO: update location
  #do -i {
  #  PYTHONPATH=/opt/yin-yang python -c 'import src.yin_yang as yy; from datetime import datetime as dt; print(yy.should_be_dark(dt.now().time(), *yy.config.times))'
  #} | complete | get stdout | into bool
  match $nu.os-info.name {
    'linux' => {
      let scheme_nr = (qdbus6 org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read "org.freedesktop.appearance" "color-scheme" | into int)
      return ($scheme_nr == 1)  # light: 2, no pref: 0
    },
    'macos' => {
      # returns error when in light mode, 'Dark' when in dark mode 🤷
      let rv = (do -i { defaults read -g AppleInterfaceStyle } | complete | get exit_code)
      return ($rv != 1)
    },
  }
}

let version = ((version).version | parse -r '^(?P<major>\d+)\.(?P<minor>\d+)(?:\.(?P<patch>\d+))?$' | transpose name val | update val { |row| $row.val | into int } | transpose -ird)

$env.config.ls.use_ls_colors = true  # use the LS_COLORS environment variable to colorize output
$env.config.ls.clickable_links = true # enable or disable clickable links. Your terminal has to support links.
$env.config.rm.always_trash = false  # always act as if -t was given. Can be overridden with -p
$env.config.table.mode = "rounded"  # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
$env.config.table.index_mode = "always"  # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
$env.config.table.trim.methodology = "wrapping"  # wrapping or truncating
$env.config.table.trim.wrapping_try_keep_words = true  # A strategy used by the 'wrapping' methodology
$env.config.table.trim.truncating_suffix = "..."  # A suffix used by the 'truncating' methodology
$env.config.history.max_size = 10000 # Session has to be reloaded for this to take effect
$env.config.history.sync_on_enter = true # Enable to share the history between multiple sessions, else you have to close the session to persist history to file
$env.config.history.file_format = "plaintext"  # "sqlite" or "plaintext"

# https://www.nushell.sh/cookbook/external_completers.html
let carapace_completer = { |spans: list<string>|
  carapace $spans.0 nushell ...$spans
  | from json
  | if ($in | default [] | where value == $"($spans | last)ERR" | is-empty) { $in } else { null }
}
let fish_completer = { |spans: list<string>|
  fish --command $"complete '--do-complete=($spans | str join ' ')'"
  | from tsv --flexible --noheaders --no-infer
  | rename value description
  | update value {
    if ($in | path exists) {$'"($in | str replace "\"" "\\\"" )"'} else {$in}
  }
}
$env.config.completions.case_sensitive = false  # set to true to enable case-sensitive completions
$env.config.completions.quick = true  # set this to false to prevent auto-selecting completions when only one remains
$env.config.completions.partial = true  # set this to false to prevent partial filling of the prompt
$env.config.completions.algorithm = "fuzzy"  # 'prefix', 'substring', or 'fuzzy'
$env.config.completions.external.enable = true  # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
$env.config.completions.external.max_results = 100  # setting it lower can improve completion performance at the cost of omitting some options
$env.config.completions.external.completer = {|spans|
  let expanded_alias = scope aliases
  | where name == $spans.0
  | get -i 0.expansion

  let spans = if $expanded_alias != null {
    $spans
    | skip 1
    | prepend ($expanded_alias | split row ' ' | take 1)
  } else {
    $spans
  }

  match $spans.0 {
    # carapace completions are incorrect for nu
    nu => $fish_completer
    # fish completes commits and branch names in a nicer way
    git => $fish_completer
    # carapace doesn't have completions for asdf
    asdf => $fish_completer
    # use zoxide completions for zoxide commands
    #__zoxide_z | __zoxide_zi => $zoxide_completer
    _ => $carapace_completer
  } | do $in $spans
}

# - A filesize unit: "B", "kB", "KiB", "MB", "MiB", "GB", "GiB", "TB", "TiB", "PB", "PiB", "EB", or "EiB".
# - An automatically scaled unit: "metric" or "binary".
# "metric" will use units with metric (SI) prefixes like kB, MB, or GB.
# "binary" will use units with binary prefixes like KiB, MiB, or GiB.
# Otherwise, setting this to one of the filesize units will use that particular unit when displaying all file sizes.
$env.config.filesize.unit = "metric"
# The number of digits to display after the decimal point for file sizes.
# When set to `null`, all digits after the decimal point will be displayed.
$env.config.filesize.precision = 1
$env.config.color_config = (if (should-be-dark) { $dark_theme } else { $light_theme })
$env.config.footer_mode = 25  # always, never, number_of_rows, auto
$env.config.float_precision = 2
# $env.config.buffer_editor: "emacs"  # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
$env.config.use_ansi_coloring = true
$env.config.edit_mode = 'emacs'  # emacs, vi
# osc2 abbreviates the path if in the home_dir, sets the tab/window title, shows the running command in the tab/window title
$env.config.shell_integration.osc2 = true
# osc7 is a way to communicate the path to the terminal, this is helpful for spawning new tabs in the same directory
$env.config.shell_integration.osc7 = true
# osc8 is also implemented as the deprecated setting ls.show_clickable_links, it shows clickable links in ls output if your terminal supports it. show_clickable_links is deprecated in favor of osc8
$env.config.shell_integration.osc8 = true
# osc9_9 is from ConEmu and is starting to get wider support. It's similar to osc7 in that it communicates the path to the terminal
$env.config.shell_integration.osc9_9 = false
# osc133 is several escapes invented by Final Term which include the supported ones below.
# 133;A - Mark prompt start
# 133;B - Mark prompt end
# 133;C - Mark pre-execution
# 133;D;exit - Mark execution finished with exit code
# This is used to enable terminals to know where the prompt is, the command is, where the command finishes, and where the output of the command is
$env.config.shell_integration.osc133 = true
# osc633 is closely related to osc133 but only exists in visual studio code (vscode) and supports their shell integration features
# 633;A - Mark prompt start
# 633;B - Mark prompt end
# 633;C - Mark pre-execution
# 633;D;exit - Mark execution finished with exit code
# 633;E - NOT IMPLEMENTED - Explicitly set the command line with an optional nonce
# 633;P;Cwd=<path> - Mark the current working directory and communicate it to the terminal
# and also helps with the run recent menu in vscode
$env.config.shell_integration.osc633 = true
# reset_application_mode is escape \x1b[?1l and was added to help ssh work better
$env.config.shell_integration.reset_application_mode = true
$env.config.show_banner = false
$env.config.render_right_prompt_on_last_line = false  # true or false to enable or disable right prompt to be rendered on last line of the prompt.
#$env.config.hooks.pre_prompt = [{ || ... }]
#$env.config.hooks.pre_execution = [{ || ... }]
#$env.config.hooks.env_change.PWD = [{ |before, after| ... }]  # # runs if the PWD environment is different since the last repl input
$env.config.hooks.display_output = { ||
  if (term size).columns >= 100 { table -e } else { table }
}
if not (which pkgfile | is-empty) and ($version.major >= 1 or ($version.major == 0 and $version.minor >= 78)) {
  $env.config.hooks.command_not_found = { |cmd_name: string| (
    try {
      let pkgs = (pkgfile --binaries --verbose $cmd_name)
      if not ($pkgs | is-empty) {
        (
          $"(ansi $env.config.color_config.shape_external)($cmd_name)(ansi reset) " +
          $"may be found in the following packages:\n($pkgs)"
        )
      } else {
        null
      }
    } catch {
      null
    }
  ) }
}
$env.config.menus = [
  # Configuration for default nushell menus
  # Note the lack of souce parameter
  {
    name: completion_menu
    only_buffer_difference: false
    marker: "| "
    type: {
        layout: columnar
        columns: 4
        col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
        col_padding: 2
    }
    style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
    }
  }
  {
    name: history_menu
    only_buffer_difference: true
    marker: "? "
    type: {
        layout: list
        page_size: 10
    }
    style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
    }
  }
  {
    name: help_menu
    only_buffer_difference: true
    marker: "? "
    type: {
        layout: description
        columns: 4
        col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
        col_padding: 2
        selection_rows: 4
        description_rows: 10
    }
    style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
    }
  }
  # Example of extra menus created using a nushell source
  # Use the source field to create a list of records that populates
  # the menu
  {
    name: commands_menu
    only_buffer_difference: false
    marker: "# "
    type: {
        layout: columnar
        columns: 4
        col_width: 20
        col_padding: 2
    }
    style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
    }
    source: { |buffer, position|
        $nu.scope.commands
        | where command =~ $buffer
        | each { |it| {value: $it.command description: $it.usage} }
    }
  }
  {
    name: vars_menu
    only_buffer_difference: true
    marker: "# "
    type: {
        layout: list
        page_size: 10
    }
    style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
    }
    source: { |buffer, position|
        $nu.scope.vars
        | where name =~ $buffer
        | sort-by name
        | each { |it| {value: $it.name description: $it.type} }
    }
  }
  {
    name: commands_with_description
    only_buffer_difference: true
    marker: "# "
    type: {
        layout: description
        columns: 4
        col_width: 20
        col_padding: 2
        selection_rows: 4
        description_rows: 10
    }
    style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
    }
    source: { |buffer, position|
        $nu.scope.commands
        | where command =~ $buffer
        | each { |it| {value: $it.command description: $it.usage} }
    }
  }
]
$env.config.keybindings = [
  {
    name: completion_menu
    modifier: none
    keycode: tab
    mode: emacs # Options: emacs vi_normal vi_insert
    event: {
      until: [
        { send: menu name: completion_menu }
        { send: menunext }
      ]
    }
  }
  {
    name: completion_previous
    modifier: shift
    keycode: backtab
    mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
    event: { send: menuprevious }
  }
  {
    name: history_menu
    modifier: control
    keycode: char_x
    mode: emacs
    event: {
      until: [
        { send: menu name: history_menu }
        { send: menupagenext }
      ]
    }
  }
  {
    name: history_previous
    modifier: control
    keycode: char_z
    mode: emacs
    event: {
      until: [
        { send: menupageprevious }
        { edit: undo }
      ]
    }
  }
  # Keybindings used to trigger the user defined menus
  {
    name: commands_menu
    modifier: control
    keycode: char_t
    mode: [emacs, vi_normal, vi_insert]
    event: { send: menu name: commands_menu }
  }
  {
    name: vars_menu
    modifier: control
    keycode: char_y
    mode: [emacs, vi_normal, vi_insert]
    event: { send: menu name: vars_menu }
  }
  {
    name: commands_with_description
    modifier: control
    keycode: char_u
    mode: [emacs, vi_normal, vi_insert]
    event: { send: menu name: commands_with_description }
  }
]

def 'sync-theme' [] {
  $env.COLOR_SCHEME = (if (should-be-dark) { 'dark' } else { 'light' })
  $env.CLIPBOARD_THEME = $env.COLOR_SCHEME

  $env.config.color_config = (if (should-be-dark) { $dark_theme } else { $light_theme })

  match $nu.os-info.name {
    'linux' => {
      qdbus6 org.kde.yakuake /yakuake/MainWindow_1 org.kde.yakuake.KMainWindow.setSettingsDirty
      let profile = (if (should-be-dark) { 'Dark' } else { 'Light' })
      qdbus6 org.kde.yakuake | lines | find -n /Sessions/ | each { qdbus6 org.kde.yakuake $in org.kde.konsole.Session.setProfile $profile }
    },
    'macos' => {},
  }
}

sync-theme

def 'into filesize2' [...cols] {
  let start = $in
  $cols | reduce --fold $start { |col, df|
    $df | upsert $col { |row|
      if ($row | get $col | is-empty) { null } else { $row | get $col | into filesize }
    }
  }
}

def ports [] {
  let $raw = (^sudo lsof -nP -iTCP -sTCP:LISTEN | ^column -t | from ssv)
  $raw # | rename ($raw | columns) ($raw | columns | lowercase)
}

# Free disk space information
def df [] {
  ^env LANG=C lsblk -r -o name,mountpoint,tran,type,fstype,label,size,fsused
    | from csv -s ' ' | where TYPE == 'part' | into filesize2 SIZE FSUSED
}

def msg [msg: string] {
  $"(ansi ub)::(ansi reset) ($msg)"
}

# Remove cache files for docker, paru, pacman, TODO: and jupyter
def gc [] {
  print (msg 'Pruning Docker')
  docker system prune
  print (msg 'Removing unneeded dependencies')
  paru -Qdtq | lines | do { || let pkgs = $in; if not ($pkgs | is-empty) { paru -Rcns ...$pkgs } }
  print (msg 'Cleaning PKGBUILD dirs')
  for dir in ([
    (ls ~/.cache/paru/clone/* | get name),
    (ls ~/Dev/PKGBUILDs/checkouts/*/* | get name),
  ] | flatten) { do -i { ^git -C $dir clean -fx } }
  print (msg 'Pruning package cache')
  ^sudo pacman -Sc
  print (msg 'Uninstalling old Rust toolchains')
  rustup toolchain list | lines | str replace ' (default)' '' | where $it =~ '^\d+[.]\d+|^nightly-\d{4}' | each { |tc| rustup toolchain uninstall $tc }
  null
}

# Clone AUR repo via SSH URL
def 'aur clone' [repo: string] {
  git clone $'ssh://aur@aur.archlinux.org/($repo).git'
}

def pacq [
  --info (-i)
  ...pkg_args: string
] {
  let pkg = (if ($pkg_args | length) == 0 { $in } else { $pkg_args })
  let raw = (
    ^python -c "
import sys
import json
import pyalpm
import importlib.util
import importlib.machinery

spec = importlib.util.spec_from_file_location('pycman_query', '/usr/bin/pycman-query', loader=importlib.machinery.SourceFileLoader('pycman_query', '/usr/bin/pycman-query'))
sys.modules['pycman_query'] = pycman_query = importlib.util.module_from_spec(spec)
spec.loader.exec_module(pycman_query)

obj_attrs = set(dir(object))

def display_pkg(pkg, options):
  displaystyle = 'file' if options.package else 'local'
  if options.info > 0:
    # pkginfo.display_pkginfo(pkg, level=options.info, style=displaystyle)
    print(json.dumps({
      k: v
      for k in pyalpm.Package.__dict__
      if not k in obj_attrs
      and not callable(v := getattr(pkg, k))
      and not type(v).__name__ == 'DB'
    }))
  elif not options.listfiles:
    print(json.dumps(dict(name=pkg.name, version=pkg.version)))

  if options.listfiles:
    if options.quiet:
      [print('/' + path) for path, size, mode in pkg.files]
    else:
      [print(pkg.name, '/' + path) for path, size, mode in pkg.files]

pycman_query.display_pkg = display_pkg
sys.exit(pycman_query.main(sys.argv[1:]))
" ([(if ($info) { ['-i'] } else []), $pkg] | flatten)
    | from json -o
  )
  if ($info) {
    $raw
      | reject 'sha256sum' 'md5sum' 'base64_sig' 'filename'
      | into filesize 'download_size' 'size' 'isize'
      | into datetime 'builddate' 'installdate'
      | into int 'reason'
      | into bool 'has_scriptlet'
  } else {
    $raw
  }
}

def revanced [] {
  let patch_ver = (pacq revanced-patches | get version | split column '-' ver rev | get ver.0)
  let yt_ver = (
    http get $'https://raw.githubusercontent.com/revanced/revanced-patches/v($patch_ver)/src/main/kotlin/app/revanced/patches/youtube/interaction/downloads/annotation/DownloadsCompatibility.kt'
    | lines
    | find '.youtube"'
    | parse --regex '.*arrayOf\((?:"(?<ver>[\d.]+)",?\s*)+\).*'
    | get ver.0
  )
  return (error make {msg: $'TODO: get YouTube ($yt_ver) apk'})
  revanced-cli -b /usr/share/revanced/revanced-patches.jar -m /usr/share/revanced/integrations.apk -c -d 19021FDF600EBV -o youtube-revanced.apk -a `~/Downloads/com.google.android.youtube_17.49.37-1533275584_minAPI26(arm64-v8a,armeabi-v7a,x86,x86_64)(nodpi)_apkmirror.com.apk`
  # -i general-resource-ads -i general-ads -i video-ads -i amoled -i custom-branding -i minimized-playback -i integrations -i microg-support
}

# List jupyter servers including their stale status
def 'jupyter servers' [] {
  ^python -c "
from rich import traceback
traceback.install()
import json
import ipynbname as i
for srv in i._list_maybe_running_servers():
  try:
    i._get_sessions(srv)
    srv['stale'] = False
  except Exception:
    srv['stale'] = True
  print(json.dumps(srv))
" | lines | each { |it| $it | from json }
}

def 'pipx list' [] {
  ^pipx list --json | from json
}

def 'pip list' [] {
  ^pip list -v --format=json | from json | default null editable_project_location
}

def 'micromamba env list' [] {
  ^micromamba env list --json | from json
}

def 'fwupdmgr get-devices' [] {
  ^fwupdmgr get-devices --json | from json | get Devices
}

def 'bombadil link' [] {
  ^bombadil link -p $nu.os-info.name
}

def 'bombadil watch' [] {
  ^bombadil watch -p $nu.os-info.name
}

if (which yarn | is-empty) {
  alias yarn = fnm exec --using v20.2.0 yarn
}

def R [...args] {
  if ($args | is-empty) {
    ^jupyter console --kernel=ir
  } else {
    ^R $args
  }
}

alias fuck = with-env {TF_ALIAS: "fuck", PYTHONIOENCODING: "utf-8"} {
  thefuck (history | last 1 | get command.0)
}

# alias cat = bat --paging=never
# alias less = bat
# alias ls = exa
# alias ll = exa -l --header --git --time-style=long-iso
# alias tree = exa --tree

# Execute a closure repeatedly
def every [duration: duration, closure: closure] {
  0.. | each { |it|
    let ret = ($it | do $closure $it)
    sleep $duration
    $ret
  }
}

def cpuinfo [] {
  cat /proc/cpuinfo
    | str trim
    | split row "\n\n"
    | each {
      |it| $it
      | lines
      | split column -r '\s*:\s+'
      | transpose -rd
    }
    | update flags {
      |it| $it.flags
      | split words
    }
}

def 'email parse' [] {
  let stdin = $in
  let code = '
import sys, email, json
m = email.message_from_file(sys.stdin)
json.dump({k: m.get_all(k) if len(m.get_all(k)) > 1 else m[k] for k in m}, sys.stdout)'
  $stdin | python -c $code | from json
}

def 'pypkg deps' [
  pkg: string
] {
  let info = (
    http get $"https://pypi.org/simple/($pkg)/" --headers [Accept application/vnd.pypi.simple.v1+json]
    | from json | get files | where not yanked and core-metadata != false
    | each { |info|
      let whl = ($info.filename | parse '{name}-{ver}-{py}-{abi}-{arch}.whl' | into record)
      { ...$info, whl: $whl }
    }
    | to json | uv run --with=packaging python -c 'import sys, json, packaging.version; json.dump([e for e in json.load(sys.stdin) if not packaging.version.Version(e["whl"]["ver"]).is_prerelease], sys.stdout)' | from json
    | last
  )
  let deps = (http get $"($info.url).metadata" | decode utf-8 | email parse | get Requires-Dist | find -vr 'extra ==')

  { ...$info.whl, deps: $deps }
}

def pyprofile [
  --hatch-env (-e): string
  --rate (-r): int = 100
  code: string
] {
  let tmp = (mktemp -t --suffix=.speedscope.json)
  let python: string = (if ($hatch_env == null) {
    'python'
  } else {
    let envs = (^hatch env find $hatch_env | lines)
    if ($envs | length) != 1 {
      return (error make { msg: $'Found multiple envs instead of 1: ($envs)' })
    }
    $'($envs | get 0)/bin/python'
  })
  let cmd = [py-spy record --format speedscope -r $rate -o $tmp -- $python -c $code]
  match $nu.os-info.name {
    'linux' => { run-external ...$cmd },
    'macos' => { run-external sudo ...$cmd },
  }
  ^speedscope $tmp
  unlink $tmp
}

def 'hatch env find' [search: string] {
  ^hatch env find $search | lines | each { |path|
    let exists = try { ls -D $path; true } catch { false }
    if $exists {
      $path | url encode | prepend 'file://' | str join '' | ansi link --text $path
    } else {
      $path
    }
  }
}

def 'sphobjinv co json' [
  -u
  in_file: string
  out_file: string = 'objects.json'
] {
  let full_args = ([(if ($u) { ['-u'] } else []), [$in_file, $out_file]] | flatten)
  if $out_file != '-' {
    return (^sphobjinv co json ...$full_args)
  }
  let raw = (^sphobjinv co json ...$full_args | complete | get stdout | from json)
  let entries = ($raw | reject project version metadata count | values)
  return ($raw | select project version metadata | insert entries $entries)
}

def "torrent list" [] {
  let hashes = (qdbus6 org.kde.ktorrent /core org.ktorrent.core.torrents | lines)
  let torrents = ($hashes | wrap hash | insert name { |e| (qdbus6 org.kde.ktorrent $"/torrent/($e.hash)" name | str trim) })
  $torrents | each { |t| { value: ($t.hash | to nuon), description: $t.name } }
}

# Check torrent status
def "torrent status" [torrent_: string@"torrent list"] {
  let torrent = if $torrent_ != '' {
    $torrent_
  } else {
    let torrents = (torrent list)
    if ($torrents | length) == 1 {
      $torrents | get 0
    } else {
      return (error make { msg: $"There’s not exactly one torrent, but instead the following. Use `torrent-status <hash>` \n($torrents | transpose -rd | table)" })
    }
  }

  let torrent_arg = $'/torrent/($torrent)'
  let total_bytes = (qdbus6 org.kde.ktorrent $torrent_arg org.ktorrent.torrent.totalSize | into int | into filesize)
  let initial = (qdbus6 org.kde.ktorrent $torrent_arg org.ktorrent.torrent.bytesDownloaded | into int | into filesize)
  every 0.06sec {
    let bytes = (qdbus6 org.kde.ktorrent $torrent_arg org.ktorrent.torrent.bytesDownloaded | into int | into filesize)
    if $bytes >= $total_bytes { break }
    $bytes | into int
  } | to text | tqdm --update_to --unit=B --unit_scale=1 --unit_divisor=1024 --null $'--total=($total_bytes | into int)' $'--initial=($initial | into int)'
}

# Get full contents of wayland clipboard
def wl-contents [] {
  ^wl-paste --list-types
    | lines
    | wrap type
    | where type =~ '[^A-Z0-9_]+'
    | insert content { |it|
      let content = (wl-paste --no-newline --type $it.type);
      if $it.type =~ '^text/.*' { $content | into string } else { $content | into binary }
    }
}

# link minifuse input 1 with both speaker channels
def 'minifuse link' [on: bool] {
  for chan in [FL, FR] {
    pw-link ([
      (if $on { [] } else { ['-d'] }),
      'alsa_input.usb-ARTURIA_MiniFuse_2_8841400635054128-00.HiFi__minifuse12_mono_in_M2_0_0__source:capture_MONO',
      $'alsa_output.pci-0000_31_00.4.analog-stereo:playback_($chan)'
    ] | flatten)
  }
}

def 'ssh benchmark-machine' [] {
  let pw_jmp = (keyring get helmholtz-munich.de philipp.angerer | str trim)
  let pw_bnh = (keyring get scvbench.helmholtz-munich.de pangerer | str trim)
  sshpass -p $pw_jmp ssh -tt -o LogLevel=error philipp.angerer@cbjumphost sshpass -p $pw_bnh ssh -tt pangerer@scvbench bash
}

use ~/.cache/starship/init.nu
