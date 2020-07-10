<#

AzureDevOpsPAT = Please create Personal Token (Doc: https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page)


Personal Token should have the following permissions 

    -Read for vso.graph (Doc: https://docs.microsoft.com/en-us/rest/api/azure/devops/graph/groups/list?view=azure-devops-rest-5.1)

    -Read for vso.memberentitlementmanagement (Doc: https://docs.microsoft.com/en-us/rest/api/azure/devops/memberentitlementmanagement/members/get?view=azure-devops-rest-5.1) 	


#>


# Setting the script to authenticate using the system access token on the Azure DevOps
# Note: Remember to set Graph as "Read" and Member Entitlement Management as "Read"
$AzureDevOpsPAT = "****qjpaf2amkvhuuwd4dkl2ouwttanut64vg6oph6qx45yvreoq"
$OrganizationName = "roprasa"
$ProjectNames = @('Proj1','Proj2', 'Proj3')

$AzureDevOpsAuthenicationHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$($AzureDevOpsPAT)")) }

# Generate report per project
ForEach ($proj in $ProjectNames) {


    $header='
    <style>
    TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
    TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
    TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black; }
    </style>
    '

    $UriForListofGroups = "https://vssps.dev.azure.com/$($OrganizationName)/_apis/graph/groups?api-version=5.1-preview.1"

    $Groups = ((Invoke-RestMethod -Uri $UriForListofGroups -Method get -Headers $AzureDevOpsAuthenicationHeader).value | Where-Object {($_.PrincipalName -like "*$($proj)*")} )

    $HTML =$null

    foreach ($Group in $Groups)
    {
    
            $GroupID = $Group.originId 
  

    $UriForMembersofGroup = "https://vsaex.dev.azure.com/$($OrganizationName)/_apis/ProjectEntitlements/$groupID/members?api-version=5.1-preview.1"

    $Users = Invoke-RestMethod -Uri $UriForMembersofGroup -Method get -Headers $AzureDevOpsAuthenicationHeader 


    #$Group.Displayname | export-csv "C:\Users\Administrator\Desktop\Output.csv" -Append -Force
    if($Users.members.user -ne $null)
    {
     $html += $Users.members.user | Select-Object -Property subjectKind, metaType, directoryAlias, principalName, mailAddress, origin, originId  | ConvertTo-Html -Fragment -PreContent "<h2><br><br>$($Group.Displayname)</h2>"
                                          

    }
    else 
    {
    $HTML += New-Object -Type PSObject -Prop @{"subjectKind" = "None" ; 
                                               "metaType" = "None" ;
                                               "directoryAlias" = "None" ;                 
                                               "principalName" = "None" ;
                                               "mailAddress" = "None" ;
                                               "origin" = "None" ;
                                               "originId"  = "None" 
                                              } | sort -Descending |ConvertTo-Html -Fragment -PreContent "<h2><br><br>$($Group.Displayname)</h2>" 

    }
    }

    $H = ConvertTo-Html -Body $HTML -title " Report" -Head $header
    $reportURL = "$Home\Desktop\" + $proj + "Output.html" 
    Set-Content -Path $reportURL -Value $H
    Invoke-Item $reportURL

}