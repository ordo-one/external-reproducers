#include "LibCpp/Test.h"
#include <iostream>

namespace Foo {

WrapClass2_2::WrapClass2_2() {
    std::cout << "default ctor() called: why?" << std::endl;
    // std::abort(); // Will crash if call Foo.WrapClass2_2(123), why?
}

WrapClass2_2::WrapClass2_2(int v) {
    std::cout << v << std::endl;
}

}
