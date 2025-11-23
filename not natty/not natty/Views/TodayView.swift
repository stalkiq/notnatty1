//
//  TodayView.swift
//  not natty
//
//  Minimal Home (Today) screen with Quick Log chips and Today's Intakes.
//

import SwiftUI

struct TodayView: View {
    @EnvironmentObject var supplements: SupplementsManager

    @State private var showLogSheet = false
    @State private var selectedSupplement: Supplement?

    var body: some View {
        NavigationView {
            List {
                Section("Quick Log") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(supplements.quickLogItems, id: \ .id) { item in
                                Menu {
                                    Button("Log") {
                                        selectedSupplement = item
                                        showLogSheet = true
                                    }
                                    Button(role: .destructive) { supplements.toggleQuickLog(name: item.name) } label: { Label("Remove", systemImage: "trash") }
                                } label: {
                                    Text(item.name)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.orange.opacity(0.15))
                                        .foregroundColor(.orange)
                                        .cornerRadius(16)
                                }
                            }
                            Menu {
                                ForEach(supplements.catalog.filter { s in !supplements.quickLogItems.map { $0.name }.contains(s.name) }, id: \ .id) { s in
                                    Button(s.name) { supplements.toggleQuickLog(name: s.name) }
                                }
                            } label: {
                                Label("Add", systemImage: "plus.circle.fill")
                                    .labelStyle(.titleAndIcon)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.orange.opacity(0.15))
                                    .foregroundColor(.orange)
                                    .cornerRadius(16)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("Today's Intakes") {
                    if supplements.intakes.isEmpty {
                        Text("No intakes logged yet today")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(supplements.intakes.filter { Calendar.current.isDateInToday($0.time) }) { log in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(log.supplementName).font(.subheadline).fontWeight(.semibold)
                                    Spacer()
                                    Text(log.time, style: .time).font(.caption).foregroundColor(.secondary)
                                }
                                Text("\(log.amount, specifier: "%.2f") \(log.unit)").font(.caption)
                                if let note = log.note, !note.isEmpty {
                                    Text(note).font(.caption2).foregroundColor(.secondary)
                                }
                            }
                        }
                        .onDelete { indexSet in
                            supplements.intakes.remove(atOffsets: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedSupplement = nil
                        showLogSheet = true
                    }) { Image(systemName: "plus.circle.fill") }
                }
            }
            .sheet(isPresented: $showLogSheet) {
                LogIntakeSheet(selected: selectedSupplement)
                    .environmentObject(supplements)
            }
        }
    }
}

struct LogIntakeSheet: View {
    @EnvironmentObject var supplements: SupplementsManager
    @Environment(\ .dismiss) var dismiss

    @State var selected: Supplement?
    @State private var amount: String = ""
    @State private var unit: String = ""
    @State private var time: Date = Date()
    @State private var note: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section("Supplement") {
                    Picker("Name", selection: Binding(get: { selected?.name ?? "" }, set: { name in
                        selected = supplements.catalog.first(where: { $0.name == name })
                        unit = selected?.allowedUnits.first ?? ""
                    })) {
                        ForEach(supplements.catalog, id: \ .id) { item in
                            Text(item.name).tag(item.name)
                        }
                    }
                }
                Section("Amount") {
                    HStack {
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                        Picker("Unit", selection: $unit) {
                            ForEach(selected?.allowedUnits ?? [], id: \.self) { u in
                                Text(u).tag(u)
                            }
                        }
                    }
                    if let ts = selected?.typicalServing {
                        Text("Typical: \(ts.min, specifier: "%.0f")-\(ts.max, specifier: "%.0f") \(ts.unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Section("Time") {
                    DatePicker("", selection: $time)
                }
                Section("Note") {
                    TextField("Optional", text: $note)
                }
            }
            .navigationTitle("Log Intake")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { save() }.disabled(!canSave) }
            }
            .onAppear {
                if selected == nil { selected = supplements.catalog.first; unit = selected?.allowedUnits.first ?? "" }
            }
        }
    }

    private var canSave: Bool {
        guard let selected else { return false }
        guard let amt = Double(amount), amt > 0 else { return false }
        return selected.allowedUnits.contains(unit)
    }

    private func save() {
        guard let selected, let amt = Double(amount) else { return }
        supplements.logIntake(supplement: selected, amount: amt, unit: unit, time: time, note: note.isEmpty ? nil : note)
        dismiss()
    }
}

// Preview (uses empty manager)
#Preview {
    TodayView().environmentObject(SupplementsManager())
}




