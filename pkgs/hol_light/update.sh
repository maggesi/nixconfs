./prefetch.sh HEAD 2> log > source.nix
grep "^Commit date " log > date
