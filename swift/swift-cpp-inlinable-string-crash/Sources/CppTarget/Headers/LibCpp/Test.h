#pragma once

#include <string>
#include <optional>

struct Foo {

    Foo(const std::string &str) : m_str(str) {}
    std::optional<std::string> getStr() const;

private:
    std::string m_str;
};
