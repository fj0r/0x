export def 'cp qng' [] {
    for i in [or openresty] {
        cp ~/world/qngx/main.js ([$i 'config' 'qng.js'] | path join)
        cp ~/world/qngx/config.json ([$i 'config' 'qng.example.json'] | path join)
    }
}

export def gen [] {
    const wd = path self .
    cd $wd
    let g = $env.generate
    let paths = ls
    | where type == dir
    | get name
    generate $paths $g
}

export def generate [
    paths
    ctx: record
] {
    let oldpwd = $env.PWD
    for x in $paths {
        cd ([$oldpwd $x] | path join)
        let bs = ls *Dockerfile | get name
        | each {|i|
            let file = $"($x)/($i)"
            if $file in $ctx.exclude { return }
            let tag = $i | path parse
            let tag = if ($tag.extension | is-empty) {
                $x
            } else {
                $"($x)-($tag.stem)"
            }
            let w = {
              context: $x
              file: $file
              push: "${{ github.event_name != 'pull_request' }}"
              tags: $"${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:($tag)"
              labels: "${{ steps.meta.outputs.labels }}"
            }
            | merge deep ($ctx.repo | get -i $x | get -i $i | default {})
            {
                name: $"Build ($x)"
                if: $"steps.changes.outputs.($x) == 'true' || github.event.name == 'workflow_dispatch'"
                uses: "docker/build-push-action@v4"
                with: $w
            }
        }

        let pf = [ $"($x)/**" ] | to yaml

        {
          name: $"build ($x)"
          on: {
            push: {
              branches: [main]
            }
            workflow_dispatch: {
              inputs: {}
            }
          }
          env: {
            REGISTRY: $ctx.registry
            IMAGE_NAME: $"($ctx.user)/($ctx.image)"
          }
          jobs: {
            build: {
              runs-on: ubuntu-latest
              if: "${{ !endsWith(github.event.head_commit.message, '~') }}"
              permissions: {
                contents: read
                packages: write
              }
              steps: [
                {
                  name: "Checkout repository",
                  uses: "actions/checkout@v3"
                }
                {
                  name: "Log into registry ${{ env.REGISTRY }}"
                  if: "github.event_name != 'pull_request'"
                  uses: "docker/login-action@v2",
                  with: {
                    registry: "${{ env.REGISTRY }}",
                    username: $ctx.user,
                    password: $"${{ ($ctx.token_ref) }}"
                  }
                }
                {
                  name: "Extract Docker metadata"
                  id: meta
                  uses: "docker/metadata-action@v4"
                  with: {
                    images: "${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}"
                  }
                }
                {
                  uses: "dorny/paths-filter@v3"
                  id: changes
                  with: {
                    filters: $pf
                  }
                }
                ...$bs
              ]
            }
          }
        }
        | to yaml
        | save -f $"($oldpwd)/.github/workflows/($x).yaml"
    }
}

export def list [] {
    let paths = ls | where type == dir | get name
    for i in $paths {
        print $"($env.REGISTRY)/($env.IMAGE_NAME):($i)"
    }
}

export def git-hooks [act ctx] {
    return
    if $act == 'pre-commit' and $ctx.branch == 'main' {
        print $'(ansi grey)generate github actions workflow(ansi reset)'
        gen
        git add .
    }
}

export def main [] {
    gen
}
