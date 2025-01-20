#!/usr/bin/env sh
NAME="$(basename "$0")"
DEFINITION_PATH="$1"

notifyc() {
    printf "$NAME: $@" >&2
}

notify() {
    notifyc "$@\n"
}

if test -z "$GITOPS_PATH"; then
    echo "error: 'GITOPS_PATH' not set"
    exit 1
fi

. "$GITOPS_PATH"/lib/yaml.sh

PREFIX="[GitOps] "

development_pipeline() {
    cat << EOF
- step:
      name: '$(echo "$PREFIX")build'
      script:
          - './gitops/make build'
- step:
      name: '$(echo "$PREFIX")test'
      script:
          - './gitops/make test'
- step:
      name: '$(echo "$PREFIX")sbom'
      script:
          - './gitops/make sbom'
- step:
      name: '$(echo "$PREFIX")doc'
      script:
          - './gitops/make doc'
EOF
}

prerelease_pipeline() {
    development_pipeline
    cat << EOF
- step:
      name: '$(echo "$PREFIX")audit'
      script:
          - './gitops/make audit'
EOF
}

release_pipeline() {
    prerelease_pipeline
    cat << EOF
- step:
      name: '$(echo "$PREFIX")release'
      script:
          - './gitops/make release'
EOF
}


top=$(cat "$DEFINITION_PATH" | yaml__get_mapping_keys 2>&1 >/dev/null)

has_pipelines=no
pipeline_offset=
for item in $top; do

    start=$(echo "$item" | cut -d ':' -f 1)
    end=$(echo "$item" | cut -d ':' -f 2)
    name="$(echo "$item" | sed -E 's|^[0-9]+:[0-9]+:||')"

    if test "$name" '=' "pipelines"; then
        has_pipelines=yes
        notify "dropping 'pipelines', will be regenerated..."
    else
        cat "$DEFINITION_PATH" | tail -n +$start | head -n $(expr $end '-' $start '+' 1)
    fi
done


node_pipelines="$(cat $DEFINITION_PATH | yaml__get_nested_mappings 'pipelines' 2>/dev/null)"
node_branches="$(echo "$node_pipelines" | yaml__get_nested_mappings 'branches' 2>/dev/null)"


echo "pipelines:"

pipelines=$(cat "$DEFINITION_PATH" | yaml__get_nested_mappings 'pipelines' 2>&1 >/dev/null)
has_branches=no
for pipeline in $pipelines; do
    start="$(echo $pipeline | cut -d ':' -f 1)"
    end="$(echo $pipeline | cut -d ':' -f 2)"
    name="$(echo $pipeline | sed -E 's|^[0-9]+:[0-9]+:||')"

    if test "$name" '=' 'branches'; then
        has_branches=yes
        branches_offset=$start
    else
        cat "$DEFINITION_PATH" | tail -n +$start | head -n $(expr $end '-' $start '+' 1)
    fi
done

echo "    branches:"

branches="$(cat "$DEFINITION_PATH" | yaml__get_nested_mappings 'pipelines' 2>/dev/null | yaml__get_nested_mappings 'branches' 2>&1 >/dev/null)"
for branch in $branches; do
    lineno="$(echo $branch | cut -d ':' -f 1)"
    elineno="$(echo $branch | cut -d ':' -f 2)"
    name="$(echo $branch | sed -E 's|^[0-9]+:[0-9]+:||')"

    y_branch="$(echo "$node_branches" | yaml__get_nested_mappings $name 2>/dev/null)"
    ta=$(echo "$y_branch" | tail -n +$(expr $lineno '-' 1) | head -n $(expr $elineno '-' $lineno))

    workflow_branch=no
    printf "checking if '$name' is workflow branch pipeline... " >&2
    for _branch in feat/* bugfix/* hotfix/* release/* master dev; do
        if test "$name" '=' "$_branch"; then
            workflow_branch=yes
            break
        fi
    done
    echo "$workflow_branch" >&2

    if test "$workflow_branch" '!=' 'yes'; then
        cat "$DEFINITION_PATH" | tail -n +$(expr $lineno '+' $branches_offset)
    else
        cat $DEFINITION_PATH | tail -n +$(expr $lineno '+' 2) | head -n 1

        steps="$(echo "$ta" | yaml__get_mapping_keys 2>&1 >/dev/null)"
        echo "$steps" | while IFS= read -r step; do
            step_lineno="$(echo $step | cut -d ':' -f 1)"
            step_elineno="$(echo $step | cut -d ':' -f 2)"
            step_name=

            y_step=$(echo "$ta" | tail -n +$(expr $step_lineno '-' 1) | head -n $(expr $step_elineno '-' $step_lineno))
            #check for `name` property with Gitops prefix
            echo "$y_step" | yaml__get_nested_mappings '- step' 2>&1 >/dev/null | while IFS= read -r prop; do
                prop_lineno="$(echo $prop | cut -d ':' -f 1)"
                prop_elineno="$(echo $prop | cut -d ':' -f 2)"
                prop_name="$(echo $prop | sed -E 's|^[0-9]+:[0-9]+:||')"

                if test "$prop_name" '=' 'name' && test $prop_lineno -lt $step_elineno; then

                    step_name=$(echo "$y_step" \
                        | tail -n +$prop_lineno \
                        | head -n 1 \
                        | sed -E 's|^[ \t]+||' \
                        | sed -E 's|name:[ \t]*||' \
                        | sed -E 's|^['\''"]||' \
                        | sed -E 's|['\''"]$||')

                    printf "checking if '$step_name' is GitOps step... " >&2
                    gitops_step=no

                    prefix="$(echo "$PREFIX" | sed 's|\[|\\[|' | sed 's|\]|\\]|')"
                    if test "$(echo "$step_name" | sed "s|^$prefix||")" '!=' "$step_name"; then
                        gitops_step=yes
                    fi
                    echo "$gitops_step" >&2

                    if test "$gitops_step" '=' 'yes'; then
                        notify "dropping step '$step_name', will be regenerated..."
                    else
                        step_offset=$(expr $branches_offset '+' $lineno '+' $step_lineno)
                        #cat "$DEFINITION_PATH" | tail -n +$step_offset | head -n $(expr $step_elineno '-' $step_lineno + 1)
                        cat $DEFINITION_PATH | tail -n +$(expr $step_offset '+' 2) | head -n $(expr $step_elineno '-' $step_lineno + '1')
                    fi
                fi
            done
        done

        #get indentation of first step
        lineno=$(echo "$steps" | head -n 1 | cut -d ':' -f 1)

        step_offset=$(expr $branches_offset '+' $lineno + 2)
        indent=$(cat "$DEFINITION_PATH" | tail -n +$step_offset | head -n 1 | sed -E 's|[\-]?[ \t]*[A-Za-z_-]+[ \t]*:[ \t]*$||')

        notify "applying GitOps steps for branch pipeline '$name'..."

        release_pipeline | sed "s|^|$indent|"
    fi
done

