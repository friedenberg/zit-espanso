call_recipe := just_executable() + " --justfile=" + justfile()

build: build-tags build-tags-hidden

_build-query query trigger:
  zit show -format json {{query}} \
    | ./object_to_choice.jq \
    | ./template.jq --arg trigger {{trigger}} \
    | yq -p=json -o=yaml

build-tags:
  {{call_recipe}} _build-query :e :zt > ~/.cache/zit/espanso/tags.yml
  ln -sf "$(realpath ~/.cache/zit/espanso/tags.yml)" ~/.config/espanso/match/zit-tags.yml

build-tags-hidden:
  {{call_recipe}} _build-query ?e :zht > ~/.cache/zit/espanso/tags-hidden.yml
  ln -sf "$(realpath ~/.cache/zit/espanso/tags-hidden.yml)" ~/.config/espanso/match/zit-tags-hidden.yml
