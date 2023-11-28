//
//  BiCalculatorTests.swift
//  BiCalculatorTests
//
//  Created by jay on 2023/11/25.
//

import XCTest
@testable import BiCalculator

final class BiCalculatorTests: XCTestCase {

  let state00 = CalculatorState.leftOpRight(left: "123", op: .divide, right: "0")

  let stateLeft = CalculatorState.left("0.32")

  // LO for leftOp
  let stateLO0 = CalculatorState.leftOp(left: "0.32", op: .multiply)
  let stateLO1 = CalculatorState.leftOp(left: "0", op: .divide)

  // LOR for leftOpRight
  let stateLOR0 = CalculatorState.leftOpRight(left: "0.32", op: .multiply, right: "100")
  let stateLOR1 = CalculatorState.leftOpRight(left: "0.32", op: .divide, right: "0.1")

  let stateError = CalculatorState.error

  let itemDigit0 = CalculatorItem.digit(5)
  let itemDigit1 = CalculatorItem.digit(0)
  let itemCommandClear = CalculatorItem.command(.clear)
  let itemCommandNegate = CalculatorItem.command(.negate)
  let itemCommandPercent = CalculatorItem.command(.percent)
  let itemOpPlus = CalculatorItem.op(.plus)
  let itemOpEqual = CalculatorItem.op(.equal)

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.

  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testErrorResult() throws {
    // [123 ÷ 0] + [=] --> error
    let res0 = state00.apply(item: itemOpEqual)
    XCTAssertEqual(res0, stateError)

    // [123 ÷ 0] + [+] --> error
    let res1 = state00.apply(item: itemOpPlus)
    XCTAssertEqual(res1, stateError)

    // [0 ÷] + [=] --> error
    let res3 = stateLO1.apply(item: itemOpEqual)
    XCTAssertEqual(res3, stateError)
  }

  func testCalculatorStateTransferLeft() throws {

    // [0.32] + `5` --> [left-"0.325"]
    let res0 = stateLeft.apply(item: itemDigit0)
    XCTAssertEqual(res0, CalculatorState.left("0.325"))

    // [0.32] + `AC` --> [left-"0"]
    let res1 = stateLeft.apply(item: itemCommandClear)
    XCTAssertEqual(res1, CalculatorState.left("0"))

    // [0.32] + `±` --> [left-"-0.32"]
    let res2 = stateLeft.apply(item: itemCommandNegate)
    XCTAssertEqual(res2, CalculatorState.left("-0.32"))

    // [0.32] + `%` --> [left-"0.0032"]
    let res3 = stateLeft.apply(item: itemCommandPercent)
    XCTAssertEqual(res3, CalculatorState.left("0.0032"))

    // [0.32] + `+` --> [leftOp-"0.32",+]
    let res4 = stateLeft.apply(item: itemOpPlus)
    XCTAssertEqual(res4, CalculatorState.leftOp(left: "0.32", op: .plus))

    // [0.32] + `=` --> [left-"0.32"]
    let res5 = stateLeft.apply(item: itemOpEqual)
    XCTAssertEqual(res5, CalculatorState.left("0.32"))

  }

  func testCalculatorStateTransferLeftOp() throws {
    // [0.32 x] + [5] --> [LOR-"0.32", x, "5"]
    let res0 = stateLO0.apply(item: itemDigit0)
    XCTAssertEqual(res0, CalculatorState.leftOpRight(left: "0.32", op: .multiply, right: "5"))

    // [0.32 x] + `AC` --> [left-"0"]
    let res1 = stateLO0.apply(item: itemCommandClear)
    XCTAssertEqual(res1, CalculatorState.left("0"))

    // [0.32 x] + `±` --> [LOR-"0.32", x, "-0"]
    let res2 = stateLO0.apply(item: itemCommandNegate)
    XCTAssertEqual(res2, CalculatorState.leftOpRight(left: "0.32", op: .multiply, right: "-0"))

    // [0.32 x] + `%` --> [LOR-"0.0032", x]
    let res3 = stateLO0.apply(item: itemCommandPercent)
    XCTAssertEqual(res3, CalculatorState.leftOp(left: "0.0032", op: .multiply))

    // [0.32 x] + `+` --> [leftOp-"0.32", +]
    let res4 = stateLO0.apply(item: itemOpPlus)
    XCTAssertEqual(res4, CalculatorState.leftOp(left: "0.32", op: .plus))

    // [0.32 x] + `=` --> [leftOp-"0.1024", x]
    let res5 = stateLO0.apply(item: itemOpEqual)
    XCTAssertEqual(res5, CalculatorState.leftOp(left: "0.1024", op: .multiply))
  }

  func testCalculatorStateTransferLeftOpRight() throws {
    // [0.32 x 100] + [5] --> [LOR-"0.32", x, "1005"]
    let res0 = stateLOR0.apply(item: itemDigit0)
    XCTAssertEqual(res0, CalculatorState.leftOpRight(left: "0.32", op: .multiply, right: "1005"))

    // [0.32 x 100] + `±` --> [LOR-"0.32", x, "-100"]
    let res1 = stateLOR0.apply(item: itemCommandNegate)
    XCTAssertEqual(res1, CalculatorState.leftOpRight(left: "0.32", op: .multiply, right: "-100"))

    // [0.32 x 100] + `%` --> [LOR-"0.32", x, "1"]
    let res2 = stateLOR0.apply(item: itemCommandPercent)
    XCTAssertEqual(res2, CalculatorState.leftOpRight(left: "0.32", op: .multiply, right: "1.0"))

    // [0.32 x 100] + `+` --> [LOR-"32", +]
    let res3 = stateLOR0.apply(item: itemOpPlus)
    XCTAssertEqual(res3, CalculatorState.leftOp(left: "32.0", op: .plus))

  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
