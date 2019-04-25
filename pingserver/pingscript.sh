pingtime=$1
address=$2
port=$3

end=$((SECONDS+$pingtime))
while [ $SECONDS -lt $end ]; do
    number=$((($RANDOM+$RANDOM+$RANDOM+$RANDOM+$RANDOM)/50))
    curl ${address}:${port}/{$number} -w 'URL: \t%{url_effective} \t Total time:\t%{time_total}\n \t Time: \t ${$(date)}' -s | grep 'Total time' >> pinglogs.txt
done

cat pinglogs.txt
echo "DONE"