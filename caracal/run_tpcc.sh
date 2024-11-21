pushd felis
git submodule update --init
buck build db_release
popd

pushd felis-controller
./mill FelisController.assembly
popd

pushd felis-controller/scripts
./expr-workflow.sh
popd
