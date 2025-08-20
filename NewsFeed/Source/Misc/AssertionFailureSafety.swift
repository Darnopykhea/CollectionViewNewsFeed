//
//  AssertionFailureSafety.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/20/25.
//

import Foundation

/// Вспомогательная функция которая исключает краши по ассерту на бою
#if !RELEASE
func assertionFailureSafety(_ message: String = "", file: StaticString = #file, line: UInt = #line) {
    assertionFailure(message, file: file, line: line)
}
#else
func assertionFailureSafety(_ message: String = "") { /* do nothing */ }
#endif
