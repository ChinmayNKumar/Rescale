﻿#Script that demonstrates how to deploy apps to an Azure VM using Custom Script Extensions

#Install-Module AzureRM - Install the AzureRM module if not installed
Import-Module AzureRM #Import the AzureRM module

#Use a service principal (non-interactive Azure account) with limited permissions for more security

$pscredential = Get-Credential #Get the service principal's credentials as an object
Connect-AzureRmAccount -ServicePrincipal -Credential $pscredential -TenantId $tenantid

#Resource Group setup
New-AzureRmResourceGroup -Name VMLab -Location EastUS
-Name "CKTest" `
-Location EastUS `

#Set Storage Account Context
$ctx = $storageAccount.Context

#Blob container setup for the installer script
New-AzureStorageContainer -Name scripts -Context $ctx -Permission blob

#File share setup for the installer (msi/exe)
New-AzureStorageShare `
 -Name fileshare `
 -Context $ctx

#Creating a directory in the file share for storing the installers
New-AzureStorageDirectory `
 -Context $ctx `
 -ShareName "fileshare" `
 -Path "AntivirusSoftware"
 -Context $ctx `
 -ShareName "fileshare" `
 -Source "pathtoinstaller" `
 -Path "AntivirusSoftware/SophosInstall.exe"
#\\CKTest.file.core.windows.net\fileshare\AntivirusSoftware\SophosInstall.exe /SP- /SILENT /NOCANCEL
-File "C:\users\chinm\Downloads\InstallSophos.ps1" `
-Container scripts `
-Blob "InstallSophos.ps1" `
-Context $ctx

#Create a VM. Alternatively, we can use an image if available

New-AzureRmVm `
 -ResourceGroupName "VMLab" `
 -Name "testVM" `
 -Location "EastUS" `
 -VirtualNetworkName "Vnet" `
 -SubnetName "Subnet" `
 -SecurityGroupName "SG" `
 -PublicIpAddressName "PublicIP" `
 -Credential $pscredential

#Deploy Sophos to the VM

$storageKey = Get-AzureRmStorageAccountKey -ResourceGroupName "VMLab" -AccountName "CKTest"

 Set-AzureRmVmCustomScriptExtension `
-ResourceGroupName VMLab `
-Location EastUS `
-VMName testVM `
-Name InstallSophos `
-TypeHandlerVersion "1.9" `
-StorageAccountName CKTest `
-StorageAccountKey $storageKey `
-FileName InstallSophos.ps1 `
-ContainerName scripts `
-Run InstallSophos.ps1