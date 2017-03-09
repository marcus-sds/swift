ps ax | awk '/[s]wift-account-auditor / { print $1 }' | xargs ionice -c 3 -p
ps ax | awk '/[s]wift-account-replicator/ { print $1 }' | xargs ionice -c 2 -n 6 -p
ps ax | awk '/[s]wift-account-server/ { print $1 }' | xargs ionice -c 2 -n 3 -p
ps ax | awk '/[s]wift-account-reaper/ { print $1 }' | xargs ionice -c 3 -p
ps ax | awk '/[s]wift-container-auditor / { print $1 }' | xargs ionice -c 3
ps ax | awk '/[s]wift-container-replicator/ { print $1 }' | xargs ionice -c 3 -p
ps ax | awk '/[s]wift-container-server/ { print $1 }' | xargs ionice -c 2 -n 3 -p
ps ax | awk '/[s]wift-container-updater/ { print $1 }' | xargs ionice -c 3 -p
ps ax | awk '/[s]wift-object-auditor/ { print $1 }' | xargs ionice -c 3 -p
ps ax | awk '/[s]wift-object-replicator/ { print $1 }' | xargs ionice -c 3 -p
ps ax | awk '/[s]wift-object-server/ { print $1 }' | xargs ionice -c 2 -n 3 -p

sudo sh -c 'echo 100 > /proc/sys/fs/xfs/xfssyncd_centisecs'
