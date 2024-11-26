# compile the binary
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
log_dir=${script_dir}/fig5-input-log
mkdir -p $log_dir
res_dir=${script_dir}/fig5-results/ycsb
mkdir -p $res_dir 

pushd ${script_dir}/doradd/app
mkdir -p build && cd build

mkdir -p results # collect latency
cmake .. -GNinja -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-DRPC_LATENCY -DLOG_LATENCY"
ninja

# run
for cont in "no" "mod" "high"; do
  final_result="${res_dir}/${cont}_cont.res"
  rm -f ${final_result}

  for i in 4000 2000 1000 800 600 400 350 300 280 250 220 200 180 160; do
    log="$log_dir/ycsb_uniform_${cont}_cont.txt"
    ia="exp:$i"

    sudo taskset -c 4-11 ./ycsb -n 8 $log -i $ia

    cd results/
    log_name=$(ls $ia-*)
    echo "$log_name"

    agg_log="$ia.txt"

    cat $log_name | sort -n | uniq -c > $agg_log

    python $script_dir/latency-throughput.py $agg_log >> $final_result

    cd ../
  done
done

echo "Finished all ycsb experiments"

popd
