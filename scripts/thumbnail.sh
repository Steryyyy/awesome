#!/bin/bash
re='^[0-9]+$'
read -n 3 -p "Chose thumbnail size percentage 1-100:" per
echo ""
if [ -z $per ] || ! [[ $per =~ $re ]] ; then
echo "Its not a number"
	exit
fi;
if  [  $per -lt 1  ] || [ $per -gt 100 ]    ; then
echo "number not in range"
exit
fi;

read -n 3 -p "Chose thumbnail quality 1-100:" qua
if [ -z $qua ] || ! [[ $qua =~ $re ]] ; then
echo "Its not a number"
	exit
fi;

if  [  $qua -lt 1  ] || [ $qua -gt 100 ]    ; then
echo "number not in range"
exit
fi;



# read -n 3 -p "Chose thumbnail quality 1-100" qua
# if [ -z qua ] || [ -z per] || ! [[ "$qua" =~ $re ]]  || ! [[ "$per" =~ $re ]] ; then
# echo "error"
# fi;
#
# echo $per
# echo $qua

echo ""
echo "removing ~/.config/awesome/images/thumbnail"
rm -rf  ~/.config/awesome/images/thumbnail/
mkdir -p $HOME/.config/awesome/config >/dev/null
mkdir -p ~/.config/awesome/images/thumbnail
echo "copying images from ~/wallpaper/* to ~/.config/awesome/images/thumbnail"
cp -r ~/wallpaper/* ~/.config/awesome/images/thumbnail/
files=~/.config/awesome/images/thumbnail
folder(){
	 arr=($@)
for i in "${arr[@]}";
do

([ -d "$i" ] && echo "converting images from $i" &&  folder    $i/*)
[ -f "$i" ] && convert $i -resize "$per%" -quality "$qua" $i
done

}
 folder $files

echo "~/.config/awesome/images/thumbnail structure"
ls ~/.config/awesome/images/thumbnail/*
echo "~/.config/awesome/config/wallpapers.lua changed to"
echo ~/wallpaper/*/* |tr ' ' '\n'  |  sed -e 's/^.*wallpaper\///' -e 's/\/.*//'  | awk ' { tot[$0]++ } END { for (i in tot) print  i" "tot[i] } ' | awk '{ print "{\""$1"\","$2"}," }' |  sed '1i return{' | sed '$s/$/\n}/'| tr -d '\n'   > $HOME/.config/awesome/config/wallpapers.lua
cat ~/.config/awesome/config/wallpapers.lua

