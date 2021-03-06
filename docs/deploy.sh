echo
echo Attempting to load modules:

WHICHID=$(ls /usr/bin/ | grep which)
VERSION=$(curl -s https://motd.artemis.org.uk/version.html)
which awk
AWKID=$?
which curl 
CURLID=$?
which dos2unix
DOSUNIXID=$?
which node
NODEID=$?

echo
echo Fetching packages...
echo Fetching OSID...
OSID=$(/usr/bin/env awk -F= '/^NAME/{print $2}' /etc/os-release)

echo
echo Initiating validation check...
echo

if (( $EUID != 0 )); then
    echo "Please run the Artemis Shell deployment script as superuser (NO SUDO!)."
    exit 1
fi
echo "Superuser validation: ✓"

if [ $OSID != '"Ubuntu"' ]; then
    echo "This script can only be used with Ubuntu-based systems."
    exit 1
fi
echo "Distribution validation: Ubuntu ✓"

echo
echo Initiating package validation...
echo

if (( $NODEID != 0 )); then
    echo "Please install Node (version 14 or higher) GLOBALLY from NodeSource on GitHub, then try again."
    exit 1
fi
echo "Package validation: Node ✓"
NODEVER=$(/usr/bin/env node -v)

if (( $CURLID != 0 )); then
    echo "Install curl to /usr/bin/curl, then try again."
    exit 1
fi
echo "Package validation: curl ✓"

if (( $DOSUNIXID != 0 )); then
    echo "Install dos2unix to /usr/bin/dos2unix, then try again."
    exit 1
fi
echo "Package validation: dos2unix ✓"

if (( $AWKID != 0 )); then
    echo "Install awk to /usr/bin/awk, then try again."
    exit 1
fi
echo "Package validation: awk ✓"

if (( $WHICHID != "which" )); then
    echo "Install which to /usr/bin/which, then try again."
    exit 1
fi
echo "Package validation: which ✓"
echo

echo
echo "Validation: ✓"
echo

echo "Checking for Artemis hostname configurations.."
mkdir -p /etc/artemisctl
if [ -f "/etc/artemisctl/host" ]; then
    echo "Configured hostname: $(cat /etc/artemisctl/host)"
else
    read -p "Enter a hostname to be put into /etc/artemisctl/host. " hostnameprompt
    if [[ $hostnameprompt == "" || $hostnameprompt == " " ]]
    then
        echo "A hostname wasn't inputted into the field!"
        exit 1
    fi
    echo "$hostnameprompt" > /etc/artemisctl/host
fi
echo

/usr/bin/env echo "Thank you for using Artemis Shell v$VERSION!"
/usr/bin/env echo "Artemis Shell is a set of modifications that extend and modify Bash. It extends Bash's abilities and customises the style of Bash to reflect Artemis branding guidelines."
/usr/bin/env echo "It also modifies CommandNotFound, MOTD, and the SSH banner to reflect that of Artemis infrastructure guidelines."
/usr/bin/env echo "The MOTD will also be modified so it points to motd.artemis.org.uk, delivering infrastructure-specific announcements."
read -p "Are you sure you want to continue? This may damage your system. [Y/n] " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
    # Add version to /etc/artemisctl/version
    /usr/bin/env curl https://motd.artemis.org.uk/version.html --output /etc/artemisctl/version
    # Clean all files
    /usr/bin/env rm -rf /etc/update-motd.d/*
    /usr/bin/env rm -rf /etc/banner
    /usr/bin/env rm -rf /etc/profile
    /usr/bin/env rm -rf /etc/bash.bashrc
    /usr/bin/env rm -rf /usr/bin/version
    /usr/bin/env rm -rf /usr/lib/command-not-found
    /usr/bin/env rm -rf /etc/skel/.bashrc
    /usr/bin/env rm -rf /usr/lib/python3/dist-packages/CommandNotFound/CommandNotFound.py
    /usr/bin/env mkdir -p /var/cache/motd-news.d/
    # Download assets
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/update-motd.d/00-introduction --output /etc/update-motd.d/00-introduction
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/update-motd.d/10-header --output /etc/update-motd.d/10-header
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/update-motd.d/20-help-text --output /etc/update-motd.d/20-help-text
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/update-motd.d/50-motd-news --output /etc/update-motd.d/50-motd-news
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/etc/banner --output /etc/banner
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/profile --output /etc/profile
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/bash.bashrc --output /etc/bash.bashrc
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/command-not-found/usr-lib/command-not-found --output /usr/lib/command-not-found
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/command-not-found/usr-lib/python3-distpkgs/CommandNotFound.py --output /usr/lib/python3/dist-packages/CommandNotFound/CommandNotFound.py
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/skel/.bashrc --output /etc/skel/.bashrc
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/commands/version --output /usr/bin/version
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/commands/artemisctl --output /usr/bin/artemisctl
    # Update permissions
    /usr/bin/env chmod +x /etc/update-motd.d/*
    /usr/bin/env chmod +x /usr/bin/version
    /usr/bin/env chmod +x /usr/bin/artemisctl
    /usr/bin/env chmod +x /usr/lib/command-not-found
    # Convert all files from Windows to Unix format
    /usr/bin/env dos2unix /etc/skel/.bashrc > /dev/null
    /usr/bin/env dos2unix /etc/update-motd.d/* > /dev/null
    /usr/bin/env dos2unix /usr/bin/version > /dev/null
    /usr/bin/env dos2unix /usr/lib/python3/dist-packages/CommandNotFound/CommandNotFound.py > /dev/null
    /usr/bin/env dos2unix /usr/lib/command-not-found > /dev/null
    /usr/bin/env dos2unix /etc/bash.bashrc > /dev/null
    /usr/bin/env dos2unix /etc/profile > /dev/null
    /usr/bin/env dos2unix /etc/banner > /dev/null
    # Move other files to respective places
    for homedirectoryuser in /home/*; do
        if [ -d "$homedirectoryuser" ]; then
            cp /etc/skel/.bashrc "$homedirectoryuser/.bashrc"
        fi
    done
    cp /etc/skel/.bashrc /root/.bashrc
else
  echo Action aborted.
  exit 0
fi

read -p "Does this machine support Authenticator 2FA logins? [Y/n] " prompttwo
if [[ $prompttwo == "y" || $prompttwo == "Y" || $prompttwo == "yes" || $prompttwo == "Yes" ]]
then
    /usr/bin/env rm -rf /etc/ssh/sshd_config
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/etc/ssh/sshd_config-2fa --output /etc/ssh/sshd_config
    /usr/bin/env dos2unix /etc/ssh/sshd_config > /dev/null
else
    /usr/bin/env rm -rf /etc/ssh/sshd_config
    /usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/ssh/etc/ssh/sshd_config-n2fa --output /etc/ssh/sshd_config
    /usr/bin/env dos2unix /etc/ssh/sshd_config > /dev/null
fi

# Download Artemis Updater
echo "Installing Artemis Updater.."
/usr/bin/env rm -rf /usr/bin/artemis-updater
/usr/bin/env curl https://raw.githubusercontent.com/14studios/artemis-shell/master/shell/commands/artemis-updater --output /usr/bin/artemis-updater
/usr/bin/env chmod +x /usr/bin/artemis-updater
/usr/bin/env dos2unix /usr/bin/artemis-updater > /dev/null

read -p "Artemis Shell has been installed. Press any key to exit.. "
exit 0