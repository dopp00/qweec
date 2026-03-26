# Changelog

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
- bug: podman-compose not installed  
- bug: fully-qualified container names in templates required  
- bug: iptables installing, even if nftables was chosen  
- bug: changing to existing user does not work, when database has no users  


## [0.5.0] - 2026-01-26

- Initial alpha release
