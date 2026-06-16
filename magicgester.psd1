@{
    RootModule         = 'magicgester.psm1'
    ModuleVersion      = '0.2.0'
    GUID               = '7419527a-be12-42d4-910f-b26e8027a3c1'
    Author             = 'Garvey k. Snow'
    CompanyName        = 'Phellams'
    Copyright          = '(c) 2025 Garvey k. Snow. All rights reserved.'
    Description        = 'High-Performance Asset Generation & Management Engine for automated SVG-to-multi-format pipelines.'
    
    FunctionsToExport  = @(
        'Invoke-Mystro'
    )
    
    CmdletsToExport    = @()
    VariablesToExport  = @()
    
    AliasesToExport    = @(
        'mystro'
    )
    
    PrivateData        = @{
        PSData = @{
            Tags                     = @('Automation', 'SVG', 'ImageMagick', 'Inkscape', 'AssetPipeline', 'TUI')
            ReleaseNotes             = @{
                '0.2.0' = 'V2 Release: Object-oriented pipeline, auto-scaling engine, and professional TUI suite.'
            }
            RequireLicenseAcceptance = $false
            LicenseUri               = 'https://choosealicense.com/licenses/mit'
            ProjectUri               = 'https://gitlab.kenscloud.online/phallems/glvigor.git'
            IconUri                  = 'https://gitlab.kenscloud.online/phallems/glvigor/-/blob/main/logo.svg'
            
            # CHOCOLATE ---------------------
            ChocoDescription         = 'High-Performance Asset Generation & Management Engine for automated SVG-to-multi-format pipelines.'
            ChocoTitle               = 'MagicGester - High-Performance Asset Engine'
            LicenseUrl               = 'https://choosealicense.com/licenses/mit'
            ProjectUrl               = 'https://gitlab.kenscloud.online/phallems/glvigor.git'
            IconUrl                  = 'https://gitlab.kenscloud.online/phallems/glvigor/-/blob/main/logo.svg'
            Docsurl                  = 'https://gitlab.kenscloud.online/phallems/glvigor/-/wikis/home'
            MailingListUrl           = 'https://gitlab.kenscloud.online/phallems/glvigor/-/issues'
            projectSourceUrl         = 'https://gitlab.kenscloud.online/phallems/glvigor.git'
            bugTrackerUrl            = 'https://gitlab.kenscloud.online/phallems/glvigor/-/issues'
            Summary                  = 'Automated high-speed asset generation pipeline.'
            # CHOCOLATE ---------------------
            Prerelease               = 'alpha1'
        }        
    }
    
    RequiredModules    = @()
    RequiredAssemblies = @()
    FormatsToProcess   = @()
    TypesToProcess     = @()
    NestedModules      = @()
    ScriptsToProcess   = @()
}
