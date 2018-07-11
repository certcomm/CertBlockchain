pushd ../web3j-3.4.0/
rm -rf dist
rm -rf build
mkdir -p build/gen-src
for file in  ~/tmail/github/CertBlockchain/ethereum/build/contracts/*.json ;do bin/web3j truffle generate $file -o build/gen-src -p com.tmailinc.blockchain.contracts;done
pushd build
CLASSPATH=.
for file in  ../lib/*.jar;do CLASSPATH=$CLASSPATH:$file;done
echo $CLASSPATH
mkdir classes
javac -classpath $CLASSPATH -d classes gen-src/com/tmailinc/blockchain/contracts/*.java
jar cvf contract-wrappers.jar -C classes/ .
popd
popd
