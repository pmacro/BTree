//
//  BTreePathTests.swift
//  BTree
//
//  Created by Károly Lőrentey on 2016-02-26.
//  Copyright © 2016 Károly Lőrentey. All rights reserved.
//

import XCTest
@testable import BTree


class PathTests<Path: BTreePath  where Path.Key == Int, Path.Payload == String> {
    typealias Tree = BTree<Int, String>
    typealias Node = BTreeNode<Int, String>

    func testInitStartOf() {
        let node = maximalNode(depth: 3, order: 3)
        let path = Path(startOf: node)
        XCTAssertTrue(path.isValid)
        XCTAssertTrue(path.isAtStart)
        XCTAssertFalse(path.isAtEnd)
        XCTAssertEqual(path.offset, 0)
        XCTAssertEqual(path.key, 0)
        XCTAssertEqual(path.payload, "0")
    }

    func testInitEndOf() {
        let node = maximalNode(depth: 3, order: 3)
        let path = Path(endOf: node)
        XCTAssertTrue(path.isValid)
        XCTAssertFalse(path.isAtStart)
        XCTAssertTrue(path.isAtEnd)
        XCTAssertEqual(path.offset, node.count)
    }

    func withClone(tree: Tree, @noescape body: Node->Node) {
        let node = tree.root.clone()
        withExtendedLifetime(node) {
            let result = body(node)
            assertEqualElements(result, tree)
        }
    }

    func testInitOffset() {
        let tree = maximalTree(depth: 3, order: 3)
        let c = tree.count
        for i in 0 ..< c {
            withClone(tree) { node in
                var path = Path(root: node, offset: i)
                XCTAssertTrue(path.isValid)
                XCTAssertEqual(path.offset, i)
                XCTAssertEqual(path.key, i)
                XCTAssertEqual(path.payload, String(i))
                return path.finish()
            }
        }
        withClone(tree) { node in
            var path = Path(root: node, offset: c)
            XCTAssertEqual(path.offset, c)
            XCTAssertTrue(path.isAtEnd)
            return path.finish()
        }
    }

    func testInitKeyFirst() {
        let c = 26
        let tree = Tree(sortedElements: (0 ... 2 * c + 1).map { ($0 & ~1, String($0)) }, order: 3)
        for i in 0 ... c {
            withClone(tree) { node in
                var path = Path(root: node, key: 2 * i, choosing: .First)
                XCTAssertTrue(path.isValid)
                XCTAssertEqual(path.offset, 2 * i)
                XCTAssertEqual(path.key, 2 * i)
                XCTAssertEqual(path.payload, String(2 * i))
                return path.finish()
            }
        }
        for i in 0 ..< c {
            withClone(tree) { node in
                var path = Path(root: node, key: 2 * i + 1, choosing: .First)
                XCTAssertTrue(path.isValid)
                XCTAssertEqual(path.offset, 2 * i + 2)
                XCTAssertEqual(path.key, 2 * i + 2)
                XCTAssertEqual(path.payload, String(2 * i + 2))
                return path.finish()
            }
        }
    }

    func testInitKeyLast() {
        let c = 26
        let tree = Tree(sortedElements: (0 ... 2 * c + 1).map { ($0 & ~1, String($0)) }, order: 3)
        for i in 0 ... c {
            withClone(tree) { node in
                var path = Path(root: node, key: 2 * i, choosing: .Last)
                XCTAssertTrue(path.isValid)
                XCTAssertEqual(path.offset, 2 * i + 1)
                XCTAssertEqual(path.key, 2 * i)
                XCTAssertEqual(path.payload, String(2 * i + 1))
                return path.finish()
            }
        }
        for i in 0 ..< c {
            withClone(tree) { node in
                var path = Path(root: node, key: 2 * i + 1, choosing: .Last)
                XCTAssertTrue(path.isValid)
                XCTAssertEqual(path.offset, 2 * i + 2)
                XCTAssertEqual(path.key, 2 * i + 2)
                XCTAssertEqual(path.payload, String(2 * i + 2))
                return path.finish()
            }
        }
    }

    func testInitKeyAfter() {
        let c = 26
        let tree = Tree(sortedElements: (0 ... 2 * c + 1).map { ($0 & ~1, String($0)) }, order: 3)
        for i in 0 ..< c {
            withClone(tree) { node in
                var path = Path(root: node, key: 2 * i, choosing: .After)
                XCTAssertTrue(path.isValid)
                XCTAssertEqual(path.offset, 2 * i + 2)
                XCTAssertEqual(path.key, 2 * i + 2)
                XCTAssertEqual(path.payload, String(2 * i + 2))
                return path.finish()
            }
        }

        for i in 0 ..< c {
            withClone(tree) { node in
                var path = Path(root: node, key: 2 * i + 1, choosing: .After)
                XCTAssertTrue(path.isValid)
                XCTAssertEqual(path.offset, 2 * i + 2)
                XCTAssertEqual(path.key, 2 * i + 2)
                XCTAssertEqual(path.payload, String(2 * i + 2))
                return path.finish()
            }
        }
    }

    func testInitKeyAny() {
        let c = 26
        let tree = Tree(sortedElements: (0 ... 2 * c + 1).map { ($0 & ~1, String($0)) }, order: 3)
        for i in 0 ... c {
            withClone(tree) { node in
                var path = Path(root: node, key: 2 * i, choosing: .Any)
                XCTAssertTrue(path.isValid)
                XCTAssertGreaterThanOrEqual(path.offset, 2 * i)
                XCTAssertLessThanOrEqual(path.offset, 2 * i + 1)
                XCTAssertEqual(path.key, 2 * i)
                XCTAssertTrue(path.payload == String(2 * i + 1) || path.payload == String(2 * i))
                return path.finish()
            }
        }
        for i in 0 ..< c {
            withClone(tree) { node in
                var path = Path(root: node, key: 2 * i + 1, choosing: .Any)
                XCTAssertTrue(path.isValid)
                XCTAssertEqual(path.offset, 2 * i + 2)
                XCTAssertEqual(path.key, 2 * i + 2)
                XCTAssertEqual(path.payload, String(2 * i + 2))
                return path.finish()
            }
        }
    }

    func testMoveForward() {
        let tree = maximalTree(depth: 3, order: 3)
        let c = tree.count
        withClone(tree) { node in
            var path = Path(startOf: node)
            var i = 0
            while !path.isAtEnd {
                XCTAssertTrue(path.isValid)
                XCTAssertEqual(path.offset, i)
                XCTAssertEqual(path.key, i)
                XCTAssertEqual(path.payload, String(i))
                path.moveForward()
                i += 1
            }
            XCTAssertEqual(i, c)
            XCTAssertTrue(path.isAtEnd)
            XCTAssertEqual(path.offset, c)
            return path.finish()
        }
    }

    func testMoveBackward() {
        let tree = maximalTree(depth: 3, order: 3)
        let c = tree.count
        withClone(tree) { node in
            var path = Path(endOf: node)
            var i = c
            while !path.isAtStart {
                path.moveBackward()
                i -= 1
                XCTAssertTrue(path.isValid)
                XCTAssertEqual(path.offset, i)
                XCTAssertEqual(path.key, i)
                XCTAssertEqual(path.payload, String(i))
            }
            XCTAssertEqual(i, 0)
            XCTAssertTrue(path.isAtStart)
            XCTAssertEqual(path.offset, 0)
            return path.finish()
        }
    }

    func testMoveToStart() {
        let tree = maximalTree(depth: 3, order: 3)
        withClone(tree) { node in
            var path = Path(endOf: node)
            path.moveToStart()
            XCTAssertTrue(path.isAtStart)
            XCTAssertEqual(path.offset, 0)
            XCTAssertEqual(path.key, 0)
            XCTAssertEqual(path.payload, "0")
            return path.finish()
        }
    }

    func testMoveToEnd() {
        let tree = maximalTree(depth: 3, order: 3)
        let c = tree.count
        withClone(tree) { node in
            var path = Path(startOf: node)
            path.moveToEnd()
            XCTAssertTrue(path.isAtEnd)
            XCTAssertEqual(path.offset, c)
            return path.finish()
        }
    }

    func testMoveToOffset() {
        let tree = maximalTree(depth: 3, order: 3)
        let c = tree.count
        withClone(tree) { node in
            var path = Path(endOf: node)
            var i = 0
            var j = c
            while i < j {
                path.move(toOffset: i)
                XCTAssertEqual(path.offset, i)
                XCTAssertEqual(path.key, i)
                i += 1

                j -= 1
                path.move(toOffset: j)
                XCTAssertEqual(path.offset, j)
                XCTAssertEqual(path.key, j)
            }
            path.move(toOffset: c)
            XCTAssertTrue(path.isAtEnd)
            XCTAssertEqual(path.offset, c)
            return path.finish()
        }
    }

    func testMoveToKeyFirst() {
        let c = 30
        let tree = Tree(sortedElements: (0 ... 2 * c + 1).map { ($0 & ~1, String($0)) }, order: 3)
        withClone(tree) { node in
            var path = Path(endOf: node)
            for i in 0...c {
                path.move(to: 2 * i, choosing: .First)
                XCTAssertEqual(path.offset, 2 * i)
                XCTAssertEqual(path.key, 2 * i)

                let j = c - i
                path.move(to: 2 * j + 1, choosing: .First)
                XCTAssertEqual(path.offset, 2 * j + 2)
                if i > 0 {
                    XCTAssertEqual(path.key, 2 * j + 2)
                }
                else {
                    XCTAssertTrue(path.isAtEnd)
                }
            }
            return path.finish()
        }
    }

    func testMoveToKeyLast() {
        let c = 26
        let tree = Tree(sortedElements: (0 ... 2 * c + 1).map { ($0 & ~1, String($0)) }, order: 3)
        withClone(tree) { node in
            var path = Path(endOf: node)
            for i in 0...c {
                path.move(to: 2 * i, choosing: .Last)
                XCTAssertEqual(path.offset, 2 * i + 1)
                XCTAssertEqual(path.key, 2 * i)

                let j = c - i
                path.move(to: 2 * j + 1, choosing: .Last)
                XCTAssertEqual(path.offset, 2 * j + 2)
                if i > 0 {
                    XCTAssertEqual(path.key, 2 * j + 2)
                }
                else {
                    XCTAssertTrue(path.isAtEnd)
                }
            }
            return path.finish()
        }
    }

    func testMoveToKeyAfter() {
        let c = 26
        let tree = Tree(sortedElements: (0 ... 2 * c + 1).map { ($0 & ~1, String($0)) }, order: 3)
        withClone(tree) { node in
            var path = Path(endOf: node)
            for i in 0...c {
                path.move(to: 2 * i, choosing: .After)
                XCTAssertEqual(path.offset, 2 * i + 2)
                if i < c {
                    XCTAssertEqual(path.key, 2 * i + 2)
                }
                else {
                    XCTAssertTrue(path.isAtEnd)
                }

                let j = c - i
                path.move(to: 2 * j + 1, choosing: .After)
                XCTAssertEqual(path.offset, 2 * j + 2)
                if i > 0 {
                    XCTAssertEqual(path.key, 2 * j + 2)
                }
                else {
                    XCTAssertTrue(path.isAtEnd)
                }
            }
            return path.finish()
        }
    }

    func testMoveToKeyAny() {
        let c = 26
        let tree = Tree(sortedElements: (0 ... 2 * c + 1).map { ($0 & ~1, String($0)) }, order: 3)
        withClone(tree) { node in
            var path = Path(endOf: node)
            for i in 0...c {
                path.move(to: 2 * i, choosing: .Any)
                XCTAssertGreaterThanOrEqual(path.offset, 2 * i)
                XCTAssertLessThanOrEqual(path.offset, 2 * i + 1)
                XCTAssertEqual(path.key, 2 * i)

                let j = c - i
                path.move(to: 2 * j + 1, choosing: .Any)
                XCTAssertEqual(path.offset, 2 * j + 2)
                if i > 0 {
                    XCTAssertEqual(path.key, 2 * j + 2)
                }
                else {
                    XCTAssertTrue(path.isAtEnd)
                }
            }
            return path.finish()
        }
    }

    func testSplit() {
        let tree = maximalTree(depth: 3, order: 3)
        let c = tree.count
        withClone(tree) { node in
            var path = Path(startOf: node)
            for i in 0 ..< c {
                XCTAssertEqual(path.offset, i)
                let (prefix, separator, suffix) = path.split()

                prefix.assertValid()
                assertEqualElements(prefix, (0..<i).map { ($0, String($0)) })

                XCTAssertEqual(separator.0, i)
                XCTAssertEqual(separator.1, String(i))

                suffix.assertValid()
                assertEqualElements(suffix, (i + 1 ..< c).map { ($0, String($0)) })

                path.moveForward()
            }
            return path.finish()
        }
    }

    func testPrefix() {
        let tree = maximalTree(depth: 3, order: 3)
        let c = tree.count
        withClone(tree) { node in
            var path = Path(startOf: node)
            for i in 0 ..< c {
                XCTAssertEqual(path.offset, i)

                let prefix = path.prefix()
                prefix.assertValid()
                assertEqualElements(prefix, (0..<i).map { ($0, String($0)) })

                path.moveForward()
            }
            return path.finish()
        }
    }

    func testSuffix() {
        let tree = maximalTree(depth: 3, order: 3)
        let c = tree.count
        withClone(tree) { node in
            var path = Path(startOf: node)
            for i in 0 ..< c {
                XCTAssertEqual(path.offset, i)

                let suffix = path.suffix()
                suffix.assertValid()
                assertEqualElements(suffix, (i + 1 ..< c).map { ($0, String($0)) })

                path.moveForward()
            }
            return path.finish()
        }
    }

    func testForEach() {
        let tree = maximalTree(depth: 3, order: 3)
        withClone(tree) { node in
            var path = Path(startOf: node)
            var p: [(Node, Int)] = []
            path.forEach(ascending: false) { node, slot in
                if !p.isEmpty {
                    let (n, s) = p.last!
                    XCTAssertTrue(n.children[s] === node)
                }
                XCTAssertEqual(slot, 0)
                p.append(node, slot)
            }
            XCTAssertTrue(p.last!.0.isLeaf)

            path.forEach(ascending: true) { node, slot in
                let (n, s) = p.removeLast()
                XCTAssertTrue(node === n)
                XCTAssertEqual(slot, s)
            }

            return path.finish()
        }
    }

    func testForEachSlot() {
        let tree = maximalTree(depth: 3, order: 3)
        withClone(tree) { node in
            var path = Path(startOf: node)
            path.forEachSlot(ascending: false) { slot in
                XCTAssertEqual(slot, 0)
            }
            path.forEachSlot(ascending: true) { slot in
                XCTAssertEqual(slot, 0)
            }

            return path.finish()
        }
    }

    var testCases: [(String, Void -> Void)] {
        return [
            ("testInitStartOf", testInitStartOf),
            ("testInitEndOf", testInitEndOf),
            ("testInitOffset", testInitOffset),
            ("testInitKeyFirst", testInitKeyFirst),
            ("testInitKeyLast", testInitKeyLast),
            ("testInitKeyAfter", testInitKeyAfter),
            ("testInitKeyAny", testInitKeyAny),
            ("testMoveForward", testMoveForward),
            ("testMoveBackward", testMoveBackward),
            ("testMoveToStart", testMoveToStart),
            ("testMoveToEnd", testMoveToEnd),
            ("testMoveToOffset", testMoveToOffset),
            ("testMoveToKeyFirst", testMoveToKeyFirst),
            ("testMoveToKeyLast", testMoveToKeyLast),
            ("testMoveToKeyAfter", testMoveToKeyAfter),
            ("testMoveToKeyAny", testMoveToKeyAny),
            ("testSplit", testSplit),
            ("testPrefix", testPrefix),
            ("testSuffix", testSuffix),
            ("testForEach", testForEach),
            ("testForEachSlot", testForEachSlot),
        ]
    }

}



class BTreePathTests: XCTestCase {
    /// Poor man's generic test runner
    func runTests<Path: BTreePath where Path.Key == Int, Path.Payload == String>(tests: PathTests<Path>) {
        for (name, testCase) in tests.testCases {
            print("  \(name)")
            testCase()
        }
    }

    func testStrongPaths() {
        let strongTests = PathTests<BTreeStrongPath<Int, String>>()
        runTests(strongTests)
    }

    func testWeakPaths() {
        let weakTests = PathTests<BTreeWeakPath<Int, String>>()
        runTests(weakTests)
    }

    func testCursorPaths() {
        let cursorTests = PathTests<BTreeCursorPath<Int, String>>()
        runTests(cursorTests)
    }
}
