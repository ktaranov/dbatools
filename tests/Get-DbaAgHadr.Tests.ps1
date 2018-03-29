$CommandName = $MyInvocation.MyCommand.Name.Replace(".Tests.ps1", "")
Write-Host -Object "Running $PSCommandPath" -ForegroundColor Cyan
. "$PSScriptRoot\constants.ps1"

Describe "$CommandName Unit Tests" -Tag "UnitTests" {
    Context "Validate parameters" {
        $paramCount = 3
        $defaultParamCount = 11
        [object[]]$params = (Get-ChildItem function:\Get-DbaAgHadr).Parameters.Keys
        $knownParameters = 'SqlInstance', 'Credential', 'EnableException'
        It "Should contian our specifc parameters" {
            ( (Compare-Object -ReferenceObject $knownParameters -DifferenceObject $params -IncludeEqual | Where-Object SideIndicator -eq "==").Count ) | Should Be $paramCount
        }
        It "Should only contain $paramCount parameters" {
            $params.Count - $defaultParamCount | Should Be $paramCount
        }
    }
}

Describe "$CommandName Integration Test" -Tag "IntegrationTests" {
    $results = Get-DbaAgHadr -SqlInstance $script:instance2
    Context "Validate output" {
        It "returns the correct properties" {
            $ExpectedProps = 'ComputerName,InstanceName,SqlInstance,IsHadrEnabled'.Split(',')
            ($results.PsObject.Properties.Name | Sort-Object) | Should -Be ($ExpectedProps | Sort-Object)
        }
        foreach ($result in $results) {
            It "returns a bool for IsHadrEnabled" {
                $result.IsHadrEnabled -is [bool] | Should -Be $true
            }
        }
    }
}