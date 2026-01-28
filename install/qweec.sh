#!/usr/bin/bash

#############################################################
# global variables

# global across other files
readonly QWEEC='/usr/local/qweec'
readonly QWEECVER='0.5.0'

# install 8.2 from remi repo by default
PHPVER='8.2';

# default vars
isemail=qweec@panel.local;
# pw minimum 12 symbols
ispassword='';
ishostname='qweec.panel.local';
isport='1505';
isforce='';

# apps
# mysql or mariadb
ismysql='';
ispgsql='';
isexim='';
isclamav='';
isspamassassin='';
# iptables or nftables
isfirewall='';
iscontainer='';
isquota='';



# apps
function parse_args_into_apps() {

    local featlist=('mariadb' 'mysql' 'pgsql' 'exim' 'clamav' 'spamassassin' 'iptables' 'nftables' 'podman' 'quota');

    # noneed to make global, only ismysql is used
    local apps_found='';
    local ismariadb='';
    local isiptables='';
    local isnftables='';

    # if less than 6gb, clamav and spamassassin are cpu/mem hogs, do not install be default, unless explicitly set by user
    local memory
    memory=$(grep 'MemTotal' /proc/meminfo | awk '{print$2}')
    if [ "$memory" -lt 6000000 ]; then
        isclamav=''
        isspamassassin=''
    fi

    local ARGS=( "$@" );
    for ARG in "${ARGS[@]}"; do
        local is_eq_sign
        is_eq_sign=$(echo "$ARG" | grep '=');
        if [ ! -z "$is_eq_sign" ]; then
            tmpvar=$(echo "$ARG" | cut -d '=' -f1 | cut -d '-' -f3- | awk '{print$1}');
            tmpval=$(echo "$ARG" | cut -d '=' -f2-);
            if [ ! -z "$tmpvar" ]; then

                if [ "$tmpvar" = 'apps' ]; then
                    apps_found='yes';
                    for feat in "${featlist[@]}"; do
                        if echo "$tmpval" | grep -iq "$feat"; then
                            eval is${feat}=$feat;
                        fi
                    done
                else
                    # trim all values of all vars except apps var
                    tmpval=$(echo "$tmpval" | awk '{print$1}');
                    eval is${tmpvar}='$tmpval';
                fi

            fi
        fi
    done

    # if apps not specified , run default
    if [ -z $apps_found ]; then
        ismysql=mariadb;
        ispgsql='';
        isexim=exim;
        isclamav='';
        isspamassassin='';
        isfirewall=nftables;
        iscontainer='';
        isquota='';
    fi

    # if set both mysql and mariadb, install mariadb only
    if [ ! -z "$ismariadb" ]; then
        ismysql=mariadb;
    fi

    if [ -z "$isexim" ]; then
        isclamav=''
        isspamassassin=''
    fi

    if [ ! -z $isnftables ]; then
        isfirewall=nftables;
    elif [ ! -z $isiptables ]; then
        isfirewall=iptables;
    else
        isfirewall=nftables;
    fi

    if [ ! -z $ispodman ]; then
        iscontainer=podman;
    fi

}


###################################################################################
# software install

function software_essential_install() {
    # bind-tools for dig
     dnf install -y bind-utils curl rsync sudo tar unzip vim which zstd zip;
}

function software_misc_install() {
    dnf install -y chrony flex freetype ftp goaccess ImageMagick ImageMagick-libs lsof libcap \
    NetworkManager openssh-server openssh-clients pcre pcre2 publicsuffix-list qweec qweenstall \
    rrdtool rsyslog screen sqlite tzdata;
}

function software_web_install() {
    # do not install mod_http2 for now
    dnf install -y nginx httpd mod_fcgid mod_ssl;
}

# 1: php version
function software_php_remi_repo_install() {
    # phpmyadmin: php-process
    # roundcube 1.6.0: php-intl php-ldap php-enchant php-mcrypt
    local software_php_base="php php-cli php-common php-fpm";
    local software_php_ext="php-bcmath php-enchant php-gd php-imap php-intl php-ldap php-mbstring php-mcrypt php-mysqli php-opcache php-pdo php-process php-soap php-tidy php-xml php-xmlrpc php-zip";

    local phpv="$1";
    if [[ -z "$phpv" ]]; then return 1; fi

    infomsg "installing php ${phpv}..";
    dnf module reset php -y;
    dnf module enable -y php:remi-${phpv};

    infomsg "$phpmodule is being installed.."
    dnf install -y $software_php_base >/dev/null;
    dnf install -y --skip-broken $software_php_ext >/dev/null;
}

function software_db_install() {
    if [ "$ismysql" = 'mariadb' ]; then
        dnf install -y mariadb mariadb-server;
        # /usr/lib64/mariadb/plugin/caching_sha2_password.so
	    dnf install -y mariadb-connector-c;
    elif [ "$ismysql" = 'mysql' ]; then
        dnf install -y mysql mysql-server;
    fi
}

function software_mail_install() {
    if [ ! -z "$isexim" ]; then
        # roundcube: enchant2 hunspell
        dnf install -y exim dovecot enchant2 hunspell;

        if [ ! -z "$isclamav" ]; then
            dnf install -y clamd clamav;
        fi

        if [ ! -z "$isspamassassin" ]; then
            dnf install -y spamassassin;
        fi
    fi
}

function software_vsftpd_install() {
    dnf install -y vsftpd;
}

function software_firewall_install() {
    if [ "$isfirewall" = 'iptables' ]; then
        dnf install -y iptables-services ipset fail2ban;
    elif [ "$isfirewall" = 'nftables' ]; then
        dnf install -y nftables fail2ban;
    fi
}

function software_podman_install() {
    if [ ! -z "$iscontainer" ]; then
        dnf install -y podman dnsmasq;
    fi
}



function update_repos() {
    infomsg 'updating repos..';

    # remi-repo requires rocky 9.5+, so unfortunately update is necessary.
    # everything else except remi, gets installed properly on rocky 9.1
    dnf update -y;

    if ! dnf install -y epel-release; then echo "epel-release repository installation failed"; fi

    local majver=$(get_distro_majver);

    # remi repo
    if [ ! -e "/etc/yum.repos.d/remi.repo" ]; then
        dnf install -y "http://rpms.remirepo.net/enterprise/remi-release-${majver}.rpm"
        if [ $? -ne 0 ]; then errmsg "failed installing remi repo"; fi
        # dnf config-manager --set-enabled remi
        dnf config-manager --set-enabled remi-safe
    fi

    # dnf-utils repo
    if ! dnf install -y dnf-utils; then echo "dnf-utils repository installation failed"; fi

    # nginx repo
    if [ ! -e "/etc/yum.repos.d/nginx.repo" ]; then
        # stable
        local nlink="https://nginx.org/packages/rhel/${majver}/\$basearch/";

        # latest (requires dnf module disable nginx)
        # local nlink="https://nginx.org/packages/mainline/rhel/${majver}/\$basearch/";
        dnf module disable -y nginx

        local nrepo="/etc/yum.repos.d/nginx.repo";
        local ngkey="https://nginx.org/keys/nginx_signing.key"
        printf "[nginx]\nname=Nginx repo\nbaseurl=%s\ngpgcheck=0\nenabled=1\ngpgkey=%s\nmodule_hotfixes=true\n" "$nlink" "$ngkey" > "$nrepo";
        dnf config-manager --set-enabled nginx
    fi

    # qweec
    curl -sL --insecure --retry 3 -o /etc/pki/rpm-gpg/RPM-GPG-KEY-qweec http://repo.qweec.net/rhel/qweec.rpm.gpg
    local qlink='http://repo.qweec.net/rhel/9/x86_64/';
    local qrepo='/etc/yum.repos.d/qweec.repo';
    local qgkey='file:///etc/pki/rpm-gpg/RPM-GPG-KEY-qweec';
    printf "[qweec]\nname=Qweec - Almalinux, Rocky repo\nbaseurl=%s\nenabled=1\ngpgcheck=1\ngpgkey=%s\n" "$qlink" "$qgkey" > "$qrepo";
    dnf config-manager --set-enabled qweec

    # upate cache
    dnf clean all
    dnf makecache

}



#############################################################
# misc functions

function errmsg() { printf "[\033[0;31merror\033[0m] %s\n" "$1" > /dev/tty; }
function okmsg() { printf "   [\033[1;32mok\033[0m] %s\n" "$1" > /dev/tty; }
function infomsg() { printf " \033[2;37m[info] %s\033[0m\n" "$1" > /dev/tty; }
function warnmsg() { printf " [\033[0;33mwarn\033[0m] %s\n" "$1" > /dev/tty; }

function check_root_user() {
    if [ "$(id -u)" != '0' ]; then
        errmsg "can be run only by root"
        return 1;
    fi
    return 0;
}

function check_arch() {
    if [ "$(uname -m)" != "x86_64" ]; then
        errmsg 'allowed arch: x86_64';
        return 1;
    fi
    return 0;
}

function get_distro_majver() {
    local majver=$(sed -n 's/^VERSION_ID="\([0-9]*\).*/\1/p' /etc/os-release);
    echo -n "$majver";
}

function check_distro() {

    if [ ! -z "$(grep -iF 'Rocky Linux' /etc/os-release)" ]; then
        # echo -n 'rocky';
        return 0;
    elif [ ! -z "$(grep -iF 'AlmaLinux' /etc/os-release)" ]; then
        # echo -n 'alma';
        return 0;
    fi

    errmsg 'get_distro_name: distro is not supported';
    echo -n '';
    return 1;
}

function is_link_valid() {
    local http_code;
    http_code=$(curl --insecure -I -L "$1" 2>/dev/null | head -n 1 | cut -d$' ' -f2);
    if [[ $http_code == 302 || $http_code == 301 || $http_code == 200 ]]; then
        return 0;
    fi
    return 1;
}

function generate_password() {
    local pass=$(< /dev/urandom tr -dc 'A-Za-z0-9' | head -c 20);
    echo -n "$pass";
}

# size_mib
function swapfile_create() {
    infomsg 'checking swap file..';

    local memory
    memory=$(grep 'MemTotal' /proc/meminfo | tr ' ' '\n' | grep '[0-9]' | awk '{print$1}');
    if  [ $memory -lt 1000000 ] && [ -z "$(swapon --show --noheadings --raw)" ]; then

        if [ ! -e "/swapfile" ]; then
            dd if=/dev/zero of=/swapfile bs=1MiB count=1024;
        fi
        chmod 600 /swapfile;

        mkswap /swapfile && swapon /swapfile;
        if [ $? -eq 0 ]; then
            if ! grep swap /etc/fstab; then echo '/swapfile none swap sw 0 0' >> /etc/fstab; fi
            if ! grep vm.swappiness /etc/sysctl.conf; then echo 'vm.swappiness=20' >> /etc/sysctl.conf; fi
            if ! grep vm.vfs_cache_pressure /etc/sysctl.conf; then echo 'vm.vfs_cache_pressure=50' >> /etc/sysctl.conf; fi
            sysctl -w vm.swappiness=20 > /dev/null && sysctl -w vm.vfs_cache_pressure=50 > /dev/null
        fi

    fi

    sleep 3;
}

# hostname: str
function validate_hostname() {
    local hname=$1
    local dotcount
    dotcount=$(echo -e "$hname" | sed -e 's/\.*$//' | tr -d -c '.' | awk '{ print length; }');
    local mask1='([[:alnum:]])';
    if [[ -n $dotcount ]] && [[ $dotcount -gt 0 ]]; then

        # hname[0]
        if [[ "${hname:0:1}" = '.' ]] || [[ "${hname:0:1}" = '-' ]]; then
            # echo "first ${hname:0:1}";
            return 1;
        fi

        # hname[len-1]
        local hname_sz=${#hname};
        if [[ $hname_sz -gt 0 ]]; then
            ((hname_sz--));
            if [[ "${hname:$hname_sz:1}" = '.' ]] || [[ "${hname:$hname_sz:1}" = '-' ]]; then
                # echo "last ${hname:$hname_sz:1}";
                return 1;
            fi
        fi

        for (( i=0; i<${#hname}; i++ )); do
            local letter="${hname:$i:1}"
            # echo -n "$letter";

            if [[ "$letter" =~ $mask1 ]] || [[ "$letter" = '-' ]] || [[ "$letter" = '.' ]]; then
                :
            else
                return 1;
            fi
        done
        return 0;
    fi
    return 1;
}

# email: str
function get_set_email() {
    local isemailok
    isemailok=$(echo "$1" | grep "@" | grep ".");
    if [ ! -z "$isemailok" ]; then
        echo -n "$1";
        return 0;
    fi

    warnmsg "invalid email, replacing with the default";
    echo -n "qweec@panel.local";
    return 0;
}

# hostname: str
function get_set_hostname() {
    validate_hostname "$1";
    if [[ $? -eq 0 ]]; then
        hostnamectl set-hostname "$1";
        export HOSTNAME="$1";
        echo "127.0.0.1 $1" >> /etc/hosts
        local is6
        is6=$(hostname -i | grep ":")
        if [ ! -z "$is6" ]; then
            echo "::1 $1" >> /etc/hosts
        fi

        echo -n "$1";
        return 0;
    fi

    local hname
    hname=$(hostname | awk '{print $1;}');
    if validate_hostname "$hname"; then
        echo -n "$hname";
    else
        hostnamectl set-hostname "qweec.panel.local";
        export HOSTNAME="qweec.panel.local";
        echo -n "qweec.panel.local";
    fi
    return 0;
}

function selinux_disable() {

    if [ -z "$(getenforce | grep Disabled)" ]; then
        infomsg "disabling selinux..";

        # since rhel 8+
        dnf install -y -q grubby;
        grubby --update-kernel ALL --args selinux=0;
        # reboot and check with getenforce

        # rhel < 8 (works for now, but can cause race conditions)
        if [ -e '/etc/selinux/config' ]; then
            sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        fi
        if [ -e '/etc/sysconfig/selinux' ]; then
            sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
        fi
        setenforce 0 2>/dev/null

        warnmsg "server will reboot in 10 seconds in order to disable selinux,";
        warnmsg "please start installation again after reboot.";
        sleep 10;
        reboot;
    fi
}

# 0:app 1:description
function summary_prinf_app() { printf "    \033[32m${1}\033[0m \t($2)\n"; }

function summary() {

    echo;
    echo '     ░                   ░  ░ ░ ░     ░     ░  ░   ░           ░░  ░        ░      ░    ░  '
    echo '  ░ ░ ███████████   ░   ███    ▒███       ██████████▒    ░  ██████████  ░    ░████████░    '
    echo '    ▓███ ░  ░░ ████   ████      ▓███▒   ████  ░ ░  ███    ████       ███    ████           '
    echo '   █████████████▓███ ████    ▓  ░ ████ ███▓█████████████░███▓█████████████░███▓  ░   ░     '
    echo '              ████ ░   ████ ███▒████  ░  ████           ░░ ███▓              ████       ░  '
    echo ' ░░ ░    ░    ▒█ ░       █████████         ████████      ░  ▒████████░        ▓████████ ░  '
    echo '       ░    ░                ░                               ░   ░     ░ ░░ ░              '

    printf "\n\nqweec.net\n\033[32mpanel version:\033[0m \t$QWEECVER\n\n";
    infomsg 'server configuration to be installed:';
    echo;

    summary_prinf_app nginx 'web server';
    summary_prinf_app httpd 'web server';
    summary_prinf_app php-fpm 'php process manager';

    if [ "$ismysql" = 'mariadb' ]; then
        summary_prinf_app mariadb 'database management server';
    elif [ "$ismysql" = 'mysql' ]; then
        summary_prinf_app mysql 'database management server';
    fi

    if [ ! -z "$isexim" ]; then
        summary_prinf_app exim 'smtp server';
        summary_prinf_app dovecot 'imap/pop3 server';
        if [ ! -z "$isclamav" ]; then
            summary_prinf_app clamav 'malware scanner';
        fi
        if [ ! -z "$isspamassassin" ]; then
            summary_prinf_app spamassassin 'mail spam filter';
        fi
    fi

    summary_prinf_app vsftpd 'ftp server';

    if [ "$isfirewall" = 'iptables' ]; then
        summary_prinf_app iptables 'firewall';
        summary_prinf_app fail2ban 'brute-force defender';
    elif [ "$isfirewall" = 'nftables' ]; then
        summary_prinf_app nftables 'firewall';
        summary_prinf_app fail2ban 'brute-force defender';
    fi

    if [ "$iscontainer" = 'podman' ]; then
        summary_prinf_app podman 'container management system';
    fi

    echo;
    # 5 minutes - dnf update
    # 8 minutes - software installation
    # 2 minutes - panel installation and software configuration
    infomsg "installation will take about 10-15 minutes.."
    echo;

    sleep 10;
}

function check_installed_package_conflicts() {

    local installed="";
    rpm -q mariadb-server &>/dev/null && installed+="mariadb-server\n";
    rpm -q mysql-server &>/dev/null && installed+="mysql-server\n";
    rpm -q php &>/dev/null && installed+="php\n";

    # do not delete firewalld, will delete needed packages

    if [ ! -z "$installed" ]; then

        errmsg 'conflicting installed packages are found.'
        warnmsg "recommended to install control panel on a fresh server.";
        echo;
        echo -e "$installed";
        echo;

        local answer='';
        echo 'Do you want install anyway?';
        read -p "If yes, packages will be deleted or reinstalled, proceed with care! [y/n]: " answer

        if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
            errmsg 'installation aborted';
            return 1;
        fi
    fi

    return 0;
}

function user_group_exist_check() {

    local ru='';
    [ ! -z "$(grep -E '^rocky:' /etc/passwd)" ] && ru='user: rocky';
    local rg='';
    [ ! -z "$(grep -E '^rocky:' /etc/group)" ] && rg='group: rocky';

    local au='';
    [ ! -z "$(grep -E '^admin:' /etc/passwd)" ] && au='user: admin';
    local ag='';
    [ ! -z "$(grep -E '^admin:' /etc/group)" ] && ag='group: admin';

    if [ ! -z $ru ] || [ ! -z $rg ] || [ ! -z $au ] || [ ! -z $ag ]; then
        errmsg 'conflicting users or groups are found.'
        echo;
        echo -e "${ru}\n${rg}\n${au}\n${ag}\n";
        echo;

        local answer='';
        read -p "Do you confirm deletion of this users and groups? [y/n]: " answer

        if [ "$answer" != "y" ] && [ "$answer" != "Y" ]; then
            errmsg 'installation aborted.'
            return 1;
        fi
    fi
    return 0;
}

function user_group_backup_and_delete() {

    local pre_inst_backup
    pre_inst_backup="/root/qweec_preinstall_backup/$(date +"%Y-%m-%d-%H-%M")";
    mkdir -p "$pre_inst_backup/home";

    # rocky dir
    if [ -e "/home/rocky" ]; then
        warnmsg "moving directory /home/rocky to $pre_inst_backup/home/ ..";
        mv -f /home/rocky "$pre_inst_backup/home/" >/dev/null 2>&1
    fi
    # delete rocky user
    if [ ! -z "$(grep -E '^rocky:' /etc/passwd)" ]; then
        warnmsg 'deleting rocky user..';
        userdel -f rocky 2>&1
        rm -f /tmp/sess_* >/dev/null 2>&1
    fi
    # delete rocky group
    if [ ! -z "$(grep -E '^rocky:' /etc/group)" ]; then
        warnmsg 'deleting rocky group..';
        groupdel rocky 2>&1
    fi

    # admin dir
    if [ -e "/home/admin" ]; then
        warnmsg "moving directory /home/admin to $pre_inst_backup/home/ ..";
        mv -f /home/admin "$pre_inst_backup/home/" >/dev/null 2>&1
    fi
    # delete admin user
    if [ ! -z "$(grep -E '^admin:' /etc/passwd)" ]; then
        warnmsg 'deleting admin user..';
        userdel -f admin 2>&1
        rm -f /tmp/sess_* >/dev/null 2>&1
    fi
    # delete admin group
    if [ ! -z "$(grep -E '^admin:' /etc/group)" ]; then
        warnmsg 'deleting admin group..';
        groupdel admin 2>&1
    fi

    return 0;
}

function backup_existing_packages() {

    local pre_inst_backup
    pre_inst_backup="/root/qweec_preinstall_backup/$(date +"%Y-%m-%d-%H-%M")";
    warnmsg "backup directory: $pre_inst_backup";
    mkdir -p "$pre_inst_backup"

    systemctl stop nginx >/dev/null 2>&1
    rsync -a /etc/nginx "$pre_inst_backup/" >/dev/null 2>&1

    systemctl stop httpd > /dev/null 2>&1
    rsync -a /etc/httpd "$pre_inst_backup/" >/dev/null 2>&1

    systemctl stop php-fpm >/dev/null 2>&1
    mkdir "$pre_inst_backup/php"
    rsync -a /etc/php.ini "$pre_inst_backup/php/" >/dev/null 2>&1
    rsync -a /etc/php.d "$pre_inst_backup/php/" >/dev/null 2>&1
    rsync -a /etc/php-fpm.conf "$pre_inst_backup/php/" >/dev/null 2>&1
    mv -f /etc/php-fpm.d "$pre_inst_backup/php/" >/dev/null 2>&1
    mkdir /etc/php-fpm.d

    systemctl stop mysql >/dev/null 2>&1
    systemctl stop mysqld >/dev/null 2>&1
    systemctl stop mariadb >/dev/null 2>&1
    mkdir "$pre_inst_backup/mysql"
    mv /var/lib/mysql "$pre_inst_backup/mysql/mysql_datadir" >/dev/null 2>&1
    rsync -a /etc/my.cnf "$pre_inst_backup/mysql/" >/dev/null 2>&1
    rsync -a /etc/my.cnf.d "$pre_inst_backup/mysql/" >/dev/null 2>&1
    mv /root/.my.cnf  "$pre_inst_backup/mysql/" >/dev/null 2>&1

    systemctl stop exim >/dev/null 2>&1
    rsync -a /etc/exim "$pre_inst_backup/" >/dev/null 2>&1

    systemctl stop clamd >/dev/null 2>&1
    mkdir "$pre_inst_backup/clamd"
    rsync -a /etc/clamd.conf "$pre_inst_backup/clamd/" >/dev/null 2>&1
    rsync -a /etc/clamd.d "$pre_inst_backup/clamd/" >/dev/null 2>&1

    systemctl stop spamassassin >/dev/null 2>&1
    rsync -a /etc/mail/spamassassin "$pre_inst_backup/" >/dev/null 2>&1

    systemctl stop dovecot >/dev/null 2>&1
    rsync -a /etc/dovecot.conf "$pre_inst_backup/" >/dev/null 2>&1
    rsync -a /etc/dovecot "$pre_inst_backup/" >/dev/null 2>&1

    systemctl stop vsftpd >/dev/null 2>&1
    mkdir "$pre_inst_backup/vsftpd"
    rsync -a /etc/vsftpd/vsftpd.conf "$pre_inst_backup/vsftpd/" >/dev/null 2>&1

}

function firewall_restart() {

    # make sure conntrack is enabled
    modprobe nf_conntrack

    # disable firewalld
    systemctl disable --now firewalld >/dev/null 2>&1

    # clean up the iptables or nftables, if already installed
    if [ "$isfirewall" = 'iptables' ]; then
        systemctl disable --now nftables >/dev/null 2>&1

        systemctl restart iptables >/dev/null 2>&1
        systemctl restart ip6tables >/dev/null 2>&1
        iptables -P INPUT ACCEPT 2>/dev/null
        iptables -F INPUT 2>/dev/null
        ip6tables -P INPUT ACCEPT 2>/dev/null
        ip6tables -F INPUT 2>/dev/null

    elif [ "$isfirewall" = 'nftables' ]; then
        systemctl disable --now iptables >/dev/null 2>&1
        systemctl disable --now ip6tables >/dev/null 2>&1

        systemctl restart nftables >/dev/null 2>&1
        nft flush ruleset >/dev/null 2>&1
    fi
}

function firewall_cleanup() {
    # clean up the iptables or nftables, if already installed
    if [ "$isfirewall" = 'iptables' ]; then
        iptables -P INPUT ACCEPT 2>/dev/null
        iptables -F INPUT 2>/dev/null
        ip6tables -P INPUT ACCEPT 2>/dev/null
        ip6tables -F INPUT 2>/dev/null

    elif [ "$isfirewall" = 'nftables' ]; then
        nft flush ruleset >/dev/null 2>&1
    fi
}

function firewall_enable() {
    if [ "$isfirewall" = 'iptables' ]; then
        infomsg "restarting and enabling iptables.."
        systemctl enable --now iptables >/dev/null 2>&1
        systemctl enable --now ip6tables >/dev/null 2>&1
    elif [ "$isfirewall" = 'nftables' ]; then
        infomsg "restarting and enabling nftables.."
        systemctl enable --now nftables >/dev/null 2>&1
    fi
}

function extra_configuration() {

    # register /usr/sbin/nologin if not exists
    if [ -e "/usr/sbin/nologin" ] && [ -z "$(grep -E '^/usr/sbin/nologin' /etc/shells)" ]; then
        echo "/usr/sbin/nologin" >> /etc/shells
    fi

    # change default systemd interval
    if [ -z "$(grep -E '^DefaultStartLimitInterval=' /etc/systemd/system.conf)" ]; then
        echo "DefaultStartLimitInterval=1s" >> /etc/systemd/system.conf
    fi
    # increasing limit from 5 to 15 might be useful for commands that run many times and restart the service
    if [ -z "$(grep -E '^DefaultStartLimitBurst=' /etc/systemd/system.conf)" ]; then
        echo "DefaultStartLimitBurst=15" >> /etc/systemd/system.conf
    fi

    systemctl daemon-reexec
}

#######################################################################################################################
#######################################################################################################################
# preparation

check_root_user;
if [ $? -ne 0 ]; then exit 1; fi

check_arch;
if [ $? -ne 0 ]; then exit 1; fi

check_distro;
if [ $? -ne 0 ]; then exit 1; fi

selinux_disable;

parse_args_into_apps "$@";

if [ "$isforce" != "yes" ]; then
    check_installed_package_conflicts;
    if [ $? -ne 0 ]; then exit 1; fi

    user_group_exist_check;
    if [ $? -ne 0 ]; then exit 1; fi
fi

summary;

isemail=$(get_set_email $isemail);
ishostname=$(get_set_hostname $ishostname);
if [ "$(echo "${#ispassword}")" -lt 12 ]; then
    warnmsg "password is too weak, a new password will be generated, it can be changed later"
    ispassword=$(generate_password);
    sleep 2;
fi

#############################################################
infomsg "system configuration.."

swapfile_create 1024;
update_repos;

user_group_backup_and_delete;
backup_existing_packages;
firewall_restart;
firewall_cleanup;
extra_configuration;

#############################################################
infomsg "installing software packages.."

software_essential_install;
software_misc_install;
software_web_install;
software_php_remi_repo_install $PHPVER;
software_db_install;
software_mail_install;
software_vsftpd_install;
software_firewall_install;
software_podman_install;


# restart rsyslog
systemctl restart rsyslog >/dev/null 2>&1

# ntp sync
systemctl enable --now chronyd;

#############################################################
infomsg "panel configuration.."

/usr/local/bin/qweenstall basedir-init "$isexim,$isclamav,$isspamassassin,$isfirewall,$iscontainer,$isquota"

infomsg "issuing host certificate.."
# generate ssl certificate for exim, dovecot, vsftpd
/usr/local/bin/qweecli ssl-ss-gen "$(hostname | awk '{print$1;}')" "" "$isemail" XX,XX,XX,common,common $QWEEC/cert/host.key $QWEEC/cert/host.pem 2048
chown root:mail $QWEEC/cert/{host.key,host.pem}
chmod 660 $QWEEC/cert/{host.key,host.pem}

#############################################################
infomsg "software configuration.."

/usr/local/bin/qweenstall filemanager-configure
/usr/local/bin/qweenstall nginx-configure
/usr/local/bin/qweenstall httpd-configure
/usr/local/bin/qweenstall php-configure
/usr/local/bin/qweenstall php-ioncube-install-all


if [ ! -z "$ismysql" ]; then
    # mysql pass
    mysql_pass=$(generate_password);

    # mysql/mariadb
    /usr/local/bin/qweenstall mysql-configure $ismysql "$mysql_pass";

    # add dbhost
    infomsg "adding dbhost.."
    /usr/local/bin/qweecli db-host-add localhost root "$mysql_pass" "$ismysql" "" ""

    # phpmyadmin
    /usr/local/bin/qweenstall phpmyadmin-configure $ismysql;
fi


if [ ! -z "$isexim" ]; then
    /usr/local/bin/qweenstall exim-configure "$isclamav,$isspamassassin";
    /usr/local/bin/qweenstall dovecot-configure

    if [ ! -z "$isclamav" ]; then
        /usr/local/bin/qweenstall clamav-configure
    fi

    if [ ! -z "$isspamassassin" ]; then
        /usr/local/bin/qweenstall spamassassin-configure
    fi

    if [ ! -z "$isexim" ] && [ ! -z "$ismysql" ]; then
        /usr/local/bin/qweenstall roundcube-configure $ismysql;
    fi
fi

/usr/local/bin/qweenstall vsftpd-configure

if [ "$isfirewall" = 'iptables' ] || [ "$isfirewall" = 'nftables' ]; then
    /usr/local/bin/qweenstall fail2ban-configure "$isfirewall,vsftpd,$isexim,$ismysql,$ispgsql";
fi

#############################################################
infomsg "admin user configuration.."

# add user
/usr/local/bin/qweecli user-add admin "$ispassword" "$isemail" "Administrator"
sleep 1;

/usr/local/bin/qweecli user-shell-set admin nologin

# sudo admin
mkdir -p /etc/sudoers.d
cat << EOF > /etc/sudoers.d/admin
Defaults:root !requiretty
Defaults:admin !requiretty
Defaults:admin !syslog
admin ALL=NOPASSWD:/usr/local/bin/qweecli,NOPASSWD:/usr/local/bin/qweerrd
EOF
chmod 440 /etc/sudoers.d/admin


infomsg "adding cron jobs.."
# randomize backup creation time between 1:00-6:55
min=$(< /dev/urandom tr -dc '012345' | head -c 2);
hour=$(< /dev/urandom tr -dc '12345' | head -c 1);
/usr/local/bin/qweecli cron-add 'admin' "$min" "$hour" '*' '*' '*' 'sudo /usr/local/bin/qweecli --bg users-backup-add' ''
/usr/local/bin/qweecli cron-add 'admin' '00' '00' '*' '*' '*' 'sudo /usr/local/bin/qweecli --bg users-stats-update disk,traffic' ''
/usr/local/bin/qweecli cron-add 'admin' '00' '*/12' '*' '*' '*' 'sudo /usr/local/bin/qweecli --bg ssl-le-update' ''
/usr/local/bin/qweecli cron-add 'admin' '*/5' '*' '*' '*' '*' 'sudo /usr/local/bin/qweerrd' 'yes'

#############################################################

infomsg "ip-update.."
/usr/local/bin/qweecli ip-update

infomsg "firewall init.."
/usr/local/bin/qweecli firewall-rules-reset yes

infomsg "setting up backup system.."
qweecli backup-conn-set local "" "" "" "" 0 ""

# enable quota in system (does not apply quota to users)
if [ ! -z "$isquota" ]; then
    infomsg "creating quota.."
    /usr/local/bin/qweecli --t300 quota-add
    warnmsg 'reboot is required for enabling a quota.' ;
fi

# qweenx listen port change, should be done after firewall installed, modifies firewall rule
if [ ! -z "$isport" ] && [ "$isport" != "1505" ]; then
    infomsg "setting panel port: $isport"
    /usr/local/bin/qweecli panel-port-set $isport
    sleep 2;
fi

firewall_enable;

systemctl restart qweec;
sleep 1;

#############################################################
# final stage

# panel access info
/usr/local/bin/qweenstall finalize $isport $ispassword

# noneed after installation
dnf remove -y -q qweenstall >/dev/null 2>&1
