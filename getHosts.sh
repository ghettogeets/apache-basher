# that runs on the Server at least has a DNS record that points to the IP-adress of the server. If not, the VirtualNameHost is most certainly dead and can be deleted.
# (this script doesnt delete anything. It just shows you a list)


apachectl -S &>hosts.tmp                                              # on some machines the output of "apachectl -S" goes to stderr
HOSTNAME=($(hostname)_$(date +%F))
if [ -s hosts.tmp ]
then
        echo "created hosts.tmp"
        echo "processing output of \"apachectl -S"
        awk '/namevhost/{print $(NF-1);next}/server/{print $(NF-1);next}/alias/{print$NF;next}' hosts.tmp >hosts2.tmp    #extract the DomainName the server listens to
        rm -f hosts.tmp
        if [ $? -eq 0 ]
        then
                echo "removed hosts.tmp"
        else
                echo "couldn't remove temporary file hosts.tmp"
        fi

        awk '/[a-zA-Z]/{print}' hosts2.tmp >hosts3.tmp
        rm -f hosts2.tmp
        if [ $? -eq 0 ]
        then
                echo "removed hosts2.tmp"
        else
                echo "couldn't remove temporary file hosts2.tmp"
        fi

        awk '/\./{print}' hosts3.tmp|sort -u >hosts4.tmp
        rm -f hosts3.tmp
        if [ $? -eq 0 ]
        then
                echo "removed hosts3.tmp"
        else
                echo "couldn't remove temporary file hosts3.tmp"
        fi

        echo "####################################################################################################" >hosts_${HOSTNAME}.txt
        echo $(hostname)>>hosts_${HOSTNAME}.txt
while read line
do
              #  host $line
                host -t A $line >> hosts_${HOSTNAME}.txt

done < hosts4.tmp
rm -f hosts4.tmp
        if [ $? -eq 0 ]
        then
                echo "removed hosts4.tmp"
        else
                echo "couldn't remove temporary file hosts4.tmp"
        fi
fi
#/sbin/ifconfig|grep 'inet addr'|cut -d':' -f2|awk '{print $1}' >> $(date +%F)_$(hostname)_hosts.txt     # extract IP adresses the Server has. The exact string to search for varies from system to system.
