# azure-devops-ocp-agent
A self hosted agent in OpenShift for Azure Devops

Pre-requisites to setting this up are to determine parameter values
1. Setup a project in Azure Devops and get the project based URL ($AZP_URL)
2. Generate and use a PAT to connect an agent with Azure Pipelines  ($AZP_TOKEN)
https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page
3. Setup the Agent Pool ($AZP_POOL)
4. Within OpenShift import the templates for the build job and deployment
5. Create an OpenShift project
6. Build the Azure Agent via the template
7. Grant permissions to the service agent 
oc policy add-role-to-user edit system:serviceaccount:<project_name>:azure-devops-sa

Running the agent
1. Launch the deployment template using parameters as required from what you setup in Pre-requisites
2. The Agent should connect to Azure Project and be ready to accept Jobs
3. When developing an azure pipeline, rather than using the default pool setup use within the pipeline
pool:
  name: <Agent Pool name>
  
4. The agent has the oc tool installed running with permissions granted to the service account, use oc commands to interact with the build process. 
5. As a default the agent will checkout the code so this will be already present in the agent container
6. The Agent is set to complete with each job and will be restarted by OpenShift
  
Scaling Agents
1. The agent can be scaled using the Deployment, this is not fully tested , but each agent will register with its pod name as a suffix to ensure AzureDevops can register with a unique name.
