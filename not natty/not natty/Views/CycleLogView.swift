//
//  CycleLogView.swift
//  not natty
//
//  Created by Apple Id on 7/26/25.
//

import SwiftUI

struct CycleLogView: View {
    @EnvironmentObject var cyclesManager: CyclesManager
    @EnvironmentObject var postsManager: PostsManager
    @State private var selectedTab = 0
    @State private var showAddInjection = false
    @State private var showAddSideEffect = false
    @State private var showCreateCycle = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    Button("New Cycle") {
                        showCreateCycle = true
                    }
                    .foregroundColor(.orange)
                    .fontWeight(.medium)
                    
                    Spacer()
                    
                    Menu {
                        Button(action: { showAddInjection = true }) {
                            Label("Log Supplement Dose", systemImage: "pills")
                        }
                        
                        Button(action: { showAddSideEffect = true }) {
                            Label("Log Side Effect", systemImage: "exclamationmark.triangle")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.orange)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Tab Selector
                Picker("Cycle Log Tabs", selection: $selectedTab) {
                    Text("Overview").tag(0)
                    Text("Doses").tag(1)
                    Text("Side Effects").tag(2)
                    Text("Analytics").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                TabView(selection: $selectedTab) {
                    CycleOverviewTab(showCreateCycle: $showCreateCycle)
                        .tag(0)
                    
                    InjectionsTab()
                        .tag(1)
                    
                    SideEffectsTab()
                        .tag(2)
                    
                    AnalyticsTab()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationBarHidden(true)
        }
        .task {
            await cyclesManager.fetchCycles()
        }
        .sheet(isPresented: $showAddInjection) {
            AddInjectionView(onLogged: { selectedTab = 1 })
        }
        .sheet(isPresented: $showAddSideEffect) {
            AddSideEffectView(onLogged: { selectedTab = 2 })
        }
        .sheet(isPresented: $showCreateCycle) {
            CreateCycleView()
        }
    }
}

struct CycleOverviewTab: View {
    @EnvironmentObject var cyclesManager: CyclesManager
    @Binding var showCreateCycle: Bool
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Current Cycle Card
                if let currentCycle = cyclesManager.cycles.first(where: { $0.status == .active }) {
                    CurrentCycleCard(cycle: currentCycle)
                } else {
                    NoActiveCycleCard(onCreate: { showCreateCycle = true })
                }
                
                // Quick Stats removed
                // Recent Activity removed
            }
            .padding()
        }
    }
}

struct CurrentCycleCard: View {
    let cycle: Cycle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Cycle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(cycle.name)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                StatusBadge(status: cycle.status)
                ShareLink(item: shareText) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.orange)
                }
            }
            
            // Cycle Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(cycleDaysElapsed) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: cycleProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
            }
            
            // Goals
            if !cycle.goals.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Goals")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(cycle.goals, id: \.self) { goal in
                            Text(goal)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            if let notes = cycle.notes {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    private var cycleDaysElapsed: Int {
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: cycle.startDate, to: Date()).day ?? 0
    }
    
    private var cycleProgress: Double {
        // Assuming a 12-week cycle for demo purposes
        let totalDays = 12 * 7
        guard totalDays > 0 else { return 0 }
        return min(Double(cycleDaysElapsed) / Double(totalDays), 1.0)
    }

    private var shareText: String {
        "My supplement program: \(cycle.name). Goals: \(cycle.goals.joined(separator: ", ")). Started on \(cycle.startDate.formatted(date: .abbreviated, time: .omitted))."
    }
}

struct NoActiveCycleCard: View {
    let onCreate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            VStack(spacing: 8) {
                Text("No Active Cycle")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Start tracking your supplement program to monitor progress and well-being.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Create New Cycle") { onCreate() }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


struct StatusBadge: View {
    let status: Cycle.CycleStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(status.color).opacity(0.2))
            .foregroundColor(Color(status.color))
            .cornerRadius(8)
    }
}

struct InjectionsTab: View {
    @EnvironmentObject var cyclesManager: CyclesManager
    @State private var showAddInjection = false
    @State private var selectedFilter = "All"
    
    let filterOptions = ["All", "This Week", "This Month", "By Compound"]
    
    var filteredInjections: [Injection] {
        let injections = cyclesManager.injections
        
        switch selectedFilter {
        case "This Week":
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return injections.filter { $0.injectedAt >= weekAgo }
        case "This Month":
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return injections.filter { $0.injectedAt >= monthAgo }
        case "By Compound":
            return injections.sorted { $0.compoundName > $1.compoundName }
        default:
            return injections.sorted { $0.injectedAt > $1.injectedAt }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Header
            HStack {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(filterOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Spacer()
                
                Button(action: { showAddInjection = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            
            if filteredInjections.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "pills")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("No Doses Logged")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Start tracking your supplement doses to monitor your plan.")
                        .font(.subheadline)
                .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Log First Dose") {
                        showAddInjection = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredInjections) { injection in
                            InjectionCard(injection: injection)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showAddInjection) {
            AddInjectionView()
        }
    }
}

struct InjectionCard: View {
    let injection: Injection
    @State private var showDetails = false
    
    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(injection.compoundName)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text("\(injection.dosageMg, specifier: "%.0f") mg")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(injection.injectedAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(injection.injectedAt, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Injection Site
                HStack {
                    Image(systemName: "location.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    
                    Text(injection.injectionSite?.displayName ?? "Not specified")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                
                // Notes (if any)
                if let notes = injection.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetails) {
            InjectionDetailView(injection: injection)
        }
    }
}

struct InjectionDetailView: View {
    let injection: Injection
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(injection.compoundName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("\(injection.dosageMg, specifier: "%.0f") mg")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                        }
                        
                        Text("Logged on \(injection.injectedAt, style: .date) at \(injection.injectedAt, style: .time)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Details
                    VStack(alignment: .leading, spacing: 16) {
                        DetailRow(title: "Intake Method", value: injection.injectionMethod?.displayName ?? "Not specified", icon: "pills")
                        
                        if let notes = injection.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "note.text")
                                        .foregroundColor(.orange)
                                    Text("Notes")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                }
                                
                                Text(notes)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Injection Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SideEffectsTab: View {
    @EnvironmentObject var cyclesManager: CyclesManager
    @State private var showAddSideEffect = false
    @State private var selectedFilter = "All"
    
    let filterOptions = ["All", "This Week", "This Month", "By Severity"]
    
    var filteredSideEffects: [SideEffect] {
        let sideEffects = cyclesManager.sideEffects
        
        switch selectedFilter {
        case "This Week":
            let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
            return sideEffects.filter { $0.recordedAt >= weekAgo }
        case "This Month":
            let monthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            return sideEffects.filter { $0.recordedAt >= monthAgo }
        case "By Severity":
            return sideEffects.sorted { $0.severity > $1.severity }
        default:
            return sideEffects.sorted { $0.recordedAt > $1.recordedAt }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with filter and add button
            HStack {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(filterOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Spacer()
                
                Button(action: { showAddSideEffect = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            
            if filteredSideEffects.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("No Side Effects Logged")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text("Track your side effects to monitor your health and cycle progress")
                        .font(.subheadline)
                .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Log First Side Effect") {
                        showAddSideEffect = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredSideEffects) { sideEffect in
                            SideEffectCard(sideEffect: sideEffect)
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showAddSideEffect) {
            AddSideEffectView()
        }
    }
}

struct AnalyticsTab: View {
    @EnvironmentObject var cyclesManager: CyclesManager
    @State private var selectedTimeframe = "30 Days"
    @State private var selectedMetric = "Injections"
    
    let timeframes = ["7 Days", "30 Days", "90 Days", "All Time"]
    let metrics = ["Doses", "Side Effects", "Compounds", "Health"]
    
    var filteredData: (injections: [Injection], sideEffects: [SideEffect]) {
        let calendar = Calendar.current
        let now = Date()
        
        let daysToSubtract: Int
        switch selectedTimeframe {
        case "7 Days": daysToSubtract = 7
        case "30 Days": daysToSubtract = 30
        case "90 Days": daysToSubtract = 90
        default: daysToSubtract = 365 // All time
        }
        
        let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: now) ?? now
        
        let filteredInjections = cyclesManager.injections.filter { $0.injectedAt >= startDate }
        let filteredSideEffects = cyclesManager.sideEffects.filter { $0.recordedAt >= startDate }
        
        return (filteredInjections, filteredSideEffects)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header with controls
                VStack(spacing: 16) {
                    HStack {
            Text("Analytics")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    // Timeframe and Metric Selectors
                    VStack(spacing: 12) {
                        // Timeframe Selector
                        HStack(spacing: 8) {
                            ForEach(timeframes, id: \.self) { timeframe in
                                Button(action: {
                                    selectedTimeframe = timeframe
                                }) {
                                    Text(timeframe)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedTimeframe == timeframe ? Color.orange : Color(.systemGray6))
                                        .foregroundColor(selectedTimeframe == timeframe ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Metric Selector
                        HStack(spacing: 8) {
                            ForEach(metrics, id: \.self) { metric in
                                Button(action: {
                                    selectedMetric = metric
                                }) {
                                    Text(metric)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedMetric == metric ? Color.orange : Color(.systemGray6))
                                        .foregroundColor(selectedMetric == metric ? .white : .primary)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Overview Cards
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    StatCard(
                        title: "Total Doses",
                        value: "\(filteredData.injections.count)",
                        icon: "pills",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Side Effects",
                        value: "\(filteredData.sideEffects.count)",
                        icon: "exclamationmark.triangle",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "Unique Compounds",
                        value: "\(Set(filteredData.injections.map { $0.compoundName }).count)",
                        icon: "pills",
                        color: .purple
                    )
                    
                    StatCard(
                        title: "Avg Severity",
                        value: averageSeverityText,
                        icon: "chart.bar",
                        color: .red
                    )
                }
                .padding(.horizontal)
                
                // Charts and Detailed Analytics
                VStack(spacing: 20) {
                    // Injection Frequency Chart
                    InjectionFrequencyChart(injections: filteredData.injections)
                    
                    // Side Effects Trend
                    SideEffectsTrendChart(sideEffects: filteredData.sideEffects)
                    
                    // Compound Usage Breakdown
                    CompoundUsageChart(injections: filteredData.injections)
                    
                    // Health Metrics Summary
                    HealthMetricsSummary(sideEffects: filteredData.sideEffects)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private var averageSeverityText: String {
        let severities = filteredData.sideEffects.map { $0.severity }
        guard !severities.isEmpty else { return "N/A" }
        let average = Double(severities.reduce(0, +)) / Double(severities.count)
        return String(format: "%.1f", average)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

struct InjectionFrequencyChart: View {
    let injections: [Injection]
    
    var weeklyData: [(week: String, count: Int)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: injections) { injection in
            calendar.startOfWeek(for: injection.injectedAt)
        }
        
        return grouped.map { (week, injections) in
            let weekString = calendar.dateFormatter.string(from: week)
            return (week: weekString, count: injections.count)
        }.sorted { $0.week < $1.week }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.blue)
                Text("Dose Frequency")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            if weeklyData.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No dose data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(weeklyData, id: \.week) { data in
                        HStack {
                            Text(data.week)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .leading)
                            
                            HStack(spacing: 4) {
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: CGFloat(data.count) * 20, height: 20)
                                    .cornerRadius(4)
                                
                                Text("\(data.count)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

struct SideEffectsTrendChart: View {
    let sideEffects: [SideEffect]
    
    var severityData: [(severity: Int, count: Int)] {
        let grouped = Dictionary(grouping: sideEffects) { $0.severity }
        return (1...5).map { severity in
            (severity: severity, count: grouped[severity]?.count ?? 0)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.orange)
                Text("Side Effects by Severity")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            if sideEffects.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No side effect data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(severityData, id: \.severity) { data in
                        HStack {
                            Text("Level \(data.severity)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 60, alignment: .leading)
                            
                            HStack(spacing: 4) {
                                Rectangle()
                                    .fill(severityColor(for: data.severity))
                                    .frame(width: CGFloat(data.count) * 25, height: 20)
                                    .cornerRadius(4)
                                
                                Text("\(data.count)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
    
    private func severityColor(for severity: Int) -> Color {
        switch severity {
        case 1...2: return .green
        case 3...4: return .orange
        case 5: return .red
        default: return .gray
        }
    }
}

struct CompoundUsageChart: View {
    let injections: [Injection]
    
    var compoundData: [(compound: String, count: Int, totalDosage: Double)] {
        let grouped = Dictionary(grouping: injections) { $0.compoundName }
        return grouped.map { (compound, injections) in
            let totalDosage = injections.reduce(0) { $0 + $1.dosageMg }
            return (compound: compound, count: injections.count, totalDosage: totalDosage)
        }.sorted { $0.count > $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "pills.fill")
                    .foregroundColor(.purple)
                Text("Compound Usage")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            if compoundData.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "pills")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No compound data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(compoundData.prefix(5), id: \.compound) { data in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(data.compound)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                
                                Text("\(data.count) doses")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 120, alignment: .leading)
                            
                            HStack(spacing: 4) {
                                Rectangle()
                                    .fill(Color.purple)
                                    .frame(width: CGFloat(data.count) * 15, height: 16)
                                    .cornerRadius(4)
                                
                                Text("\(Int(data.totalDosage))mg")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

struct HealthMetricsSummary: View {
    let sideEffects: [SideEffect]
    
    var averageMood: Double {
        let moods = sideEffects.compactMap { $0.moodRating }
        guard !moods.isEmpty else { return 0 }
        return Double(moods.reduce(0, +)) / Double(moods.count)
    }
    
    var averageLibido: Double {
        let libidos = sideEffects.compactMap { $0.libidoRating }
        guard !libidos.isEmpty else { return 0 }
        return Double(libidos.reduce(0, +)) / Double(libidos.count)
    }
    
    var averageAcne: Double {
        let acnes = sideEffects.compactMap { $0.acneSeverity }
        guard !acnes.isEmpty else { return 0 }
        return Double(acnes.reduce(0, +)) / Double(acnes.count)
    }
    
    var averageBloodPressure: (systolic: Double, diastolic: Double) {
        let pressures: [(systolic: Double, diastolic: Double)] = sideEffects.compactMap { effect in
            guard let systolic = effect.bloodPressureSystolic,
                  let diastolic = effect.bloodPressureDiastolic else { return nil }
            return (systolic: Double(systolic), diastolic: Double(diastolic))
        }
        
        guard !pressures.isEmpty else { return (0, 0) }
        let avgSystolic = pressures.map { $0.systolic }.reduce(0, +) / Double(pressures.count)
        let avgDiastolic = pressures.map { $0.diastolic }.reduce(0, +) / Double(pressures.count)
        return (avgSystolic, avgDiastolic)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("Health Metrics")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            if sideEffects.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No health data")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    MetricItem(
                        title: "Mood",
                        value: averageMood > 0 ? String(format: "%.1f/10", averageMood) : "N/A",
                        icon: "face.smiling",
                        color: .blue
                    )
                    
                    MetricItem(
                        title: "Libido",
                        value: averageLibido > 0 ? String(format: "%.1f/10", averageLibido) : "N/A",
                        icon: "heart.fill",
                        color: .pink
                    )
                    
                    MetricItem(
                        title: "Acne",
                        value: averageAcne > 0 ? String(format: "%.1f/10", averageAcne) : "N/A",
                        icon: "pimple",
                        color: .orange
                    )
                    
                    MetricItem(
                        title: "Blood Pressure",
                        value: averageBloodPressure.systolic > 0 ? "\(Int(averageBloodPressure.systolic))/\(Int(averageBloodPressure.diastolic))" : "N/A",
                        icon: "heart.circle.fill",
                        color: .red
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

struct MetricItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct SideEffectCard: View {
    let sideEffect: SideEffect
    @State private var showDetails = false
    
    var severityColor: Color {
        switch sideEffect.severity {
        case 1...2: return .green
        case 3...4: return .orange
        case 5: return .red
        default: return .gray
        }
    }
    
    var severityText: String {
        switch sideEffect.severity {
        case 1: return "Mild"
        case 2: return "Light"
        case 3: return "Moderate"
        case 4: return "Severe"
        case 5: return "Critical"
        default: return "Unknown"
        }
    }
    
    var body: some View {
        Button(action: { showDetails.toggle() }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sideEffect.symptoms.joined(separator: ", "))
                            .font(.headline)
                            .fontWeight(.bold)
                            .lineLimit(2)
                        
                        HStack {
                            Circle()
                                .fill(severityColor)
                                .frame(width: 8, height: 8)
                            
                            Text(severityText)
                                .font(.subheadline)
                                .foregroundColor(severityColor)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(sideEffect.recordedAt, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(sideEffect.recordedAt, style: .time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Symptoms
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 4) {
                    ForEach(sideEffect.symptoms, id: \.self) { symptom in
                        Text(symptom)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
                
                // Notes (if any)
                if let notes = sideEffect.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetails) {
            SideEffectDetailView(sideEffect: sideEffect)
        }
    }
}

struct SideEffectDetailView: View {
    let sideEffect: SideEffect
    @Environment(\.dismiss) var dismiss
    
    var severityColor: Color {
        switch sideEffect.severity {
        case 1...2: return .green
        case 3...4: return .orange
        case 5: return .red
        default: return .gray
        }
    }
    
    var severityText: String {
        switch sideEffect.severity {
        case 1: return "Mild"
        case 2: return "Light"
        case 3: return "Moderate"
        case 4: return "Severe"
        case 5: return "Critical"
        default: return "Unknown"
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Side Effect Details")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            Circle()
                                .fill(severityColor)
                                .frame(width: 12, height: 12)
                            
                            Text(severityText)
                                .font(.headline)
                                .foregroundColor(severityColor)
                                .fontWeight(.medium)
                        }
                    }
                    
                    // Symptoms
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Symptoms")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                            ForEach(sideEffect.symptoms, id: \.self) { symptom in
                                Text(symptom)
                                    .font(.subheadline)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    
                    // Health Metrics
                    if let systolic = sideEffect.bloodPressureSystolic,
                       let diastolic = sideEffect.bloodPressureDiastolic {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("Blood Pressure")
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                            
                            DetailRow(title: "Systolic", value: "\(systolic) mmHg", icon: "heart.circle.fill")
                            DetailRow(title: "Diastolic", value: "\(diastolic) mmHg", icon: "heart.circle.fill")
                        }
                    }
                    
                    // Ratings
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.blue)
                            Text("Ratings")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        
                        if let moodRating = sideEffect.moodRating {
                            DetailRow(title: "Mood", value: "\(moodRating)/10", icon: "face.smiling")
                        }
                        
                        if let libidoRating = sideEffect.libidoRating {
                            DetailRow(title: "Libido", value: "\(libidoRating)/10", icon: "heart.fill")
                        }
                        
                        if let acneSeverity = sideEffect.acneSeverity {
                            DetailRow(title: "Acne", value: "\(acneSeverity)/10", icon: "pimple")
                        }
                    }
                    
                    // Notes
                    if let notes = sideEffect.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.orange)
                                Text("Notes")
                                    .font(.headline)
                                .fontWeight(.medium)
                            }
                            
                            Text(notes)
                                .font(.body)
                                .foregroundColor(.primary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                    
                    // Date & Time
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.secondary)
                            Text("Recorded")
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        
                        DetailRow(title: "Date", value: sideEffect.recordedAt.formatted(date: .long, time: .omitted), icon: "calendar.circle.fill")
                        DetailRow(title: "Time", value: sideEffect.recordedAt.formatted(date: .omitted, time: .shortened), icon: "clock.circle.fill")
                    }
                }
                .padding()
            }
            .navigationTitle("Side Effect Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Placeholder views for forms
struct AddInjectionView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cyclesManager: CyclesManager
    var onLogged: (() -> Void)? = nil
    
    @State private var selectedCycle: Cycle?
    @State private var selectedCompound = ""
    @State private var dosage = ""
    @State private var injectionDate = Date()
    @State private var injectionSite = Injection.InjectionSite.glute
    @State private var notes = ""
    @State private var showingCycleSelector = false
    @State private var showingCompoundSelector = false
    
    let injectionSites = Injection.InjectionSite.allCases
    
    var body: some View {
        NavigationView {
            Form {
                Section("Cycle") {
                    Button(action: {
                        showingCycleSelector = true
                    }) {
                        HStack {
                            Text("Select Cycle")
                            Spacer()
                            if let cycle = selectedCycle {
                                Text(cycle.name)
                    .foregroundColor(.secondary)
                            } else {
                                Text("Required")
                                    .foregroundColor(.orange)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Supplement Dose Details") {
                    Button(action: {
                        showingCompoundSelector = true
                    }) {
                        HStack {
                            Text("Compound")
                            Spacer()
                            if !selectedCompound.isEmpty {
                                Text(selectedCompound)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Required")
                                    .foregroundColor(.orange)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        TextField("Dosage", text: $dosage)
                            .keyboardType(.decimalPad)
                        Text("mg")
                            .foregroundColor(.secondary)
                    }
                    
                    DatePicker("Date & Time", selection: $injectionDate)
                    
                    Picker("Intake Site", selection: $injectionSite) {
                        ForEach(injectionSites, id: \.self) { site in
                            Text(site.displayName).tag(site)
                        }
                    }
                }
                
                Section("Notes") {
                    TextField("Add notes about this dose...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log Dose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Log") { logInjection() }
                    .fontWeight(.semibold)
                    .disabled(selectedCycle == nil || selectedCompound.isEmpty || dosage.isEmpty)
                }
            }
            .sheet(isPresented: $showingCycleSelector) {
                CycleSelectorView(selectedCycle: $selectedCycle)
            }
            .sheet(isPresented: $showingCompoundSelector) {
                CompoundSelectorView(selectedCompound: $selectedCompound, selectedCompounds: .constant([]))
            }
        }
    }
    
    private func logInjection() {
        guard let dosageValue = Double(dosage) else { return }
        
        Task {
            await cyclesManager.logInjection(
                compoundName: selectedCompound,
                dosageMg: dosageValue,
                injectionSite: injectionSite,
                injectionMethod: nil,
                cycleId: selectedCycle?.id,
                notes: notes.isEmpty ? nil : notes
            )
            onLogged?()
            dismiss()
        }
    }

}

struct CycleSelectorView: View {
    @Binding var selectedCycle: Cycle?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cyclesManager: CyclesManager
    
    var body: some View {
        NavigationView {
            List {
                if cyclesManager.cycles.isEmpty {
                    Text("No cycles available")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(cyclesManager.cycles) { cycle in
                        Button(action: {
                            selectedCycle = cycle
                            dismiss()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(cycle.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("Started \(cycle.startDate, style: .date)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedCycle?.id == cycle.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Cycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CompoundSelectorView: View {
    @Binding var selectedCompound: String
    @Binding var selectedCompounds: [String]
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    
    let compounds = [
        "Whey Protein",
        "Micellar Casein",
        "Mass Gainers",
        "Creatine Monohydrate",
        "BCAAs",
        "EAAs",
        "Glutamine",
        "Beta-Alanine",
        "Citrulline",
        "Arginine",
        "Betaine",
        "HMB",
        "Caffeine",
        "Fish Oil",
        "Vitamin D",
        "CoQ10",
        "Carnitine",
        "Multivitamins",
        "ZMA",
        "DHEA",
        "Essential Fatty Acids"
    ]
    
    var filteredCompounds: [String] {
        if searchText.isEmpty {
            return compounds
        } else {
            return compounds.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding()
                
                List {
                    ForEach(filteredCompounds, id: \.self) { compound in
                        Button(action: {
                            // Support both single and multiple selection
                            if !selectedCompounds.isEmpty {
                                if selectedCompounds.contains(compound) {
                                    selectedCompounds.removeAll { $0 == compound }
                                } else {
                                    selectedCompounds.append(compound)
                                }
                            } else {
                                selectedCompound = compound
                                dismiss()
                            }
                        }) {
                            HStack {
                                Text(compound)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if !selectedCompounds.isEmpty {
                                    if selectedCompounds.contains(compound) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.orange)
                                    }
                                } else if selectedCompound == compound {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.orange)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Compound")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}



struct CreateCycleView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cyclesManager: CyclesManager
    @EnvironmentObject var supplementsManager: SupplementsManager
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var postsManager: PostsManager
    @Environment(\.appContainer) var appContainer: AppContainer
    
    @State private var cycleName = ""
    @State private var startDate = Date()
    @State private var durationWeeks = 12
    @State private var selectedGoals: Set<String> = []
    @State private var notes = ""
    @State private var selectedCompounds: [SupplementPlan] = []
    @State private var showingCompoundSelector = false
    @State private var postToFeed = true
    
    let availableGoals = [
        "Muscle Gain", "Fat Loss", "Strength", "Performance", 
        "Competition Prep", "Recomp", "Maintenance", "Recovery"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Cycle Information") {
                    TextField("Cycle Name", text: $cycleName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    
                    Stepper("Duration: \(durationWeeks) weeks", value: $durationWeeks, in: 4...52)
                }
                
                Section("Goals") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(availableGoals, id: \.self) { goal in
                            GoalToggleButton(
                                goal: goal,
                                isSelected: Binding(
                                    get: { selectedGoals.contains(goal) },
                                    set: { newValue in
                                        if newValue { selectedGoals.insert(goal) } else { selectedGoals.remove(goal) }
                                    }
                                )
                            )
                        }
                    }
                }
                
                Section("Supplements") {
                    if selectedCompounds.isEmpty {
                        Button(action: { showingCompoundSelector = true }) {
                            HStack { Image(systemName: "plus.circle"); Text("Add Supplements") }
                        }
                        .foregroundColor(.orange)
                    } else {
                        ForEach($selectedCompounds) { $plan in
                            SupplementPlanRow(plan: $plan)
                        }
                        .onDelete { idx in selectedCompounds.remove(atOffsets: idx) }
                        Button(action: { showingCompoundSelector = true }) { Text("Add more") }
                            .foregroundColor(.orange)
                    }
                }
                
                Section("Notes") {
                    TextField("Add notes about your cycle...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Cycle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createCycle()
                    }
                    .fontWeight(.semibold)
                    .disabled(cycleName.isEmpty || selectedGoals.isEmpty || selectedCompounds.isEmpty)
                }
            }
            .sheet(isPresented: $showingCompoundSelector) {
                SupplementMultiSelector(
                    preselected: Set(selectedCompounds.map { $0.supplement.name }),
                    onDone: { names in
                        let chosen = supplementsManager.catalog.filter { names.contains($0.name) }
                        for s in chosen {
                            if !selectedCompounds.contains(where: { $0.supplement.name == s.name }) {
                                selectedCompounds.append(SupplementPlan(supplement: s))
                            }
                        }
                    }
                ).environmentObject(supplementsManager)
            }
            Section("Sharing") {
                Toggle("Post to feed after creating", isOn: $postToFeed)
            }
        }
    }
    
    private func createCycle() {
        Task {
            do {
                let userId = authManager.currentUser?.id ?? "local-user"
                let created = try await appContainer.createCyclePlan(
                    userId: userId,
                    name: cycleName,
                    startDate: startDate,
                    durationWeeks: durationWeeks,
                    goals: Array(selectedGoals),
                    supplementPlans: selectedCompounds,
                    notes: notes.isEmpty ? nil : notes
                )
                await cyclesManager.fetchCycles()
                if postToFeed {
                    await postCycleToFeed(cycleName: created.name, goals: created.goals)
                }
                dismiss()
            } catch {
                // Fallback to existing manager if needed
                await cyclesManager.createCycle(
                    name: cycleName,
                    startDate: startDate,
                    goals: Array(selectedGoals),
                    compounds: [],
                    notes: notes.isEmpty ? nil : notes
                )
                if postToFeed { await postCycleToFeed(cycleName: cycleName, goals: Array(selectedGoals)) }
                dismiss()
            }
        }
    }

    private func postCycleToFeed(cycleName: String, goals: [String]) async {
        let content = "Started a new program: \(cycleName). Goals: \(goals.joined(separator: ", "))."
        await postsManager.createPost(
            content: content,
            postType: Post.PostType.general,
            privacyLevel: Post.PrivacyLevel.public,
            compoundTags: selectedCompounds.map { $0.supplement.name }
        )
    }
}

struct SupplementPlanRow: View {
    @Binding var plan: SupplementPlan
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(plan.supplement.name).font(.headline)
                Spacer()
                Text("every \(plan.frequencyDays)d").font(.caption).foregroundColor(.secondary)
            }
            HStack {
                TextField("Amount", value: $plan.dosage, format: .number)
                    .keyboardType(.decimalPad)
                Picker("", selection: $plan.unit) {
                    ForEach(plan.supplement.allowedUnits, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.menu)
            }
            Stepper("Frequency: every \(plan.frequencyDays) day(s)", value: $plan.frequencyDays, in: 1...7)
            if let ts = plan.supplement.typicalServing as TypicalServing? {
                Text("Typical: \(ts.min, specifier: "%.0f").\(ts.max, specifier: "%.0f") \(ts.unit)")
                    .font(.caption).foregroundColor(.secondary)
            }
            TextField("Notes (optional)", text: $plan.notes)
        }
    }
}

struct SupplementMultiSelector: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var supplementsManager: SupplementsManager
    
    let preselected: Set<String>
    let onDone: (Set<String>) -> Void
    
    @State private var selections: Set<String> = []
    @State private var searchText: String = ""
    
    var filtered: [Supplement] {
        let base = supplementsManager.catalog
        guard !searchText.isEmpty else { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchText) || ($0.aka ?? "").localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText).padding()
                List(filtered, id: \.id, selection: Binding(get: { selections }, set: { selections = $0 })) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        if selections.contains(item.name) { Image(systemName: "checkmark.circle.fill").foregroundColor(.orange) }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selections.contains(item.name) { selections.remove(item.name) } else { selections.insert(item.name) }
                    }
                }
                .environment(\.editMode, .constant(.active))
            }
            .navigationTitle("Select Supplements")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { onDone(selections); dismiss() }.disabled(selections.isEmpty) }
            }
            .onAppear { selections = preselected }
        }
    }
}

struct GoalToggleButton: View {
    let goal: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button(action: { isSelected.toggle() }) {
            Text(goal)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .orange)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color.orange.opacity(0.1))
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

struct CompoundTag: View {
    let compound: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(compound)
                .font(.caption)
                .fontWeight(.medium)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.orange.opacity(0.2))
        .foregroundColor(.orange)
        .cornerRadius(12)
    }
}

struct AddSideEffectView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var cyclesManager: CyclesManager
    var onLogged: (() -> Void)? = nil
    
    @State private var selectedCycle: Cycle?
    @State private var selectedSymptoms: Set<String> = []
    @State private var severity = 3
    @State private var bloodPressureSystolic = ""
    @State private var bloodPressureDiastolic = ""
    @State private var moodRating = 5
    @State private var libidoRating = 5
    @State private var acneSeverity = 1
    @State private var notes = ""
    @State private var showingCycleSelector = false
    
    let commonSymptoms = [
        "Acne", "Hair Loss", "Mood Swings", "Aggression", "Anxiety", "Depression",
        "Insomnia", "Night Sweats", "Water Retention", "High Blood Pressure",
        "Liver Stress", "Kidney Stress", "Gynecomastia", "Testicular Atrophy",
        "Libido Changes", "Erectile Dysfunction", "Headaches", "Nausea",
        "Back Pain", "Joint Pain", "Muscle Cramps", "Fatigue", "Increased Appetite"
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Cycle (Optional)") {
                    Button(action: {
                        showingCycleSelector = true
                    }) {
                        HStack {
                            Text("Select Cycle")
                            Spacer()
                            if let cycle = selectedCycle {
                                Text(cycle.name)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Optional")
                                    .foregroundColor(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Symptoms") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(commonSymptoms, id: \.self) { symptom in
                            Button(action: {
                                if selectedSymptoms.contains(symptom) {
                                    selectedSymptoms.remove(symptom)
                                } else {
                                    selectedSymptoms.insert(symptom)
                                }
                            }) {
                                Text(symptom)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedSymptoms.contains(symptom) ? .white : .orange)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(selectedSymptoms.contains(symptom) ? Color.orange : Color.orange.opacity(0.1))
                                    .cornerRadius(16)
                            }
                        }
                    }
                }
                
                Section("Severity") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Level \(severity)")
                            Spacer()
                            Text(severityText)
                                .foregroundColor(severityColor)
                                .fontWeight(.medium)
                        }
                        
                        Slider(value: Binding(
                            get: { Double(severity) },
                            set: { severity = Int($0) }
                        ), in: 1...5, step: 1)
                        .accentColor(severityColor)
                        
                        HStack {
                            Text("Mild")
                                .font(.caption)
                                .foregroundColor(.green)
                            Spacer()
                            Text("Critical")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Section("Health Metrics (Optional)") {
                    HStack {
                        TextField("Systolic", text: $bloodPressureSystolic)
                            .keyboardType(.numberPad)
                        Text("mmHg")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        TextField("Diastolic", text: $bloodPressureDiastolic)
                            .keyboardType(.numberPad)
                        Text("mmHg")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Ratings (Optional)") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Mood: \(moodRating)/10")
                            Spacer()
                            Text(moodEmoji)
                                .font(.title2)
                        }
                        Slider(value: Binding(
                            get: { Double(moodRating) },
                            set: { moodRating = Int($0) }
                        ), in: 1...10, step: 1)
                        .accentColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Libido: \(libidoRating)/10")
                            Spacer()
                            Text(libidoEmoji)
                                .font(.title2)
                        }
                        Slider(value: Binding(
                            get: { Double(libidoRating) },
                            set: { libidoRating = Int($0) }
                        ), in: 1...10, step: 1)
                        .accentColor(.pink)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Acne: \(acneSeverity)/10")
                            Spacer()
                            Text(acneEmoji)
                                .font(.title2)
                        }
                        Slider(value: Binding(
                            get: { Double(acneSeverity) },
                            set: { acneSeverity = Int($0) }
                        ), in: 1...10, step: 1)
                        .accentColor(.orange)
                    }
                }
                
                Section("Notes") {
                    TextField("Add notes about your side effects...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Log Side Effect")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) { Button("Log") { logSideEffect() }.fontWeight(.semibold).disabled(selectedSymptoms.isEmpty) }
            }
            .sheet(isPresented: $showingCycleSelector) {
                CycleSelectorView(selectedCycle: $selectedCycle)
            }
        }
    }
    
    private var severityColor: Color {
        switch severity {
        case 1...2: return .green
        case 3...4: return .orange
        case 5: return .red
        default: return .gray
        }
    }
    
    private var severityText: String {
        switch severity {
        case 1: return "Mild"
        case 2: return "Light"
        case 3: return "Moderate"
        case 4: return "Severe"
        case 5: return "Critical"
        default: return "Unknown"
        }
    }
    
    private var moodEmoji: String {
        switch moodRating {
        case 1...3: return "😢"
        case 4...6: return "😐"
        case 7...8: return "🙂"
        case 9...10: return "😄"
        default: return "😐"
        }
    }
    
    private var libidoEmoji: String {
        switch libidoRating {
        case 1...3: return "💔"
        case 4...6: return "💙"
        case 7...8: return "💖"
        case 9...10: return "💕"
        default: return "💙"
        }
    }
    
    private var acneEmoji: String {
        switch acneSeverity {
        case 1...3: return "😊"
        case 4...6: return "😐"
        case 7...8: return "😟"
        case 9...10: return "😱"
        default: return "😊"
        }
    }
    
    private func logSideEffect() {
        let systolic = Int(bloodPressureSystolic)
        let diastolic = Int(bloodPressureDiastolic)
        
        Task {
            await cyclesManager.logSideEffect(
                symptoms: Array(selectedSymptoms),
                severity: severity,
                bloodPressureSystolic: systolic,
                bloodPressureDiastolic: diastolic,
                moodRating: moodRating,
                libidoRating: libidoRating,
                acneSeverity: acneSeverity,
                notes: notes.isEmpty ? nil : notes,
                cycleId: selectedCycle?.id
            )
            onLogged?()
            dismiss()
        }
    }
}

// MARK: - Calendar Extensions
extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd"
        return formatter
    }
}

#Preview {
    CycleLogView()
        .environmentObject(CyclesManager())
} 