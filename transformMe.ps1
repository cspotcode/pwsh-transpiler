param($parentInvocation)

pushd $PSScriptRoot
try {
    import-module -Force $PSScriptRoot/core.psm1
    import-module -Force $PSScriptRoot/transformers/createEmptyBlocks.psm1
    import-module -Force $PSScriptRoot/transformers/blocksWrappedInTryCatch.psm1
    import-module -Force $PSScriptRoot/transformers/defaultBlockIsProcess.psm1
    import-module -Force $PSScriptRoot/transformers/expandAliases.psm1
} finally {
    popd
}

# A default stack of transformations
# TODO allow modules to pass a custom stack
function __transform($cmd) {
    $result = $cmd.scriptblock
    $result = transform $result ( get-command defaultBlockIsProcess )
    $result = transform $result ( get-command createEmptyBlocks )
    $result = transform $result ( get-command blocksWrappedInTryCatch )
    $result = transform $result ( get-command expandAliases )
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
