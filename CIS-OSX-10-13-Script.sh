#!/bin/bash

##################################################################################
# Updated: 01/11/2019	
# Author: Michael Wylie
# Description: Automate Apple macOS 10.13 and 10.14 v1.0.0.0 CIS Benchmark tasks
# This script was tested against OSX 10.14.2 Mojave
##################################################################################

# 1.1 Verify all Apple provided software is current (Scored)
softwareupdate -l

# Pause
echo -n 'If no updates are available, press ENTER to continue'
read

##################################################################################

# 1.2 Enable Auto Update (Scored)
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -int 1 

# 1.3 Enable app update installs (Scored)
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool TRUE 

# 1.4 Enable system data files and security update installs (Scored)
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool true && sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true

# 1.5 Enable macOS update installs (Scored)
sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool TRUE

# 2.2.1 Enable "Set time and date automatically" (Scored)
sudo systemsetup -setnetworktimeserver [NTP Server]
sleep 5s # errors when moving too fast
sudo systemsetup -setusingnetworktime on

# 2.3.1 Set an inactivity interval of 20 minutes or less for the screen saver (Scored)
defaults -currentHost write com.apple.screensaver idleTime -int 600

# 2.4.1 Disable Remote Apple Events (Scored)
sudo systemsetup -setremoteappleevents off

# 2.4.5 Disable Remote Login (Scored)
echo yes | sudo systemsetup -setremotelogin off

# 2.4.8 Disable File Sharing (Scored)
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.AppleFileServer.plist

# 2.5.1 Disable "Wake for network access" (Scored)
sudo pmset -a womp 0

# 2.6.2 Enable Gatekeeper (Scored)
sudo spctl --master-enable

############
# Firewall
############

# 2.6.4 Enable Firewall Stealth Mode (Scored)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

# 2.6.6 Enable Location Services (Not Scored)
sudo launchctl unload /System/Library/LaunchDaemons/com.apple.locationd.plist

# 3.1 Enable security auditing (Scored)
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist

# 3.2 Configure Security Auditing Flags (Scored)
sudo sed -i '' 's/flags.*/flags:lo,aa,ad,fd,fm,-all/1' /etc/security/audit_control

# 3.3 Ensure security auditing retention (Scored)
sudo sed -i -s 's/expire-after:10M/expire-after:1G/g' /etc/security/audit_control

# 3.5 Retain install.log for 365 or more days (Scored)
sudo sed -i '' '/^\* file/s/\* file.*/\* file \/var\/log\/install\.log mode=0640 format=bsd rotate=utc compress file_max=10M ttl=365/g' /etc/asl/com.apple.install 
 
# 3.6 Ensure Firewall is configured to log (Scored)
/usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on

# 4.2 Enable "Show Wi-Fi status in menu bar" (Scored)
Open /System/Library/CoreServices/Menu/Extras/AirPort.menu

# 4.5 Ensure nfs server is not running (Scored)
sudo nfsd disable

# 5.1.4 Check Library folder for world writable files (Scored)
sudo chmod -R o-w /Library/Application\ Support/GarageBand/Learn\ to\ Play/

# 5.2.1 - 5.2.8
# 5.2.1 Configure account lockout threshold (Scored) = 7
# 5.2.2 Set a minimum password length (Scored) =14
# 5.2.3 Complex passwords must contain an Alphabetic Character (Not Scored) = True
# 5.2.4 Complex passwords must contain a Numeric Character (Not Scored) = True
# 5.2.5 Complex passwords must contain a Special Character (Not Scored) = True
# 5.2.6 Complex passwords must uppercase and lowercase letters (Not Scored) = True
# 5.2.7 Password Age (Scored) = 365
# 5.2.8 Password History (Scored) = 15

####################
# Password Policy  #
####################
echo "<dict><!-- Authentication Policy --> <key>policyCategoryAuthentication</key>  <array>   <dict>    <key>policyContent</key>     <string>(policyAttributeFailedAuthentications &lt; policyAttributeMaximumFailedAuthentications) OR (policyAttributeCurrentTime &gt; (policyAttributeLastFailedAuthenticationTime + autoEnableInSeconds))</string>    <key>policyIdentifier</key>     <string>Authentication Lockout</string>    <key>policyParameters</key>  <dict>  <key>autoEnableInSeconds</key>   <integer>600</integer> <!-- Lockout time in seconds -->   <key>policyAttributeMaximumFailedAuthentications</key>   <integer>7</integer> <!-- MAX failed logins -->  </dict> </dict> </array><!-- Password Change Policy -->  <key>policyCategoryPasswordChange</key>  <array>   <dict>    <key>policyContent</key>     <string>policyAttributeCurrentTime &gt; policyAttributeLastPasswordChangeTime + (policyAttributeExpiresEveryNDays * 24 * 60 * 60)</string>    <key>policyIdentifier</key>     <string>Change every 365 days</string>    <key>policyParameters</key>    <dict>     <key>policyAttributeExpiresEveryNDays</key>      <integer>365</integer>    </dict>   </dict>  </array><!-- Password Content -->    <key>policyCategoryPasswordContent</key> <array>  <dict>   <key>policyContent</key>    <string>policyAttributePassword matches '.{14,}+'</string>   <key>policyIdentifier</key>    <string>Has at least 14 characters</string>   <key>policyParameters</key>   <dict>    <key>minimumLength</key>     <integer>14</integer>   </dict>  </dict><!-- Password Format Includes NUMBER Policy -->    <dict>   <key>policyContent</key>    <string>policyAttributePassword matches '(.*[0-9].*){14,}+'</string>   <key>policyIdentifier</key>    <string>Has a number</string>   <key>policyParameters</key>   <dict>   <key>minimumNumericCharacters</key>    <integer>1</integer>   </dict>  </dict><!-- Password Format Includes LOWERCASE LETTER Policy -->  <dict>   <key>policyContent</key>    <string>policyAttributePassword matches '(.*[a-z].*){1,}+'</string>   <key>policyIdentifier</key>    <string>Has a lower case letter</string>   <key>policyParameters</key>   <dict>   <key>minimumAlphaCharactersLowerCase</key>    <integer>1</integer>   </dict>  </dict><!-- Password Format Includes UPPERCASE LETTER Policy -->  <dict>   <key>policyContent</key>    <string>policyAttributePassword matches '(.*[A-Z].*){1,}+'</string>   <key>policyIdentifier</key>    <string>Has an upper case letter</string>   <key>policyParameters</key>   <dict>   <key>minimumAlphaCharacters</key>    <integer>1</integer>   </dict>  </dict><!-- Password Format Includes SPECIAL CHARACTER Policy -->     <dict>   <key>policyContent</key>    <string>policyAttributePassword matches '(.*[^a-zA-Z0-9].*){1,}+'</string>   <key>policyIdentifier</key>    <string>Has a special character</string>   <key>policyParameters</key>   <dict>   <key>minimumSymbols</key>    <integer>1</integer>   </dict>  </dict><!-- Password History Policy -->   <dict>   <key>policyContent</key>    <string>none policyAttributePasswordHashes in policyAttributePasswordHistory</string>   <key>policyIdentifier</key>    <string>Does not match any of last 15 passwords</string>   <key>policyParameters</key>   <dict>    <key>policyAttributePasswordHistoryDepth</key>     <integer>15</integer>   </dict>  </dict> </array></dict>" > /private/var/tmp/password-policy.plist && pwpolicy -setaccountpolicies /private/var/tmp/password-policy.plist && rm -f /private/var/tmp/password-policy.plist

# 5.9 Enable OCSP and CRL certificate checking (Scored)
defaults write com.apple.security.revocation CRLStyle -string RequireIfPresent; defaults write com.apple.security.revocation OCSPStyle -string RequireIfPresent

# 5.12 Disable automatic login (Scored)
sudo defaults delete /Library/Preferences/com.apple.loginwindow.plist autoLoginUser

# 5.13 Require a password to wake the computer from sleep or screen saver (Scored)
defaults -currentHost write com.apple.screensaver idleTime 300

# 5.17 Create a custom message for the Login Screen (Scored)
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText " IT IS AN OFFENSE TO CONTINUE WITHOUT PROPER AUTHORIZATION - This system is restricted to authorized users. Individuals who attempt unauthorized access will be prosecuted. If you are unauthorized, terminate access now. Anyone using this system expressly consents to monitoring."

# 5.18 Create a Login window banner (Scored)
echo IT IS AN OFFENSE TO CONTINUE WITHOUT PROPER AUTHORIZATION - This system is for the use of authorized users only. Individuals using this computer system without authority, or in excess of their authority, are subject to having all of their activities on this system monitored and recorded by system personnel.  In the course of monitoring individuals improperly using this system, or in the course of system maintenance, the activities of authorized users may also be monitored.  Anyone using this system expressly consents to such monitoring and is advised that if such monitoring reveals possible evidence of criminal activity, system personnel may provide the evidence of such monitoring to law enforcement officials. Click "Accept" to indicate your acceptance of this information. > /tmp/PolicyBanner.txt && sudo mv /tmp/PolicyBanner.txt /Library/Security/ && sudo chmod o+r /Library/Security/PolicyBanner.txt

# 5.19 Do not enter a password-related hint (Not Scored)
defaults write com.apple.loginwindow RetriesUntilHint -int 0

# 5.20 Disable Fast User Switching (Not Scored)
defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool 'NO'

# 5.23 System Integrity Protection status (Scored)
/usr/bin/csrutil enable

# 6.1.1 Display login window as name and password (Scored)
sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool yes

# 6.1.2 Disable "Show password hints" (Scored)
sudo defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0

# 6.1.3 Disable guest account login (Scored)
sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO

# 6.1.4 Disable "Allow guests to connect to shared folders" (Scored)
sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool no
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool no

# 6.1.5 Remove Guest home folder (Scored)
rm -R /Users/Guest

# 6.2 Turn on filename extensions (Scored)
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# 6.3 Disable the automatic run of safe files in Safari (Scored)
defaults write com.apple.Safari AutoOpenSafeDownloads -boolean no

