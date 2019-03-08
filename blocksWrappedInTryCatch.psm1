import-module -Force $PSScriptRoot/core.psm1

function blocksWrappedInTryCatch($ast) {
  extractBefore $ast $ast.body.beginBlock.statements[0]
  'try {'
  extractBlockStatements $ast.body.beginBlock
  '} catch {throw $_}'
  extractBetween $ast $ast.body.beginBlock.statements[-1] $ast.body.processBlock.statements[0]
  'try {'
  extractBlockStatements $ast.body.processBlock
  '} catch {throw $_}'
  extractBetween $ast $ast.body.processBlock.statements[-1] $ast.body.endBlock.statements[0]
  'try {'
  extractBlockStatements $ast.body.endBlock
  '} catch {throw $_}'
  extractAfter $ast $ast.body.endBlock.statements[-1]
}