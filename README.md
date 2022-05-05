Original Repository: https://github.com/holmari/repostats

#To update UI
cd gerrit-stats
./gradlew assemble //to install library and npm package
cd GerritStats
npm run webpack-watch // watch changes in reactjs
change your code in src/main/frontend
push your code to repository and the rest will be taken by Jenkins :)) well done.
