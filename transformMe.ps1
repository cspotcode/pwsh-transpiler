param($parentInvocation)

$transformers = @(
    # Catch early limitations
    'validate',

    # Normalize syntax; makes subsequent transformers easier to write because
    # they don't have to deal with as many corner-cases
    'parametersToParamBlock',
    'defaultBlockIsProcess',
    'createEmptyBlocks',

    # Additional transformations and behaviors
    'blocksWrappedInTryCatch',
    'expandAliases'
)

pushd $PSScriptRoot
$transformerFunctions = . {
    try {
        foreach($t in $transformers) {
            import-module -Force $PSScriptRoot/transformers/$t.psm1
            get-command $t
        }
    } finally {
        popd
    }
}

# A default stack of transformations
# TODO allow modules to pass a custom stack
function __transform($cmd) {
    $result = $cmd.scriptblock
    foreach($transformer in $transformerFunctions) {
        write-host "Applying transformation $transformer"
        try {
            $result = transform $result $transformer
        } catch {
            throw $_
        }
        write-host $result
    }
    $result
}

$modulePath = $parentInvocation.MyCommand.Path
$sourceText = Get-Content -Raw $modulePath
$ast = [scriptblock]::create($sourceText).ast

foreach($statement in $ast.endblock.statements) {
    if($statement -is [Management.Automation.Language.FunctionDefinitionAst]) {
        $fn = get-command $statement.name
        write-host "Recompiling local function: $fn"
        $transformed = __transform $fn
        # Dot-source the result to re-declare the function
        . ([scriptblock]::create($transformed))
    }
}
