function ConvertTo-APNMarkdownInspectionReport {
    <#
    .SYNOPSIS

    Converts Appian inspection results to a markdown table.

    .DESCRIPTION

    Converts Appian inspection results to a markdown table.

    .PARAMETER InputObject

    The input object to convert.

    .OUTPUTS

    String, The inspection results in markdown table format

    .EXAMPLE
    $content = Get-Content -Path $pathToFile
    ConvertTo-APNMarkdownInspectionReport -InputObject $content

    .LINK

    https://docs.appian.com/suite/help/22.1/Deployment_Rest_API.html
    #>
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory)]
        [PSObject[]]
        $InputObject
    )

    begin {
        $objectsExpected = $InputObject.summary.objectsExpected
        $problems = $InputObject.summary.problems
        $errorRows = @()
        $errorColumns = @{ }
        $errorHeaderOrder = @(
            'objectName'
            'errorMessage'
            'objectUuid'
        )
        $warningRows = @()
        $warningColumns = @{ }
        $warningHeaderOrder = @(
            'objectName'
            'warningMessage'
            'objectUuid'
        )
    }

    process {
        foreach ($row in $problems.errors) {
            $errorRows += $row
            foreach ($property in $row.PSObject.Properties) {
                if ($null -ne $property.Value) {
                    if (-not $errorColumns.ContainsKey($property.Name) -or $errorColumns[$property.Name] -lt $property.Value.ToString().Length) {
                        $errorColumns[$property.Name] = $property.Value.ToString().Length
                    }
                }
            }
        }
        $errorRows = $errorRows | Sort-Object 'objectName'

        foreach ($row in $problems.warnings) {
            $warningRows += $row
            foreach ($property in $row.PSObject.Properties) {
                if ($null -ne $property.Value) {
                    if (-not $warningColumns.ContainsKey($property.Name) -or $warningColumns[$property.Name] -lt $property.Value.ToString().Length) {
                        $warningColumns[$property.Name] = $property.Value.ToString().Length
                    }
                }
            }
        }
        $warningRows = $warningRows | Sort-Object 'objectName'
    }

    end {
        # Summary
        '# Summary'
        '## Objects Expected'
        "- Total $($objectsExpected.Total)"
        "- Imported $($objectsExpected.Imported)"
        "- Failed $($objectsExpected.Failed)"
        "- Skipped $($objectsExpected.Skipped)"
        # Problems
        '# Problems'
        "- Total Errors $($problems.totalErrors)"
        "- Total Warnings $($problems.totalWarnings)"
        If ($problems.totalErrors -gt 0) {
            '## Errors'
            # Column width
            foreach ($key in $($errorColumns.Keys)) {
                $errorColumns[$key] = [Math]::Max($errorColumns[$key], $key.Length)
            }
            # Header
            $header = @()
            $sortedKeys = $errorColumns.Keys | Sort-Object { $errorHeaderOrder.IndexOf($PSitem) }
            foreach ($key in $sortedKeys) {
                $header += ('{0,-' + $errorColumns[$key] + '}') -f $key
            }
            $header -join ' | '
            # Separator
            $separator = @()
            foreach ($key in $sortedKeys) {
                $separator += '-' * $errorColumns[$key]
            }
            $separator -join ' | '
            # Rows
            foreach ($row in $errorRows) {
                $values = @()
                foreach ($key in $sortedKeys) {
                    $values += ('{0,-' + $errorColumns[$key] + '}') -f $row.($key)
                }
                $values -join ' | '
            }
        }
        If ($problems.totalWarnings -gt 0) {
            '## Warnings'
            foreach ($key in $($warningColumns.Keys)) {
                $warningColumns[$key] = [Math]::Max($warningColumns[$key], $key.Length)
            }
            # Header
            $header = @()
            $sortedKeys = $warningColumns.Keys | Sort-Object { $warningHeaderOrder.IndexOf($PSitem) }
            foreach ($key in $sortedKeys) {
                $header += ('{0,-' + $warningColumns[$key] + '}') -f $key
            }
            $header -join ' | '
            # Separator
            $separator = @()
            foreach ($key in $sortedKeys) {
                $separator += '-' * $warningColumns[$key]
            }
            $separator -join ' | '
            # Rows
            foreach ($row in $warningRows) {
                $values = @()
                foreach ($key in $sortedKeys) {
                    $values += ('{0,-' + $warningColumns[$key] + '}') -f $row.($key)
                }
                $values -join ' | '
            }
        }

    }
}
