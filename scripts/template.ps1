<#
Generic in-place markdown template rendering
Delimit spans with `<!--{ ...scriptblock here... }--><!--/-->`
The body will be replaced with the output of ScriptBlock
Template syntax will be preserved so you can keep the template syntax and output
in the same file.
#>
param(
    [string]$Path,
    [string]$OutputPath,
    [switch]$InPlace,
    [Parameter(ValueFromPipeline)]$InputObject
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'stop'

class Block {
    [string]$prefix = ''
    [string]$openingTag = [nullstring]::value
    [ScriptBlock]$scriptBlock = $null
    [Collections.Generic.List[Object]]$body = [Collections.Generic.List[Object]]::new()
    [string]$closingTag = ''
    [string]$suffix = ''
}

# Result of parsing for blocks
# returns array of fully parsed blocks
# returns closingTag that made it have to stop
# returns everything after that
class ParseResult {
    [Block[]]$blocks
    [string]$closingTag
    [string]$remainder
}

<#
Parse a single scriptblock.
Return parseresult
#>
function _parse([string]$sourceText) {
    $result = [ParseResult]::new()
    
    $a = $sourceText
    $block = $null
    $result.blocks = while($true) {
        $_m = $a | select-string -pattern '^(?<prefix>[\s\S]*?)(?:(?<openingTag><!--{(?<scriptBlock>[\s\S]*?)}-->)|(?<closingTag><!--/-->))'
        if(-not $_m) {
            if(-not $block) {
                $block = [block]::new()
                $block
            }
            $block.suffix = $a
            break
        }
        $m = matchDict $_m
        $remainder = $a.substring($_m.matches[0].length)
        if($m['closingTag']) {
            if(-not $block) {
                $block = [block]::new()
                $block
            }
            $block.suffix = $m.prefix
            $result.closingTag = $m.closingTag
            $result.remainder = $remainder
            break
        }
        $block = [Block]::new()
        $block.prefix = $m.prefix
        $block.openingTag = $m.openingTag
        $block.scriptBlock = [scriptblock]::create($m.scriptBlock)

        $r = _parse($remainder)
        $block.body = $r.blocks
        $block.closingTag = $r.closingTag
        $a = $r.remainder

        # write out
        $block
    }
    $result
}
function parse([string]$sourceText) {
    $r = _parse $sourceText
    $b = [Block]::new()
    $b.body = $r.blocks
    $b.suffix = $r.remainder
    $b
}
function matchDict($m) {
    $dict = @{}
    $m.matches[0].groups | % {
        $dict.($_.name) = $_.value
    }
    $dict
}

# $block = parse @"
#     hello world
#     <!--{ `$a = 2 ; echo `$a }-->
#     between hello and world
#     <!--{ echo 2 }-->
#     body of world
#     <!--/-->
#     between closing tags
#     <!--/-->
#     <!--{ `$a += 3 ; echo `$a }-->
#     <!--/-->
# "@

function render([block]$b) {
    $renderModule = new-module -scriptblock {}
    _render $b
}
function _render([block]$b) {
    (. {
        $b.prefix
        $b.openingTag
        if($b.scriptBlock) {
            (& $renderModule $b.scriptBlock) -join "`n"
        } else {
            foreach($b2 in $b.body) {
                _render $b2
            }
        }
        $b.closingTag
        $b.suffix
    }) -join ''
}

$input = $InputObject
if($Path) {
    $input = get-content -raw $Path
}
$output = render (parse $input)
if($InPlace) {
    out-file -encoding utf8 -nonewline -literalpath $path -inputobject $output
} elseif($OutputPath) {
    out-file -encoding utf8 -nonewline -literalpath $outputPath -inputobject $output
} else {
    $output
}