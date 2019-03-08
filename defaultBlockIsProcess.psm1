import-module $PSScriptRoot/core.psm1

function defaultBlockIsProcess($ast) {
  $ast = $function.ast
  # If function only has default block, rewrite so it's the process block
  if(-not $ast.body.beginblock -and -not $ast.body.processblock -and $ast.body.endBlock.unnamed) {
    $endBlock = $ast.body.endBlock
    
    $newSource =
      $ast.extent.text.substring(0, $endBlock.extent.startoffset) + `
      'process {' + $endBlock.extent.text + '}' + $ast.extent.text.substring($endBlock.extent.endOffset)
  }
  write-output $newSource
}