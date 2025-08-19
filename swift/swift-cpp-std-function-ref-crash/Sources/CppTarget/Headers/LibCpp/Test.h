#pragma once

#include <functional>

struct FooStruct {};

void returnPtr(std::function<void(const FooStruct * _Nonnull)>);
void returnReference(std::function<void(const FooStruct &)>);
