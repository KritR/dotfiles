if status is-interactive
    if command -q munch
        munch init fish | source
    end
    
    if command -q zoxide
        zoxide init fish | source
    end

    set fish_greeting ''
    
    function fish_prompt
        string join '' '(' (prompt_pwd) ') λ '
    end

    alias lt='lsd -t -r -1'
end

fish_add_path /opt/homebrew/bin
fish_add_path /opt/homebrew/sbin
fish_add_path ~/.local/bin

