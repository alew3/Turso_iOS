SRC_DIR="$(pwd)/libsql/libsql-sqlite3"
DST_DIR="$(pwd)/Turso_ios/sqlite"
XCODE_PATH=$(xcode-select --print-path)
SDK_VERSION=$(xcrun --sdk iphoneos --show-sdk-version)



# Build for iOS (arm64)
xcrun --sdk iphoneos clang -arch arm64 -isysroot $(xcrun --sdk iphoneos --show-sdk-path) -dynamiclib ${SRC_DIR}/sqlite3.c -o ${DST_DIR}/libsqlite3_arm64.dylib -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_COLUMN_METADATA -install_name @rpath/libsqlite3_arm64.dylib

# Build for iOS Simulator (arm64)
xcrun --sdk iphonesimulator clang -arch arm64 -isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -dynamiclib ${SRC_DIR}/sqlite3.c -o ${DST_DIR}/libsqlite3_sim_arm64.dylib -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_COLUMN_METADATA -install_name @rpath/libsqlite3_sim_arm64.dylib

# Build for iOS Simulator (x86_64)
xcrun --sdk iphonesimulator clang -arch x86_64 -isysroot $(xcrun --sdk iphonesimulator --show-sdk-path) -dynamiclib ${SRC_DIR}/sqlite3.c -o ${DST_DIR}/libsqlite3_x86_64.dylib -DSQLITE_ENABLE_FTS5 -DSQLITE_ENABLE_JSON1 -DSQLITE_ENABLE_RTREE -DSQLITE_ENABLE_COLUMN_METADATA -install_name @rpath/libsqlite3_x86_64.dylib



# Copy sqlite3.h into XCode Project
cp ${SRC_DIR}/sqlite3.h ${DST_DIR}/sqlite3.h

echo "Source Dir= ${SRC_DIR}"
echo "Destiny Dir= ${DST_DIR}"