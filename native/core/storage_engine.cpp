#include "usf/storage_engine.hpp"
namespace usf {
bool api_supported(const int api_level) { return api_level >= 34 && api_level <= 37; }
std::string issue_class_name(const IssueClass value) {
  switch (value) {
    case IssueClass::Informational: return "INFORMATIONAL"; case IssueClass::SafeToFix: return "SAFE_TO_FIX";
    case IssueClass::RequiresUserAction: return "REQUIRES_USER_ACTION"; case IssueClass::RequiresRoot: return "REQUIRES_ROOT";
    case IssueClass::RequiresSystemApp: return "REQUIRES_SYSTEM_APP"; case IssueClass::OemSpecific: return "OEM_SPECIFIC";
    case IssueClass::Unsupported: return "UNSUPPORTED"; case IssueClass::HighRisk: return "HIGH_RISK"; case IssueClass::Unknown: return "UNKNOWN";
  }
  return "UNKNOWN";
}
Issue classify_volume(const Volume& volume, const int api_level) {
  if (!api_supported(api_level)) return {"api_compatibility", IssueClass::Unsupported, "API level is outside tested target range"};
  if (!volume.present) return {"volume_missing", IssueClass::RequiresUserAction, "Volume is not mounted"};
  if (!volume.writable) return {"volume_read_only", IssueClass::RequiresUserAction, "Volume is read-only"};
  if (volume.available_kib == 0U) return {"volume_full", IssueClass::RequiresUserAction, "Volume has no reported free space"};
  return {"volume_healthy", IssueClass::Informational, "Volume is accessible"};
}
}
