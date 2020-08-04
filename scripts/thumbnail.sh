#!/bin/bash
rm -rf  ~/.config/awesome/images/thumbnail/
cp -r ~/wallpaper/ ~/.config/awesome/images/thumbnail/
files=~/.config/awesome/images/thumbnail

[ -z "$1" ] && echo "empty"  #rm /home/steryyy/colorsheme.txt
 folder(){
	 arr=($@)
for i in "${arr[@]}";
do

([ -d "$i" ] && folder    $i/*)
[ -f "$i" ] && convert $i -resize 300 -quality 60 $i
done

}
[ -z "$1"  ] && folder $files || folder $1

ls ~/.config/awesome/images/thumbnail/*
echo "$HOME/.config/awesome/config/wallpapers.lua changed to"
echo $HOME/wallpaper/*/* |tr ' ' '\n'  |  sed -e 's/^.*wallpaper\///' -e 's/\/.*//'  | awk ' { tot[$0]++ } END { for (i in tot) print  i" "tot[i] } ' | awk '{ print "{\""$1"\","$2"}," }' |  sed '1i return{' | sed '$s/$/\n}/'| tr -d '\n'   > $HOME/.config/awesome/config/wallpapers.lua
cat $HOME/.config/awesome/config/wallpapers.lua

