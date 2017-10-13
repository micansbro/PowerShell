<#

Git is a version control system for tracking changes in computer files and coordinating work on those files among multiple people. 
It is primarily used for source code management in software development, but it can be used to keep track of changes in any set of files.

#>

$Directory = 'C:\TEMP\Git'
$fileName = 'Get-dayOfTheWeek.ps1'
$filePath = "$Directory\$fileName"
$Code = 'Get-Date -Format dddd'


# Install Git

	# Click, click, next method
		Download msi/exe from https://git-scm.com
    
    # Command line
	    Choco install git

# Make directory, file and add code
    
    New-Item $filePath -Force | Set-Content  -Value $Code
    . $filePath
    
# Create repository

    cd $Directory
    explorer.exe $Directory

    git init

    git status
        

# Commit code
    git add $fileName

    Git status
    
    git commit -m "Added a day of the week function"

    Set-Content $filePath 'Get-Date -Format ddd'

    . $filePath

    git status

    git add $fileName

    git commit -m 'Fixed output error'

# View commit history
    git log

# Undo commit
    git revert HEAD

# Git branching
    git branch testing
    git checkout testing

# Solving conflicts