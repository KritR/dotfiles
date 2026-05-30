function tssh --description "ssh to a host on the currently-connected tailnet"
    if test (count $argv) -eq 0
        echo "usage: tssh <host> [ssh-args...]" >&2
        return 1
    end

    set -l ts /Applications/Tailscale.app/Contents/MacOS/Tailscale
    set -l suffix ($ts status --json 2>/dev/null | jq -r '.CurrentTailnet.MagicDNSSuffix // empty')

    if test -z "$suffix"
        echo "tssh: no active tailnet (is Tailscale running?)" >&2
        return 1
    end

    set -l host $argv[1]
    set -l rest $argv[2..-1]

    # If the user already typed a FQDN (contains a dot), leave it alone.
    if string match -q '*.*' -- $host
        ssh $host $rest
    else
        ssh $host.$suffix $rest
    end
end
