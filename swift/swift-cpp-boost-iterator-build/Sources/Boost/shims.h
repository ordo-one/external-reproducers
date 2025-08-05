#include "boost/iterator/iterator_facade.hpp"
#include "boost/filesystem.hpp"


inline boost::filesystem::path shim_path(const boost::filesystem::path& p) {
    auto it = p.rbegin();
    while (it != p.rend()) {
        ++it;
    }
}
