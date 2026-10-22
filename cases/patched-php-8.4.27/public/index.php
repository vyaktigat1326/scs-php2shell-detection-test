<?php
// Harmless test entry point for SCS PHP2Shell detection tests.
// It only prints the interpreter version; it does not exercise any vulnerable code path.
declare(strict_types=1);

header('Content-Type: text/plain');
echo 'scs-php2shell-detection-test running on PHP ' . PHP_VERSION . PHP_EOL;
