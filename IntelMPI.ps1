#Script to show how Intel MPI HPC nodes work with AD authentication
#This script shows how to use domain-based authorization method with the delegation ability

#Import the AD module
Import-Module ActiveDirectory

#Login to the DC as a Domain Admin (Start a remote session on the DC)
$s = New-PSSession -ComputerName DC
Enter-PSSession -Session $s

#Per documentation, Enable the delegation for cluster nodes and Trust this computer for delegation to any service (Kerberos only)
Get-ADComputer -Identity Node1,Node2 | Set-ADAccountControl ‑TrustedForDelegation $true
#Repeat the steps for other nodes

#Per documentation, Disable the account is sensitive and cannot be delegated option.
Set-ADAccountControl -Identity MPIService -AccountNotDelegated $False

#Register service principal name (SPN) for cluster nodes. Adds the specified SPN for the computer, after verifying that no duplicates exist.
setspn.exe -S impi_hydra/node1:8679/impi_hydra node1

#Login to each ndoe and execute
#hydra_service -register_spn

#Set user authorization method to Delegate using env. variable
I_MPI_AUTH_METHOD=delegate

#Checking accessiblity of the hosts by running a simple command (hostname)
mpiexec -ppn 1 -n 2 -hosts node1,node2 hostname

Exit-PSSession
