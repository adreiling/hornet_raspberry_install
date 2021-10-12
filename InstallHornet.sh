// Instalacion Hornet en Raspberry Pi 4 (https://hornet.docs.iota.org/getting_started/hornet_apt_repository/)
1. Instalar Ubuntu Server 21.04 64b (20.04 no bootea desde usb)
	1.1 Usar RaspberryPiImage e instalar en SSD/Microsd
2. Conectarse por SSH
	2.2 Conectarse por ssh. Credenciales por default ubuntu/ubuntu
3. Instalar Hornet
	3.1 wget -qO - https://ppa.hornet.zone/pubkey.txt | sudo apt-key add -
	3.2 sudo sh -c 'echo "deb http://ppa.hornet.zone stable main" >> /etc/apt/sources.list.d/hornet.list'
	3.3 sudo apt update && sudo apt install hornet
		(Si quiero desinstalar -> sudo apt-get purge --auto-remove hornet)		
4. IP estatica
	route -ne -> Saco dato de gateway
		192.168.0.1
		
	cat /etc/resolv.conf -> DNS			
		nameserver 127.0.0.53
		options edns0 trust-ad
		search fibertel.com.ar	
		
		// Ubuntu Server
		//Obtengo nombre interface
		ip link
			eth0
		
		//Modifico archivo YAML 
		//Ver nombre de archivo YAML, puede variar por ej.: 01-netcfg.yaml, 50-cloud-init.yaml, NN_interfaceName.yaml
		ls /etc/netplan
		
		//Deshabilito "cloud-init"
		sudo nano /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
		
		//Agrego en el archivo
		network: {config: disabled}
		
		//Edito archivo respetando identacion
		sudo nano /etc/netplan/50-cloud-init.yaml
		
		//Debe quedar como:
		network:
		  version: 2
		  renderer: networkd
		  ethernets:
			ens3:
			  dhcp4: no
			  addresses:
				- STATIC_IP/24
			  gateway4: ROUTER_IP
			  nameservers:
				  addresses: [DNS_IPs, DNS_IPs]	

		// Por ej.:
network:
    version: 2
    renderer: networkd
    ethernets:
        eth0:
            dhcp4: no
            addresses:
                - 192.168.0.16/24
            gateway4: 192.168.0.1
            nameservers:
                addresses: [127.0.0.53,8.8.8.8, 8.8.4.4]


		//Luego
		sudo netplan apply
		
		//Verifico
		ip addr show dev eth0
		
		//Extra: Ver script local con cron para DDNS (por ej. DuckDNS)
	
5. Abrir ports en router
    15600 TCP - Gossip protocol port
    14626 UDP - Autopeering port (optional)
    14265 TCP - REST HTTP API port (optional)
    8081 TCP - Dashboard (optional)
    8091 TCP - Faucet website (optional)
    1883 TCP - MQTT (optional)
	
6. Habilitar servicio	
	6.1 sudo systemctl enable hornet.service
	
7. Acceso en red LAN al dashboard
	Cambiar "dashboard":"bindAddress" a "0.0.0.0:8081" en /var/lib/hornet/config.json

8. Autopeering 
	Agregar plugin "Autopeering" en "node":"enablePlugins":"Autopeering"



Manejo basico, logs
	* sudo service hornet start
	* sudo systemctl stop hornet
	* sudo systemctl restart hornet
	* journalctl -fu hornet
	
	* sudo service hornet start && journalctl -fu hornet	
	
// Archivos de configuracion	
	sudo nano /var/lib/hornet/peering.json
	sudo nano /var/lib/hornet/config.json
	
//Path ejecutable:
sudo /usr/bin/hornet --deleteAll

// Instalar nodejs y npm
sudo apt install nodejs
sudo apt install npm


sudo bash -c "bash <(curl -s https://raw.githubusercontent.com/adreiling/hornet_raspberry_install/main/InstallHornet.sh)"
DEVICE_NAME="$( getInternetInfo 5 )"
METHOD="$( getInternetInfo 7 )"
PREFIX="$( ip r | grep kernel | cut -f1 -d' ' | cut -f2 -d'/' )"

createStaticYAML() {
   local YAML="network:\n"
    YAML+="    version: 2\n"
    YAML+="    renderer: $NETWORK_MANAGER\n"
    YAML+="    ethernets:\n"
    YAML+="        $DEVICE_NAME:\n"
    YAML+="            dhcp4: no\n"
    YAML+="            addresses: [$IP/$PREFIX]\n"
    YAML+="            gateway4: $GATEWAY\n"
    YAML+="            nameservers:\n"
    YAML+="                addresses: [${NAMESERVERS[0]},${NAMESERVERS[1]},${NAMESERVERS[2]}]"
    printf "%s" "$YAML"
}

clearConfigs() {
    [ -f $END_CONFIG ] && sudo rm $END_CONFIG
}

setYAML() {
    sudo echo -e "$(createStaticYAML)" > $END_CONFIG
}

clearConfigs
setYAML
generateAndApply
restartNetwork

echo "=================================================================="
echo "Enable the systemd service"
systemctl enable hornet.service

echo "=================================================================="
echo "Open dashboard to LAN"
sed -i 's/localhost:8081/0.0.0.0:8081/g' /var/lib/hornet/config*.json

echo "=================================================================="
echo "Starting Hornet"
service hornet start && journalctl -fu hornet
createStaticYAML() {
   local YAML="network:\n"
    YAML+="    version: 2\n"
    YAML+="    renderer: $NETWORK_MANAGER\n"
    YAML+="    ethernets:\n"
    YAML+="        $DEVICE_NAME:\n"
    YAML+="            dhcp4: no\n"
    YAML+="            addresses: [$IP/$PREFIX]\n"
    YAML+="            gateway4: $GATEWAY\n"
    YAML+="            nameservers:\n"
    YAML+="                addresses: [${NAMESERVERS[0]},${NAMESERVERS[1]},${NAMESERVERS[2]}]"
    printf "%s" "$YAML"
}

clearConfigs() {
    [ -f $END_CONFIG ] && sudo rm $END_CONFIG
}

setYAML() {
    sudo echo -e "$(createStaticYAML)" > $END_CONFIG
}

clearConfigs
setYAML
generateAndApply
restartNetwork

echo "=================================================================="
echo "Enable the systemd service"
systemctl enable hornet.service

echo "=================================================================="
echo "Open dashboard to LAN"
sed -i 's/localhost:8081/0.0.0.0:8081/g' /var/lib/hornet/config*.json

echo "=================================================================="
echo "Starting Hornet"
service hornet start && journalctl -fu hornet
