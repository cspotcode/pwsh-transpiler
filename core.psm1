# Simple source-to-source transformer for PowerShell functions

function transform($fn, $transformer) {
    $result = & $transformer (normalizeToFunctionAst $fn)
    return (normalizeToFunctionAst $result)
}

# Convert source code string into a FunctionDefinitionAst
function normalizeToFunctionAst($sourceText) {
  # Allow transformers to emit an array of strings and AST nodes
  if($fn.count -gt 1) {
    $acc = ''
    foreach($item in $fn) {
      if($item -is [Management.Automation.Language.Ast]) {
        $acc += $item.extent.text
      }
    }
    $fn = $acc
  }
  # Normalize to a function AST
  if($fn -is [scriptblock]) { $fn = $fn.ast }
  if($fn -is [string]) { $fn = stringToFunctionAst $fn }
  return $fn
}

function stringToFunctionAst($str) {
  $sb = [scriptblock]::create($sourceText)
  return $sb.Ast.EndBlock.Statements[0]
}

function extractBlockStatements($blockAst) {
  $rootOffset = $ast.extent.startoffset
  $start = $ast.statements[0].extent.startoffset - $rootOffset
  $end = $ast.statements[-1].extent.endoffset - $rootOffset
  return $ast.extent.text.substring($start, $end)
}


function extractBefore($rootAst, $beforeAst) {
  $rootOffset = $rootAst.extent.startoffset
  $end = $beforeAst.extent.startOffset - $rootOffset
  return $rootAst.extent.text.substring(0, $end)
}

function extractAfter($rootAst, $afterAst) {
  $rootOffset = $rootAst.extent.startoffset
  $start = $afterAst.extent.endOffset - $rootOffset
  return $rootAst.extent.text.substring($start)
}

function extractBetween($rootAst, $beforeAst, $afterAst) {
  $rootOffset = $rootAst.extent.startoffset
  $start = $beforeAst.extent.endoffset - $rootOffset
  $end = $afterAst.extent.startoffset - $rootOffset
  return $rootAst.extent.text.substring($start, $end)
}
