#!/usr/bin/env bash

# This script builds the HTML files from the AsciiDoc files
# to the build folder and adds an extra sidemap.

# Sets the src and build folder.
source_folder="src"
build_folder="build"

# Ensures that the script runs from its own folder.
if ! cd "$(dirname "$0")"; then exit; fi

# Checks if Asciidoctor is installed.
if ! command -v asciidoctor &>/dev/null; then
  echo "Error: The asciidoctor command is not installed. Please install it first."
  exit 1
fi

# Checks if the required Asciidoctor libraries are installed.
error=0
for gem_name in "asciidoctor-diagram" "asciidoctor-diagram-plantuml"; do
  if ! gem list -i "$gem_name" &>/dev/null; then
    echo "Error: The $gem_name gem is not installed. Please install it first."
    echo "> gem install $gem_name"
    error=1
  fi
done
if [ $error -ne 0 ]; then exit 1; fi

# Checks the src folder.
if [ ! -d "$source_folder" ]; then
  echo "Error: Source folder '$source_folder' does not exist."
  exit 1
fi

# Cleans or creates the build folder.
printf "Clean '%s' folder: " "$build_folder"
mkdir -p "$build_folder"
if [ -d "$build_folder" ]; then
  find "$build_folder" -mindepth 1 -maxdepth 1 -exec rm -rf {} \;
else
  echo "Error: Build folder '${build_folder}' does not exist or cannot be created."
  exit 1
fi
echo "done"

# Generates the HTML files from the AsciiDoc files
# in the src folder to the build folder.
echo "Generate HTML files:"
attributes="-a toc=left"
required_libs="-r asciidoctor-diagram"
find "$source_folder" -maxdepth 1 -type f -name "*.adoc" -not -name "*.inc.adoc" -exec echo "  "{} \; -exec asciidoctor $attributes $required_libs -D "$build_folder" {} \;
attributes="-a toc=auto"
for special_subfolder in "faq" "installation-und-konfiguration"; do
  find "${source_folder}/${special_subfolder}" -type f -name "*.adoc" -not -name "*.inc.adoc" -exec echo "  "{} \; -exec asciidoctor $attributes $required_libs -D "${build_folder}/${special_subfolder}" {} \;
done
echo "done"

# Adds an extra sitemap to the HTML files in 'build' folder:
search='<li><a href="#sitemap"><span class="icon"><i class="fa fa-sitemap"><\/i><\/span> Seitenübersicht<\/a><\/li>'
replace='\
  <li><span style="color: #7a2518"><br \/><span class="icon"><i class="fa fa-sitemap"><\/i><\/span> Seitenübersicht<\/span><\/li>\
  <li><a href="index.html">Einführung<\/a><\/li>\
  <li><a href="installation-und-konfiguration\/index.html" target="_blank" rel="noopener noreferrer"><span class="icon"><i class="fa fa-sticky-note-o"><\/i><\/span> Installation \&amp; Konfiguration<\/a><\/li>\
  <li><a href="faq\/index.html" target="_blank" rel="noopener noreferrer"><span class="icon"><i class="fa fa-sticky-note-o"><\/i><\/span> FAQ \&amp; Tipps<\/a><\/li>\
  <li><span style="color: #ccc;"><span class="icon"><i class="fa fa-sticky-note-o"><\/i><\/span> Notizen<\/span><\/li>\
  <li><span style="color: #7a2518"><br \/><span class="icon"><i class="fa fa-sitemap"><\/i><\/span> Praktika - SE I<\/span><\/li>\
  <li><a href="praktikumsaufgaben-teil-01.html">Teil 1 - Grundlagen<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-02.html">Teil 2 - AsciiDoc<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-03.html">Teil 3 - Teamarbeit: Merge-Konflikte<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-04.html">Teil 4 - Teamarbeit: Issues<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-05.html">Teil 5 - Teamarbeit: Projektplanung<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-06.html">Teil 6 - Diagramme 1<\/a><\/li>\
  <\/li>\
  <li><span style="color: #7a2518"><br \/><span class="icon"><i class="fa fa-sitemap"><\/i><\/span> Praktika - SE II<\/span><\/li>\
  <li><a href="praktikumsaufgaben-teil-07.html">Teil 7 - Git: Versionen<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-08.html">Teil 8 - Git: Branches<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-09.html">Teil 9 - Teamarbeit: Code-Review<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-10.html">Teil 10 - Diagramme 2<\/a><\/li>\
  <li><a href="praktikumsaufgaben-teil-11.html">Teil 11 - GitHub Actions<\/a><\/li>\
  <\/li>\
'
printf "Add extra sidemap: "
if [ "$(uname -s)" = "Darwin" ]; then
  find "$build_folder" -type f -name "*.html" -exec sed -i '' "s/${search}/${replace}/g" {} \; #macOS
else
  find "$build_folder" -type f -name "*.html" -exec sed -i "s/${search}/${replace}/g" {} \; #Linux
fi
echo "done"

# Adds a preview warning if in 'next' branch.
git_branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$git_branch" = "next" ]; then
  search='<div id="header">'
  replace='<div id="cz_preview_warning" style="position: fixed;padding: 15px;background-color: rgba(255,244,0,.9);right: -130px;top: 15px;z-index: 1000;width: 400px;text-align: center;transform: rotate(35deg);border: 3px dashed #e00;">PREVIEW<br \/><a href="..\/arbeiten-mit-git-und-asciidoc\/" style="font-size: 10px;">Come to the productive side!<\/a><\/div><div id="header">'
  printf "Add preview warning: "
  if [ "$(uname -s)" = "Darwin" ]; then
    find "$build_folder" -type f -name "*.html" -exec sed -i '' "s/${search}/${replace}/g" {} \; #macOS
  else
    find "$build_folder" -type f -name "*.html" -exec sed -i "s/${search}/${replace}/g" {} \; #Linux
  fi
  echo "done"
fi

# Copies additional folders and files to the build folder.
printf "Copy additional files: "
find "$source_folder" -mindepth 1 -maxdepth 1 -not \( -name "*.adoc" -o -name "*docinfo*" -o -name ".*" -o -name "plantuml" -o -name "faq" -o -name "installation-und-konfiguration" \) -exec cp -r {} "${build_folder}/" \;
find "${source_folder}/faq" -mindepth 1 -maxdepth 1 -not \( -name "*.adoc" -o -name "*docinfo*" -o -name ".*" -o -name "plantuml" \) -exec cp -r {} "${build_folder}/faq/" \;
find "${source_folder}/installation-und-konfiguration" -mindepth 1 -maxdepth 1 -not \( -name "*.adoc" -o -name "*docinfo*" -o -name ".*" -o -name "plantuml" \) -exec cp -r {} "${build_folder}/installation-und-konfiguration/" \;
echo "done"

# Runs the deploy script if needed.
if [ "$1" = "--deploy" ]; then
  ./deploy.sh
fi
