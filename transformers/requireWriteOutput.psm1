Ipmo -fo $PSScriptRoot/../core.psm1

function requireWriteOutput($ast) {
    <#
    .SYNOPSIS
    Prevent accidental output by requiring use of Write-Output
    
    We do this by transforming all Write-Output calls into pwsh-transpiler-Write-Output calls,
    which wraps each value written to output in a wrapper class.
   
    Then each block is wrapped in a pipeline filter that unwraps wrapped items and suppresses all
    others.
    #>

    wrapBlocks $ast '. {' '} | . {process{if($_ -is [OutputWrapper]) {$_.value}}}'
}

# TODO emit this helper code into the target module
$helper = {
    class OutputWrapper {
        OutputWrapper([Object]$value) {
            $this.value = $value
        }
        [Object]$value
    }
}
. $helper
