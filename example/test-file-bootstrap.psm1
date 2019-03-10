import-module ./test-file.psm1












$sbAst = [Management.Automation.Language.Parser]::ParseInput("
    write-output fake1
    write-output fake2
    write-output fake3
    throw 'error'",
    'C:\Users\abradley\Documents\Personal-dev\@cspotcode\pwsh-transpiler\test-file.ps1',
    [ref]@(),
    [ref]@()
)
$sb = $sbAst.getScriptBlock()
. $sb
