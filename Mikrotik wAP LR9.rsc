# Example config for Mikrotik wAP LR9 kit  
# Don't forget to set your own Wifi Password
# model = RBwAPR-2nD
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n channel-width=20/40mhz-XX country="new zealand" disabled=no distance=indoors frequency=auto installation=outdoor mode=ap-bridge ssid=MyLora9 wireless-protocol=802.11
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa2-psk mode=dynamic-keys supplicant-identity=MikroTik wpa-pre-shared-key="MySecretPassword" wpa2-pre-shared-key="MySecretPassword"
/ip pool
add name=dhcp ranges=192.168.88.10-192.168.88.254
/ip dhcp-server
add address-pool=dhcp disabled=no interface=wlan1 name=defconf
/lora servers
add address=eu.mikrotik.thethings.industries down-port=1700 name=TTN-EU up-port=1700
add address=us.mikrotik.thethings.industries down-port=1700 name=TTN-US up-port=1700
add address=eu1.cloud.thethings.industries down-port=1700 name="TTS Cloud (eu1)" up-port=1700
add address=nam1.cloud.thethings.industries down-port=1700 name="TTS Cloud (nam1)" up-port=1700
add address=au1.cloud.thethings.industries down-port=1700 name="TTS Cloud (au1)" up-port=1700
add address=eu1.cloud.thethings.network down-port=1700 name="TTN V3 (eu1)" up-port=1700
add address=nam1.cloud.thethings.network down-port=1700 name="TTN V3 (nam1)" up-port=1700
add address=au1.cloud.thethings.network down-port=1700 name="TTN V3 (au1)" up-port=1700
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/interface list member
add comment=defconf interface=wlan1 list=LAN
add comment=defconf interface=ether1 list=WAN
add list=LAN
/ip address
add address=192.168.88.1/24 comment=defconf interface=wlan1 network=192.168.88.0
/ip dhcp-client
add comment=defconf disabled=no interface=ether1
/ip dhcp-server network
add address=192.168.88.0/24 comment=defconf gateway=192.168.88.1
/ip dns
set allow-remote-requests=yes
/ip dns static
add address=192.168.88.1 comment=defconf name=router.lan
/ip firewall filter
add action=accept chain=forward comment="defconf: accept in ipsec policy" ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" connection-state=established,related
add action=accept chain=forward comment="defconf: accept established,related, untracked" connection-state=established,related,untracked
add action=drop chain=forward comment="defconf: drop invalid" connection-state=invalid
add action=drop chain=forward comment="defconf: drop all from WAN not DSTNATed" connection-nat-state=!dstnat connection-state=new in-interface-list=WAN
/ip firewall nat
add action=masquerade chain=srcnat comment="defconf: masquerade" ipsec-policy=out,none out-interface-list=WAN
/lora
set 0 antenna=uFL antenna-gain=6dBi channel-plan=au-915-2 forward=crc-valid,crc-disabled servers="TTN V3 (au1)"
/system clock
set time-zone-name=Pacific/Auckland
/system identity
set name=MyLora9
