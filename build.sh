#!/bin/sh

# cd & check
if ! cd "$(dirname "$0")"; then exit; fi

# check TODO
buildFolder="build";
sourceFolder="src";

# clear 'build' folder
#rm -rf "$buildFolder"; mkdir "$buildFolder"
##rm -rf `ls -Ad "$buildFolder"/{*,.*}`
###rm -rf "$buildFolder"/{..?*,.[!.]*,*}
printf "Clear '${buildFolder}' folder: "
mkdir -p "$buildFolder"
if [ -d "$buildFolder" ]; then
  find "$buildFolder" -mindepth 1 -maxdepth 1 -exec rm -rf {} \;
else
  echo "Error: Can't open '${buildFolder}' directory!"
  exit
fi
echo "done"

# asciidoctor: generate html files in the 'build' folder
attributes="-a toc=left"
#attributes="-a toc=left -a source-highlighter=highlightjs"
resources=" -r asciidoctor-diagram"
echo "Generate HTML files:"
find "$sourceFolder" -type f -name "*.adoc" -not -name "*.inc.adoc" -exec echo "  "{} \; -exec asciidoctor $attributes $resources -D "$buildFolder" {} \;

# sed: add sitemap to html files in 'build' folder
search='<li><a href="#sitemap"><span class="icon"><i class="fa fa-sitemap"><\/i><\/span> Seitenübersicht<\/a><\/li>'
replace='\
  <li><span style="color: #7a2518"><br \/><span class="icon"><i class="fa fa-sitemap"><\/i><\/span> Seitenübersicht - SE I<\/span><\/li>\
  <li><a href="index.html">Einführung<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-01.html">Teil 1 - Grundlagen<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-02.html">Teil 2 - AsciiDoc<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-03.html">Teil 3 - Zusammenarbeit 1<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-04.html">Teil 4 - Zusammenarbeit 2<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-05.html">Teil 5 - Diagramme 1<\/a><\/li>\
  <!--<li><span style="color: #ccc;">Q\&amp;A<\/span><\/li>-->\
  <\/li>\
  <li><span style="color: #7a2518"><br \/><span class="icon"><i class="fa fa-sitemap"><\/i><\/span> Seitenübersicht - SE II<\/span><\/li>\
  <li><a href="praktikumsaufgaben-teil-06.html">Teil 6 - Versionen<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-07.html">Teil 7 - Branches<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-08.html">Teil 8 - Zusammenarbeit 3<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-09.html">Teil 9 - Diagramme 2<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-10.html">Teil 10 - GitHub Actions<\/a><\/li>\
  <!--<li><span style="color: #ccc;">Q\&amp;A<\/span><\/li>-->\
  <\/li>\
'

printf "Replace text: "
if [ $(uname -s) = "Darwin" ]; then
  find "$buildFolder" -type f -name "*.html" -exec sed -i '' "s/${search}/${replace}/g" {} \; #macOS
else
  find "$buildFolder" -type f -name "*.html" -exec sed -i "s/${search}/${replace}/g" {} \; #Linux
fi
echo "done"

# add preview warning
gitBranch=`git rev-parse --abbrev-ref HEAD`
if [ "$gitBranch" = "next" ]; then
  search='<div id="header">'
  replace='<div id="cz_preview_warning" style="position: fixed;padding: 15px;background-color: rgba(255,244,0,.9);right: -130px;top: 15px;z-index: 1000;width: 400px;text-align: center;transform: rotate(35deg);border: 3px dashed #e00;">PREVIEW<br \/><a href="..\/arbeiten-mit-git-und-asciidoc\/" style="font-size: 10px;">Come to the productive side!<\/a><\/div><div id="header">'
  printf "Add preview warning: "
  if [ $(uname -s) = "Darwin" ]; then
    find "$buildFolder" -type f -name "*.html" -exec sed -i '' "s/${search}/${replace}/g" {} \; #macOS
  else
    find "$buildFolder" -type f -name "*.html" -exec sed -i "s/${search}/${replace}/g" {} \; #Linux
  fi
  echo "done"
fi

# copy additionally folders and files to 'build' folder
printf "Copy additionally files: "
find "$sourceFolder" -mindepth 1 -maxdepth 1 -not \( -name "*.adoc" -o -name "*docinfo*" -o -name ".*" -o -name "plantuml" \) -exec cp -r {} "${buildFolder}/" \;
echo "done"

# check options
# deploy
if [ "$1" = "--deploy" -o "$1" = "-d" ]; then
  ./deploy.sh
fi
