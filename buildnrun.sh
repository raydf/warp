echo "changes detected..."
crystal build src/warp.cr
echo "built"
ps aux | grep '[.]/warp' | awk '{print $2}' | xargs kill
echo "killed"
./warp &
