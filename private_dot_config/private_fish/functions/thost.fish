function thost --description "resolve a shortname to its FQDN on the current tailnet"
    if test (count $argv) -ne 1
        echo "usage: thost <shortname>" >&2
        return 1
    end

    set -l ts /Applications/Tailscale.app/Contents/MacOS/Tailscale
    set -l name $argv[1]

    set -l fqdn ($ts status --json 2>/dev/null | jq -r --arg name "$name" '
        ([.Self] + (.Peer // {} | to_entries | map(.value)))
        | map(.DNSName | rtrimstr("."))
        | map(select(startswith($name + ".")))
        | .[0] // empty
    ')

    if test -z "$fqdn"
        echo "thost: no tailnet host named '$name'" >&2
        return 1
    end

    echo $fqdn
end
