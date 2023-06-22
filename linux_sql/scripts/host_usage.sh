#!/bin/bash

psql_host=$1 
psql_port=$2 
db_name=$3 
psql_user=$4 
psql_password=$5 

if [ "$#" -ne 5 ]; then 
echo "Illegal number of parameters" 
exit 1 
fi 

vmstat_mb=$(vmstat --unit M) 
hostname=$(hostname -f)

timestamp=$(date --utc -u '+%Y-%m-%d %H:%M:%S')

host_id="(SELECT id FROM host_info WHERE hostname='$hostname')"

memory_free=$( vmstat --unit M | awk '{print $4}'| tail -n1 | xargs)

cpu_idle=$( vmstat --unit M | tail -1 | awk -v col="15" '{print $col}' | xargs)

cpu_kernel=$( vmstat --unit M | tail -1 | awk -v col="14" '{print $col}' | xargs)

disk_io=$(vmstat  -d | awk '{print $10}'| tail -n1 | xargs)

disk_available=$( df -BM / |tail -1 | awk -v col="4" '{print $col}' | sed 's/M//')

insert_stmt="INSERT INTO host_usage(timestamp, host_id, memory_free, cpu_idle, cpu_kernel,  disk_io, disk_available) VALUES('$timestamp',$host_id,$memory_free,$cpu_idle,$cpu_kernel,$disk_io,$disk_available);"

export PGPASSWORD=$psql_password
psql -h $psql_host -p $psql_port -d $db_name -U $psql_user -c "$insert_stmt"
exit $?

