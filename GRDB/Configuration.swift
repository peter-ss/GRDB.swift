//
// GRDB.swift
// https://github.com/groue/GRDB.swift
// Copyright (c) 2015 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


/**
Configuration are arguments to the DatabaseQueue initializers.
*/
public struct Configuration {
    
    // MARK: - Utilities
    
    /// A tracing function that logs SQL statements
    public static func logSQL(sql: String, arguments: QueryArguments?) {
        NSLog("GRDB: %@", sql)
        if let arguments = arguments {
            NSLog("GRDB: arguments %@", arguments.description)
        }
    }
    
    // MARK: - Configuration options
    
    /**
    A tracing function.

    - parameter sql: An SQL query
    - parameter arguments: Eventual query arguments.
    */
    public typealias TraceFunction = (sql: String, arguments: QueryArguments?) -> Void
    
    /// If true, the database has support for foreign keys.
    public var foreignKeysEnabled: Bool
    
    /// If true, the database is opened readonly.
    public var readonly: Bool
    
    /**
    An optional tracing function.

    You can use Configuration.logSQL as a tracing function: it logs all SQL
    statements with NSLog().
    */
    public var trace: TraceFunction?
    
    
    // MARK: - Initialization
    
    /**
    Setup a configuration.
    
    You can use Configuration.logSQL as a tracing function: it logs all SQL
    statements with NSLog().
    
    - parameter foreignKeysEnabled: If true (the default), the database has
                                    support for foreign keys.
    - parameter readonly:           If false (the default), the database will be
                                    created and opened for writing. If true, the
                                    database is opened readonly.
    - parameter trace:              An optional tracing function (default nil).
    
    - returns: A Configuration.
    */
    public init(foreignKeysEnabled: Bool = true, readonly: Bool = false, trace: TraceFunction? = nil) {
        self.foreignKeysEnabled = foreignKeysEnabled
        self.readonly = readonly
        self.trace = trace
    }
    
    
    // MARK: - Not public
    
    var sqliteOpenFlags: Int32 {
        // See https://www.sqlite.org/c3ref/open.html
        return readonly ? SQLITE_OPEN_READONLY : (SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE)
    }
}
