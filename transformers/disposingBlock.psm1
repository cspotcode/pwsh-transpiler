<#

Support a new `disposing {}` block that is called when an error happens.

Ideally this would be its own block.  To simulate that, however, we put it at the top of the `begin {}` block.

    function {
        begin {
            disposing {
                # cleanup code here
            }
        }
    }

This is valid PS syntax and is easy for our code transformer to detect and process.

We can't actually invent new powershell syntax with these transformers, since they use Pwsh's built-in
parser and AST.  However, we can get close enough.

The goal is not to match target syntax *exactly*.  The goal is to get so close that it is trivial for
developers to:
    a) understand how their code will look when native syntax is introduced
    b) convert their code to native syntax in the future (we can even write a transformer to do that)

#>