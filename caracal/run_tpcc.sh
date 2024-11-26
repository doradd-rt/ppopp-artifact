pushd felis
git submodule update --init
git checkout master
buck build db_release
popd

pushd felis-controller
sudo rm -rf ./out # clean build
./mill FelisController.assembly
popd

pushd felis-controller/scripts
./expr-workflow.sh
popd
