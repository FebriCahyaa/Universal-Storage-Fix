#include "usf/path_policy.hpp"
namespace usf {
bool is_module_owned_path(const std::string& path) {
  static const std::string prefix = "/data/adb/universal_storage_fix/";
  return path.size() > prefix.size() && path.compare(0, prefix.size(), prefix) == 0 && path.find("..") == std::string::npos;
}
bool is_safe_relative_name(const std::string& name) { return !name.empty() && name.find('/') == std::string::npos && name.find("..") == std::string::npos && name.find('\0') == std::string::npos; }
}
