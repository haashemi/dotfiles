function pacu
    set -l cmd $argv[1]

    switch $cmd
        case "modified" "etc"
            __pacu_modified
        case "cleanup" "orphans"
            __pacu_cleanup
        case "size"
            __pacu_size
        case "*"
            echo "Unknown option: $cmd"
            __pacu_help
            return 1
    end
end

function __pacu_modified
    set -l exclude_packages "filesystem" "linux"
    set -l exclude_files "/etc/locale.gen"

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case '--exclude-package'
                set -a exclude_packages $argv[(math $i + 1)]
                set i (math $i + 2)
                continue
            case '--exclude-file'
                set -a exclude_files $argv[(math $i + 1)]
                set i (math $i + 2)
                continue
        end
        set i (math $i + 1)
    end

    echo -e "╔═══════════════════════════════════════╗"
    echo -e "║  📝 Modified Configuration Files      ║"
    echo -e "╚═══════════════════════════════════════╝"

    set -l current_pkg ""
    set -l current_files

    pacman -Qii | awk '/\[modified\]/ {print $(NF - 1)}' | while read filepath
        if contains $filepath $exclude_files
            continue
        end

        set -l pkgname (pacman -Qo "$filepath" 2>/dev/null | awk '{print $(NF - 1)}')

        if contains $pkgname $exclude_packages
            continue
        end

        if test "$pkgname" != "$current_pkg"
            if test -n "$current_pkg"
                echo -e "\033[1;36m→ $current_pkg\033[0m"
                printf "  \033[0;33m• %s\033[0m\n" $current_files
            end
            set current_pkg $pkgname
            set current_files $filepath
        else
            set -a current_files $filepath
        end
    end

    if test -n "$current_pkg"
        echo -e "\033[1;36m→ $current_pkg\033[0m"
        printf "  \033[0;33m• %s\033[0m\n" $current_files
    end
end

function __pacu_cleanup
    set -l orphans (pacman -Qtdq)
    if test -z "$orphans"
        echo "No orphaned packages found."
        return 0
    end
    echo $orphans | sudo pacman -Rns -
end

function __pacu_help
    echo "pacman_utils [command]"
    echo ""
    echo "Commands:"
    echo "  modified    List modified configuration files"
    echo "  cleanup     Remove orphaned packages"
    echo "  help        Show this help message"
end

complete -c pacman_utils -f -n "__fish_use_subcommand_from_list modified cleanup search info size updates help"
