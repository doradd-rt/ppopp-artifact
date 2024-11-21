pushd felis
git checkout ycsb
git submodule update --init
buck build db_release
popd

pushd felis-controller
git checkout ycsb
sudo rm -rf ./out # clean build
./mill FelisController.assembly
popd

pushd felis-controller/scripts
./run_ycsb.sh
popd
