if [ $# = 2 ]
then
ID=$(curl -H "Authorization: Token $2" https://api.ribes.me/hosts/status/me/)
cat ssh-tunnel@remoteHost > ssh-tunnel@$1
echo "LOCAL_PORT=$((2200+ID))" >> ssh-tunnel@$1
echo "TARGET=$1" >> ssh-tunnel@$1
curl -H "Authorization: Token $2" -X POST-d '{"id":4,"ip":"0.0.0.0","local_ip":"0.0.0.0","state":0, "host":$ID}' http://localhost:8000/hosts/status/
sudo cp ssh-tunnel@.service /etc/systemd/system/
sudo cp ssh-tunnel@$1 /etc/default/
sudo useradd --create-home status
sudo sh -c 'yes $2 |passwd status'
sudo su status -c "
cd /home/status
git clone https://github.com/JeanRibes/central-client.git
cd central-client
virtualenv -p /usr/bin/python3 venv
source venv/bin/activate
pip install -r requirements.txt
ssh-keygen -t rsa
echo 'source venv/bin/activate' > start.sh
echo 'python main.py https://api.$1 $2 $1' >> start.sh
chmod +x start.sh
"
echo "------------------------------------"
echo "PASTE IN TERMNIAL AND INPUT PASSWORD"
echo "su status && cd"
echo "ssh-copy-id -o 'VerifyHostKeyDNS yes' -o 'StrictHostKeyChecking no' $1"

else
	echo "Usage : setup.sh central_fqdn machine_token"
	echo "You need curl installed, and a Host entry associated with the user in Central"
	exit 1
fi
