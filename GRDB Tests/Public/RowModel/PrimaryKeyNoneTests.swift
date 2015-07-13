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


import XCTest
import GRDB

// Item has no primary key.
class Item: RowModel {
    var name: String?
    
    override class var databaseTable: Table? {
        return Table(named: "items")
    }
    
    override var storedDatabaseDictionary: [String: DatabaseValueConvertible?] {
        return ["name": name]
    }
    
    override func setDatabaseValue(dbv: DatabaseValue, forColumn column: String) {
        switch column {
        case "name":    name = dbv.value()
        default:        super.setDatabaseValue(dbv, forColumn: column)
        }
    }
    
    static func setupInDatabase(db: Database) throws {
        try db.execute(
            "CREATE TABLE items (" +
                "name NOT NULL" +
            ")")
    }
}

class PrimaryKeyNoneTests: RowModelTestCase {

    func testInsert() {
        // Models with None primary key should be able to be inserted.
        
        assertNoError {
            let item = Item()
            item.name = "foo"
            
            try dbQueue.inTransaction { db in
                // The tested method
                try item.insert(db)
                
                return .Commit
            }
            
            // After insertion, model should be present in the database
            dbQueue.inDatabase { db in
                let items = db.fetchAll(Item.self, "SELECT * FROM items ORDER BY name")
                XCTAssertEqual(items.count, 1)
                XCTAssertEqual(items.first!.name!, "foo")
            }
        }
    }
    
    func testInsertTwice() {
        // Models with None primary key should be able to be inserted.
        //
        // The second insertion simply inserts a second row.
        
        assertNoError {
            let item = Item()
            item.name = "foo"
            
            try dbQueue.inTransaction { db in
                // The tested method
                try item.insert(db)
                try item.insert(db)
                
                return .Commit
            }
            
            // After insertion, model should be present in the database
            dbQueue.inDatabase { db in
                let items = db.fetchAll(Item.self, "SELECT * FROM items ORDER BY name")
                XCTAssertEqual(items.count, 2)
                XCTAssertEqual(items.first!.name!, "foo")
                XCTAssertEqual(items.last!.name!, "foo")
            }
        }
    }
    
    func testSave() {
        assertNoError {
            let item = Item()
            item.name = "foo"
            
            try dbQueue.inTransaction { db in
                try item.save(db)       // insert
                let itemCount = db.fetchOne(Int.self, "SELECT COUNT(*) FROM items")!
                XCTAssertEqual(itemCount, 1)
                return .Commit
            }
            
            try dbQueue.inTransaction { db in
                try item.save(db)       // insert
                let itemCount = db.fetchOne(Int.self, "SELECT COUNT(*) FROM items")!
                XCTAssertEqual(itemCount, 2)
                return .Commit
            }
        }
    }
    
    func testSelectWithKey() {
        assertNoError {
            try dbQueue.inDatabase { db in
                var item = Item()
                item.name = "foo"
                try item.insert(db)
                
                item = db.fetchOne(Item.self, key: ["name": "foo"])!
                XCTAssertEqual(item.name!, "foo")
            }
        }
    }
}