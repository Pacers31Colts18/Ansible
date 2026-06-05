function ConvertTo-DistinguishedName {
    param([string]$CanonicalName)
    $parts = $CanonicalName.Split('/')
    $domain = $parts[0]
    $ouParts = $parts[1..($parts.Length - 1)]
    $dcParts = ($domain.Split('.') | ForEach-Object { "DC=$_" }) -join ','
    $ouDN = if ($ouParts.Count -gt 0) {
        (($ouParts | Select-Object -Last ($ouParts.Count) | ForEach-Object { "OU=$_" } | Sort-Object -Descending) -join ',') + ','
    } else { "" }
    return "$ouDN$dcParts"
}