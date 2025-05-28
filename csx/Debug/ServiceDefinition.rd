<?xml version="1.0" encoding="utf-8"?>
<serviceModel xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" name="lab12" generation="1" functional="0" release="0" Id="50afea9a-344e-433d-b304-da5bc4171ce6" dslVersion="1.2.0.0" xmlns="http://schemas.microsoft.com/dsltools/RDSM">
  <groups>
    <group name="lab12Group" generation="1" functional="0" release="0">
      <componentports>
        <inPort name="Server:Endpoint1" protocol="http">
          <inToChannel>
            <lBChannelMoniker name="/lab12/lab12Group/LB:Server:Endpoint1" />
          </inToChannel>
        </inPort>
      </componentports>
      <settings>
        <aCS name="ServerInstances" defaultValue="[1,1,1]">
          <maps>
            <mapMoniker name="/lab12/lab12Group/MapServerInstances" />
          </maps>
        </aCS>
        <aCS name="WorkerInstances" defaultValue="[1,1,1]">
          <maps>
            <mapMoniker name="/lab12/lab12Group/MapWorkerInstances" />
          </maps>
        </aCS>
      </settings>
      <channels>
        <lBChannel name="LB:Server:Endpoint1">
          <toPorts>
            <inPortMoniker name="/lab12/lab12Group/Server/Endpoint1" />
          </toPorts>
        </lBChannel>
      </channels>
      <maps>
        <map name="MapServerInstances" kind="Identity">
          <setting>
            <sCSPolicyIDMoniker name="/lab12/lab12Group/ServerInstances" />
          </setting>
        </map>
        <map name="MapWorkerInstances" kind="Identity">
          <setting>
            <sCSPolicyIDMoniker name="/lab12/lab12Group/WorkerInstances" />
          </setting>
        </map>
      </maps>
      <components>
        <groupHascomponents>
          <role name="Server" generation="1" functional="0" release="0" software="C:\Users\oenea\Downloads\lab12\csx\Debug\roles\Server" entryPoint="base\x64\WaHostBootstrapper.exe" parameters="base\x64\WaIISHost.exe " memIndex="-1" hostingEnvironment="frontendadmin" hostingEnvironmentVersion="2">
            <componentports>
              <inPort name="Endpoint1" protocol="http" portRanges="80" />
            </componentports>
            <settings>
              <aCS name="__ModelData" defaultValue="&lt;m role=&quot;Server&quot; xmlns=&quot;urn:azure:m:v1&quot;&gt;&lt;r name=&quot;Server&quot;&gt;&lt;e name=&quot;Endpoint1&quot; /&gt;&lt;/r&gt;&lt;r name=&quot;Worker&quot; /&gt;&lt;/m&gt;" />
            </settings>
            <resourcereferences>
              <resourceReference name="DiagnosticStore" defaultAmount="[4096,4096,4096]" defaultSticky="true" kind="Directory" />
              <resourceReference name="EventStore" defaultAmount="[1000,1000,1000]" defaultSticky="false" kind="LogStore" />
            </resourcereferences>
          </role>
          <sCSPolicy>
            <sCSPolicyIDMoniker name="/lab12/lab12Group/ServerInstances" />
            <sCSPolicyUpdateDomainMoniker name="/lab12/lab12Group/ServerUpgradeDomains" />
            <sCSPolicyFaultDomainMoniker name="/lab12/lab12Group/ServerFaultDomains" />
          </sCSPolicy>
        </groupHascomponents>
        <groupHascomponents>
          <role name="Worker" generation="1" functional="0" release="0" software="C:\Users\oenea\Downloads\lab12\csx\Debug\roles\Worker" entryPoint="base\x64\WaHostBootstrapper.exe" parameters="base\x64\WaWorkerHost.exe " memIndex="-1" hostingEnvironment="consoleroleadmin" hostingEnvironmentVersion="2">
            <settings>
              <aCS name="__ModelData" defaultValue="&lt;m role=&quot;Worker&quot; xmlns=&quot;urn:azure:m:v1&quot;&gt;&lt;r name=&quot;Server&quot;&gt;&lt;e name=&quot;Endpoint1&quot; /&gt;&lt;/r&gt;&lt;r name=&quot;Worker&quot; /&gt;&lt;/m&gt;" />
            </settings>
            <resourcereferences>
              <resourceReference name="DiagnosticStore" defaultAmount="[4096,4096,4096]" defaultSticky="true" kind="Directory" />
              <resourceReference name="EventStore" defaultAmount="[1000,1000,1000]" defaultSticky="false" kind="LogStore" />
            </resourcereferences>
          </role>
          <sCSPolicy>
            <sCSPolicyIDMoniker name="/lab12/lab12Group/WorkerInstances" />
            <sCSPolicyUpdateDomainMoniker name="/lab12/lab12Group/WorkerUpgradeDomains" />
            <sCSPolicyFaultDomainMoniker name="/lab12/lab12Group/WorkerFaultDomains" />
          </sCSPolicy>
        </groupHascomponents>
      </components>
      <sCSPolicy>
        <sCSPolicyUpdateDomain name="ServerUpgradeDomains" defaultPolicy="[5,5,5]" />
        <sCSPolicyUpdateDomain name="WorkerUpgradeDomains" defaultPolicy="[5,5,5]" />
        <sCSPolicyFaultDomain name="ServerFaultDomains" defaultPolicy="[2,2,2]" />
        <sCSPolicyFaultDomain name="WorkerFaultDomains" defaultPolicy="[2,2,2]" />
        <sCSPolicyID name="ServerInstances" defaultPolicy="[1,1,1]" />
        <sCSPolicyID name="WorkerInstances" defaultPolicy="[1,1,1]" />
      </sCSPolicy>
    </group>
  </groups>
  <implements>
    <implementation Id="5e8cd3a3-3742-4c38-9651-ef1d5219f63a" ref="Microsoft.RedDog.Contract\ServiceContract\lab12Contract@ServiceDefinition">
      <interfacereferences>
        <interfaceReference Id="b6a2966f-25c7-4663-a16f-00e9660b05ae" ref="Microsoft.RedDog.Contract\Interface\Server:Endpoint1@ServiceDefinition">
          <inPort>
            <inPortMoniker name="/lab12/lab12Group/Server:Endpoint1" />
          </inPort>
        </interfaceReference>
      </interfacereferences>
    </implementation>
  </implements>
</serviceModel>