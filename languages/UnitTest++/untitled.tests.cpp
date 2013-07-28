#include "untitled.h"
#include <UnitTest++.h>

TEST(example)
{
    CHECK_EQUAL(6*9, hhg());
}

int main()
{
    return UnitTest::RunAllTests();
}
