#Can we write CmdLets as classes, to get lexical scoping?

enum Block {
    dynamicparams;
    begin;
    process;
    end;
}

$outer = 'this is outer'
class MyCmdlet {
    MyCmdlet([management.automation.pscmdlet]$PsCmdLet) {
        $this.pscmdlet = $pscmdlet
    }
    [management.automation.pscmdlet]$pscmdlet
    body([Block]$block, $_) {
        $foo = $null
        switch ($block) {
            dynamicparams {
                write-host 'dp block'
                ([ref]$foo).value += "dp"
            }
            begin {
                write-host 'begin block'
                ([ref]$foo).value += "b"
            }
            process {
                write-host 'process block'
                ([ref]$foo).value += "p"
            }
            end {

            }
        }
        $this.pscmdlet.writeObject($foo)
    }
}

function foo {
    [cmdletbinding()]
    param()
    $c = [MyCmdlet]::new($pscmdlet)
    $c.body('dynamicparams', 123)
    $c.body('begin', 123)
    $c.body('process', 123)
}