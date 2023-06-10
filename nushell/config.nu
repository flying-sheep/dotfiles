# Nushell Config File

use conda.nu

module completions {
  def "nu-complete qdbus servicenames" [] {
    ^qdbus | lines | where $it !~ '^:' | each { |line| $line | str trim } | sort
  }

  def "nu-complete qdbus path" [line: string, pos: int] {
    let args = ($line | str trim | split row ' ' | skip 1)
    ^qdbus $args.0 | lines | each { |line| $line | str trim } | sort
  }

  def "nu-complete qdbus method" [line: string, pos: int] {
    let args = ($line | str trim | split row ' ' | skip 1)
    ^qdbus $args.0 $args.1 | lines | str trim |
      parse -r '(?P<kind>\w+) (?P<rtype>[\w\s]+) (?P<name>[\w.]+)(\((?P<args>[\w\s,]*)\))?' |
      each { |sig|
        # method [Q_NOREPLY] void org.freedesktop.DBus.Properties.Set(QString interface_name, QString property_name, QDBusVariant value)
        { value: $sig.name, description: $"($sig.rtype) \(($sig.kind)\)" }
      }
  }
  
  export extern qdbus [
    servicename?: string@"nu-complete qdbus servicenames"
    path?: string@"nu-complete qdbus path"
    method?: string@"nu-complete qdbus method"
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
  let scheme_nr = (qdbus org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read "org.freedesktop.appearance" "color-scheme" | into int)
  return ($scheme_nr == 1)  # light: 2, no pref: 0
}

let-env CLIPBOARD_THEME = (if (should-be-dark) { 'dark' } else { 'light' })

let carapace_completer = { |spans| 
  {
    $spans.0: { || carapace $spans.0 nushell $spans | from json } # default
    paru: { || carapace pacman nushell $spans | from json }
    #example: { example _carapace nushell $spans | from json }
    #vault: { carapace --bridge vault/posener nushell $spans | from json }
  } | get $spans.0 | each {|it| do $it}
}

let version = ((version).version | parse -r '^(?P<major>\d+)\.(?P<minor>\d+)(?:\.(?P<patch>\d+))?$' | transpose name val | update val { |row| $row.val | into int } | transpose -ird)

# The default config record. This is where much of your global configuration is setup.
let-env config = {
  ls: {
    use_ls_colors: true  # use the LS_COLORS environment variable to colorize output
    clickable_links: true # enable or disable clickable links. Your terminal has to support links.
  }
  rm: {
    always_trash: false  # always act as if -t was given. Can be overridden with -p
  }
  cd: {
    abbreviations: true  # allows `cd s/o/f` to expand to `cd some/other/folder`
  }
  table: {
    mode: rounded  # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
    index_mode: always  # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
    trim: {
      methodology: wrapping  # wrapping or truncating
      wrapping_try_keep_words: true  # A strategy used by the 'wrapping' methodology
      truncating_suffix: "..."  # A suffix used by the 'truncating' methodology
    }
  }
  history: {
    max_size: 10000 # Session has to be reloaded for this to take effect
    sync_on_enter: true # Enable to share the history between multiple sessions, else you have to close the session to persist history to file
    file_format: "plaintext"  # "sqlite" or "plaintext"
  }
  completions: {
    case_sensitive: false  # set to true to enable case-sensitive completions
    quick: true  # set this to false to prevent auto-selecting completions when only one remains
    partial: true  # set this to false to prevent partial filling of the prompt
    algorithm: "prefix"  # prefix or fuzzy
    external: {
      enable: true  # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
      max_results: 100  # setting it lower can improve completion performance at the cost of omitting some options
      completer: $carapace_completer
    }
  }
  filesize: {
    metric: true  # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
    format: "auto"  # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, zb, zib, auto
  }
  color_config: (if (should-be-dark) { $dark_theme } else { $light_theme })
  use_grid_icons: true
  footer_mode: "25"  # always, never, number_of_rows, auto
  float_precision: 2
  # buffer_editor: "emacs"  # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
  use_ansi_coloring: true
  edit_mode: emacs  # emacs, vi
  shell_integration: true  # enables terminal markers and a workaround to arrow keys stop working issue
  show_banner: false
  render_right_prompt_on_last_line: false  # true or false to enable or disable right prompt to be rendered on last line of the prompt.
  hooks: (
    {
      pre_prompt: [{ ||
        $nothing  # replace with source code to run before the prompt is shown
      }]
      pre_execution: [{ ||
        $nothing  # replace with source code to run before the repl input is run
      }]
      env_change: {
        PWD: [{ |before, after|
          $nothing  # replace with source code to run if the PWD environment is different since the last repl input
        }]
      }
      display_output: { ||
        if (term size).columns >= 100 { table -e } else { table }
      }
    } | merge (
      if $version.major >= 1 or ($version.major == 0 and $version.minor >= 78) {
        {
          command_not_found: { |cmd_name| (
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
      } else { {} }
    )
  )
  menus: [
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
  keybindings: [
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
}

def 'into filesize2' [...cols] {
  let start = $in
  $cols | reduce --fold $start { |col, df|
    $df | upsert $col { |row|
      if ($row | get $col | empty?) { null } else { $row | get $col | into filesize }
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
  paru -Rcns (paru -Qdtq | lines)
  print (msg 'Cleaning PKGBUILD dirs')
  for dir in ([
    (ls ~/.cache/paru/clone/* | get name),
    (ls ~/Dev/PKGBUILDs/checkouts/*/* | get name),
  ] | flatten) { do -i { ^git -C $dir clean -fx } }
  print (msg 'Pruning package cache')
  ^sudo pacman -Sc
  print (msg 'Uninstalling old Rust toolchains')
  rustup toolchain list | lines | str replace -s ' (default)' '' | where $it =~ '^\d+[.]\d+|^nightly-\d{4}' | each { |tc| rustup toolchain uninstall $tc }
  $nothing
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
  exit (error make {msg: $'TODO: get YouTube ($yt_ver) apk'})
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
  ^pip list -v --format=json | from json
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

# Execute a closure repeatedly
def every [duration: duration, closure: closure] {
  0.. | each { |it|
    let ret = ($it | do $closure $it)
    sleep $duration
    $ret
  }
}

def "torrent list" [] {
  let hashes = (qdbus org.kde.ktorrent /core org.ktorrent.core.torrents | lines)
  let torrents = ($hashes | wrap hash | insert name { |e| (qdbus org.kde.ktorrent $"/torrent/($e.hash)" name | str trim) })
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
  let total_bytes = (qdbus org.kde.ktorrent $torrent_arg org.ktorrent.torrent.totalSize | into int | into filesize)
  let initial = (qdbus org.kde.ktorrent $torrent_arg org.ktorrent.torrent.bytesDownloaded | into int | into filesize)
  every 0.06sec {
    let bytes = (qdbus org.kde.ktorrent $torrent_arg org.ktorrent.torrent.bytesDownloaded | into int | into filesize)
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