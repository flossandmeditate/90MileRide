param(
  [int]$StartYear = 2027,
  [int]$EndYear = 2027,
  [string]$OutputDirectory = "$PSScriptRoot\..\data"
)

$ErrorActionPreference = "Stop"
$apiKey = $env:NIWA_API_KEY

if ([string]::IsNullOrWhiteSpace($apiKey)) {
  throw "Set NIWA_API_KEY in the current PowerShell session before running this script."
}

if ($apiKey -match 'your-new-regenerated-key|paste-your-regenerated-key-here|^\s*placeholder\s*$') {
  throw "NIWA_API_KEY is still set to a placeholder value. Replace it with your real NIWA API key from the NIWA developer portal."
}

if ($apiKey.Length -lt 20) {
  throw "NIWA_API_KEY looks too short. Use the API key value, not the secret, label, or placeholder text."
}

if ($EndYear -lt $StartYear) {
  throw "EndYear must be greater than or equal to StartYear."
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$endpoint = "https://api.niwa.co.nz/tides/data"

for ($year = $StartYear; $year -le $EndYear; $year++) {
  $predictions = [System.Collections.Generic.List[object]]::new()
  $cursor = Get-Date -Date "$year-01-01T00:00:00"
  $yearEnd = Get-Date -Date "$($year + 1)-01-01T00:00:00"

  Write-Host "Downloading $year..."

  while ($cursor -lt $yearEnd) {
    $remainingDays = [math]::Ceiling(($yearEnd - $cursor).TotalDays)
    $numberOfDays = [math]::Min(31, [int]$remainingDays)
    $query = "lat=-34.537&long=172.736&numberOfDays=$numberOfDays&startDate=$($cursor.ToString('yyyy-MM-dd'))&datum=LAT"

    $response = Invoke-RestMethod -Uri "$endpoint`?$query" -Headers @{ "x-apikey" = $apiKey }
    $rows = @($response.values)

    if ($rows.Count -eq 0) {
      throw "NIWA returned no tide values for $($cursor.ToString('yyyy-MM-dd')). No file was written for $year."
    }

    foreach ($row in $rows) {
      $time = $row.time
      $height = $row.value
      if ($time -and $null -ne $height) {
        $predictions.Add([ordered]@{ time = $time; height = [double]$height })
      }
    }

    $cursor = $cursor.AddDays($numberOfDays)
  }

  $output = [ordered]@{
    source = "NIWA Tide Forecasting API"
    latitude = -34.537
    longitude = 172.736
    datum = "LAT"
    generated = (Get-Date).ToUniversalTime().ToString("o")
    predictions = $predictions
  }

  if ($predictions.Count -eq 0) {
    throw "No predictions were collected for $year. No file was written."
  }

  $file = Join-Path $OutputDirectory "$year.json"
  $output | ConvertTo-Json -Depth 5 | Set-Content -Path $file -Encoding UTF8
  Write-Host "Wrote $file with $($predictions.Count) predictions."
}

Write-Host "Finished. The NIWA key was used only from the environment and was not written to disk."