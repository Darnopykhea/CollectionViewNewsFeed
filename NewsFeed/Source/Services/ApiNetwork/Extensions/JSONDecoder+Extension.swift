//
//  JSONDecoder+Extension.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/18/25.
//

import Foundation

/// Декодер JSON с поддержкой дат ISO 8601 (с миллисекундами и без)
public extension JSONDecoder {
    
    /// Декодер JSON с поддержкой нескольких форматов дат:
    /// - ISO 8601 с миллисекундами
    /// - ISO 8601 без миллисекунд
    /// - "yyyy-MM-dd'T'HH:mm:ss" (без часового пояса)
    static var iso8601Friendly: JSONDecoder = {
        let decoder = JSONDecoder()

        let isoWithFraction = ISO8601DateFormatter()
        isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let isoNoFraction = ISO8601DateFormatter()
        isoNoFraction.formatOptions = [.withInternetDateTime]

        let plainFormatter = DateFormatter()
        plainFormatter.locale = Locale(identifier: "en_US_POSIX")
        plainFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        plainFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = isoWithFraction.date(from: dateString) { return date }
            if let date = isoNoFraction.date(from: dateString) { return date }
            if let date = plainFormatter.date(from: dateString) { return date }

            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "Неподдерживаемый формат даты: \(dateString)"
            ))
        }

        return decoder
    }()
}


