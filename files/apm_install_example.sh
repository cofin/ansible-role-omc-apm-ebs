#!/bin/bash
# /tmp/APM/ProvisionApmJavaAsAgent.sh -d PATH_TO_NE_FS -gateway-host datacenter_primary_gateway -gateway-port 4459 -additional-gateways https://failover_gateway:4459


ebs_env="ebsdev"
config_path="./config.xml"
cp "${config_path}" "${config_path}.original"
apm_instrumentation_path="/u01/app/${ebs_env}/fs_ne/apmagent/lib/system/ApmAgentInstrumentation.jar"
apm_startup_arg="-javaagent:${apm_instrumentation_path}"
server_name="oafm_server1"
echo "Locating startup arguments for ${server_name}"
server_startup_args=$(xmlstarlet sel -N d=http://xmlns.oracle.com/weblogic/domain \
                    -t -m "/d:domain/d:server[d:name='${server_name}']" \
                    -v 'd:server-start/d:arguments' $config_path)
if [[ $server_startup_args =~ "ApmAgentInstrumentation.jar" ]]; then
    echo "Found existing APM installation.  Updating arguments."
    updated_server_startup_args="${server_startup_args//(-javaagent:.*ApmAgentInstrumentation\.jar)+/${apm_startup_arg}/}"
else
    echo "No prior installation found.  Adding APM startup arguments."
    updated_server_startup_args="${server_startup_args} ${apm_startup_arg}"
fi
xmlstarlet edit -N d=http://xmlns.oracle.com/weblogic/domain \
    --update "/d:domain/d:server[d:name='${server_name}']/d:server-start/d:arguments" \
    --value $updated_server_startup_args $config_path
echo $server_startup_args
echo $updated_server_startup_args