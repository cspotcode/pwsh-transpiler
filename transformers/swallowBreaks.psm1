import-module -force "$PSScriptRoot/../core.psm1"

function swallowBreaks($ast) {
  <# 
  .SYNOPSIS
  Swallow all `break` statements in this function and in code called by this function.
  #>

  $before = 'do {'
  $after = '} until($true)'
  wrapBlocks $ast $before $after
}
