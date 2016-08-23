./buildnrun.sh &
fswatch -e ".*" -i ".*/[^.]*\\.cr$" -0 src/ | xargs -0 -n1 ./buildnrun.sh
