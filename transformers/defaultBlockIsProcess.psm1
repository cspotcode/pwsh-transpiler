import-module -Force $PSScriptRoot/../core.psm1

function defaultBlockIsProcess($ast) {
  # If function only has default block, rewrite so it's the process block
  if(-not $ast.body.beginblock -and -not $ast.body.processblock -and $ast.body.endBlock.unnamed) {
    write-host 'rewriting'
    $endBlock = $ast.body.endBlock
    $param = $ast.body.paramblock
    $paramFirstAttribute = $param.attributes[0]
    extractBefore $ast $param
    $param
    'process {'
    extractBetween $ast $param $endBlock.statements[0]
    $endBlock.statements[0]
    extractAfter $endBlock $endBlock.statements[0]
    '}'
    extractAfter $ast $endBlock
  } else {
      $ast
  }
}