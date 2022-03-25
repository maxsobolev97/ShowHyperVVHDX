Class VirtualMachine{

    [int]$Number
    [string]$VMname
    [string]$VMstate
    [string]$VMmemory
    [string]$VMcpuUsage
    [string]$VMprocessorCount
    [array[]]$VMhardDisks

}

Class VirtualHardDisk{

    [string]$VHDpath
    [string]$VHDtype
    [int]$VHDsize

}

$hyperVhost = Read-Host "Введите имя гипервизора: "
$massVMs = @()
$VMs = Get-VM -ComputerName $hyperVhost
$num = 1

foreach($VM in $VMs){

    $objVM = [VirtualMachine]::new()
    $objVM.Number = $num
    $objVM.VMname = $VM.Name
    $objVM.VMstate = $VM.State
    $objVM.VMmemory = $VM.MemoryAssigned
    $objVM.VMcpuUsage = $VM.CPUUsage
    $objVM.VMprocessorCount = $VM.ProcessorCount
    
    $massVHD = @()
    $disks = Get-VHD -ComputerName $hyperVhost -VMId $VM.VMId | Select -Property path, vhdtype,@{label='Size(GB)';expression={$_.filesize/1gb -as [int]}}
    
    foreach($disk in $disks){
    
        $VHD = [VirtualHardDisk]::new()
        $VHD.VHDpath = $disk.Path
        $VHD.VHDtype = $disk.VhdType
        $VHD.VHDsize = $disk.'Size(GB)'
        $massVHD = $massVHD + @($VHD)

    }

    $objVM.VMhardDisks = $massVHD

    $massVMs = $massVMs + @($objVM)

    $num = $num + 1
}

Write-Output $massVMs | select Number, VMname, VMstate

$num = Read-Host