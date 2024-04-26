# Nushell Environment Config File

def create_left_prompt [] {
    let path_segment = ($env.PWD)

    $path_segment
}

def create_right_prompt [] {
    let time_segment = ([
        (date now | format date '%F %T')
    ] | str join)

    $time_segment
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = { || create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = { || "〉\u{200C}" }
$env.PROMPT_INDICATOR_VI_INSERT = { || ": " }
$env.PROMPT_INDICATOR_VI_NORMAL = { || "〉\u{200C}" }
$env.PROMPT_MULTILINE_INDICATOR = { || "::: " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) }
    to_string: { |v| $v | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) }
    to_string: { |v| $v | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
$env.NU_LIB_DIRS = [
  ($nu.config-path | path dirname | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
  ($nu.config-path | path dirname | path join 'plugins'),
  ($'($env.HOME)/.cargo/bin'),
]

let data_dir = $'($env.HOME)/(
  if $nu.os-info.name == 'macos' {
    "Library/Application Support"
  } else {
    $env | get -i XDG_DATA_HOME | default ".local/share"
  }
)'

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
$env.PATH = ($env.PATH | split row (char esep) | prepend [
  $'($env.HOME)/.local/bin'
  $'($env.HOME)/.cargo/bin',
  $'($data_dir)/hatch/pythons/3.11/python/bin',
  $'($data_dir)/hatch/pythons/3.10/python/bin',
  '/nix/var/nix/profiles/default/bin',
  '/run/current-system/sw/bin',
  '/usr/local/bin',
])

if not (which fnm | is-empty) {
  load-env (^fnm env --json | from json)
  $env.PATH = ($env.PATH | append $"($env.FNM_MULTISHELL_PATH)/bin")
  #$env.YARN_GLOBAL_FOLDER = $"($env.FNM_MULTISHELL_PATH)/yarn-global"
  #$env.YARN_PREFIX = $env.FNM_MULTISHELL_PATH
}

#TODO don’t overwrite PATH here
if ('/opt/context-lmtx/setuptex' | path exists) {
  load-env (
    bash -c ". /opt/context-lmtx/setuptex; jq -n '$ENV'"
    | from json
    | transpose var val
    | where var in (
      open -r /opt/context-lmtx/setuptex | lines | parse '    export {v}' | get v
    ) | transpose -rd
  )
}

echo | do -i { DISPLAY=':0' bash -c 'ssh-add&' } | complete | ignore
$env.EDITOR = (if (which kate | is-empty) { 'code -w' } else { 'kate -b' })
$env.PAGER = 'less'
$env.PARU_PAGER = 'git delta'  # paru prefers $PAGER to its own config
$env.DIFFPROG = 'git delta'  # for pacdiff
$env.MERGEPROG = 'kdiff3'  # for pacdiff

$env.SYSTEMD_LESS = 'FRSMK'
$env.LESS = $'-($env.SYSTEMD_LESS)'
$env.BAT_PAGER = $'less ($env.LESS)'

$env.DOCKER_BUILDKIT = '1'

# On systems where a global `pip` exists and the Python install isn’t marked as external, I want this:
# $env.PIP_REQUIRE_VIRTUALENV = 'true'
$env.PNPM_HOME = $'($env.HOME)/.local/bin'
# TODO remove, is part of plasmashell env
# $env.PASSWORD_STORE_DIR = $env | get -i XDG_DATA_HOME | default $'($env.HOME)/.local/share' | path join password-store

$env.VIRTUAL_ENV_DISABLE_PROMPT = true

mkdir ~/.cache/starship
starship init nu | save -f ~/.cache/starship/init.nu
