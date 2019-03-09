# Simple source-to-source transformer for PowerShell functions

function transform($fn, $transformer) {
    $result = & $transformer (normalizeToFunctionAst $fn)
    return (normalizeToFunctionAst $result)
}

# Convert source code string into a FunctionDefinitionAst
function normalizeToFunctionAst($sourceText) {
  # Allow transformers to emit an array of strings and AST nodes
  if($sourceText.count -gt 1) {
    $acc = ''
    foreach($item in $sourceText) {
      if($item -is [Management.Automation.Language.Ast]) {
        $acc += $item.extent.text
      } elseif($item -is [string]) {
        $acc += $item
      } else {
        throw '$item is unexpected type: ' + $item.gettype()
      }
    }
    $sourceText = $acc
  }
  # Normalize to a function AST
  if($sourceText -is [scriptblock]) { $sourceText = $sourceText.ast }
  if($sourceText -is [string]) { $sourceText = stringToFunctionAst $sourceText }
  return $sourceText
}

function stringToFunctionAst([string]$str) {
  $sb = [scriptblock]::create($str)
  return $sb.Ast.EndBlock.Statements[0]
}

function extractBlockStatements([Management.automation.language.NamedBlockAst]$blockAst) {
  $rootOffset = $blockAst.extent.startoffset
  $start = $blockAst.statements[0].extent.startoffset - $rootOffset
  $end = $blockAst.statements[-1].extent.endoffset - $rootOffset
  return $blockAst.extent.text.substring($start, $end - $start)
}
function extractSpan([Management.automation.language.Ast]$rootAst, [Management.automation.language.Ast]$beginAst, [Management.automation.language.Ast]$endAst) {
  $rootOffset = $rootAst.extent.startoffset
  $start = $beginAst.extent.startoffset - $rootOffset
  $end = $endAst.extent.endoffset - $rootOffset
  return $rootAst.extent.text.substring($start, $end - $start)
}

function extractBefore([management.automation.language.ast]$rootAst, [management.automation.language.ast]$beforeAst) {
  $rootOffset = $rootAst.extent.startoffset
  $end = $beforeAst.extent.startOffset - $rootOffset
  return $rootAst.extent.text.substring(0, $end)
}

function extractAfter([management.automation.language.ast]$rootAst, [management.automation.language.ast]$afterAst) {
  $rootOffset = $rootAst.extent.startoffset
  $start = $afterAst.extent.endOffset - $rootOffset
  return $rootAst.extent.text.substring($start)
}

function extractBetween([management.automation.language.ast]$rootAst, [management.automation.language.ast]$beforeAst, [management.automation.language.ast]$afterAst) {
  $rootOffset = $rootAst.extent.startoffset
  $start = $beforeAst.extent.endoffset - $rootOffset
  $end = $afterAst.extent.startoffset - $rootOffset
  return $rootAst.extent.text.substring($start, $end - $start)
}

class ReplacingVisitor : Management.Automation.Language.AstVisitor2 {
    ReplacingVisitor() {
        $this.replacements = [Replacements]::new()
    }
    [Replacements]$replacements
}

class Replacement {
    Replacement([Management.Automation.Language.Ast]$node, [string]$text) {
        $this.node = $node
        $this.text = $text
        $this.start = $node.extent.startoffset
    }
    [Management.Automation.Language.Ast]$node
    [string]$text
    [int]$start
}

class Replacements {
    [System.Collections.Generic.List[Replacement]]$list = [System.Collections.Generic.List[Replacement]]::new()
    add([Management.Automation.Language.Ast]$node, [string]$text) {
        $this.list.insert(0, [Replacement]::new($node, $text))
    }
    [string] apply([Management.Automation.Language.Ast]$ast) {
        $acc = ''
        $baseOffset = $ast.extent.startoffset
        $sliceEnd = $ast.extent.endoffset - $baseOffset
        foreach($r in $this.list) {
            $sliceStart = $r.node.extent.endoffset - $baseOffset
            $acc = $r.text + $ast.extent.text.substring($sliceStart, $sliceEnd - $sliceStart) + $acc
            $sliceEnd = $r.node.extent.startOffset - $baseOffset
        }
        $sliceStart = 0
        $acc = $ast.extent.text.substring(0, $sliceEnd) + $acc
        return $acc
    }
}
