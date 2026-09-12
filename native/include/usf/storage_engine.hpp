#pragma once
#include <cstdint>
#include <string>
namespace usf {
enum class IssueClass { Informational, SafeToFix, RequiresUserAction, RequiresRoot, RequiresSystemApp, OemSpecific, Unsupported, HighRisk, Unknown };
struct Volume { std::string path; std::uint64_t total_kib{}; std::uint64_t available_kib{}; bool present{}; bool writable{}; };
struct Issue { std::string id; IssueClass classification{IssueClass::Unknown}; std::string message; };
Issue classify_volume(const Volume& volume, int api_level); bool api_supported(int api_level); std::string issue_class_name(IssueClass value);
}
