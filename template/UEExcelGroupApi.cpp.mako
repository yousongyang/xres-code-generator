## -*- coding: utf-8 -*-
<%!
import time
import os
import re
%><%namespace name="pb_loader" module="pb_loader"/><%namespace name="ue_excel_utils" module="UEExcelUtils"/><%
ue_api_definition = pb_set.get_custom_variable("ue_api_definition")
if ue_api_definition:
  ue_api_definition = ue_api_definition + " "

file_path_prefix = os.path.relpath(output_file, output_dir).replace("\\", "/")
if file_path_prefix.endswith(".cc"):
  file_path_prefix = file_path_prefix[:-3]
elif file_path_prefix.endswith(".cpp") or file_path_prefix.endswith(".cxx"):
  file_path_prefix = file_path_prefix[:-4]
else:
  file_path_prefix = file_path_prefix

ue_excel_loader_include_rule = pb_set.get_custom_variable("ue_excel_loader_include_rule")
if not ue_excel_loader_include_rule:
  ue_excel_loader_include_rule = pb_set.get_custom_variable("ue_include_prefix", "ExcelLoader") + "/%(file_path_camelname)s.h"
ue_excel_group_api_include_rule = pb_set.get_custom_variable("ue_excel_group_api_include_rule", ue_excel_loader_include_rule)

config_manager_include = pb_set.get_custom_variable("config_manager_include", "config/excel/config_manager.h")
config_group_wrapper_type_name = ue_excel_utils.UECppUClassNameFromString("ConfigGroupWrapper")
%>// Copyright ${time.strftime("%Y")} xresloader. All rights reserved.
// Generated by xres-code-generator, please don't edit it
//
<%
message_include_args_file_base_camelname = pb_loader.MakoToCamelName(os.path.basename(file_path_prefix))
message_include_format_args = {
  "file_path_without_ext": file_path_prefix,
  "file_basename_without_ext": os.path.basename(file_path_prefix),
  "file_camelname": pb_loader.MakoToCamelName(file_path_prefix),
  "file_base_camelname": message_include_args_file_base_camelname,
  "file_path_camelname": os.path.dirname(file_path_prefix) + "/" + message_include_args_file_base_camelname,
}
current_file_include_path = ue_excel_group_api_include_rule % message_include_format_args
current_file_include_path = re.sub("//+", "/", current_file_include_path)
%>
#include "${current_file_include_path}"

#include "${config_manager_include}"

${ue_api_definition}${config_group_wrapper_type_name}::${config_group_wrapper_type_name}() : Super()
{
}

${ue_api_definition}void ${config_group_wrapper_type_name}::_InternalBindConfigGroup(const std::shared_ptr<${pb_loader.CppFullPath(global_package)}config_group_t>& ConfigGroup)
{
    config_group_ = ConfigGroup;
}

% for message_inst in pb_set.generate_message:
<%
message_class_name = ue_excel_utils.UECppUClassName(message_inst)
%>
    // ======================================== ${message_class_name} ========================================
%   for loader in message_inst.loaders:
    // ---------------------------------------- ${loader.code.class_name} ----------------------------------------
%     for code_index in loader.code.indexes:
${ue_api_definition}int64 ${config_group_wrapper_type_name}::Get${pb_loader.MakoToCamelName(loader.code.class_name)}_SizeOf_${pb_loader.MakoToCamelName(code_index.name)}()
{
    if(!config_group_)
    {
        return 0;
    }
    return static_cast<int64>(config_group_->${loader.get_cpp_public_var_name()}.get_all_of_${code_index.name}().size());
}

${ue_api_definition}TArray<${message_class_name}*> ${config_group_wrapper_type_name}::GetAll${pb_loader.MakoToCamelName(loader.code.class_name)}_Of_${pb_loader.MakoToCamelName(code_index.name)}()
{
    TArray<${message_class_name}*> Ret;
    if(!config_group_)
    {
      return Ret;
    }

%       if code_index.is_list():
    size_t TotalSize = 0;
    for(auto& item_list : config_group_->${loader.get_cpp_public_var_name()}.get_all_of_${code_index.name}())
    {
        TotalSize += item_list.second.size();
    }
    Ret.Reserve(static_cast<TArray<${message_class_name}>::SizeType>(TotalSize));
    for(auto& item_list : config_group_->${loader.get_cpp_public_var_name()}.get_all_of_${code_index.name}())
    {
        for(auto& item : item_list.second)
        {
            ${message_class_name}* Value = NewObject<${message_class_name}>();
            Value->_InternalBindLifetime(std::static_pointer_cast<const ::google::protobuf::Message>(item), *item);
            Ret.Emplace(Value);
        }
    }
%       else:
    Ret.Reserve(static_cast<TArray<${message_class_name}>::SizeType>(config_group_->${loader.get_cpp_public_var_name()}.get_all_of_${code_index.name}().size()));
    for(auto& item : config_group_->${loader.get_cpp_public_var_name()}.get_all_of_${code_index.name}())
    {
        ${message_class_name}* Value = NewObject<${message_class_name}>();
        Value->_InternalBindLifetime(std::static_pointer_cast<const ::google::protobuf::Message>(item.second), *item.second);
        Ret.Emplace(Value);
    }
%       endif
    return Ret;
}
%       if code_index.is_list():

${ue_api_definition}TArray<${message_class_name}*> ${config_group_wrapper_type_name}::GetRow${pb_loader.MakoToCamelName(loader.code.class_name)}_AllOf_${pb_loader.MakoToCamelName(code_index.name)}(${ue_excel_utils.UECppGetLoaderIndexKeyDecl(message_inst, code_index)}, bool& IsValid)
{
    TArray<${message_class_name}*> Ret;
    if(!config_group_)
    {
        IsValid = false;
        return Ret;
    }

    auto item_list = config_group_->${loader.get_cpp_public_var_name()}.get_list_by_${code_index.name}(${ue_excel_utils.UECppGetLoaderIndexKeyParams(message_inst, code_index)});
    if (nullptr == item_list)
    {
        IsValid = false;
        return Ret;
    }
    IsValid = true;

    Ret.Reserve(static_cast<TArray<${message_class_name}>::SizeType>(item_list->size()));
    for(auto& item : *item_list) {
        ${message_class_name}* Value = NewObject<${message_class_name}>();
        Value->_InternalBindLifetime(std::static_pointer_cast<const ::google::protobuf::Message>(item), *item);
        Ret.Emplace(Value);
    }

    return Ret;
}

${ue_api_definition}${message_class_name}* ${config_group_wrapper_type_name}::GetRow${pb_loader.MakoToCamelName(loader.code.class_name)}_Of_${pb_loader.MakoToCamelName(code_index.name)}(${ue_excel_utils.UECppGetLoaderIndexKeyDecl(message_inst, code_index)}, int64 Index, bool& IsValid)
{
    if(!config_group_)
    {
        IsValid = false;
        return nullptr;
    }

    auto item = config_group_->${loader.get_cpp_public_var_name()}.get_by_${code_index.name}(${ue_excel_utils.UECppGetLoaderIndexKeyParams(message_inst, code_index)}, static_cast<size_t>(Index));
    if (!item)
    {
        IsValid = false;
        return nullptr;
    }

    ${message_class_name}* Value = NewObject<${message_class_name}>();
    Value->_InternalBindLifetime(std::static_pointer_cast<const ::google::protobuf::Message>(item), *item);
    return Value;
}
%       else:

${ue_api_definition}${message_class_name}* ${config_group_wrapper_type_name}::GetRow${pb_loader.MakoToCamelName(loader.code.class_name)}_Of_${pb_loader.MakoToCamelName(code_index.name)}(${ue_excel_utils.UECppGetLoaderIndexKeyDecl(message_inst, code_index)}, bool& IsValid)
{
    if(!config_group_)
    {
        IsValid = false;
        return nullptr;
    }

    auto item = config_group_->${loader.get_cpp_public_var_name()}.get_by_${code_index.name}(${ue_excel_utils.UECppGetLoaderIndexKeyParams(message_inst, code_index)});
    if (!item)
    {
        IsValid = false;
        return nullptr;
    }

    ${message_class_name}* Value = NewObject<${message_class_name}>();
    Value->_InternalBindLifetime(std::static_pointer_cast<const ::google::protobuf::Message>(item), *item);
    return Value;
}
%       endif

%     endfor
%   endfor
% endfor
