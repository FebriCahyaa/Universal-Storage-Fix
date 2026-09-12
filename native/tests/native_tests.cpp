#include <cassert>
#include "usf/path_policy.hpp"
#include "usf/runtime_info.hpp"
#include "usf/storage_engine.hpp"
int main() {
  assert(usf::api_supported(34)); assert(usf::api_supported(37)); assert(!usf::api_supported(33));
  assert(usf::is_arm64_abi("arm64-v8a")); assert(!usf::is_arm64_abi("armeabi-v7a"));
  assert(usf::is_module_owned_path("/data/adb/universal_storage_fix/cache/a"));
  assert(!usf::is_module_owned_path("/data/adb/modules/other")); assert(!usf::is_safe_relative_name("../x"));
  auto issue = usf::classify_volume({"/data", 1U, 1U, true, true}, 35); assert(issue.classification == usf::IssueClass::Informational);
}
