use std/assert
use std/testing *

export def main []: record -> table {
  transpose name items
  | reduce --fold ({|| }) {|source prev_fn|
    {
      do $prev_fn | each --flatten {|left_item|
        $source.items | each {|right_item|
          $left_item | merge {($source.name): $right_item}
        }
      }
    }
  }
  | let fn

  [{}] | do $fn
}

@test
def "streaming-record-prod test" [] {
  let got = {
    color: [red, green]
    size: [small, large]
    letter: [A, B]
  } | main

  let expected = [
    [color, size, letter];
    [red, small, A]
    [red, small, B]
    [red, large, A]
    [red, large, B]
    [green, small, A]
    [green, small, B]
    [green, large, A]
    [green, large, B]
  ]

  assert equal $got $expected
}
