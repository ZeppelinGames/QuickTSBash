#!/bin/bash
echo "Creating new TypeScript project"

# Adds extension to file (if needed)
# $1 = file name : e.g 'main'
# $2 = extension to add : e.g '.html'
add_extension() {
    ret=$1
    if [[ $1 != *$2 ]]; then
        ret+=$2
    fi
}

# creates new file
# $1 = default file name : e.g. 'index.html'
# $2 = file extension : e.g '.html'
# $3 = pretty print file type : e.g 'HTML'
# $4 = relative path to save to : e.g '/src/'
create_file() {
    newFileName=$1
    read -p "Main $3 filename ($1): " $newFile
    if [ -n "${newFile}" ]; then
        add_extension $newFile $2
        newFileName=$ret
    fi

    cd $4
    touch $newFileName
    cd ..
}

#Create dist and src directories
mkdir -p "dist"
mkdir -p "src" 

#Create HTML file
create_file "index.html" ".html" "HTML" "dist"
htmlFile=$newFileName

#HTML Template
cd "dist"
printf "<!doctype html>
<html lang=\"en\">
<head>
    <meta charset=\"UTF-8\">
    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">

    <title>Title</title>

    <link rel=\"stylesheet\" href=\"/dist/$cssFile\">
<head>

<body>
    <script src=\"/dist/$jsFile\"> </script>
</body>
</html>" > $htmlFile
cd ..

#Create CSS file
create_file "index.css" ".css" "CSS" "dist"
cssFile=$newFileName

#CSS Template
cd "dist"
printf "/*CSS template goes here*/" > $cssFile
cd ..

#Create TS and JS file (for webpack)
create_file "index.ts" ".ts" "Typescript" "src"
tsFile=$newFileName
jsFile="${newFileName%%.*}.js"

#TS Template
cd "src"
printf "//TS template goes here" > $tsFile
cd ..

#Initialise NPM
npm init -y

#Edit package.json to be private and remove main (webpack to manage)
sed -i "s/\"main\": \"index.js\",/\"private\": true,/" "package.json"

#Add webpack build into package.json
sed -i "s/\"scripts\": {/\"scripts\": {\n\"build\": \"webpack\",/" "package.json"

#Install NPM dependancies
npm install typescript --save-dev
npm install webpack webpack-cli --save-dev
npm install lodash --save

#Create webpack config
touch "webpack.config.js"

#Webpack template
printf "const path = require('path');
module.exports = {
  entry: './src/$tsFile',
  output: {
    filename: '${jsFile}',
    path: path.resolve(__dirname, 'dist'),
  },
  mode: 'none'
};" > "webpack.config.js"