#!/bin/bash
export LANG=
set -e
CC="${CC:-cc}"
CXX="${CXX:-c++}"
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t=out/test/elf/$testname
mkdir -p $t

cat <<EOF | $CC -fPIC -o $t/a.o -c -xc -
#include <stdio.h>
void hello() {
  printf("Hello");
}
EOF

$CC -B. -o $t/b.so -shared $t/a.o -Wl,-z,ibtplt

cat <<EOF | $CC -o $t/c.o -c -xc -
#include <stdio.h>

void hello();

int main() {
  hello();
  puts(" world");
}
EOF

$CC -B. -o $t/exe $t/c.o $t/b.so -Wl,-z,ibtplt
$t/exe | grep -q 'Hello world'

echo OK
