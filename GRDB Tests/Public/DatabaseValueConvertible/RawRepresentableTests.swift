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

enum Color : Int {
    case Red
    case White
    case Rose
}

enum Grape : String {
    case Chardonnay
    case Merlot
    case Riesling
}

extension Color : DatabaseIntRepresentable {
    typealias FetchedType = Color
}
extension Grape : DatabaseStringRepresentable {
    typealias FetchedType = Grape
}

class RawRepresentableTests: GRDBTestCase {
    
    override func setUp() {
        super.setUp()
        
        var migrator = DatabaseMigrator()
        migrator.registerMigration("createPersons") { db in
            try db.execute("CREATE TABLE wines (grape TEXT, color INTEGER)")
        }
        assertNoError {
            try migrator.migrate(dbQueue)
        }
    }
    
    func testColor() {
        assertNoError {
            try dbQueue.inTransaction { db in
                
                do {
                    for color in [Color.Red, Color.White, Color.Rose] {
                        try db.execute("INSERT INTO wines (color) VALUES (?)", arguments: [color])
                    }
                    try db.execute("INSERT INTO wines (color) VALUES (?)", arguments: [4])
                }
                
                do {
                    let rows = Row.fetchAll(db, "SELECT color FROM wines ORDER BY color")
                    let colors = rows.map { $0.value(atIndex: 0) as Color? }
                    XCTAssertEqual(colors[0]!, Color.Red)
                    XCTAssertEqual(colors[1]!, Color.White)
                    XCTAssertEqual(colors[2]!, Color.Rose)
                    XCTAssertTrue(colors[3] == nil)
                }
                
                do {
                    let colors = Color.fetchAll(db, "SELECT color FROM wines ORDER BY color")
                    XCTAssertEqual(colors[0]!, Color.Red)
                    XCTAssertEqual(colors[1]!, Color.White)
                    XCTAssertEqual(colors[2]!, Color.Rose)
                    XCTAssertTrue(colors[3] == nil)
                }
                
                return .Rollback
            }
        }
    }
    
    func testGrape() {
        assertNoError {
            try dbQueue.inTransaction { db in
                
                do {
                    for grape in [Grape.Chardonnay, Grape.Merlot, Grape.Riesling] {
                        try db.execute("INSERT INTO wines (grape) VALUES (?)", arguments: [grape])
                    }
                    try db.execute("INSERT INTO wines (grape) VALUES (?)", arguments: ["Syrah"])
                }
                
                do {
                    let rows = Row.fetchAll(db, "SELECT grape FROM wines ORDER BY grape")
                    let grapes = rows.map { $0.value(atIndex: 0) as Grape? }
                    XCTAssertEqual(grapes[0]!, Grape.Chardonnay)
                    XCTAssertEqual(grapes[1]!, Grape.Merlot)
                    XCTAssertEqual(grapes[2]!, Grape.Riesling)
                    XCTAssertTrue(grapes[3] == nil)
                }
                
                do {
                    let grapes = Grape.fetchAll(db, "SELECT grape FROM wines ORDER BY grape")
                    XCTAssertEqual(grapes[0]!, Grape.Chardonnay)
                    XCTAssertEqual(grapes[1]!, Grape.Merlot)
                    XCTAssertEqual(grapes[2]!, Grape.Riesling)
                    XCTAssertTrue(grapes[3] == nil)
                }
                
                return .Rollback
            }
        }
    }
}
