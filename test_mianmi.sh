PORT=$1

if [ $# -ne 1 ];then
    echo "please user in : ./test_mianmi.sh ssh_port"
    exit 1
fi

if [ -n `which expect`]; then
        echo 'expect exist'
else
        echo 'expect does not exist,install expect'
        brew install expect
        if [ $? != 0  ];then
                echo "please chech your brew resource"
                exit 1
        fi
fi

exit 1

if [ $USER = root ];then
    echo "yum install expect -y -d 0 -e 0"
    yum install expect -y -d 0 -e 0

    if [ $? != 0  ];then
        echo "please chech your yum resource"
        exit 1
    fi
fi

L=0
for i in $(cat host.file)
do
	ip[$L]=`echo $i | awk -F: '{print $1}'`
	user[$L]=`echo $i |awk -F: '{print $2}'`
	password[$L]=`echo $i |awk -F: '{print $3}'`
	let "L=$L+1"
done

echo "hostfile has ${#ip[@]} servers "

function copy(){
	expect -c "
		set timeout -1;
		spawn scp -P$1 root@$2:/root/.ssh/id_rsa.pub ./key/$2key
		expect {
			\"*yes/no*\" {send \"yes\r\";exp_continue}
			\"*password*\" {send \"$3\r\";exp_continue}
		}
	"
}


# to gen all machine authorized_keys
# check ssh id_rsa.pub isExist

for((i=0;i<${#ip[@]};i++))
do
	echo ${ip[$i]}
	result=$(copy $PORT ${ip[$i]} ${password[$i]})
        echo $result |grep 100%
        if [ $? -ne 0 ];then
                expect -c "
                set timeout -1;
                spawn ssh -p$PORT ${user[$i]}@${ip[$i]} 'ssh-keygen'
                expect {
                        \"*password*\" {send \"${password[$i]}\r\"; exp_continue}
                        \"*Enter file*\" {send \"\r\"; exp_continue}
                        \"*Enter passphrase*\" {send \"\r\"; exp_continue}
                        \"*Enter same passphrase*\" {send \"\r\"; exp_continue}
                        \"*The key fingerprint*\" {send \"\r\"; exp_continue}
                }"

                echo "successs make key"

		result=$(copy $PORT ${ip[$i]} ${password[$i]})
		echo $result |grep 100%
		if [ $? -ne 0 ];then
			echo "failed to excute the command,please check your network or other reason "
		fi
        fi
done


for i in `ls ./key`
do
    cat ./key/$i >> ./authorized_keys
done
chmod 600 ./authorized_keys

# copy authorized_keys to all matchine
for((i=0;i<${#ip[@]};i++))
do
    expect -c "
        set timeout -1;
        spawn ssh -p${PORT} root@${ip[$i]} \"mkdir -p /data/tmp \"
        expect {
                \"*yes/no*\" {send \"yes\r\"; exp_continue}
                \"*password*\" {send \"${password[$i]}\r\"; exp_continue}
        }
    "

    expect -c "
            set timeout -1;
            spawn scp -P$PORT ./authorized_keys  root@${ip[$i]}:/tmp
            expect {
                    \"*yes/no*\" {send \"yes\r\"; exp_continue}
                    \"*password*\" {send \"${password[$i]}\r\"; exp_continue}
            }"
    expect -c "
            set timeout -1;
            spawn ssh -p$PORT root@${ip[$i]}  \"cat /tmp/authorized_keys >> /root/.ssh/authorized_keys \"
            expect {
                    \"*yes/no*\" {send \"yes\r\"; exp_continue}
                    \"*password*\" {send \"${password[$i]}\r\"; exp_continue}
            }"
    	
    expect -c "
            set timeout -1;
            spawn ssh -p$PORT root@${ip[$i]}  \"chmod 600 /root/.ssh/authorized_keys \"
            expect {
                    \"*yes/no*\" {send \"yes\r\"; exp_continue}
                    \"*password*\" {send \"${password[$i]}\r\"; exp_continue}
            }"

done