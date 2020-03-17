﻿## -*- coding: utf-8 -*-
<%!
import time

from pb_loader import PbMsgPbFieldisSigned,PbMsgGetPbFieldFn

%><%
pb_msg_class_name = pb_msg.get_cpp_class_name()
%>
//
// generated by xrescode on ${time.strftime("%Y-%m-%d %H:%M:%S")}, please don't edit it
//

#include <algorithm>
#include <cstddef>
#include <functional>
#include <iostream>
#include <map>
#include <memory>
#include <string>
#include <tuple>
#include <vector>
#include <sstream>

// 禁用掉unordered_map，我们要保证mt_core中逻辑有序
#if 0 && defined(__cplusplus) && __cplusplus >= 201103L
#include <unordered_map>
#define LIBXRESLOADER_USING_HASH_MAP 1
#else

#endif

#ifdef _MSC_VER
#if (defined(__cplusplus) && __cplusplus >= 201703L) || (defined(_MSVC_LANG) && _MSVC_LANG >= 201703L)
#pragma warning(push)
#pragma warning(disable : 4996)
#pragma warning(disable : 4309)
#if _MSC_VER >= 1922 && ((defined(__cplusplus) && __cplusplus >= 201704L) || (defined(_MSVC_LANG) && _MSVC_LANG >= 201704L))
#pragma warning(disable : 5054)
#endif
#endif
#include <Windows.h>
#endif

#if defined(__GNUC__) && !defined(__clang__) && !defined(__apple_build_version__)  // && (__GNUC__ * 100 + __GNUC_MINOR__ * 10) >= 460
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
#elif defined(__clang__) || defined(__apple_build_version__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-parameter"
#endif

#include <google/protobuf/arena.h>
#include <google/protobuf/arenastring.h>
#include <google/protobuf/extension_set.h>  // IWYU pragma: export
#include <google/protobuf/generated_message_table_driven.h>
#include <google/protobuf/generated_message_util.h>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/message_lite.h>
#include <google/protobuf/metadata_lite.h>
#include <google/protobuf/repeated_field.h>  // IWYU pragma: export
#include <google/protobuf/stubs/common.h>

#if defined(__GNUC__) && !defined(__clang__) && !defined(__apple_build_version__)  // && (__GNUC__ * 100 + __GNUC_MINOR__ * 10) >= 460
#pragma GCC diagnostic pop
#elif defined(__clang__) || defined(__apple_build_version__)
#pragma clang diagnostic pop
#endif

#ifdef _MSC_VER
#if (defined(__cplusplus) && __cplusplus >= 201703L) || (defined(_MSVC_LANG) && _MSVC_LANG >= 201703L)
#pragma warning(pop)
#endif
#endif

#include <log/log_wrapper.h>
#include <lock/lock_holder.h>
#include <common/string_oprs.h>

#include "config_manager.h"
#include "${pb_msg.get_cpp_header_path()}"

namespace excel {
${pb_msg.get_cpp_namespace_decl_begin()}

    ${pb_msg_class_name}::${pb_msg_class_name}() {
    }

    ${pb_msg_class_name}::~${pb_msg_class_name}(){
    }

    int ${pb_msg_class_name}::on_inited() {
        ::util::lock::write_lock_holder<::util::lock::spin_rw_lock> wlh(load_file_lock_);
        
        file_status_.clear();
        return reload_file_lists();
    }

    int ${pb_msg_class_name}::load_all() {
        int ret = 0;
        ::util::lock::write_lock_holder<::util::lock::spin_rw_lock> wlh(load_file_lock_);
        for (std::unordered_map<std::string, bool>::iterator iter = file_status_.begin(); iter != file_status_.end(); ++ iter) {
            if (!iter->second) {
                int res = load_file(iter->first);
                if (res < 0) {
                    WLOGERROR("[EXCEL] load config file %s for %s failed", iter->first.c_str(), "${pb_msg_class_name}");
                    ret = res;
                } else if (ret >= 0) {
                    ret += res;
                }
            }
        }

        return ret;
    }

    void ${pb_msg_class_name}::clear() {
        ::util::lock::write_lock_holder<::util::lock::spin_rw_lock> wlh(load_file_lock_);
% for code_index in pb_msg.code.indexes:
        ${code_index.name}_data_.clear();
% endfor
        file_status_.clear();
        reload_file_lists();
    }

    int ${pb_msg_class_name}::load_file(const std::string& file_path) {
        std::unordered_map<std::string, bool>::iterator iter = file_status_.find(file_path);
        if (iter == file_status_.end()) {
            WLOGERROR("[EXCEL] load config file %s for %s failed, not exist in any file_list/file_path", file_path.c_str(), "${pb_msg_class_name}");
            return -2;
        }

        if (iter->second) {
            return 0;
        }
        iter->second = true;

        std::string content;
        if (!config_manager::me()->load_file_data(content, file_path)) {
            WLOGERROR("[EXCEL] load file %s for %s failed", file_path.c_str(), "${pb_msg_class_name}");
            return -3;
        }

        ${pb_msg.get_pb_outer_class_name()} outer_data;
        if (!outer_data.ParseFromString(content)) {
            WLOGERROR("[EXCEL] parse file %s for %s(message type: %s) failed, msg: %s",
                file_path.c_str(), "${pb_msg_class_name}", "${pb_msg.get_pb_outer_class_name()}",
                outer_data.InitializationErrorString().c_str()
            );
            return -4;
        }

% for code_index in pb_msg.code.indexes:
% if code_index.is_vector():
        // vector index: ${code_index.name}
        if(${code_index.name}_data_.capacity() < static_cast<size_t>(outer_data.${pb_msg.code_field.name.lower()}_size())) {
            ${code_index.name}_data_.reserve(static_cast<size_t>(outer_data.${pb_msg.code_field.name.lower()}_size()));
        }
% endif
% endfor

        for (int i = 0; i < outer_data.${pb_msg.code_field.name.lower()}_size(); ++ i) {
            merge_data(std::make_shared<item_type>(outer_data.${pb_msg.code_field.name.lower()}(i)));
        }

        WLOGINFO("[EXCEL] load file %s for %s(message type: %s) with %d item(s) success",
            file_path.c_str(), "${pb_msg_class_name}", "${pb_msg.get_pb_outer_class_name()}",
            outer_data.${pb_msg.code_field.name.lower()}_size()
        );

        return 1;
    }

    int ${pb_msg_class_name}::load_list(const char* file_list_path) {
        std::string content;
        if (!config_manager::me()->load_file_data(content, file_list_path)) {
            WLOGERROR("[EXCEL] load file %s for %s failed", file_list_path, "${pb_msg_class_name}");
            return -1;
        }

        const char* line_start = content.c_str();
        const char* line_end;
        int ret = 0;
        for (; line_start < content.c_str() + content.size() && *line_start; line_start = line_end + 1) {
            line_end = line_start;

            while (*line_end && '\r' != *line_end && '\n' != *line_end) {
                ++ line_end;
            }

            std::pair<const char*, size_t> file_path_trimed = ::util::string::trim(line_start, line_end - line_start);
            if (file_path_trimed.second == 0) {
                continue;
            }

            std::string file_path;
            file_path.assign(file_path_trimed.first, file_path_trimed.second);
            if (file_status_.end() == file_status_.find(file_path)) {
                file_status_[file_path] = false;
            }
        }

        return ret;
    }

    int ${pb_msg_class_name}::reload_file_lists() {
% if pb_msg.code.file_list:
        return load_list("${pb_msg.code.file_list}");
% else:
        file_status_["${pb_msg.code.file_path}"] = false;
        return 0;
% endif
    }

    void ${pb_msg_class_name}::merge_data(item_ptr_type item) {
        if (!item) {
            WLOGERROR("[EXCEL] merge_data(nullptr) is not allowed for %s", "${pb_msg_class_name}");
            return;
        }

% for code_index in pb_msg.code.indexes:
        // index: ${code_index.name}
        do {
% if code_index.is_vector():
            size_t idx = 0;
%   for idx_field in code_index.fields:
%       if PbMsgPbFieldisSigned(idx_field):
            if (item->${PbMsgGetPbFieldFn(idx_field)} < 0) {
                WLOGERROR("[EXCEL] merge_data with vector index %lld for %s is not allowed",
                    static_cast<long long>(item->${PbMsgGetPbFieldFn(idx_field)}), "${pb_msg_class_name}"
                );
                break;
            }
%       endif
            idx = static_cast<size_t>(item->${PbMsgGetPbFieldFn(idx_field)});
%   endfor
            if (${code_index.name}_data_.capacity() <= idx) {
                ${code_index.name}_data_.reserve(idx * 2 + 1);
            }

            if (${code_index.name}_data_.size() <= idx) {
                ${code_index.name}_data_.resize(idx + 1);
            }

%   if code_index.is_list():
            ${code_index.name}_data_[idx].push_back(item);
%   else:
            ${code_index.name}_data_[idx] = item;
%   endif
% else:
%   if code_index.is_list():
            ${code_index.name}_data_[std::make_tuple(${code_index.get_key_value_list("item->")})].push_back(item);
%   else:
            std::tuple<${code_index.get_key_type_list()}> key = std::make_tuple(${code_index.get_key_value_list("item->")});
            if (${code_index.name}_data_.end() != ${code_index.name}_data_.find(key)) {
                WLOGERROR("[EXCEL] merge_data() with key=<${code_index.get_key_fmt_list()}> for %s is already exists, we will cover it with the newer value", 
                    ${code_index.get_key_fmt_value_list("item->")}, "${pb_msg_class_name}");
            }
            ${code_index.name}_data_[key] = item;
%   endif
% endif
        } while(false);

% endfor
    }

% for code_index in pb_msg.code.indexes:
// ------------------- index: ${code_index.name} APIs -------------------
% if code_index.is_list():
    const ${pb_msg_class_name}::${code_index.name}_value_type* ${pb_msg_class_name}::get_list_by_${code_index.name}(${code_index.get_key_decl()}) {
        ::util::lock::read_lock_holder<::util::lock::spin_rw_lock> rlh(load_file_lock_);
        return _get_list_by_${code_index.name}(${code_index.get_key_params()});
    }

    ${pb_msg_class_name}::item_ptr_type ${pb_msg_class_name}::get_by_${code_index.name}(${code_index.get_key_decl()}, size_t index) {
        ::util::lock::read_lock_holder<::util::lock::spin_rw_lock> rlh(load_file_lock_);
        const ${pb_msg_class_name}::${code_index.name}_value_type* list_item = _get_list_by_${code_index.name}(${code_index.get_key_params()});
        if (nullptr == list_item) {
%   if not code_index.allow_not_found:
            WLOGERROR("[EXCEL] load index %s with key=<${code_index.get_key_fmt_list()}>, index=%llu for %s failed, list not found",
                "${code_index.name}", ${code_index.get_key_params_fmt_value_list()}, 
                static_cast<unsigned long long>(index), "${pb_msg_class_name}"
            );
%   endif
            return nullptr;
        }

        if (list_item->size() <= index) {
%   if not code_index.allow_not_found:
            WLOGERROR("[EXCEL] load index %s with key=<${code_index.get_key_fmt_list()}>, index=%llu for %s failed, index entend %llu",
                "${code_index.name}", ${code_index.get_key_params_fmt_value_list()}, 
                static_cast<unsigned long long>(index), "${pb_msg_class_name}", static_cast<unsigned long long>(list_item->size())
            );
%   endif
            return nullptr;
        }

        return (*list_item)[index];
    }

    const ${pb_msg_class_name}::${code_index.name}_value_type* ${pb_msg_class_name}::_get_list_by_${code_index.name}(${code_index.get_key_decl()}) {
% if code_index.is_vector():
        size_t idx = 0;
%   for idx_field in code_index.fields:
%       if PbMsgPbFieldisSigned(idx_field):
        if (${idx_field.name} < 0) {
            WLOGERROR("[EXCEL] vector index %lld for %s is not allowed",
                static_cast<long long>(${idx_field.name}), "${pb_msg_class_name}"
            );
            return nullptr;
        }
%       endif
        idx = static_cast<size_t>(${idx_field.name});
%   endfor
        if (${code_index.name}_data_.size() > idx && ${code_index.name}_data_[idx]) {
            return &${code_index.name}_data_[idx];
        }
% else:
        ${code_index.name}_container_type::iterator iter = ${code_index.name}_data_.find(std::make_tuple(${code_index.get_key_params()}));
        if (iter != ${code_index.name}_data_.end()) {
            return &iter->second;
        }
% endif

%   if pb_msg.code.file_list and code_index.file_mapping:
%       for code_line in code_index.get_load_file_code("file_path"):
        ${code_line}
%       endfor
%   else:
        std::string file_path = "${pb_msg.code.file_path}";
%   endif

        int res = load_file(file_path);
        if (res < 0) {
            WLOGERROR("[EXCEL] load file %s for %s failed, res: %d", file_path.c_str(), "${pb_msg_class_name}", res);
            return nullptr;
        }

% if code_index.is_vector():
        if (${code_index.name}_data_.size() > idx && ${code_index.name}_data_[idx]) {
            return &${code_index.name}_data_[idx];
        }

%   if not code_index.allow_not_found:
        WLOGERROR("[EXCEL] load index %s with key=<${code_index.get_key_fmt_list()}> for %s failed, not found",
            "${code_index.name}", ${code_index.get_key_params_fmt_value_list()}, "${pb_msg_class_name}"
        );
%   endif
        return nullptr;

% else:
        iter = ${code_index.name}_data_.find(std::make_tuple(${code_index.get_key_params()}));
        if (iter == ${code_index.name}_data_.end()) {
%   if not code_index.allow_not_found:
            WLOGERROR("[EXCEL] load index %s with key=<${code_index.get_key_fmt_list()}> for %s failed, not found",
                "${code_index.name}", ${code_index.get_key_params_fmt_value_list()}, "${pb_msg_class_name}"
            );
%   endif
            return nullptr;
        }

        return &iter->second;

% endif
    }

% else:
    ${pb_msg_class_name}::${code_index.name}_value_type ${pb_msg_class_name}::get_by_${code_index.name}(${code_index.get_key_decl()}) {
% if code_index.is_vector():
        size_t idx = 0;
%   for idx_field in code_index.fields:
%       if PbMsgPbFieldisSigned(idx_field):
        if (${idx_field.name} < 0) {
            WLOGERROR("[EXCEL] vector index %lld for %s is not allowed",
                static_cast<long long>(${idx_field.name}), "${pb_msg_class_name}"
            );
            return nullptr;
        }
%       endif
        idx = static_cast<size_t>(${idx_field.name});
%   endfor
        if (${code_index.name}_data_.size() > idx && ${code_index.name}_data_[idx]) {
            return ${code_index.name}_data_[idx];
        }
% else:
        ::util::lock::read_lock_holder<::util::lock::spin_rw_lock> rlh(load_file_lock_);
        ${code_index.name}_container_type::iterator iter = ${code_index.name}_data_.find(std::make_tuple(${code_index.get_key_params()}));
        if (iter != ${code_index.name}_data_.end()) {
            return iter->second;
        }
% endif

%   if pb_msg.code.file_list and code_index.file_mapping:
%       for code_line in code_index.get_load_file_code("file_path"):
        ${code_line}
%       endfor
%   else:
        std::string file_path = "${pb_msg.code.file_path}";
%   endif

        int res = load_file(file_path);
        if (res < 0) {
            WLOGERROR("[EXCEL] load file %s for %s failed, res: %d", file_path.c_str(), "${pb_msg_class_name}", res);
            return nullptr;
        }

% if code_index.is_vector():
        if (${code_index.name}_data_.size() > idx && ${code_index.name}_data_[idx]) {
            return ${code_index.name}_data_[idx];
        }

%   if not code_index.allow_not_found:
        WLOGERROR("[EXCEL] load index %s with key=<${code_index.get_key_fmt_list()}> for %s failed, not found",
            "${code_index.name}", ${code_index.get_key_params_fmt_value_list()}, "${pb_msg_class_name}"
        );
%   endif
        return nullptr;

% else:
        iter = ${code_index.name}_data_.find(std::make_tuple(${code_index.get_key_params()}));
        if (iter == ${code_index.name}_data_.end()) {
%   if not code_index.allow_not_found:
            WLOGERROR("[EXCEL] load index %s with key=<${code_index.get_key_fmt_list()}> for %s failed, not found",
                "${code_index.name}", ${code_index.get_key_params_fmt_value_list()}, "${pb_msg_class_name}"
            );
%   endif
            return nullptr;
        }

        return iter->second;
% endif
    }
% endif

    const ${pb_msg_class_name}::${code_index.name}_container_type& ${pb_msg_class_name}::get_all_of_${code_index.name}() const {
        return ${code_index.name}_data_;
    }
% endfor

${pb_msg.get_cpp_namespace_decl_end()}
}
