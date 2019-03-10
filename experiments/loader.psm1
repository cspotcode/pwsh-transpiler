function Import-CompiledModule($Path) {
    <#
    .SYNOPSIS
    Transpile and Import a module
    #>

    $sourceText = get-content -raw $Path
    $sb = [scriptblock]::create($sourceText)
    $ast = $sb.ast

    # TODO Pass through transformer stack

    # TODO all current transformers assume a FunctionDeclarationAst
    # Allow transformers to have a *type* so we can invoke them with whole script
    # or only with function declaration.

    # Compile and execute as a new module
    $finalAst = [Management.Automation.Language.Parser]::ParseInput(ast.extent.text, $Path, [ref]@(), [ref]@())
    $moduleScriptBlock = $finalAst.getScriptBlock()
    $Name = Split-Path -LeafBase $Path
    $module = New-Module -Name $Name -ScriptBlock $moduleScriptBlock
    $module | Import-Module
}