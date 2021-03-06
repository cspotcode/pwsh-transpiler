import-module -Force $PSScriptRoot/../core.psm1

function parametersToParamBlock($ast) {
    <#
    .SYNOPSIS
    Move params into a param() block and add [cmdletbinding()]

    Convert `function foo($a) {}` into `function {[cmdletbinding()]param($a)}`
    #>

    if(-not $ast.body.paramblock) {
        if($ast.parameters) {
            $paramBlockContent = $ast.parameters
            extractBefore $ast $ast.parameters[0]
            extractBetween $ast $ast.parameters[-1] $ast.body
        } else {
            $paramBlockContent = ''
            extractBefore $ast $ast.body
        }
        '{[cmdletbinding()]param('
        $paramBlockContent
        ')'
        (extractSpan $ast $ast.body $ast.body).substring(1)
        extractAfter $ast $ast.body
    } else {
        $ast
    }
}