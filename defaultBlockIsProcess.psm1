import-module -Force $PSScriptRoot/core.psm1

function defaultBlockIsProcess($ast) {
  # If function only has default block, rewrite so it's the process block
  if(-not $ast.body.beginblock -and -not $ast.body.processblock -and $ast.body.endBlock.unnamed) {
    $endBlock = $ast.body.endBlock
    extractBefore $ast $endBlock
    'process {'
    extractBlockStatements $endBlock
    '}'
    extractAfter $ast $endBlock
  } else {
      $ast
  }
}