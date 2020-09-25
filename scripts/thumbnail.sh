#!/bin/bash
echo "removing ~/.config/awesome/images/thumbnail"
rm -rf  ~/.config/awesome/images/thumbnail/
mkdir -p ~/.config/awesome/images/thumbnail
echo "copying images from ~/wallpaper/* to ~/.config/awesome/images/thumbnail"
cp -r ~/wallpaper/* ~/.config/awesome/images/thumbnail/
files=~/.config/awesome/images/thumbnail
folder(){
	 arr=($@)
for i in "${arr[@]}";
do

([ -d "$i" ] && echo "converting images from $i" &&  folder    $i/*)
[ -f "$i" ] && convert $i -resize 300 -quality 60 $i
done

}
 folder $files

echo "~/.config/awesome/images/thumbnail structure"
ls ~/.config/awesome/images/thumbnail/*
echo "~/.config/awesome/config/wallpapers.lua changed to"
echo ~/wallpaper/*/* |tr ' ' '\n'  |  sed -e 's/^.*wallpaper\///' -e 's/\/.*//'  | awk ' { tot[$0]++ } END { for (i in tot) print  i" "tot[i] } ' | awk '{ print "{\""$1"\","$2"}," }' |  sed '1i return{' | sed '$s/$/\n}/'| tr -d '\n'   > $HOME/.config/awesome/config/wallpapers.lua
cat ~/.config/awesome/config/wallpapers.lua

