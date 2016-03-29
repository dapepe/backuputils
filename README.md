Backup Utility Scripts
======================

Purpose
-------


Scripts
-------

### cleanup.sh ###

```
cleanup.sh <DIRECTORY> <BASENAME> <LIMIT>
```

Performs a cleanup based on a file's basename. `LIMIT` specifies the number of files that will remain after the cleanup.


### mysql-backupall.sh ###

```
mysql-backupall.sh <DIR> <USER> <PASSWORD>
```

Create a `mysql_dump` for each individual database.


### mysql-cleanupall.sh ###

```
mysql-cleanupall.sh <DIRECTORY> <LIMIT> 
```

Executes the `cleanup.sh` script for each database.


### xen-backup.sh ###

```
xen-backup.sh <DIR> <VMNAME>
```

Creates a backup for a XenServer Virtual Machine. If no <VMNAME> is provided, all VMs will be backed up.


Example configuration for XenServer
-----------------------------------

I am running XenServer using an NFS data store for the virtual disks and using a local mount to
backup snapshots once a month. This is an example cron file for one machine:

```
# /etc/cron.d/xenbackup

# Create a backup at the first day of the month at 1:00AM
00  01  1   *    *   root   /opt/backuputils/xen-backup.sh /mnt/backup/ www.zeyos.com >/dev/null 2>&1

# Perform a cleanup
00  12  1   *    *   root   /opt/backuputils/cleanup.sh 1 www.zeyos.com /mnt/backup/ >/dev/null 2>&1

```
