# Turso_iOS
This is an XCode sample project to run Turso's SQLite fork with vector search capabilities. 
It was created for this [Medium Post](https://medium.com/@alessandrocauduro/from-frustration-to-innovation-building-ai-powered-vector-search-on-iphone-996b1502f4aa) about running vector search on device.


## How to build libsqlite3 for iOS
If you want to rebuild the [libsqlite3_arm64.dylib](Turso_ios/sqlite/libsqlite3_arm64.dylib) with the latest functionality.

Make sure to have Xcode and command line tools installed
```bash
xcode-select --install
```
Clone the source code of the project. Currently the vector functionality is only available in the beta branch **"vector"** before it becomes GA.

```bash
git clone --branch vector --depth 1 https://github.com/tursodatabase/libsql.git
```

First build SQLite for Mac (needed to generate files for the iOS build)
```bash
cd libsql/libsql-sqlite3 && ./configure && make
```

Build SQLite for iOS
```bash
# go back to project folder and run the build script
cd ../..
./build_ios.sh
```

## Xcode
This sample is already working, but if you want instructions on how to link the dylib, check the original
[Medium Post](https://medium.com/@alessandrocauduro/from-frustration-to-innovation-building-ai-powered-vector-search-on-iphone-996b1502f4aa) 
