<?php
$i = 0;
$target = (int) $argv[1];
while ($i < $target) {
  $i = ($i + 1) | 1;
}
echo $i . "\n";
?>