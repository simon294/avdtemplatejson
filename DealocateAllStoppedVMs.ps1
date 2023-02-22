
$ConnectionInformation = Get-AutomationConnection -Name 'Subscription-AVD-2022'

Connect-AzAccount @ConnectionInformation



$VMs = Get-AzVM -Name VM8* -Status
$date = Get-Date

foreach($VM in $VMs)
{
    

    if($VM.Powerstate -eq "VM stopped")
    {
        Write-Output $VM.Name
        Write-Output $VM.Powerstate
        $Logs = Get-AzActivityLog -ResourceId $VM.Id -StartTime $date.AddDays(-1) | where OperationName -like "Health Event Updated" | Select EventTimeStamp, @{N='Status';E={$_.Properties.Content.title}} | Sort -Property EventTimeStamp -Descending |  where Status -eq "Stopped by user or process" | Select -First 1
        
        if($date.AddHours(-1) -ge $LogDate)
        {
            Write-Output "-Stop VM-"

            Stop-AzVM -ResourceGroupName WVD-RG -Name $VM.Name -Force
        } 
        Write-Output "------"
    }
}
