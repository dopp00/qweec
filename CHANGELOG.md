# Changelog

## [0.6.6] - 2026-08-28

- by default only sftp access is allowed for users
- allow to enable ssh access on user profile page
- cli: user-ssh-set
- added support for http/3 in web templates
- improved security when importing/exporting database
- fixed a timeout bug in executive scripts
- rate limit requests from web interface 
- added network bandwidth graph on the monitoring page
- cli: tab auto-completion for function names
- fixed small memory leak
- improved shutdown policy
- improved queue handling
- added possibility to display the logs of finished tasks in web panel
- added templates for opening panel via domain
- white labeling
- possibility to add custom logos

## [0.6.5] - 2026-05-04

- colors can be changed by editing css file, more information in the docs  
- fixed bug not recreating ipv6 rules on rules reset  

## [0.6.4] - 2026-05-01

- simplified the templates page, removed New and Rename buttons  
- do not allow to delete the default templates  
- admin user can see events of other users on the monitoring events page   
- fix for correct ip address removal from fail2ban  
- fix for correct switch of dns providers  
- fix to make sure ipsets are created  
- fixed user profile import, when limits are set to unlimited value  
- fixed error, changing database host password did not work  
- changed style of buttons for password visibility and generation  
- fixed bug for comment not displayed on the firewall rule editing page  
- possibility to isntall podman from web interface  
- small visual tweaks  

## [0.6.3] - 2026-04-02

- fixed bug with images not showing on monitoring page, introduced in 0.6.2
- --version argument for checking the version, --help to see a list of commands 

## [0.6.2] - 2026-03-31

- improved user-backup-restore function
- fixed bug with notification icon, introduced in 0.6.0

## [0.6.1] - 2026-03-26

- set restrictions for suspended users in web interface 

## [0.6.0] - 2026-03-24

- ordinary users can use cli  
- improvement for cli messages on error  
- queue-list cli function improved
- make sure ordinary suspended users cannot do most actions via cli  
- do not rewrite index.html file, if it already exists on adding site  
- go back button on 2-factor verification page  
- fixed backup restore button
- fixed bug when switching from using one firewall to another
- possibility to reorder firewall rules by dragging and dropping in web interface
- table filter field
- added ips-list cli function
- changed behavior in firewall-rules-reset: do not delete unrelated rules

## [0.5.2] - 2026-03-02

- 2-factor authentication  

## [0.5.1] - 2026-02-28

- quota support for ext4 added. now supported fs are: xfs, ext4  
- harden web login security  
- fix for podman-compose not being installed  
- fix for fully-qualified container names requirement in templates  
- fixed the bug of iptables being installed, even if nftables was selected  
- fix for changing to existing user does not work, when database has no users  


## [0.5.0] - 2026-01-26

- Initial alpha release
