#!/bin/bash -ex
echo " Cai dat moi truong Java"
sleep 2
apt-get install -y openjdk-7-jdk

# Thuc hien cai dat Java
echo "Tai OpenDaylight va giai nen"
sleep 2
wget https://nexus.opendaylight.org/content/groups/public/org/opendaylight/integration/distribution-karaf/0.2.4-Helium-SR4/distribution-karaf-0.2.4-Helium-SR4.tar.gz

tar xvfz distribution-karaf-0.2.4-Helium-SR4.tar.gz
cd distribution-karaf-0.2.4-Helium-SR4
