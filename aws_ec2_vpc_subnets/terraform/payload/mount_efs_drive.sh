EFS_NFS_PRIVATE_IP=$1
sudo apt-get update
sudo apt-get -y install nfs-common
sudo apt-get -y install nfs-kernel-server
sudo service nfs-server start
sudo systemctl is-enabled nfs-server
sudo systemctl status nfs-server
sudo mkdir -p /mnt/nfs
# sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 10.0.2.191:/ /mnt/nfs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $EFS_NFS_PRIVATE_IP:/ /mnt/nfs