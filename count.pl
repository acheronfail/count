my $i = 0;
my $limit = $ARGV[0] + 0;
for ($i = 0; $i < $limit; $i = ($i + 1) | 1) {}
print "$i\n";
