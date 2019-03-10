import-module -Force $PSScriptRoot/../core.psm1

function validate($ast) {
  <#
  .SYNOPSIS
  Not a transformer per-se.  It validates the input function,
  throwing a helpful error if it uses syntax that these transformers do not yet support.
  #>

  # if(-not $ast.body.paramblock) {
  #   throw 'We do not yet support omitting the param() block from your functions.'
  # }
  $ast
}