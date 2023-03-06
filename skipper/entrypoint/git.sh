if [ -n "$git_pull" ]; then
    mkdir -p /var/log/git_pull/
    for dir in $(echo $git_pull| tr "," "\n"); do
        cd $dir
        echo "git pull in $dir"
        git pull &> /var/log/git_pull/$(basename $dir) &
    done
fi
