#include "LibCpp/Test.h"

void cpp_foo(
    const FooEvents & vec,
    std::function<void(int64_t)> callback
) {
    callback(42);
}

void executeInThread(std::function<void()> func) {
    func();
}
