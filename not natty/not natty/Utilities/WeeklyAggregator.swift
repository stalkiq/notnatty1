//
//  WeeklyAggregator.swift
//  not natty

import Foundation

struct SummaryBucket {
    let date: Date
    let totalsBySupplement: [String: Double]
    let totalAmount: Double
}

enum SummaryRange {
    case week
    case month
    var days: Int { self == .week ? 7 : 30 }
}

enum WeeklyAggregator {
    static func buckets(for intakes: [IntakeLog], range: SummaryRange, calendar: Calendar = .current) -> [SummaryBucket] {
        let now = Date()
        let start = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -(range.days - 1), to: now) ?? now)
        var dayToSuppTotals: [Date: [String: Double]] = [:]
        for offset in 0..<range.days {
            if let day = calendar.date(byAdding: .day, value: offset, to: start) {
                dayToSuppTotals[calendar.startOfDay(for: day)] = [:]
            }
        }
        for log in intakes {
            let day = calendar.startOfDay(for: log.time)
            guard day >= start else { continue }
            var dict = dayToSuppTotals[day] ?? [:]
            dict[log.supplementName, default: 0] += log.amount
            dayToSuppTotals[day] = dict
        }
        return dayToSuppTotals.keys.sorted().map { day in
            let map = dayToSuppTotals[day] ?? [:]
            let total = map.values.reduce(0, +)
            return SummaryBucket(date: day, totalsBySupplement: map, totalAmount: total)
        }
    }

    static func totals(intakes: [IntakeLog], range: SummaryRange, calendar: Calendar = .current) -> Double {
        let buckets = buckets(for: intakes, range: range, calendar: calendar)
        return buckets.map { $0.totalAmount }.reduce(0, +)
    }

    static func averagePerDay(intakes: [IntakeLog], range: SummaryRange, calendar: Calendar = .current) -> Double {
        let total = totals(intakes: intakes, range: range, calendar: calendar)
        return total / Double(range.days)
    }

    static func adherence(intakes: [IntakeLog], range: SummaryRange, calendar: Calendar = .current) -> Double {
        let buckets = buckets(for: intakes, range: range, calendar: calendar)
        let daysWithAny = buckets.filter { $0.totalAmount > 0 }.count
        return Double(daysWithAny) / Double(range.days)
    }

    static func streak(intakes: [IntakeLog], calendar: Calendar = .current) -> Int {
        var streak = 0
        var day = calendar.startOfDay(for: Date())
        let grouped = Dictionary(grouping: intakes) { calendar.startOfDay(for: $0.time) }
        while let logs = grouped[day], !logs.isEmpty {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }
}







