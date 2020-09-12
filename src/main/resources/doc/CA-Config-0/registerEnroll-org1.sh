工作目录,除非特殊说明，一般命令的执行都是在工作目录进行。
cd $GOPATH/src/github.com/hyperledger/fabric-samples/first


(三)【docker】方式运行org1CA

docker-compose -f docker-compose-ca-org1.yaml up -d 2>&1

# 在下面的命令中，我们将CA的ROOT证书的受信任根证书已复制到 ./fabric-ca-server/intermediaca1/root-ca-cert.pem 存在fabric-ca-client二进制文件的主机上。如果客户端二进制文件位于其他主机上，则需要通过带外过程获取签名证书。
cp ./crypto-config/rootOrganizations/root.example.com/crypto/ca-cert.pem ./crypto-config/peerOrganizations/org1.example.com/crypto/root-ca-cert.pem

1. 生成org1.example.com的msp

进入容器
docker exec -it org1.ca.example.com bash


export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./admin
fabric-ca-client enroll -d -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056

2） 添加联盟成员
fabric-ca-client affiliation list -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation remove --force org1 -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation remove --force org2 -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation add com -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation add com.example -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056
fabric-ca-client affiliation add com.example.org1 -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056

1. 生成example.com的msp
3） 注册Admin@example.com
fabric-ca-client register --id.name Admin@org1.example.com --id.type admin  --id.affiliation "com.example.org1" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=org1adminpw --csr.cn=org1.example.com --csr.hosts=['org1.example.com'] -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056

1） 注册User1@org1.example.com
fabric-ca-client register --id.name User1@org1.example.com --id.type client  --id.affiliation "com.example.org1" --id.attrs '"hf.Registrar.Roles=client,orderer,peer,user","hf.Registrar.DelegateRoles=client,orderer,peer,user",hf.Registrar.Attributes=*,hf.GenCRL=true,hf.Revoker=true,hf.AffiliationMgr=true,hf.IntermediateCA=true,role=admin:ecert' --id.secret=org1userpw --csr.cn=org1.example.com --csr.hosts=['org1.example.com'] -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056

1） 注册peer0.org1.example.com
fabric-ca-client register --id.name peer0.org1.example.com --id.type peer --id.affiliation "com.example.org1" --id.attrs '"role=peer",ecert=true' --id.secret=peer0org1pw --csr.cn=peer0.org1.example.com --csr.hosts=['peer0.org1.example.com'] -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056

1） 注册peer1.org1.example.com
fabric-ca-client register --id.name peer1.org1.example.com --id.type peer --id.affiliation "com.example.org1" --id.attrs '"role=peer",ecert=true' --id.secret=peer1org1pw --csr.cn=peer1.org1.example.com --csr.hosts=['peer1.org1.example.com'] -u https://org1-admin:org1-adminpw@org1.ca.example.com:7056


3） 登记Admin@example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./users/Admin@org1.example.com/msp
fabric-ca-client enroll -u https://Admin@org1.example.com:org1adminpw@org1.ca.example.com:7056 --csr.cn=org1.example.com --csr.hosts=['org1.example.com']


1） 登记User1@org1.example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./users/User1@org1.example.com/msp
fabric-ca-client enroll -u https://User1@org1.example.com:org1userpw@org1.ca.example.com:7056 --csr.cn=org1.example.com --csr.hosts=['org1.example.com']



mkdir -p ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/admincerts
cp ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/cert.pem ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/admincerts/
cp ./org1-config/config.yaml ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/

mkdir -p ./crypto-config/peerOrganizations/org1.example.com/msp
cp -r ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/ ./crypto-config/peerOrganizations/org1.example.com/






3. 生成peer0.org1.example.com的msp和tls


1） 登记peer0.org1.example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer0.org1.example.com/msp
fabric-ca-client enroll -u https://peer0.org1.example.com:peer0org1pw@org1.ca.example.com:7056 --csr.cn=peer0.org1.example.com --csr.hosts=['peer0.org1.example.com']

1） 登记peer0.org1.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer0.org1.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://peer0.org1.example.com:peer0org1pw@root.ca.example.com:7054 --csr.cn=peer0.org1.example.com --csr.hosts=['peer0.org1.example.com']


1） 复制证书


cp ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/keystore/*_sk ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/keystore/key.pem 
mkdir -p ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/admincerts
cp ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/cert.pem ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/admincerts/
cp ./org1-config/config.yaml ./crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/





3. 生成peer1.org1.example.com的msp和tls


1） 登记peer1.org1.example.com的mps
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer1.org1.example.com/msp
fabric-ca-client enroll -u https://peer1.org1.example.com:peer1org1pw@org1.ca.example.com:7056 --csr.cn=peer1.org1.example.com --csr.hosts=['peer1.org1.example.com']

1） 登记peer1.org1.example.com的tls
export FABRIC_CA_CLIENT_TLS_CERTFILES=/etc/hyperledger/fabric-ca-server/crypto/root-ca-cert.pem
export FABRIC_CA_CLIENT_HOME=/etc/hyperledger/fabric-ca-server
export FABRIC_CA_CLIENT_MSPDIR=./peers/peer1.org1.example.com/tls
fabric-ca-client enroll -d --enrollment.profile tls -u https://peer1.org1.example.com:peer1org1pw@root.ca.example.com:7054 --csr.cn=peer1.org1.example.com --csr.hosts=['peer1.org1.example.com']


1） 复制证书

cp ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/keystore/*_sk ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/keystore/key.pem 
mkdir -p ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/admincerts
cp ./crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/cert.pem ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/admincerts/
cp ./org1-config/config.yaml ./crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/












