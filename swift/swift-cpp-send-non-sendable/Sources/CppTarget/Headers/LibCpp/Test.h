#pragma once

#include <functional>
#include <vector>

using FooEvents = std::vector<uint8_t>;
void executeInThread(std::function<void()> func);
void cpp_foo(
    const FooEvents & vec,
    std::function<void(int64_t)> callback
);
