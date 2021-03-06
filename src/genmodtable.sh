#! /bin/sh
# Copyright 2011 SRI International
# See LICENSE for other credits and copying information

set -e

output="$1"
ttag="${1%list.cc}"
vtag="$(echo $1 | cut -c1)"
shift

modules=$(sed -ne \
    's/[A-Z][A-Z]*_DEFINE_MODULE(\([a-zA-Z_][a-zA-Z0-9_]*\)[,)].*$/\1/p' \
    "$@")

trap "rm -f '$output.$$'" 0
exec 1> "$output.$$"

printf \
'/* Automatically generated by %s - do not edit
 *
 * This file defines a table of all supported %s modules.
 */

struct %s_module;

' $(basename "$0") "$ttag" "$ttag" "$ttag"

for m in $modules; do
    printf 'extern const %s_module %s_mod_%s;\n' "$ttag" "$vtag" "$m"
done

printf '\nextern const %s_module *const supported_%ss[] =\n{\n' "$ttag" "$ttag"

for m in $modules; do
    printf '  &%s_mod_%s,\n' "$vtag" "$m"
done

printf '  0\n};\n'

exec 1>&-
if cmp -s "$output.$$" "$output"
then rm -f "$output.$$"; echo "$output" is unchanged >&2
else mv -f "$output.$$" "$output"
fi
trap "" 0
