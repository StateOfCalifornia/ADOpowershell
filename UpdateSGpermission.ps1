az login
az extension add --name "azure-devops"


# Find the group identifier of the group you want to set permissions for
# There is a weird edge case here when an Azure DevOps Organization has a Team Project with the same name as the org.
# In that case you must also add a query to filter on the right domain property `?@.domain == '?'`  

# update permissions at the organization level
# e.g. pull request bypass policy at the org level
function Update-OrganizationSG
{
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $true)]
        [string]$azDevOpsOrg,

        [Parameter(mandatory = $true)]
        [string]$azDevOpsProject,

        [Parameter(mandatory = $true)]
        [string]$securityGroupName
    )

    $subject = az devops security group list `
        --org "$azDevOpsOrg/" `
        --scope organization `
        --subject-types vssgp `
        --query "graphGroups[?@.principalName == '[$azDevOpsOrg]\Project Collection Administrators'].descriptor | [0]"

    $namespaceId = az devops security permission namespace list `
        --org "$azDevOpsOrg/" `
        --query "[?@.name == 'Git Repositories'].namespaceId | [0]"

    $bit = az devops security permission namespace show `
        --namespace-id $namespaceId `
        --org "$azDevOpsOrg/" `
        --query "[0].actions[?@.name == 'PullRequestBypassPolicy'].bit | [0]"

    az devops security permission update `
        --id $namespaceId `
        --subject $subject `
        --token "repoV2/" `
        --allow-bit $bit `
        --merge true `
        --org https://dev.azure.com/$azDevOpsOrg/
}

# update security group permission at the project level
# e.g. Contributors in target project will not have permission to edit releases
function Update-ProjectSG 
{
    [CmdletBinding()]
    param
    (
        [Parameter(mandatory = $true)]
        [string]$azDevOpsOrg,

        [Parameter(mandatory = $true)]
        [string]$azDevOpsProject,

        [Parameter(mandatory = $true)]
        [string]$securityGroupName
    )

    # get security group descriptor ID
    $subject = az devops security group list `
        --org "$azDevOpsOrg/" `
        --project $azDevOpsProject `
        --scope project `
        --subject-types vssgp `
        --query "graphGroups[?@.displayName == '$securityGroupName'].descriptor | [0]"

    # parse permission namespaces in org e.g. ReleaseManagement, Build, Git Repositories, etc
    # optionally, view entire list with --output table
    # https://docs.microsoft.com/en-us/azure/devops/cli/security_tokens?view=azure-devops
    $namespaceId = az devops security permission namespace list `
        --org "$azDevOpsOrg/" `
        --query "[?@.name == 'ReleaseManagement'].namespaceId | [1]"

    # identify setting to flip 
    # e.g. Build: 2048 edit pipeline, 4096 delete build pipeline
    # e.g. Release:2 edit release pipeline, 4, delete release pipeline
    $bit = az devops security permission namespace show `
        --namespace-id $namespaceId `
        --org "$azDevOpsOrg/" `
        --query "[0].actions[?@.name == 'EditReleaseDefinition'].bit | [0] "
    
    # finally, update the target permission on the target subject(security group)
    # --allow-bit/--deny-bit could be a single permission bit OR use addition of multiple permission bits
    # https://docs.microsoft.com/en-us/azure/devops/cli/permissions?view=azure-devops
    # https://docs.microsoft.com/en-us/cli/azure/ext/azure-devops/devops/security/permission?view=azure-cli-latest
    az devops security permission update `
        --id $namespaceId `
        --subject $subject `
        --token "repoV2/" `
        --deny-bit $bit `
        --merge true `
        --org "$azDevOpsOrg/"

}

# target members of a security group in a project
$targetMembers = @{
    azDevOpsOrg              = "https://calenterprise.visualstudio.com/";
    azDevOpsProject          = "TestThinkSmart";
    SecurityGroupName        = "Contribute-NoDelete"
};

Update-ProjectSG @targetMembers;
