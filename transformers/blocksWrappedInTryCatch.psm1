import-module -Force $PSScriptRoot/../core.psm1

function blocksWrappedInTryCatch($ast) {
  # This wrapper is lifted from https://github.com/PoshCode/PowerShellPracticeAndStyle/issues/37#issuecomment-338117653
  # There are pros and cons to this approach; we should eventually pick something better, since we can afford the complexity.
  $try = 'try {'
  $catch = '} catch {$PSCmdlet.ThrowTerminatingError($PSItem)}'
  extractBefore $ast $ast.body.beginBlock.statements[0]
  $try
  extractBlockStatements $ast.body.beginBlock
  $catch
  extractBetween $ast $ast.body.beginBlock.statements[-1] $ast.body.processBlock.statements[0]
  $try
  extractBlockStatements $ast.body.processBlock
  $catch
  extractBetween $ast $ast.body.processBlock.statements[-1] $ast.body.endBlock.statements[0]
  $try
  extractBlockStatements $ast.body.endBlock
  $catch
  extractAfter $ast $ast.body.endBlock.statements[-1]
}