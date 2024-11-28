# Define the path for the tasks file
$taskFilePath = "$HOME\.config\Tasks\tasks.txt"

# Ensure the task file exists
if (!(Test-Path -Path $taskFilePath)) {
    New-Item -ItemType File -Path $taskFilePath -Force | Out-Null
}

# Function to add a new task
function Add-Task {
    param (
        [string]$taskDescription
    )
    # Append the new task with "incomplete" status
    "$taskDescription : incomplete" | Out-File -FilePath $taskFilePath -Append -Encoding UTF8
    Write-Host "Task added: $taskDescription"
}

# Function to mark a task as complete
function Complete-Task {
    param (
        [int]$taskNumber
    )
    # Read all tasks from file
    $tasks = Get-Content -Path $taskFilePath -Encoding UTF8
    if ($taskNumber -le 0 -or $taskNumber -gt $tasks.Count) {
        Write-Host "Invalid task number."
        return
    }

    # Mark the selected task as complete
    $tasks[$taskNumber - 1] = $tasks[$taskNumber - 1] -replace ": incomplete$", ": complete"
    $tasks | Set-Content -Path $taskFilePath -Encoding UTF8
    Write-Host "Task #$taskNumber marked as complete."
}

# Function to clear all tasks
function Clear-Tasks {
    Clear-Content -Path $taskFilePath
    Write-Host "All tasks have been cleared." -ForegroundColor Red
}

# Function to display incomplete tasks
function Show-IncompleteTasks {
    $tasks = Get-Content -Path $taskFilePath -Encoding UTF8
    $incompleteTasks = $tasks | Where-Object { $_ -match ": incomplete$" }

    if ($incompleteTasks.Count -eq 0) {
        Write-Host "( .-.)" -ForegroundColor Green
    } else {
        $index = 1
        foreach ($task in $incompleteTasks) {
            Write-Host "> $task" -ForegroundColor Yellow
            $index++
        }
    }
}


# Function to delete a specific task
function Remove-Task {
    param (
        [int]$taskNumber
    )
    # Read all tasks from file
    $tasks = Get-Content -Path $taskFilePath -Encoding UTF8
    if ($taskNumber -le 0 -or $taskNumber -gt $tasks.Count) {
        Write-Host "Invalid task number."
        return
    }

    # Remove the selected task
    $tasks = $tasks[0..($taskNumber - 2)] + $tasks[$taskNumber..($tasks.Count - 1)]

    # Write the updated task list back to the file
    $tasks | Set-Content -Path $taskFilePath -Encoding UTF8
    Write-Host "Task #$taskNumber has been deleted."
}



# Override the PowerShell prompt to display tasks on every prompt
Show-IncompleteTasks
function prompt {
    $p = Split-Path -leaf -path (Get-Location)
    return " ~ $p> "  # Customizes the prompt display
}

#icons
Import-Module -Name Terminal-Icons

#Alias
Set-Alias c clear
Set-Alias st Show-IncompleteTasks
Set-Alias at Add-Task
Set-Alias ct Complete-Task
Set-Alias dt Clear-Tasks
