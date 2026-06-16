. .\helpers\log_utils\ctstring.ps1  
. .\helpers\log_utils\kvstring.ps1  
. .\helpers\log_utils\Write-Logr.ps1

$validate_set_types = @(
    'inf',
    'wrn',
    'err',
    'api',
    'git',
    'act',
    'chk',
    'exc'
)

$kvstring_types = @(
    'inf',
    'err',
    'wrn',
    'prop',
    'property',
    'api',
    'git',
    'value',
    'type',
    'key',
    'meta',
    'metadata',
    'confval',
    'none'
)

$colors = 1..256

$validateset_actions = @( 
            'create',
            'read',
            'update',
            'delete',
            'push',
            'pull',
            'convert',
            'check',
            'config',
            'fetch',
            'request',
            'response',
            'patch',
            'build',
            'sticher',
            'compile',
            'astscan',
            'exc',
            'ast',
            'test',
            'lint',
            'format',
            'gitpull',
            'gitpush',
            'gitfetch',
            'gitclone',
            'gitmerge',
            'gitbranch',
            'success',
            'complete',
            'finished',
            'failed',
            'error',
            'warning',
            'info',
            'debug',
            'trace',
            'gemparser',
            'action'
)

$global:__logging = $true # enable logging globally Write-logr will not output unless this is set to true

foreach ($type in $validate_set_types) {
    foreach ($action in $validateset_actions) {
        Write-Logr -Message "Test Message {$($kvstring_types | get-random):kv:KeyName=value can have space and be of anysize}" `
                   -Action $action `
                   -Type $type `
                   -LogName "autotest"
    }
    foreach ($type in $validate_set_types) { 
        Write-Logr -Message "Test Message {$($kvstring_types | get-random):kv:KeyName=value can have space and be of anysize}" `
                   -Action ($validateset_actions | Where-Object { $_ -ne "none" } | get-random) `
                   -Type $type `
                   -LogName "autotest" `
                   -ChildLog
    }
    
}

# no timestand and embedded name
# foreach ($type in $validate_set_types) {
#     foreach ($action in $validateset_actions) {
#         Write-Logr -Message "Test Message {$($kvstring_types | get-random):kv:KeyName=value and be of anysize},{ct:$($colors | get-random):b:Text in random 256 color}" -Action $action -Type $type -LogName "autotest" -EmbeddedName 'Test-Auto' -ChildLog
#     }
#     foreach ($type in $validate_set_types) {
#         Write-Logr -Message "Test Message {$($kvstring_types | get-random):kv:KeyName=value can have space and be of anysize},{ct:$($colors | get-random):b:Text in random 256 color}" -Action "create" -Type $type -LogName "autotest" -ChildLog -EmbeddedName 'Test-Auto'
#     }
    
# }