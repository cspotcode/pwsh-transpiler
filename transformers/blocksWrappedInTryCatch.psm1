import-module -Force $PSScriptRoot/../core.psm1
function blocksWrappedInTryCatch($ast) {
  <#
  .SYNOPSIS
  Wrap all function blocks in a `try {} catch {}` that throws errors predictably.
  #>
  $before = 'try {'
  $after = '} catch {$PSCmdlet.ThrowTerminatingError($PSItem)}'
  wrapBlocks $ast $before $after
}
