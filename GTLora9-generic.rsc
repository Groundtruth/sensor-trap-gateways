# 2024-12-20 11:45:00 by RouterOS 7.16.2
# software id = EFTT-KCC2
#
# model = RBwAPR-2nD
# serial number = DA4A0CB27DAC
:delay 25s
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/interface lte apn
set [ find default=yes ] ip-type=ipv4 use-network-apn=no
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa2-psk group-ciphers=\
    tkip,aes-ccm mode=dynamic-keys supplicant-identity=MikroTik \
    unicast-ciphers=tkip,aes-ccm wpa2-pre-shared-key=supersecret
add authentication-types=wpa2-psk group-ciphers=tkip,aes-ccm mode=\
    dynamic-keys name=Client supplicant-identity="" unicast-ciphers=\
    tkip,aes-ccm wpa2-pre-shared-key=supersecret
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n country="new zealand" \
    disabled=no distance=indoors installation=outdoor security-profile=Client \
    ssid=yourwifihere wireless-protocol=802.11
add disabled=no keepalive-frames=disabled \
    master-interface=wlan1 multicast-buffering=disabled name=wlan2 ssid=Lora9 \
    wds-cost-range=1 wds-default-cost=1 wps-mode=disabled
/ip pool
add name=dhcp ranges=192.168.88.10-192.168.88.254
/ip smb users
set [ find default=yes ] disabled=yes
/routing bgp template
set default disabled=no output.network=bgp-networks
/routing ospf instance
add disabled=no name=default-v2
/routing ospf area
add disabled=yes instance=default-v2 name=backbone-v2
/ip firewall connection tracking
set udp-timeout=10s
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/ip settings
set max-neighbor-entries=8192
/ipv6 settings
set disable-ipv6=yes max-neighbor-entries=8192
/interface list member
add comment=defconf interface=wlan1 list=WAN
add comment=defconf interface=ether1 list=WAN
/iot lora
set 0 antenna=uFL antenna-gain=6dBi channel-plan=au-915-2 disabled=no \
    servers="TTN V3 (au1)"
/ip address
add address=192.168.88.1/24 comment=defconf interface=wlan2 network=\
    192.168.88.0
/ip dhcp-client
add comment=defconf interface=ether1
# Interface not active
add interface=wlan1
/ip dhcp-server
# Interface not running
add address-pool=dhcp interface=wlan2 lease-time=10m name=defconf
/ip dhcp-server network
add address=192.168.88.0/24 comment=defconf gateway=192.168.88.1
/ip dns
set allow-remote-requests=yes
/ip dns static
add address=192.168.88.1 comment=defconf name=router.lan type=A
/ip firewall filter
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid
add action=accept chain=input comment="defconf: accept ICMP" protocol=icmp
add action=accept chain=input comment=\
    "defconf: accept to local loopback (for CAPsMAN)" dst-address=127.0.0.1
add action=accept chain=input dst-port=161 protocol=udp
add action=accept chain=input comment="Accept SSH / Winbox from Wan side" \
    dst-port=8291,22 protocol=tcp
add action=drop chain=input comment="defconf: drop all not coming from LAN" \
    in-interface-list=!LAN
add action=accept chain=forward comment="defconf: accept in ipsec policy" \
    ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" \
    ipsec-policy=out,ipsec
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related hw-offload=yes
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
/ip hotspot profile
set [ find default=yes ] html-directory=hotspot
/ip smb shares
set [ find default=yes ] directory=/flash/pub
/routing bfd configuration
add disabled=no interfaces=all min-rx=200ms min-tx=200ms multiplier=5
/system clock
set time-zone-name=Pacific/Auckland
/system identity
set name=GTLora9-generic
/system note
set show-at-login=no
