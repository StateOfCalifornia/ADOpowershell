function New-AzDevOpsSecurityGroup 
{
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $true)]
        [string]$azDevOpsOrgUrl,

        [Parameter(mandatory = $true)]
        [string]$azDevOpsProject,

        [Parameter(mandatory = $true)]
        [string]$securityGroupName,

        [Parameter(mandatory = $true)]
        [string]$securityGroupDescription,

        [Parameter(mandatory = $false)]
        [array]$memberArray
    )

    $newSecurityGroup = az devops security group create --name $securityGroupName --project $azDevOpsProject --description $securityGroupDescription --output json;
    if (!$newSecurityGroup)
    {
        throw "Failed to create security group!";
    }

    Write-Output "Security group successfully created:";
    Write-Output $newSecurityGroup;

    if ($memberArray)
    {
        $newSecurityGroup = $newSecurityGroup | ConvertFrom-Json;

        $addedMembers = @();
        
        foreach ($member in $memberArray)
        {
            $thisMember = az devops security group membership add --group-id $newSecurityGroup.descriptor --member-id $member --output json;
        
            if ($thisMember)
            {
                $addedMembers += $($thisMember | ConvertFrom-Json);
            }
            else
            {
                Write-Error -Message "Failed to add $member to the $securityGroupName security group!" -ErrorAction Continue;
            }
        }

        Write-Output "Members successfully added:";
        Write-Output $($addedMembers | ConvertTo-Json -Depth 10);
    }
}

function Add-AzDevOpsSecurityGroupMembers
{
    [CmdletBinding()]
    param (
        [Parameter(mandatory = $true)]
        [string]$azDevOpsOrgUrl,

        [Parameter(mandatory = $true)]
        [string]$azDevOpsProject,

        [Parameter(mandatory = $true)]
        [string]$securityGroupName,

        [Parameter(mandatory = $true)]
        [array]$memberArray
    )

    $addedMembers = @();

    # list security groups
    $securityGroups = az devops security group list --project $azDevOpsProject --output json;
    if (!$securityGroups)
    {
        Write-Error -Message "Unable to list security groups!" -ErrorAction Stop;
    }
    
    $securityGroups = $securityGroups | ConvertFrom-Json;
    $thisSecurityGroup = $securityGroups.graphGroups | ? { $_.displayName -eq $securityGroupName };
    if (!$thisSecurityGroup)
    {
        Write-Error -Message "The security group $SecurityGroupName does not exist!" -ErrorAction Stop;
    }

    foreach ($member in $memberArray)
    {
        $thisMember = az devops security group membership add --group-id $thisSecurityGroup.descriptor --member-id $member --output json;
    
        if ($thisMember)
        {
            $addedMembers += $($thisMember | ConvertFrom-Json);
        }
        else
        {
            Write-Error -Message "Failed to add $member to the $securityGroupName security group!" -ErrorAction Continue;
        }
    }
    
    Write-Output "Members successfully added:";
    Write-Output $($addedMembers | ConvertTo-Json -Depth 10);
}

# create security group and add members
$newSG2 = @{
    azDevOpsOrgUrl           = "https://calenterprise.visualstudio.com/";
    azDevOpsProject          = "TestThinkSmart";
    securityGroupName        = "Contribute-NoDelete";
    securityGroupDescription = "Foo bar 2 description can go here";
    memberArray              = @(
        "chad.bratton@state.ca.gov"
    );
};
New-AzDevOpsSecurityGroup @newSG2;



