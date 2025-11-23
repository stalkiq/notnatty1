//
//  WeeklySummaryView.swift
//  not natty
//

import SwiftUI

struct WeeklySummaryView: View {
    @EnvironmentObject var supplements: SupplementsManager
    @State private var selectedRange: SummaryRange = .week

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Picker("Range", selection: $selectedRange) {
                    Text("Week").tag(SummaryRange.week)
                    Text("Month").tag(SummaryRange.month)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                summaryHeader

                // Line-item summary of intakes (for CSV parity)
                List {
                    ForEach(filteredIntakes, id: \ .id) { log in
                        IntakeLineRow(log: log)
                    }
                }
            }
            .navigationTitle("Summary")
            .safeAreaInset(edge: .bottom) {
                Button(action: exportCSV) {
                    HStack { Image(systemName: "square.and.arrow.up"); Text("Export CSV") }
                        .font(.headline)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .padding(.bottom, 6)
                }
                .background(Color(.systemBackground).opacity(0.97))
            }
        }
    }

    private var summaryHeader: some View {
        let total = WeeklyAggregator.totals(intakes: supplements.intakes, range: selectedRange)
        let avg = WeeklyAggregator.averagePerDay(intakes: supplements.intakes, range: selectedRange)
        let adh = WeeklyAggregator.adherence(intakes: supplements.intakes, range: selectedRange)
        let streak = WeeklyAggregator.streak(intakes: supplements.intakes)
        return HStack(spacing: 16) {
            MetricCard(title: "Total", value: String(format: "%.0f", total))
            MetricCard(title: "Avg/Day", value: String(format: "%.1f", avg))
            MetricCard(title: "Adherence", value: String(format: "%.0f%%", adh * 100))
            MetricCard(title: "Streak", value: "\(streak)d")
        }.padding(.horizontal)
    }

    private func exportCSV() {
        var csv = "Date,Time,Supplement,Amount,Unit,Note\n"
        for log in supplements.intakes.sorted(by: { $0.time < $1.time }) {
            let date = ISO8601DateFormatter().string(from: log.time)
            let note = log.note?.replacingOccurrences(of: ",", with: ";") ?? ""
            csv += "\(date),,\(log.supplementName),\(log.amount),\(log.unit),\(note)\n"
        }
        // For MVP: print to console. Next step: ShareLink/UIDocumentInteractionController
        print(csv)
    }

    private var filteredIntakes: [IntakeLog] {
        let cal = Calendar.current
        let now = Date()
        let start = cal.startOfDay(for: cal.date(byAdding: .day, value: -(selectedRange.days - 1), to: now) ?? now)
        return supplements.intakes
            .filter { $0.time >= start }
            .sorted { $0.time > $1.time }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    var body: some View {
        VStack { Text(value).font(.headline); Text(title).font(.caption).foregroundColor(.secondary) }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

private struct IntakeLineRow: View {
    let log: IntakeLog
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(log.time.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(log.supplementName)
                    .font(.body)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.2f %@", log.amount, log.unit))
                    .font(.body)
                    .monospacedDigit()
                if let note = log.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WeeklySummaryView().environmentObject(SupplementsManager())
}




