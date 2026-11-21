# Generates integration scripts for the original uopilot.exe from the unit
# tests cases in tests/unit/cases/*.tsv.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File tests\integration\tools\gen_integration_tests.ps1
#   powershell -ExecutionPolicy Bypass -File tests\integration\tools\gen_integration_tests.ps1 -Check
#
# -Check regenerates in memory and compares with the committed .txt files.
# A difference (or a missing file) makes the script exit with code 1.
#
# Output: UTF-8 without BOM, LF line endings, like the other integration
# scripts. The generator itself is intentionally ASCII-only: Windows
# PowerShell 5.1 reads .ps1 without BOM using the system ANSI code page.

param(
  [switch]$Check,
  [string]$OutputDir = ''
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$integrationDir = Split-Path -Parent $scriptDir
$rootDir = Split-Path -Parent (Split-Path -Parent $integrationDir)
$casesDir = Join-Path $rootDir 'tests\unit\cases'
if ($OutputDir -eq '') {
  $OutputDir = $integrationDir
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$emDash = [string][char]0x2014

# Production parses floating-point literals and timestamps with the system
# locale. The unit binary forces '.' / yyyy-mm-dd, so these cases stay unit
# only; the generator marks them as locale skips instead of emitting scripts
# that would fail or abort on a non-en-US machine.
$localeMathSkips = @(
  'round_2_4', 'round_2_6', 'round_neg_2_6',
  'floor_2_9', 'floor_neg_2_1',
  'ceil_2_1', 'ceil_neg_2_9',
  'trunc_pos', 'trunc_neg'
)

$fileMap = @(
  @{ Tsv = 'expr_math.tsv';  Txt = 'expr_math_tests.txt' },
  @{ Tsv = 'expr_dates.tsv'; Txt = 'expr_dates_tests.txt' },
  @{ Tsv = 'expr_constants.tsv'; Txt = 'expr_constants_tests.txt' },
  @{ Tsv = 'cmd_set.tsv';    Txt = 'cmd_set_tests.txt' },
  @{ Tsv = 'arrays.tsv';     Txt = 'arrays_tests.txt' },
  @{ Tsv = 'flow.tsv';       Txt = 'flow_tests.txt' },
  @{ Tsv = 'known_bugs.tsv'; Txt = 'known_bugs_tests.txt' }
)

function Unescape-Tsv([string]$s) {
  # Mirrors uScriptTestCases.Unescape: only \n, \r, \t and \\ are decoded;
  # unknown escapes such as \d and \w are preserved for regexp patterns.
  $sb = New-Object System.Text.StringBuilder
  $i = 0
  while ($i -lt $s.Length) {
    $c = $s[$i]
    if (($c -eq '\') -and (($i + 1) -lt $s.Length)) {
      $n = $s[$i + 1]
      if ($n -eq 'n') {
        [void]$sb.Append([char]10)
        $i += 2
      } elseif ($n -eq 'r') {
        [void]$sb.Append([char]13)
        $i += 2
      } elseif ($n -eq 't') {
        [void]$sb.Append([char]9)
        $i += 2
      } elseif ($n -eq '\') {
        [void]$sb.Append('\')
        $i += 2
      } else {
        [void]$sb.Append($c)
        $i += 1
      }
    } else {
      [void]$sb.Append($c)
      $i += 1
    }
  }
  return $sb.ToString()
}

function Read-Tsv([string]$path) {
  $text = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
  $text = $text.TrimStart([char]0xFEFF)
  $rawLines = $text -split "`n"
  $rows = New-Object System.Collections.ArrayList
  $lineIndex = 0
  foreach ($raw in $rawLines) {
    $line = $raw
    if ($line.EndsWith("`r")) {
      $line = $line.Substring(0, $line.Length - 1)
    }
    if (($lineIndex -eq 0) -and $line.StartsWith('name' + "`t")) {
      $lineIndex += 1
      continue
    }
    $lineIndex += 1
    if ($line -eq '') {
      continue
    }
    if ($line.StartsWith('//')) {
      continue
    }
    $f = $line -split "`t"
    if ($f.Length -ne 6) {
      throw ("{0}:{1}: expected 6 TSV columns, got {2}" -f $path, $lineIndex, $f.Length)
    }
    $rec = [pscustomobject]@{
      Name     = $f[0].Trim()
      Kind     = $f[1].Trim()
      Target   = $f[2].Trim()
      Script   = (Unescape-Tsv $f[3])
      Expected = (Unescape-Tsv $f[4])
      Note     = $f[5]
    }
    if ($rec.Name -eq '') {
      throw ("{0}:{1}: empty name" -f $path, $lineIndex)
    }
    if (($rec.Kind -ne 'eval') -and ($rec.Kind -ne 'script') -and ($rec.Kind -ne 'skip')) {
      throw ("{0}:{1}: unknown kind '{2}'" -f $path, $lineIndex, $rec.Kind)
    }
    [void]$rows.Add($rec)
  }
  return ,$rows.ToArray()
}

function Test-Numeric([string]$s) {
  return ($s -match '^-?[0-9]+$')
}

function Get-ScriptLines([string]$script) {
  $out = New-Object System.Collections.ArrayList
  foreach ($raw in ($script -split "`n")) {
    $line = $raw
    if ($line.EndsWith("`r")) {
      $line = $line.Substring(0, $line.Length - 1)
    }
    [void]$out.Add($line)
  }
  return ,$out.ToArray()
}

function Test-ArrayScriptIs2D([string]$script) {
  # A `set %name value` line with a pipe or slash in the value creates a 2D
  # array. Bracket form (`set %a [1] value`) is always a single cell.
  foreach ($line in (Get-ScriptLines $script)) {
    if ($line -match '^\s*set\s+%[A-Za-z0-9_]+\s+([^\[\s][^\n]*)$') {
      if ($Matches[1] -match '[|/]') {
        return $true
      }
    }
  }
  return $false
}

function Get-ArrayName([string]$script, [string]$target) {
  if ($target.StartsWith('%')) {
    $m = [regex]::Match($target, '^%([A-Za-z0-9_]+)')
    if ($m.Success) {
      return $m.Groups[1].Value
    }
  }
  foreach ($line in (Get-ScriptLines $script)) {
    $m = [regex]::Match($line, '^\s*(?:set|delete_array|sort_array)\s+%([A-Za-z0-9_]+)')
    if ($m.Success) {
      return $m.Groups[1].Value
    }
  }
  return ''
}

function Transform-Body([string]$script, [string]$name) {
  # Namespaces case-local labels and rewrites end_script to a goto that
  # preserves the observable variable state. `case N:` inside switch is left
  # untouched: it does not start with a colon.
  $out = New-Object System.Collections.ArrayList
  $hasEndScript = $false
  foreach ($line in (Get-ScriptLines $script)) {
    $trim = $line.Trim()
    if ($trim -match '^:([A-Za-z0-9_]+)$') {
      [void]$out.Add(':case_' + $name + '_' + $Matches[1])
      continue
    }
    if ($trim -imatch '^(goto|gosub)\s+([A-Za-z0-9_]+)$') {
      [void]$out.Add($Matches[1] + ' case_' + $name + '_' + $Matches[2])
      continue
    }
    if ($trim -ieq 'end_script') {
      [void]$out.Add('goto case_' + $name + '_end')
      $hasEndScript = $true
      continue
    }
    [void]$out.Add($line)
  }
  if ($hasEndScript) {
    [void]$out.Add(':case_' + $name + '_end')
  }
  return ,$out.ToArray()
}

function Get-SkipReason($rec) {
  if ($rec.Kind -eq 'skip') {
    return $rec.Note
  }
  if ($rec.Expected.Contains('"')) {
    return 'expected value contains a double quote; escaping is not established for the production engine'
  }
  if ($rec.Name -eq 'flow_end_script') {
    return 'stops the script; covered by unit tests only'
  }
  if ($rec.Name -eq 'flow_exit') {
    return 'stops the process; covered by unit tests only'
  }
  if ($localeMathSkips -contains $rec.Name) {
    return 'decimal separator is locale-dependent in production; covered by unit tests with a forced "."'
  }
  if ($rec.Script -match 'timestamp\s*\(') {
    return 'timestamp parsing uses the system locale (StrToDateTime); covered by unit tests with a forced locale'
  }
  if ($rec.Target.StartsWith('%')) {
    $m = [regex]::Match($rec.Target, '^%[A-Za-z0-9_]+\[([0-9]+)\]\[([0-9]+)\]$')
    if (-not $m.Success) {
      return 'array target is not a supported cell reference'
    }
    if ([int]$m.Groups[2].Value -gt 1) {
      return 'array cell references are not supported in production expressions'
    }
    if (Test-ArrayScriptIs2D $rec.Script) {
      return 'two-dimensional array; covered indirectly by arrays_2d_tests.txt'
    }
  }
  return $null
}

function Add-AssertForValue($lines, [string]$readLine, [string]$expected) {
  # String targets are always compared as strings, even when the expected
  # text looks numeric (for example the string variable set by
  # set_case_insensitive_str). Empty values go through ord(): size("") is a
  # known crash (BUGS.md).
  [void]$lines.Add($readLine)
  if ($expected -eq '') {
    [void]$lines.Add('set #t_num_actual ord($t_str_actual)')
    [void]$lines.Add('set #t_num_expected 0')
    [void]$lines.Add('gosub assert_num')
  } else {
    [void]$lines.Add('set $t_str_expected "' + $expected + '"')
    [void]$lines.Add('gosub assert_str')
  }
}

function Render-Case($rec) {
  $lines = New-Object System.Collections.ArrayList
  $name = $rec.Name
  [void]$lines.Add(':case_' + $name)
  [void]$lines.Add('set $t_name ' + $name)

  if ($rec.Kind -eq 'eval') {
    [void]$lines.Add('set $t_input ' + $rec.Script)
    if ($rec.Expected -eq '') {
      [void]$lines.Add('set $t_str_actual ' + $rec.Script)
      [void]$lines.Add('set #t_num_actual ord($t_str_actual)')
      [void]$lines.Add('set #t_num_expected 0')
      [void]$lines.Add('gosub assert_num')
    } elseif (Test-Numeric $rec.Expected) {
      [void]$lines.Add('set #t_num_actual ' + $rec.Script)
      [void]$lines.Add('set #t_num_expected ' + $rec.Expected)
      [void]$lines.Add('gosub assert_num')
    } else {
      [void]$lines.Add('set $t_str_actual ' + $rec.Script)
      [void]$lines.Add('set $t_str_expected "' + $rec.Expected + '"')
      [void]$lines.Add('gosub assert_str')
    }
    [void]$lines.Add('return')
    return ,$lines.ToArray()
  }

  [void]$lines.Add('set $t_input ' + $name)

  $arrayName = Get-ArrayName $rec.Script $rec.Target
  if ($arrayName -ne '') {
    [void]$lines.Add('delete_array %' + $arrayName + ' -1 100')
  }

  foreach ($b in (Transform-Body $rec.Script $name)) {
    [void]$lines.Add($b)
  }

  $t = $rec.Target
  if ($t.StartsWith('#')) {
    [void]$lines.Add('set #t_num_actual ' + $t)
    if ($rec.Expected -eq '') {
      [void]$lines.Add('set #t_num_expected 0')
    } else {
      [void]$lines.Add('set #t_num_expected ' + $rec.Expected)
    }
    [void]$lines.Add('gosub assert_num')
  } elseif ($t.StartsWith('$')) {
    Add-AssertForValue $lines ('set $t_str_actual ' + $t) $rec.Expected
  } elseif ($t.StartsWith('%')) {
    $m = [regex]::Match($t, '^%([A-Za-z0-9_]+)\[([0-9]+)\]\[([0-9]+)\]$')
    $row = $m.Groups[2].Value
    $cellRef = '%' + $m.Groups[1].Value + '[' + $row + ']'
    Add-AssertForValue $lines ('set $t_str_actual ' + $cellRef) $rec.Expected
  } else {
    throw ("unsupported target '{0}' for case {1}" -f $t, $name)
  }

  [void]$lines.Add('return')
  return ,$lines.ToArray()
}

function Get-HelperLines() {
  $lines = New-Object System.Collections.ArrayList
  [void]$lines.Add(':assert_num')
  [void]$lines.Add('if #t_num_actual = #t_num_expected')
  [void]$lines.Add('  log PASS $t_name')
  [void]$lines.Add('  set #pass #pass + 1')
  [void]$lines.Add('else')
  [void]$lines.Add('  log FAIL $t_name input=$t_input actual=#t_num_actual expected=#t_num_expected')
  [void]$lines.Add('  set #fail #fail + 1')
  [void]$lines.Add('end_if')
  [void]$lines.Add('return')
  [void]$lines.Add('')
  [void]$lines.Add(':assert_str')
  [void]$lines.Add('set #t_p1 posex($t_str_expected $t_str_actual)')
  [void]$lines.Add('set #t_p2 posex($t_str_actual $t_str_expected)')
  [void]$lines.Add('if (#t_p1 = 1) and (#t_p2 = 1)')
  [void]$lines.Add('  log PASS $t_name')
  [void]$lines.Add('  set #pass #pass + 1')
  [void]$lines.Add('else')
  [void]$lines.Add('  log FAIL $t_name input=$t_input actual=$t_str_actual expected=$t_str_expected')
  [void]$lines.Add('  set #fail #fail + 1')
  [void]$lines.Add('end_if')
  [void]$lines.Add('return')
  [void]$lines.Add('')
  [void]$lines.Add(':test_summary')
  [void]$lines.Add('log TEST RESULT PASS=#pass FAIL=#fail')
  [void]$lines.Add('if #fail = 0')
  [void]$lines.Add('  log ALL TESTS PASSED')
  [void]$lines.Add('else')
  [void]$lines.Add('  log SOME TESTS FAILED')
  [void]$lines.Add('end_if')
  [void]$lines.Add('return')
  return ,$lines.ToArray()
}

function Build-File($entry) {
  $tsvPath = Join-Path $casesDir $entry.Tsv
  $rows = Read-Tsv $tsvPath

  $executed = New-Object System.Collections.ArrayList
  $skipped = New-Object System.Collections.ArrayList
  foreach ($rec in $rows) {
    $reason = Get-SkipReason $rec
    if ($reason -ne $null) {
      [void]$skipped.Add([pscustomobject]@{ Rec = $rec; Reason = $reason })
    } else {
      [void]$executed.Add($rec)
    }
  }

  $lines = New-Object System.Collections.ArrayList
  if ($skipped.Count -gt 0) {
    [void]$lines.Add('// Skipped cases (not executed):')
    foreach ($sk in $skipped) {
      [void]$lines.Add('// SKIP: ' + $sk.Rec.Name + ' ' + $emDash + ' ' + $sk.Reason)
    }
  }
  [void]$lines.Add('log clear')
  [void]$lines.Add('log mode noTime')
  [void]$lines.Add('set linedelay 0')
  [void]$lines.Add('set #pass 0')
  [void]$lines.Add('set #fail 0')
  [void]$lines.Add('')

  foreach ($rec in $executed) {
    [void]$lines.Add('gosub case_' + $rec.Name)
  }
  [void]$lines.Add('')
  [void]$lines.Add('gosub test_summary')
  [void]$lines.Add('exit')
  [void]$lines.Add('')
  [void]$lines.Add('')
  [void]$lines.Add('// ===== assertion helpers =====')
  foreach ($h in (Get-HelperLines)) {
    [void]$lines.Add($h)
  }
  [void]$lines.Add('')
  [void]$lines.Add('')
  [void]$lines.Add('// ===== cases =====')
  foreach ($rec in $executed) {
    [void]$lines.Add('')
    foreach ($c in (Render-Case $rec)) {
      [void]$lines.Add($c)
    }
  }

  $content = [string]::Join("`n", $lines.ToArray()) + "`n"
  return [pscustomobject]@{
    Content  = $content
    Executed = $executed.Count
    Skipped  = $skipped.Count
  }
}

$failures = 0
foreach ($entry in $fileMap) {
  $result = Build-File $entry
  $targetPath = Join-Path $OutputDir $entry.Txt

  if ($Check) {
    if (-not (Test-Path -LiteralPath $targetPath)) {
      Write-Host ('MISSING: {0}' -f $entry.Txt)
      $failures += 1
      continue
    }
    $existing = [System.IO.File]::ReadAllText($targetPath, [System.Text.Encoding]::UTF8)
    if ($existing -ne $result.Content) {
      Write-Host ('OUT OF DATE: {0} (run the generator without -Check)' -f $entry.Txt)
      $failures += 1
    }
  } else {
    [System.IO.File]::WriteAllText($targetPath, $result.Content, $utf8NoBom)
    Write-Host ('wrote {0}: {1} executed, {2} skipped' -f $entry.Txt, $result.Executed, $result.Skipped)
  }
}

if ($Check) {
  if ($failures -gt 0) {
    Write-Host ('Check failed: {0} file(s) differ.' -f $failures)
    exit 1
  }
  Write-Host 'All generated engine test files are up to date.'
  exit 0
}
