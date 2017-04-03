./prefetch.sh HEAD 2> log > source.json
grep "^Commit date " log > date
