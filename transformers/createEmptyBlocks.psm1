import-module -Force $PSScriptRoot/../core.psm1

<#
 # Other transformers can be simpler if the input function has all blocks declared with at least one statement.
 # This is not ideal, but during prototyping, it's helpful.
 #>
function createEmptyBlocks($ast) {
  $dynamic = $ast.body.DynamicParamBlock
  $begin = $ast.body.beginBlock
  $process = $ast.body.processBlock
  $end = $ast.body.endBlock
  $all = @($dynamic, $begin, $process, $end) | ? { $_ }

  if($all.count -eq 0) {
    # HACK: append all missing blocks
    return $ast.extent.text -replace '}$',"dynamicparam{out-null}begin{out-null}process{out-null}end{out-null}}"
  }

  $prev = $null
  function emitBlockOrEmptyReplacement($block, $name) {
    if($block) {
      if(-not $prev) {
        extractBetween $ast $ast.body.paramblock $block
      } else {
        extractBetween $ast $prev $block
      }
      $block
      ([ref]$prev).value = $block
    } else {
      "$name{out-null}"
    }
  }

  extractBefore $ast $ast.body
  extractSpan $ast $ast.body $ast.body.paramblock
  emitBlockOrEmptyReplacement $dynamic 'dynamicparam'
  emitBlockOrEmptyReplacement $begin 'begin'
  emitBlockOrEmptyReplacement $process 'process'
  emitBlockOrEmptyReplacement $end 'end'
  extractAfter $ast $prev
}