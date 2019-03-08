using module "./core.psm1"

class Visitor : ReplacingVisitor {
    [Management.Automation.Language.AstVisitAction]VisitCommand([Management.Automation.Language.CommandAst]$commandAst) {
        $commandName = $commandAst.CommandElements[0]
        $alias = get-alias $commandName.Value
        if($alias) {
            $this.replacements.add($commandName, "$( $alias.ResolvedCommand.Source )\$( $alias.ResolvedCommand.Name )")
        }
        return [Management.Automation.Language.astvisitaction]::Continue
    }
}

function expandAliases([Management.Automation.Language.FunctionDefinitionAst]$ast) {
    $visitor = [Visitor]::new()
    $ast.visit($visitor)
    return $visitor.replacements.apply($ast)
}
