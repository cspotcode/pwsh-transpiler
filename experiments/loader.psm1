using module "./core.psm1"

function New-CompiledModule($Path) {
    <#
    .SYNOPSIS
    Transpile and instantiate a module.
    Pipe to Import-Module to bring exports into scope.
    #>

    $sourceText = get-content -raw $Path
    $sb = [scriptblock]::create($sourceText)
    $ast = $sb.ast

    # TODO Pass through transformer stack
    $replacements = [Replacements]::new()
    foreach($statement in $ast.endblock.statements) {
        if($statement -is [Management.Automation.Language.FunctionDefinitionAst]) {
            $transformed = transformFunctionAst $statement
            $replacements.add($statement, $transformed.extent.text)
        }
    }
    $sourceText = $replacements.apply($ast)

    # TODO all current transformers assume a FunctionDeclarationAst
    # Allow transformers to have a *type* so we can invoke them with whole script
    # or only with function declaration.

    # Compile and execute as a new module
    $finalAst = [Management.Automation.Language.Parser]::ParseInput($sourceText, $Path, [ref]@(), [ref]@())
    $moduleScriptBlock = $finalAst.getScriptBlock()
    $Name = Split-Path -LeafBase $Path
    $module = New-Module -Name $Name -ScriptBlock $moduleScriptBlock
    $module
}

$transformers = @(
    # Catch early limitations
    'validate',

    # Normalize syntax; makes subsequent transformers easier to write because
    # they don't have to deal with as many corner-cases
    'parametersToParamBlock',
    'defaultBlockIsProcess',
    'createEmptyBlocks',

    # Additional transformations and behaviors
    'swallowBreaks',
    'blocksWrappedInTryCatch',
    'expandAliases'
)

pushd "$PSScriptRoot/.."
try {
    $transformerFunctions = . {
        foreach($t in $transformers) {
            import-module -Force ./transformers/$t.psm1
            get-command $t
        }
    }
} finally {
    popd
}
function transformFunctionAst($ast) {
    $result = $ast
    foreach($transformer in $transformerFunctions) {
        # write-host "Applying transformation $transformer"
        try {
            $result = transform $result $transformer
        } catch {
            throw $_
        }
        # write-host $result
    }
    $result
}
