########
echo "############ Installing neutron agent ############"
sleep 5
########
# Install neutron agent
# apt-get -y install neutron-common neutron-plugin-ml2 neutron-plugin-openvswitch-agent openvswitch-datapath-dkms 

apt-get -y install neutron-common neutron-plugin-ml2 openvswitch-datapath-dkms -y

##############################
echo "############ Configuring neutron.conf ############"
sleep 5
#############################
comfileneutron=/etc/neutron/neutron.conf
test -f $comfileneutron.orig || cp $comfileneutron $comfileneutron.orig
rm $comfileneutron
#Update config file /etc/neutron/neutron.conf
 
cat << EOF > $comfileneutron
[DEFAULT]

rpc_backend = rabbit
auth_strategy = keystone

core_plugin = ml2
service_plugins = router
allow_overlapping_ips = True
verbose = True

[matchmaker_redis]
[matchmaker_ring]
[quotas]
[agent]
root_helper = sudo /usr/bin/neutron-rootwrap /etc/neutron/rootwrap.conf

[keystone_authtoken]
auth_uri = http://$CON_MGNT_IP:5000
auth_url = http://$CON_MGNT_IP:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = neutron
password = $NEUTRON_PASS

[database]
# connection = sqlite:////var/lib/neutron/neutron.sqlite
[nova]
[oslo_concurrency]
lock_path = \$state_path/lock
[oslo_policy]
[oslo_messaging_amqp]
[oslo_messaging_qpid]

[oslo_messaging_rabbit]
rabbit_host = $CON_MGNT_IP
rabbit_userid = openstack
rabbit_password = $RABBIT_PASS

EOF
#

########
echo "############ Configuring ml2_conf.ini ############"
sleep 5
########
comfileml2=/etc/neutron/plugins/ml2/ml2_conf.ini
test -f $comfileml2.orig || cp $comfileml2 $comfileml2.orig
rm $comfileml2
touch $comfileml2
#Update ML2 config file /etc/neutron/plugins/ml2/ml2_conf.ini
cat << EOF > $comfileml2
[ml2]
type_drivers = flat,vlan,gre,vxlan
tenant_network_types = gre
mechanism_drivers = opendaylight

[ml2_type_flat]
[ml2_type_vlan]
[ml2_type_gre]
tunnel_id_ranges = 1:1000

[ml2_type_vxlan]
[securitygroup]
enable_security_group = True
enable_ipset = True
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

[ovs]
local_ip = $COM1_DATA_VM_IP
enable_tunneling = True

[agent]
tunnel_types = gre

[ml2_odl]
password = admin
username = admin
url = http://$ODL_MGNT_IP/controller/nb/v2/neutron

EOF

# Restarting OpenvSwitch
########
echo "############ Restarting OpenvSwitch ############"
sleep 5
########
service openvswitch-switch restart


########
echo "############ Create Integration Bridge ############"
sleep 5
########
# Create Integration Bridge
# ovs-vsctl add-br br-int


# fix bug libvirtError: internal error: no supported architecture for os type 'hvm'
echo 'kvm_intel' >> /etc/modules

##########
echo "############ Restarting Nova Compute service ############"
sleep 5

########
# Restarting Nova Compute service
service nova-compute restart
service nova-compute restart

########
echo "############ Restarting OpenvSwitch agent ############"
sleep 5
########
# Restarting OpenvSwitch agent
service neutron-plugin-openvswitch-agent restart

echo "============== Conectting to Opendaylight=============="
sleep 4
id_ovs=`ovs-vsctl show | awk "NR==1{print;exit}"`
ovs-vsctl set Open_vSwitch $id_ovs other_config={'local_ip'='$COM1_DATA_VM_IP'}
ovs-vsctl set-manager tcp:$ODL_MGNT_IP:6640

service neutron-plugin-openvswitch-agent restart

echo "########## Creating Environment script file ##########"
sleep 5
echo "export OS_USERNAME=admin" > admin-openrc.sh
echo "export OS_PASSWORD=$ADMIN_PASS" >> admin-openrc.sh
echo "export OS_TENANT_NAME=admin" >> admin-openrc.sh
echo "export OS_AUTH_URL=http://$CON_MGNT_IP:35357/v2.0" >> admin-openrc.sh
