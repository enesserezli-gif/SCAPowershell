# SCAPowershell

# Disk Space Health Check

A PowerShell tool checks every fixwd drive across one or more Windows machines, calculates how full each is, and flags any drive running low on space - printing a color-coded status as it goes and expoerting one combined CSV report.

## What it does

-Pulls every local, fixed drive (skipping USB drives and network shares) using `Get-CimInstance`, on local machine or any list of remote machines you give it.
-Calculates percent free space for each drive.
-Labels each drive **Healthy** (green), **Warning** (yellow), or **Critical** (Red) against two adjustable thresholds.
-Prints a live, color-coded status line per computer and per drive.
-Exports one CSV report - computer name, size, free space, percent free, and status for every drive across every machine checked.
-Handles errors gracefully if a computer is unreachable, and keeps checking the rest instead of stopping the whole run.

## Why it's useful

Running out of disk space is one of the most common - and most preventable - server problems, but nobody wants to manually open file Explorer on every machine to check, especially across several servers. This turns that into a single automated pass across as many machines as you list, with configurable thresholds, and leaves behind a CSV you could hand to a manager, attach to a ticket, or feed into a scheduled report.

## How it works

1. An outer loop goes through each computer name given to it (defaults to the local machine).
2. For each one, `Get-CimInstance - ClassName Win32_LogicalDisk -Filter "DriveType=3"` pulls its fixed drives - locally for the machine the script is running on, or via `-ComputerName` for a remote one - wrapped in try/catch so one unreachable machine doesn't stop the whole run.
3. An inner loop calculates each drive's percent free space, then classifies it Healthy / Warning / Critical against two treshold parameters.
4. Each drive gets a colored status line immediately, tagged with its computer name, and is collected into a combined results list.
5. The full results are exported to oen timestamed CSV report.

## Usage

```PowerShell 
# Local machine
.\Disk_Space_Health_Check.ps1

# Check multiple lab machines in one run
.\Disk_Space_Health_Check.ps1 -ComputerName "LON-CL1","LON-DC1","LON-SVR1"

#Custom threshols
.\Disk_Space_Helath_Check.ps1 -ComputerName "LON-CL1","LON-DC1","LON-SVR1" -WarningThreshold 30 -CriticalThreshold 15```

## A note on checking the local machine by name

Passing `-ComputerName` - even pointing at the machine the script is running on - normally routes the request through WinRM instead of the fast local path, which fails if WinRM isn't configured there (common on client machines). This script detects when a target is local computer and skips the network call for it, using the direct local CIM provider instead.

## Demo Day Summary

**Problem:** Checking disk space across several machines by hand doesn't scale, and disk space issues are usually invisible until something breaks.

**Solution:** One script, run against a list of computers, that reports free space with clear color-coded status and a combined CSV report, handling unreachable machines gracefully instead crashing.

**Rubric coverage:** pipeline, `Get-CIMInstance`, filtering, error handling, looping, exporting results, progress messages, and checking multiple computers - every functional requirement, when only 3 were required.