# Note, this script uses hard coded IP addresses. Where possible use then LORA_WIFI_ETH_ONLY_DHCP.rsc script for DHCP IP resolution.

:global WIFISSID "SET ME"
:global WIFIPASSWORD "SET ME"
:global DEFAULTGATEWAY "192.168.88.1" 


# oct/10/2022 16:26:50 by RouterOS 6.49.6
# software id = FSX2-68AP

/lora servers
:do {
	add address=au1.cloud.thethings.network down-port=1700 name="TTN V3 (au1)" up-port=1700
} on-error={
	:log info message="au1.cloud.thethings.network exists"
}


/lora
set 0 antenna=uFL antenna-gain=6dBi channel-plan=au-915-2 disabled=no \
    servers="TTN V3 (au1)"
    
    set 0 antenna=uFL antenna-gain=6dBi channel-plan=au-915-2 disabled=no forward=crc-valid,crc-disabled

/system clock
set time-zone-name=Pacific/Auckland

/system routerboard settings
set auto-upgrade=yes


#Firewall
/ip firewall filter
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment=\
    "defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=drop chain=input comment="defconf: drop all not coming from LAN" \
    in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" \
    ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" \
    ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related
add action=accept chain=forward comment=\
    "defconf: accept established,related, untracked" connection-state=\
    established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid
add action=drop chain=forward comment=\
    "defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" \
    ipsec-policy=out,none out-interface-list=WAN


/interface bridge
add name=local
/interface list
add name=WAN
add name=LAN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik


add authentication-types=wpa-psk,wpa2-psk\
    mode=dynamic-keys\
    name="CLIENT_WIFI_PROFILE"\
    supplicant-identity=MikroTik\
    wpa-pre-shared-key=$WIFIPASSWORD\
    wpa2-pre-shared-key=$WIFIPASSWORD


/interface wireless
set 0 antenna=uFL antenna-gain=6dBi channel-plan=au-915-2 forward=crc-valid,crc-disabled servers="TTN V3 (au1)"

/ip hotspot profile
set [ find default=yes ] html-directory=hotspot
/ip pool
add name=dhcp ranges=192.168.89.2-192.168.89.254
/ip dhcp-server
add address-pool=dhcp disabled=no interface=local name=dhcp1

/interface bridge port
add bridge=local interface=ether1
/interface detect-internet
set detect-interface-list=all
/interface list member
add interface=wlan1 list=WAN
add interface=local list=LAN
/ip address
add address=192.168.89.1/24 interface=local network=192.168.89.0
/ip dhcp-server network
add address=192.168.89.0/24 dns-server=$DEFAULTGATEWAY gateway=192.168.89.1 \
    netmask=24
