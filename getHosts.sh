#!/bin/bash
# this script extracts the ServerNames and aliases from "apachectl -S" and runs the Linux "host" command on it to determine if the VirtualNameHost
# that runs on the Server at least has a DNS record that points to the IP-adress of the server. If not, the VirtualNameHost is most certainly dead and can be deleted. 
# (this script doesnt delete anything. It just shows you a list)     


apachectl -S &>aapachectl.txt                                              # on some machines the output of "apachectl -S" goes to stderr
awk '/namevhost/{print $(NF-1);next}/server/{print $(NF-1);next}/alias/{print$NF;next}' aapachectl.txt >aaapachectl.txt    #extract the DomainName the server listens to
awk '/[a-zA-Z]/{print}' aaapachectl.txt >aapachectl.txt
awk '/\./{print}' aapachectl.txt|sort -u >aaapachectl.txt
while read line
do
                host $line
                host $line >> aaaapachectl.txt

done < aaapachectl.txt
/sbin/ifconfig|grep 'inet addr'|cut -d':' -f2|awk '{print $1}' >> aaaapachectl.txt     # extract IP adresses the Server has. The exact string to search for varies from system to system.
