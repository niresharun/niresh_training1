#!/bin/bash


# ----------------------- Functions - START ------------------------------

focal () {
	echo "Adding device to AD.ZIFFITY domain"

	apt update

	apt install -y	vim \
					adcli \
					krb5-user \
					libnss-sss \
					libpam-sss \
					oddjob \
					oddjob-mkhomedir \
					packagekit \
					realmd \
					samba-common-bin \
					sssd \
					sssd-tools

	# vim /etc/ssh/ssh_config
	if ! grep -q "Ziffity AD Customization" /etc/ssh/ssh_config
	then
	    sed -i '$ a \\n# Ziffity AD Customization\nGSSAPIKeyExchange yes' /etc/ssh/ssh_config
	fi

	# vim /etc/pam.d/common-session
	if ! grep -q "Ziffity AD Customization" /etc/pam.d/common-session
	then
	    sed -i '$ a \\n# Ziffity AD Customization\nsession    required    pam_mkhomedir.so skel=/etc/skel/ umask=0022' /etc/pam.d/common-session
	fi
	
	# vim /etc/krb5.conf
	if ! grep -q "Ziffity AD Customization" /etc/krb5.conf
	then
	    sed -i '$ a \\n# Ziffity AD Customization\n[libdefaults]\ndns_lookup_realm = false\n ticket_lifetime = 24h\n renew_lifetime = 7d\n forwardable = true\n rdns = false\n default_ccache_name = KEYRING:persistent:%{uid}' /etc/krb5.conf
	fi	

	# vim /etc/sudoers
	if ! grep -q "Ziffity AD Customization" /etc/sudoers
	then
	    sed -i '$ a \\n# Ziffity AD Customization\n%domain\\ users@ad.ziffity.com ALL=(ALL:ALL) ALL' /etc/sudoers
	fi

	# Realm
	realm discover ad.ziffity.com

	realm join ad.ziffity.com -U Admin
}

others () {
	echo "Ubuntu distro unknown"
	focal
}

# ----------------------- Functions - END ------------------------------

os_version=$(lsb_release -r | awk '{print $2}')

if [ $os_version = '20.04' ];
then
	focal
else
	others
fi
