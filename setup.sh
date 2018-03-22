if [ $# = 2 ]
then
sudo useradd --create-home status
sudo su status -c "
cd /home/status
git clone https://github.com/JeanRibes/central-client.git
cd central-client
virtualenv -p /usr/bin/python3 venv
source venv/bin/activate
pip install -r requirements.txt
ssh-keygen -t rsa
echo 'python main.py https://api.$1 $2 $1' > start.sh
chmod +x start.sh
"
echo "PASTE IN TERMNIAL AND INPUT PASSWORD"
echo "sudo su status"
echo "ssh-copy-id -o 'VerifyHostKeyDNS yes' -o 'StrictHostKeyChecking no' $1"

else
	echo "Usage : setup.sh central_fqdn machine_token"
fi
