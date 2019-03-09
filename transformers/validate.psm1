import-module -Force $PSScriptRoot/../core.psm1

<#
 # Not a transformer per-se.  It validates the input function,
 # throwing a helpful error if you're using syntax that the transformers do not yet support.
 #>
function validate($ast) {
  # if(-not $ast.body.paramblock) {
  #   throw 'We do not yet support omitting the param() block from your functions.'
  # }
  $ast
}