FROM registry.access.redhat.com/ubi8/ubi:latest 
# These should be set to interact with Azure service
ENV AZP_URL=https://dev.azure.com/CableOne-ProductDevelopers/DevOpsDerek
ENV AZP_POOL="DerekTest"
ENV AZP_TOKEN=76mpwboxojlfkwtzd5zcihcv22qnxfjzgi5azcvdbgywqudwo2jq
ENV AZP_AGENT_NAME=myagent
# If a working directory was specified, create that directory
ENV AZP_WORK=/_work
ARG AZP_AGENT_VERSION=2.187.2
ARG OPENSHIFT_VERSION=4.9.7
ENV OPENSHIFT_BINARY_FILE="openshift-client-linux-${OPENSHIFT_VERSION}.tar.gz"
ENV OPENSHIFT_4_CLIENT_BINARY_URL=https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OPENSHIFT_VERSION}/${OPENSHIFT_BINARY_FILE}

WORKDIR /
USER root
RUN dnf install -y git skopeo
# Make directories for azure and tools
RUN mkdir -p "$AZP_WORK"
RUN mkdir -p /azp/agent/_diag
RUN mkdir -p /usr/local/bin 
WORKDIR /azp/agent

# Get the oc binary

RUN curl  ${OPENSHIFT_4_CLIENT_BINARY_URL} > ${OPENSHIFT_BINARY_FILE} && tar xzf ${OPENSHIFT_BINARY_FILE} -C /usr/local/bin &&  rm -rf ${OPENSHIFT_BINARY_FILE} 
RUN chmod +x /usr/local/bin/oc 

#Install hostname for current script support

# Download and extract the agent package
RUN curl https://vstsagentpackage.azureedge.net/agent/$AZP_AGENT_VERSION/vsts-agent-linux-x64-$AZP_AGENT_VERSION.tar.gz > vsts-agent-linux-x64-$AZP_AGENT_VERSION.tar.gz \
     && tar zxvf vsts-agent-linux-x64-$AZP_AGENT_VERSION.tar.gz && rm -rf vsts-agent-linux-x64-$AZP_AGENT_VERSION.tar.gz 

# Install the agent software
RUN /bin/bash -c 'chmod +x ./bin/installdependencies.sh'
RUN /bin/bash -c './bin/installdependencies.sh'

RUN chmod -R 775 "$AZP_WORK" 
RUN chown -R 1001:root "$AZP_WORK"
RUN chmod -R 775 /azp
RUN chown -R 1001:root /azp
USER 1001

# AgentService.js understands how to handle agent self-update and restart
ENTRYPOINT /bin/bash -c '/azp/agent/bin/Agent.Listener configure --unattended \
  --agent "${AZP_AGENT_NAME}-${MY_POD_NAME}" \
  --url "$AZP_URL" \
  --auth PAT \
  --token "$AZP_TOKEN" \
  --pool "${AZP_POOL}" \
  --work /_work \
  --replace \
  --acceptTeeEula && \
   /azp/agent/externals/node/bin/node /azp/agent/bin/AgentService.js interactive --once'



