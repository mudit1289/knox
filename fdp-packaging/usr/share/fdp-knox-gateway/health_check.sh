#!/bin/bash

sleep 30
exec 2>&1

PACKAGE=__PACKAGE__

exec /usr/lib/nagios/plugins/fk-nsca-wrapper/nsca_wrapper -H `hostname -f | sed -r 's#.(nm|ch).flipkart.com##g'` -S 'Knox Gateway Health Check:'  -b /usr/sbin/send_nsca -c /etc/send_nsca.cfg -C "/etc/init.d/${PACKAGE} status" >> /var/log/nsca.log 2>&1
