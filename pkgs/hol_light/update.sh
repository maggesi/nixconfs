./prefetch.sh HEAD 2> log > source.xml
grep "^Commit date " log > date
