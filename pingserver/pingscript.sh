pingtime=$1
address=$2
port=$3

end=$((SECONDS+$pingtime))
while [ $SECONDS -lt $end ]; do
    curl ${address}:${port}/{$RANDOM} -w 'URL: \t%{url_effective} \t Total time:\t%{time_total}\n' -s | grep 'Total time' >> pinglogs.txt
done

cat pinglogs.txt