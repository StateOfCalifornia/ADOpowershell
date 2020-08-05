# ADOpowershell
Collection of utilities for security group management in Azure DevOps to update permissions on a security group, find members linked to a security group, create a new security group and assign members and generate a project level report for security group membership.

### UpdateSGPermission 🔑
Updates permissions on given security group
#### Requirements: Azure CLI with Azure DevOps extension
###### 1 – get security group descriptor id
###### 2 – parse permission namespaces in org e.g. Release Management, Build, Git Repositories, etc 
###### 3 – identify permission setting to flip e.g. Build: 2048 edit pipeline, 4096 delete pipeline or Release: 2 edit release pipeline, 4 delete release pipeline
###### 4 – update the target permission on the target subject where --allow-bit/--deny-bit could be a single permission bit or use addition of multiple permission bits
[Security tokens in Azure DevOps](https://docs.microsoft.com/en-us/azure/devops/cli/security_tokens?view=azure-devops)
</br>
[Manage security permissions in Azure DevOps](https://docs.microsoft.com/en-us/azure/devops/cli/permissions?view=azure-devops)
</br>
[az devops security permission](https://docs.microsoft.com/en-us/cli/azure/ext/azure-devops/devops/security/permission?view=azure-cli-latest)
</br>
[Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
</br></br>
### Get Target SG Members 🎯
Aggregates members associated to a given security group
#### Requirements: Azure CLI with Azure DevOps extension
###### 1 - get list of members to migrate e.g. contributors in target project
###### 2 - create new security group and add these member to it
###### 3 - remove membership from previous group e.g. contributors
[About security and identity in Azure DevOps](https://docs.microsoft.com/en-us/azure/devops/organizations/security/about-security-identity)
</br>
[Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
</br></br>
### Create SG Add member to SG 🦺
Create a new security group and add members or add members to a existing security group
#### Requirements: Azure CLI with Azure DevOps extension
[Add and manage security groups in Azure DevOps](https://docs.microsoft.com/en-us/azure/devops/organizations/security/add-manage-security-groups)
</br>
[Create a custom security group in Azure DevOps](https://docs.microsoft.com/en-us/azure/devops/organizations/security/change-individual-permissions)
</br>
[Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
</br></br>
### Export ADO Project User Settings for Multiple Projects 📜
Generates HTML report for security group membership per project 
#### Requirements: PAT token with Graph as “Read” and Member Entitlement Management as “Read”
[PAT authentication](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)
