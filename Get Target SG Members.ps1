az login
az extension add --name "azure-devops"

function Get-SGMembers
{
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $true)]
        [string]$securityGroupID
    )
    
    # aggregate users linked to the security group id
    $linkedMembers = @();
    $levelMembers = az devops security group membership list --id $securityGroupID --output json;
    
    if (!$levelMembers) {
        Write-Error -Message "Failed to list members of the $securityGroupName security group!" -ErrorAction Continue;
    } else {
        $members = $levelMembers | ConvertFrom-Json;
        foreach ($member in $members.PSObject.Properties) {
            $member = $member.Value;
            if ($member.subjectKind -eq "user") {
               # add members of SG to aggregate list
               $email = $member.mailAddress;
               $linkedMembers += $email; 
            }
            if ($member.subjectKind -eq "group") {
                # recursion for linked group members
                $sgID = $member.descriptor;
                $linkedMembers += Get-SGMembers $sgID;
            }
        }
    }
    return $linkedMembers;
  }

# aggregate members of SecurityGroupName
function Get-TargetSGMembers
{
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $true)]
        [string]$azDevOpsOrgUrl,

        [Parameter(mandatory = $true)]
        [string]$azDevOpsProject,

        [Parameter(mandatory = $true)]
        [string]$securityGroupName
    )
    Write-Output "Checking groups..."

    # transform SG displayName to descriptor(id) in target project
    $securityGroups = az devops security group list --org $azDevOpsOrgUrl --project $azDevOpsProject --output json;
    if (!$securityGroups) {
        throw "Unable to list security groups!";
    }
    $securityGroups = $securityGroups | ConvertFrom-Json;
    $thisSecurityGroup = $securityGroups.graphGroups | ? { $_.displayName -eq $securityGroupName };
    if (!$thisSecurityGroup) {
        throw "The security group $securityGroupName does not exist!";
    }
    # query members linked to this SG
    $linkedMembers = Get-SGMembers $thisSecurityGroup.descriptor;
    $uniqueMembers = $linkedMembers | select -Unique;
    Write-Output "Members linked to $securityGroupName -";
    Write-Output $uniqueMembers;
              
}


# target members of a security group in a project
$targetMembers = @{
    azDevOpsOrgUrl           = "https://dev.azure.com/org";
    azDevOpsProject          = "Project";
    SecurityGroupName        = "Contributors"
};

Get-TargetSGMembers @targetMembers;
