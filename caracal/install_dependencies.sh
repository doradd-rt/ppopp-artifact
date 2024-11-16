## prerequisite
sudo apt-get update
sudo apt-get install -y default-jdk ant python2 git python-is-python3 wget gnupg lsb-release software-properties-common

## llvm toolchain
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 14
sudo apt update
sudo apt install -y clang-14 libc++-14-dev libc++abi-14-dev lld-14

## install buck from source
git clone https://github.com/facebook/buck.git
cd buck
ant
./bin/buck build --show-output buck
sudo ln -sf "$(pwd)/bin/buck" /usr/local/bin/buck
