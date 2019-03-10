Set-StrictMode -version latest

function foo([parameter(valuefrompipeline)]$_) {
    write-output "Got item: $_"
}