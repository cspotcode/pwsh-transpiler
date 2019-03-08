import-module $PSScriptRoot/core.psm1

function blocksWrappedInTryCatch($ast) {
  extractBefore $ast $ast.body.beginBlock
  'try {'
  extractBlockStatements $ast.body.beginBlock
  '} catch {throw $_}'
  extractBetween $ast $ast.body.beginBlock $ast.body.processBlock
  'try {'
  extractBlockStatements $ast.body.processBlock
  '} catch {throw $_}'
  extractBetween $ast $ast.body.processBlock $ast.body.endBlock
  'try {'
  extractBlockStatements $ast.body.endBlock
  '} catch {throw $_}'
  extractAfter $ast $ast.body.endBlock
}