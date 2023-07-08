﻿## -*- coding: utf-8 -*-
<%!
import time
%><%namespace name="pb_loader" module="pb_loader"/>
// Copyright ${time.strftime("%Y")} xresloader. All rights reserved.
// Generated by xres-code-generator, please don't edit it
//

#ifndef CONFIG_EXCEL_CONFIG_SET_${loader.get_cpp_if_guard_name()}_H
#define CONFIG_EXCEL_CONFIG_SET_${loader.get_cpp_if_guard_name()}_H

#pragma once

#include <stdint.h>
#include <cstddef>
#include <functional>
#include <vector>
#include <string>
#include <map>
#include <unordered_map>
#include <memory>
#include <cstring>

#include "spin_rw_lock.h"

% for block_file in pb_set.get_custom_blocks("custom_config_include"):
// include custom_config_include: ${block_file}
<%include file="${block_file}" />
% endfor

#ifndef EXCEL_CONFIG_LOADER_API
#  define EXCEL_CONFIG_LOADER_API
#endif

#if defined(_MSC_VER)
#  pragma warning(push)

#  if ((defined(__cplusplus) && __cplusplus >= 201703L) || (defined(_MSVC_LANG) && _MSVC_LANG >= 201703L))
#    pragma warning(disable : 4996)
#    pragma warning(disable : 4309)
#    if _MSC_VER >= 1922
#      pragma warning(disable : 5054)
#    endif
#  endif

#  if _MSC_VER < 1910
#    pragma warning(disable : 4800)
#  endif
#  pragma warning(disable : 4244)
#  pragma warning(disable : 4251)
#  pragma warning(disable : 4267)
#  pragma warning(disable : 4668)
#  pragma warning(disable : 4946)
#  pragma warning(disable : 6001)
#  pragma warning(disable : 6244)
#  pragma warning(disable : 6246)
#  ifndef WIN32_LEAN_AND_MEAN
#    define WIN32_LEAN_AND_MEAN
#  endif
#  include <Windows.h>
#endif

#ifdef max
#undef max
#endif

#ifdef min
#undef min
#endif

#if defined(__GNUC__) && !defined(__clang__) && !defined(__apple_build_version__)
#  if (__GNUC__ * 100 + __GNUC_MINOR__ * 10) >= 460
#    pragma GCC diagnostic push
#  endif
#  pragma GCC diagnostic ignored "-Wunused-parameter"
#  pragma GCC diagnostic ignored "-Wtype-limits"
#  pragma GCC diagnostic ignored "-Wsign-compare"
#  pragma GCC diagnostic ignored "-Wsign-conversion"
#  pragma GCC diagnostic ignored "-Wshadow"
#  pragma GCC diagnostic ignored "-Wuninitialized"
#  pragma GCC diagnostic ignored "-Wconversion"
#  if (__GNUC__ * 100 + __GNUC_MINOR__) >= 409
#    pragma GCC diagnostic ignored "-Wfloat-conversion"
#  endif
#  if (__GNUC__ * 100 + __GNUC_MINOR__) >= 501
#    pragma GCC diagnostic ignored "-Wsuggest-override"
#  endif
#elif defined(__clang__) || defined(__apple_build_version__)
#  pragma clang diagnostic push
#  pragma clang diagnostic ignored "-Wunused-parameter"
#  pragma clang diagnostic ignored "-Wtype-limits"
#  pragma clang diagnostic ignored "-Wsign-compare"
#  pragma clang diagnostic ignored "-Wsign-conversion"
#  pragma clang diagnostic ignored "-Wshadow"
#  pragma clang diagnostic ignored "-Wuninitialized"
#  pragma clang diagnostic ignored "-Wconversion"
#  if ((__clang_major__ * 100) + __clang_minor__) >= 305
#    pragma clang diagnostic ignored "-Wfloat-conversion"
#  endif
#  if ((__clang_major__ * 100) + __clang_minor__) >= 306
#    pragma clang diagnostic ignored "-Winconsistent-missing-override"
#  endif
#  if ((__clang_major__ * 100) + __clang_minor__) >= 1100
#    pragma clang diagnostic ignored "-Wsuggest-override"
#  endif
#endif

#include <${pb_set.pb_include_prefix}${loader.get_pb_header_path()}>
#include <pb_header_v3.pb.h>

#if defined(__GNUC__) && !defined(__clang__) && !defined(__apple_build_version__)
#  if (__GNUC__ * 100 + __GNUC_MINOR__ * 10) >= 460
#    pragma GCC diagnostic pop
#  endif
#elif defined(__clang__) || defined(__apple_build_version__)
#  pragma clang diagnostic pop
#endif

#if defined(_MSC_VER)
#  pragma warning(pop)
#endif

#ifndef EXCEL_CONFIG_LOADER_API
#  define EXCEL_CONFIG_LOADER_API
#endif

${pb_loader.CppNamespaceBegin(global_package)}
${loader.get_cpp_namespace_decl_begin()}

class ${loader.get_cpp_class_name()} {
public:
  typedef const ${loader.get_pb_inner_class_name()} item_type;
  typedef ${loader.get_pb_inner_class_name()} proto_type;
  typedef std::shared_ptr<item_type> item_ptr_type;

public:
  EXCEL_CONFIG_LOADER_API ${loader.get_cpp_class_name()}();
  EXCEL_CONFIG_LOADER_API ~${loader.get_cpp_class_name()}();

  EXCEL_CONFIG_LOADER_API int on_inited();

  EXCEL_CONFIG_LOADER_API int load_all();

  EXCEL_CONFIG_LOADER_API void clear();

  EXCEL_CONFIG_LOADER_API const std::list<org::xresloader::pb::xresloader_data_source>& get_data_source() const;

private:
  int load_file(const std::string& file_path);
  int load_list(const char*);
  int reload_file_lists();
  void merge_data(item_ptr_type);

private:
  ::excel::lock::spin_rw_lock           load_file_lock_;
  std::unordered_map<std::string, bool> file_status_; // true: already loaded
  std::list<org::xresloader::pb::xresloader_data_source> datasource_;
  bool all_loaded_;

% for code_index in loader.code.indexes:
  // ------------------------- index: ${code_index.name} -------------------------
public:
% if code_index.is_list():
  typedef std::vector<item_ptr_type> ${code_index.name}_value_type;
  EXCEL_CONFIG_LOADER_API const ${code_index.name}_value_type* get_list_by_${code_index.name}(${code_index.get_key_decl()});
  EXCEL_CONFIG_LOADER_API item_ptr_type get_by_${code_index.name}(${code_index.get_key_decl()}, size_t index);
private:
  const ${code_index.name}_value_type* _get_list_by_${code_index.name}(${code_index.get_key_decl()});
public:
% else:
  typedef item_ptr_type ${code_index.name}_value_type;
  EXCEL_CONFIG_LOADER_API ${code_index.name}_value_type get_by_${code_index.name}(${code_index.get_key_decl()});
% endif
% if code_index.is_vector():
  typedef std::vector<${code_index.name}_value_type> ${code_index.name}_container_type;
% else:
  typedef std::map<std::tuple<${code_index.get_key_type_list()}>, ${code_index.name}_value_type> ${code_index.name}_container_type;
% endif
  EXCEL_CONFIG_LOADER_API const ${code_index.name}_container_type& get_all_of_${code_index.name}() const;

private:
% if code_index.is_vector():
  ${code_index.name}_container_type ${code_index.name}_data_;
% else:
  ${code_index.name}_container_type ${code_index.name}_data_;
% endif

% endfor
};

${loader.get_cpp_namespace_decl_end()}
${pb_loader.CppNamespaceEnd(global_package)} // ${global_package}

#endif // CONFIG_EXCEL_CONFIG_SET_${loader.get_cpp_if_guard_name()}_H
