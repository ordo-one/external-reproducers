#include "LibCpp/Test.h"

void returnPtr(std::function<void(const FooStruct * _Nonnull)> on_struct) {
    const auto foo = FooStruct();
    on_struct(&foo);
}

void returnReference(std::function<void(const FooStruct &)> on_struct) {
    const auto foo = FooStruct();
    on_struct(foo);
}
