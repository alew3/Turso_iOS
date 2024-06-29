import Dispatch
import Foundation
import SQLite3

enum DatabaseError: Error {
    case statementPreparationFailed(String)
    case executionFailed(String)
}

// example class on how to interact with sqlite from swift
class Database {
    var db_filename: String = "vector.sqlite"

    func executeStatements(_ statements: [String]) {
        for statement in statements {
            executeStatement(statement)
        }
    }

    func getDBPath() -> URL {
        let fileManager = FileManager.default
        let documentsURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentsURL.appendingPathComponent(db_filename)
        return fileURL
    }

    func executeStatement(_ sql: String) {
        autoreleasepool {
            var db: OpaquePointer?
            var sqlStatement: OpaquePointer?
            
            // OpenDB
            if sqlite3_open(getDBPath().path, &db) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error opening database: \(errmsg)")
                return
            }
            
            // Prepare statement
            if sqlite3_prepare_v2(db, sql, -1, &sqlStatement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("Error preparing statement: \(errmsg)")
                sqlite3_close(db)
                return
            }
                 
            // Execute statement
            while sqlite3_step(sqlStatement) == SQLITE_ROW {
                // Processar os resultados
                let columnText = sqlite3_column_text(sqlStatement, 0)
                if let text = columnText {
                    let name = String(cString: text)
                    print("Column Value: \(name)")
                }
            }
            
            // Finalize statement
            if sqlStatement != nil {
                sqlite3_finalize(sqlStatement)
            }
            
            // Close DB
            if db != nil {
                sqlite3_close(db)
            }
        }
    }
    
    func selectFromDatabase(query: String) -> [DatabaseRow]? {
        var db: OpaquePointer?
        var sqlStatement: OpaquePointer?

        var results: [DatabaseRow] = []
        
        // OpenDB
        if sqlite3_open(getDBPath().path, &db) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error opening database: \(errmsg)")
            return nil
        }
        // Prepare Statement
        if sqlite3_prepare_v2(db, query, -1, &sqlStatement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error preparing statement: \(errmsg)")
            sqlite3_close(db)
            return nil
        }
        
        while sqlite3_step(sqlStatement) == SQLITE_ROW {
            var rowData: [String: Any] = [:]
            
            for i in 0..<sqlite3_column_count(sqlStatement) {
                let columnName = String(cString: sqlite3_column_name(sqlStatement, i))
                
                switch sqlite3_column_type(sqlStatement, i) {
                case SQLITE_INTEGER:
                    rowData[columnName] = sqlite3_column_int64(sqlStatement, i)
                case SQLITE_FLOAT:
                    rowData[columnName] = sqlite3_column_double(sqlStatement, i)
                case SQLITE_TEXT:
                    if let cString = sqlite3_column_text(sqlStatement, i) {
                        rowData[columnName] = String(cString: cString)
                    }
                case SQLITE_NULL:
                    rowData[columnName] = NSNull()
                default:
                    print("Unsupported column type")
                }
            }
            
            let databaseRow = DatabaseRow(data: rowData)
            results.append(databaseRow)
        }
        
        sqlite3_finalize(sqlStatement)
        sqlite3_close(db)
        
        print("Returning \(results.count) rows")
        return results
    }

    func executeSelect(query: String) -> [DatabaseRow]? {
        var db: OpaquePointer?
        var queryStatement: OpaquePointer?
        var results: [DatabaseRow] = []
        
        print("Query=\(query)")
        
        // Open the database
        if sqlite3_open(getDBPath().path, &db) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error opening database: \(errmsg)")
            return nil
        }
        
        defer {
            sqlite3_close(db)
        }

        if sqlite3_prepare_v2(db, query, -1, &queryStatement, nil) == SQLITE_OK {
            defer {
                sqlite3_finalize(queryStatement)
            }

            while true {
                let stepResult = sqlite3_step(queryStatement)
                if stepResult == SQLITE_ROW {
                    var row: [String: Any] = [:]
                    let columnCount = sqlite3_column_count(queryStatement)

                    for i in 0..<columnCount {
                        let columnName = String(cString: sqlite3_column_name(queryStatement, i))

                        switch sqlite3_column_type(queryStatement, i) {
                        case SQLITE_INTEGER:
                            row[columnName] = sqlite3_column_int64(queryStatement, i)
                        case SQLITE_FLOAT:
                            row[columnName] = sqlite3_column_double(queryStatement, i)
                        case SQLITE_TEXT:
                            if let cString = sqlite3_column_text(queryStatement, i) {
                                row[columnName] = String(cString: cString)
                            }
                        case SQLITE_BLOB:
                            if let blob = sqlite3_column_blob(queryStatement, i) {
                                let length = sqlite3_column_bytes(queryStatement, i)
                                row[columnName] = Data(bytes: blob, count: Int(length))
                            }
                        case SQLITE_NULL:
                            row[columnName] = NSNull()
                        default:
                            row[columnName] = NSNull()
                        }
                    }
                    results.append(DatabaseRow(data: row))
                } else if stepResult == SQLITE_DONE {
                    break
                } else {
                    let errorMessage = String(cString: sqlite3_errmsg(db))
                    print("Error executing query: \(errorMessage)")
                    return nil
                }
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            print("SELECT statement could not be prepared: \(errorMessage)")
            return nil
        }

        print("Returning \(results.count) rows")
        return results
    }

    func recreateDatabase() {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: getDBPath().path) {
            do {
                try fileManager.removeItem(at: getDBPath())
                print("File deleted successfully")
            } catch {
                print("Could not delete file: \(getDBPath().path) \n \(error)")
                return
            }
        } else {
            print("File does not exist: \(getDBPath().path)")
        }
    }
}
