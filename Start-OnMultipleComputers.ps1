<#
	.SYNOPSIS
		This script is used to run a script or a script block on multiple computers.
	
	.DESCRIPTION
		This script
	
	.PARAMETER JsonFilePath
		The fullname of the Json file that contains the execution settings.
	
	.PARAMETER ScriptBlock
		The script block that will be ran on all specified computers.
	
	.PARAMETER ScriptFile
		The full name of the script to run
	
	.PARAMETER MaxThreats
		The maximum number of simultaneous jobs to run.
	
	.PARAMETER ListOfComputers
		The FQDNs of the computer on which the execution must be performed.
	
	.OUTPUTS
		pscustomobject, pscustomobject
	
	.NOTES
		===========================================================================
		Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2021 v5.8.192
		Created on:   	16-02-22 09:40
		Created by:   	stef
		Organization:
		Filename:
		===========================================================================
#>
[OutputType([pscustomobject], ParameterSetName = 'JSONFILE')]
[OutputType([pscustomobject], ParameterSetName = 'SCRIPTBLOCK')]
[OutputType([pscustomobject], ParameterSetName = 'SCRIPTFILE')]
param
(
	[Parameter(ParameterSetName = 'JSONFILE',
			   Position = 0,
			   HelpMessage = 'Json File Fullname')]
	[ValidateScript({ test-path $psitem })]
	[Alias('JFP')]
	[string]$JsonFilePath,
	[Parameter(ParameterSetName = 'SCRIPTBLOCK',
			   Mandatory = $true,
			   Position = 0,
			   HelpMessage = 'Script Block to run')]
	[ValidateScript({
			if (($psitem.gettype().name) -eq "ScriptBlock")
			{
				return $true
			}
			else
			{
				return $false
			}
		})]
	[Alias('SB')]
	[scriptblock]$ScriptBlock,
	[Parameter(ParameterSetName = 'SCRIPTFILE',
			   Mandatory = $true,
			   Position = 0,
			   HelpMessage = 'The full name of the script to run')]
	[ValidateScript({ test-path $psitem })]
	[Alias('SF')]
	[string]$ScriptFile,
	[Parameter(ParameterSetName = 'JSONFILE',
			   Position = 1,
			   HelpMessage = 'Max simultaneous jobs.')]
	[Parameter(ParameterSetName = 'SCRIPTBLOCK',
			   Position = 1,
			   HelpMessage = 'Max simultaneous jobs.')]
	[Parameter(ParameterSetName = 'SCRIPTFILE',
			   Position = 1,
			   HelpMessage = 'Max simultaneous jobs.')]
	[ValidateRange(1, 250)]
	[Alias('MT')]
	[int]$MaxThreats = (get-ComputerInfo).csNumberOfLogicalProcessors,
	[Parameter(ParameterSetName = 'SCRIPTBLOCK',
			   Mandatory = $true,
			   Position = 2,
			   HelpMessage = 'Target Computers FQDNs')]
	[Parameter(ParameterSetName = 'SCRIPTFILE',
			   Mandatory = $true,
			   Position = 2,
			   HelpMessage = 'Target Computers FQDNs')]
	[Alias('LOC')]
	[strin[]]$ListOfComputers
)

<###########################################################################################################################################################################################
                                                                                                                                                                                       
FFFFFFFFFFFFFFFFFFFFFFUUUUUUUU     UUUUUUUUNNNNNNNN        NNNNNNNN        CCCCCCCCCCCCCTTTTTTTTTTTTTTTTTTTTTTTIIIIIIIIII     OOOOOOOOO     NNNNNNNN        NNNNNNNN   SSSSSSSSSSSSSSS 
F::::::::::::::::::::FU::::::U     U::::::UN:::::::N       N::::::N     CCC::::::::::::CT:::::::::::::::::::::TI::::::::I   OO:::::::::OO   N:::::::N       N::::::N SS:::::::::::::::S
F::::::::::::::::::::FU::::::U     U::::::UN::::::::N      N::::::N   CC:::::::::::::::CT:::::::::::::::::::::TI::::::::I OO:::::::::::::OO N::::::::N      N::::::NS:::::SSSSSS::::::S
FF::::::FFFFFFFFF::::FUU:::::U     U:::::UUN:::::::::N     N::::::N  C:::::CCCCCCCC::::CT:::::TT:::::::TT:::::TII::::::IIO:::::::OOO:::::::ON:::::::::N     N::::::NS:::::S     SSSSSSS
  F:::::F       FFFFFF U:::::U     U:::::U N::::::::::N    N::::::N C:::::C       CCCCCCTTTTTT  T:::::T  TTTTTT  I::::I  O::::::O   O::::::ON::::::::::N    N::::::NS:::::S            
  F:::::F              U:::::D     D:::::U N:::::::::::N   N::::::NC:::::C                      T:::::T          I::::I  O:::::O     O:::::ON:::::::::::N   N::::::NS:::::S            
  F::::::FFFFFFFFFF    U:::::D     D:::::U N:::::::N::::N  N::::::NC:::::C                      T:::::T          I::::I  O:::::O     O:::::ON:::::::N::::N  N::::::N S::::SSSS         
  F:::::::::::::::F    U:::::D     D:::::U N::::::N N::::N N::::::NC:::::C                      T:::::T          I::::I  O:::::O     O:::::ON::::::N N::::N N::::::N  SS::::::SSSSS    
  F:::::::::::::::F    U:::::D     D:::::U N::::::N  N::::N:::::::NC:::::C                      T:::::T          I::::I  O:::::O     O:::::ON::::::N  N::::N:::::::N    SSS::::::::SS  
  F::::::FFFFFFFFFF    U:::::D     D:::::U N::::::N   N:::::::::::NC:::::C                      T:::::T          I::::I  O:::::O     O:::::ON::::::N   N:::::::::::N       SSSSSS::::S 
  F:::::F              U:::::D     D:::::U N::::::N    N::::::::::NC:::::C                      T:::::T          I::::I  O:::::O     O:::::ON::::::N    N::::::::::N            S:::::S
  F:::::F              U::::::U   U::::::U N::::::N     N:::::::::N C:::::C       CCCCCC        T:::::T          I::::I  O::::::O   O::::::ON::::::N     N:::::::::N            S:::::S
FF:::::::FF            U:::::::UUU:::::::U N::::::N      N::::::::N  C:::::CCCCCCCC::::C      TT:::::::TT      II::::::IIO:::::::OOO:::::::ON::::::N      N::::::::NSSSSSSS     S:::::S
F::::::::FF             UU:::::::::::::UU  N::::::N       N:::::::N   CC:::::::::::::::C      T:::::::::T      I::::::::I OO:::::::::::::OO N::::::N       N:::::::NS::::::SSSSSS:::::S
F::::::::FF               UU:::::::::UU    N::::::N        N::::::N     CCC::::::::::::C      T:::::::::T      I::::::::I   OO:::::::::OO   N::::::N        N::::::NS:::::::::::::::SS 
FFFFFFFFFFF                 UUUUUUUUU      NNNNNNNN         NNNNNNN        CCCCCCCCCCCCC      TTTTTTTTTTT      IIIIIIIIII     OOOOOOOOO     NNNNNNNN         NNNNNNN SSSSSSSSSSSSSSS   
  
###########################################################################################################################################################################################>

<#
	.SYNOPSIS
		This function retrieves data from finished jobs .
	
	.DESCRIPTION
		This function retrieves data from already completed jobs.
	
	.EXAMPLE
				PS C:\> Get-CompletedJobsData
	
	.NOTES
		Additional information about the function.
#>
function Get-CompletedJobsData
{
	[CmdletBinding()]
	param ()
	Write-Verbose "Retrieving Completed Jobs  ."
	$CurrentlycompletedJobs = Get-Job -State Completed
	
	foreach ($LoopInCurrentlyCompletedJobs in $CurrentlyCompletedJobs)
	{
		$JobData = Receive-Job $LoopInCurrentlyCompletedJobs
		$Script:StatusOfAllComputers.add($JobData) | Out-Null
		Remove-Job $JobData
		
	} # END 	foreach ($LoopInCurrentlyCompletedJobs in $CurrentlyCompletedJobs)
} # END function Get-CompletedJobsData


<#
	.SYNOPSIS
		This function retrieves data from finished Scripts .
	
	.DESCRIPTION
		This function retrieves data from already completed Scripts.
	
	.EXAMPLE
				PS C:\> Get-CompletedScriptsData
	
	.NOTES
		Additional information about the function.
#>
function Get-CompletedScriptsData
{
	[CmdletBinding()]
	param ()
	Write-Verbose "Retrieving Completed Scripts  ."
	$Currentlycompletedscripts = Get-Job -State Completed
	
	foreach ($LoopInCurrentlyCompletedScripts in $CurrentlyCompletedScripts)
	{
		$ScriptData = Receive-Job $LoopInCurrentlyCompletedScripts
		$script:ScriptExecutionStatus.add($ScriptData) | Out-Null
		Remove-Job $ScriptData
		
	} # END 	foreach ($LoopInCurrentlyCompletedJobs in $CurrentlyCompletedJobs)
} # END function Get-CompletedScriptsData





<####################################################################################################
                                                                                                  
MMMMMMMM               MMMMMMMM               AAA               IIIIIIIIIINNNNNNNN        NNNNNNNN
M:::::::M             M:::::::M              A:::A              I::::::::IN:::::::N       N::::::N
M::::::::M           M::::::::M             A:::::A             I::::::::IN::::::::N      N::::::N
M:::::::::M         M:::::::::M            A:::::::A            II::::::IIN:::::::::N     N::::::N
M::::::::::M       M::::::::::M           A:::::::::A             I::::I  N::::::::::N    N::::::N
M:::::::::::M     M:::::::::::M          A:::::A:::::A            I::::I  N:::::::::::N   N::::::N
M:::::::M::::M   M::::M:::::::M         A:::::A A:::::A           I::::I  N:::::::N::::N  N::::::N
M::::::M M::::M M::::M M::::::M        A:::::A   A:::::A          I::::I  N::::::N N::::N N::::::N
M::::::M  M::::M::::M  M::::::M       A:::::A     A:::::A         I::::I  N::::::N  N::::N:::::::N
M::::::M   M:::::::M   M::::::M      A:::::AAAAAAAAA:::::A        I::::I  N::::::N   N:::::::::::N
M::::::M    M:::::M    M::::::M     A:::::::::::::::::::::A       I::::I  N::::::N    N::::::::::N
M::::::M     MMMMM     M::::::M    A:::::AAAAAAAAAAAAA:::::A      I::::I  N::::::N     N:::::::::N
M::::::M               M::::::M   A:::::A             A:::::A   II::::::IIN::::::N      N::::::::N
M::::::M               M::::::M  A:::::A               A:::::A  I::::::::IN::::::N       N:::::::N
M::::::M               M::::::M A:::::A                 A:::::A I::::::::IN::::::N        N::::::N
MMMMMMMM               MMMMMMMMAAAAAAA                   AAAAAAAIIIIIIIIIINNNNNNNN         NNNNNNN
  
###################################################################################################>

Write-Verbose "Defining scriptblock to collect computer status.  "
[scriptblock]$GetComputerStatus =
{
	param
	(
		[string]$ComputerFqdn
	)
	$ComputerStatus = @{ }
	
	try
	{
		$ComputerResolve = Resolve-DnsName -Name $ComputerFqdn -Verbose -ErrorAction Stop
		Write-Verbose "ComputerFQDN was successfully resolved to an IP address."
		$ComputerStatus.DnsResolve = $true
		
		# TEST PING
		Write-Verbose "Checking Response to PING  ."
		try
		{
			$PingResponse = Test-Connection -ComputerName $ComputerFqdn -Quiet -ErrorAction Stop
			Write-Verbose "Computer responded to ping  ."
			$ComputerStatus.RespondToping = $true
		}
		catch
		{
			Write-Verbose "Computer did not respond to ping  ."
			$ComputerStatus.RespondToping = $false
		}
		
		# TEST PORT 5985
		Write-Verbose "Checking Access to port 5985  ."
		try
		{
			$Port5985 = Test-NetConnection -ComputerName $ComputerFqdn -Port 5985 -ErrorAction stop
			Write-Verbose "Port 5985 is not accessible  ."
			$ComputerStatus.Port5985 = "ACCESSIBLE"
			
			#TEST PSSESSION ESTABLISHMENT
			Write-Verbose "Port 5985 could be accessed.  Trying to establish a PsSession  ."
			try
			{
				$PSConnection = New-PSSession -ComputerName $ComputerFqdn -Name "PS$ComputerFqdn" -ErrorAction stop
				Write-Verbose "A PS Session was successfully established on port 5985  ."
				$ComputerStatus.PSSessionPort5985 = $true
				Write-Verbose "Removing Session  ."
				Remove-PSSession -Name "PS$ComputerFqdn"
			}
			catch
			{
				Write-Verbose "A PS Session could not be established on port 5985  ."
				$ComputerStatus.PSSessionPort5985 = $false
			}
		}
		catch
		{
			Write-Verbose "Port 5985 is unaccessible  ."
			$ComputerStatus.Port5985 = "NOT-ACCESSIBLE"
		}
		
		# TEST PORT 5986
		Write-Verbose "Checking Access to port 5986  ."
		try
		{
			$Port5986 = Test-NetConnection -ComputerName $ComputerFqdn -Port 5986 -ErrorAction stop
			Write-Verbose "Port 5986 is not accessible  ."
			$ComputerStatus.Port5986 = "ACCESSIBLE"
			
			#TEST PSSESSION ESTABLISHMENT
			Write-Verbose "Port 5986 could be accessed.  Trying to establish a PsSession  ."
			try
			{
				$PSConnection = New-PSSession -ComputerName $ComputerFqdn -Name "PS$ComputerFqdn" -ErrorAction stop
				Write-Verbose "A PS Session was successfully established on port 5986  ."
				$ComputerStatus.PSSessionPort5986 = $true
				Write-Verbose "Removing Session  ."
				Remove-PSSession -Name "PS$ComputerFqdn"
			}
			catch
			{
				Write-Verbose "A PS Session could not be established on port 5986  ."
				$ComputerStatus.PSSessionPort5986 = $false
			}
		}
		catch
		{
			Write-Verbose "Port 5986 is unaccessible  ."
			$ComputerStatus.Port5986 = "NOT-ACCESSIBLE"
		}
	}
	catch
	{
		Write-Verbose "ComputerFQDN could not be resolved to an IP Address.  Other tests cannot be performed."
		$ComputerStatus.DnsResolve = $false
	}
} # END [scriptblock]$GetComputerStatus

Write-Verbose "Initializing variable to store computer status as an array list  ."
$Script:StatusOfAllComputers = New-Object -TypeName System.Collections.ArrayList

Write-Verbose "Initializing variable to store script execution results."
$script:ScriptExecutionStatus = New-Object -TypeName System.Collections.ArrayList









if ($PSBoundParameters -contains "ScriptFile")
{
	Write-Verbose "PARAMETER SET : SCRIPTFILE."
	
	Write-Verbose "Beginning retrieval of target computers status."
	
	Write-Verbose "Initializing variables required for progress bar display"
	$NumberOfComputers = $ListOfComputers.count
	$CurrentComputer = 1
	
	foreach ($LoopInListOfComputers in $ListOfComputers)
	{
		Write-Progress -Activity "Launching Get Computer Status as Background Job  ." -CurrentOperation "Computer : $LoopInListOfComputers" -PercentComplete ($CurrentComputer / $NumberOfComputers * 100) -Id 0
		Start-Job -ScriptBlock $GetComputerStatus -Name "Collect_$($LoopInListOfComputers)" -ArgumentList $LoopInListOfComputers | Out-Null
		
		Write-Verbose "Waiting until number of running jobs is lower than Maximum number of simuktaneous jobs  ."
		while ((Get-Job -State Running).count -ge $MaxThreats) { Start-Sleep -Seconds 1 }
		Get-CompletedJobsData
	} # END foreach ($LoopInListOfComputers in $ListOfComputers)
	
	# process remaining jobs 
	Wait-Job -State Running -Timeout 30 | Out-Null
	Get-Job -State Running | Stop-Job
	Get-CompletedJobsData
	
	Write-Verbose "Launching script on Available Computers."
	
	Write-Verbose "Defining Computers where remoting is possible."
	$RemotingAccessibleComputers = $script:StatusOfAllComputers | Where-Object -FilterScript { $psitem.PSSessionPort5985 -eq $true -or $psitem.PSSessionPort5986 -eq $true }
	
	Write-Verbose "Launching ScriptFile on accessible computers."
	foreach ($LoopInRemotingAccessibleComputers in $RemotingAccessibleComputers)
	{
		
		
	} # END foreach ($LoopInRemotingAccessibleComputers in $RemotingAccessibleComputers)





} # END if ($PSBoundParameters -contains "ScriptFile")
elseif ($PSBoundParameters -contains "ScriptBlock")
{
	Write-Verbose "PARAMETER SET : SCRIPTBLOCK"
} # END elseif ($PSBoundParameters -contains "ScriptBlock")
else
{
	Write-Verbose "PARAMETER SET : JSON FILE"
}




