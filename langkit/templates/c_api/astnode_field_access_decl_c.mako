## vim: filetype=makocpp

${c_doc(field)}
extern int
${accessor_name}(${node_type} node,
                 ${field.type.c_type(capi).name} *value_p);
