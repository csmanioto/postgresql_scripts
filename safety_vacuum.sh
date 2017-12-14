#/bin/bash
DB=$1
LIMIT=$2

if [ -z "$1" ] && [ -z "$2" ]
	echo "Is necessary db (param 1) name and limit of partition where xlog use (param 2)"
	echo "Exemple: safety_vacuum.sh fool 98"
	echo "in this case, 98 = 98% of used with partition is my limit than when the script get this limit, he will exit (1)"
	exit 1
fi

tables=$(psql -U postgres $DB -t -c '\dt'|awk '{ print $3 }')

for table in $tables; do 
	echo "Vacuum full on $table..."
	/usr/bin/vacuumdb -U postgres -f -z -d erp -t $table
	echo "$table is done"
	spacefree=$(df -h |grep pg_xlog|awk '{print $5}'|cut -d'%' -f1)
	if [ "$spacefree" -gt "$limit" ]; then
		echo "I got the LIMIT, exiting..."
		exit 1
	fi
done
