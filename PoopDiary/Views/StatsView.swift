import SwiftUI

/// Analytics screen showing trends and habit tracking.
struct StatsView: View {
    @ObservedObject var viewModel: StoolViewModel
    @State private var selectedMonth = Date()
    @State private var showMonthPicker = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Mascot
                    MascotView(
                        message: "",
                        imageName: "Pipi Stand Wave",
                        isAnimated: false,
                        size: 150
                    )
                    .padding(.top, 8)

                    // Top Stats Row
                    HStack(spacing: 20) {
                        statCircle(
                            label: "AVG TYPE:",
                            value: viewModel.mostCommonType?.label ?? "--",
                            icon: AnyView(
                                Group {
                                    if let commonType = viewModel.mostCommonType {
                                        PoopIconView(bristolType: commonType, size: 30)
                                    } else {
                                        Text("🍌").font(.system(size: 30))
                                    }
                                }
                            ),
                            color: Color.pdPeach
                        )
                        
                        statCircle(
                            label: "AVG:",
                            value: String(format: "%.0fm", viewModel.averageDuration),
                            icon: AnyView(Text("🕒").font(.system(size: 30))),
                            color: Color.pdMint
                        )
                        
                        statCircle(
                            label: "",
                            value: "\(viewModel.totalEntries) TOTAL",
                            icon: AnyView(
                                pooImage("Poo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                            ),
                            color: Color.pdLavender
                        )
                    }
                    .padding(.horizontal)

                    // Type Consistency Card
                    typeConsistencyCard

                    // Weekly Schedule
                    weeklyScheduleCard

                    // Keep the monthly habit card as it's useful
                    monthlyHabitCard

                    Spacer(minLength: 60)
                }
                .padding(.horizontal)
            }
            .background(Color.pdCream.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Stats")
                        .font(.headline.weight(.bold))
                        .foregroundColor(Color.pdBrown)
                }
            }
            .onAppear {
                viewModel.fetchAll()
            }
        }
    }

    // MARK: - Circular Stats
    
    private func statCircle(label: String, value: String, icon: AnyView, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 70, height: 70)
                icon
            }
            
            VStack(spacing: 2) {
                if !label.isEmpty {
                    Text(label)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color.pdBrownLight)
                }
                Text(value)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.pdBrown)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Type Consistency
    
    private var typeConsistencyCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("TYPE CONSISTENCY")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.pdBrown)
                
                Spacer()
                
                Text("Last 7 Days")
                    .font(.system(size: 11))
                    .foregroundColor(Color.pdBrownLight)
            }
            
            // Segmented Bar
            GeometryReader { geo in
                HStack(spacing: 0) {
                    ForEach(viewModel.typeConsistencyData, id: \.type.id) { data in
                        Rectangle()
                            .fill(colorForType(data.type))
                            .frame(width: geo.size.width * CGFloat(data.percentage))
                    }
                }
                .cornerRadius(8)
            }
            .frame(height: 35)
            
            // Legend
            let columns = [
                GridItem(.flexible(), alignment: .leading),
                GridItem(.flexible(), alignment: .leading),
                GridItem(.flexible(), alignment: .leading)
            ]
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(viewModel.typeConsistencyData, id: \.type.id) { data in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(colorForType(data.type))
                            .frame(width: 8, height: 8)
                        Text(data.type.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color.pdBrown)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.pdBrown.opacity(0.05), lineWidth: 1)
        )
    }
    
    private func colorForType(_ type: BristolType) -> Color {
        switch type {
        case .hardLumps, .lumpySausage: return Color.pdPink
        case .crackedSausage: return Color.pdBrown
        case .smoothSausage: return Color.pdPeach
        case .softBlobs: return Color.pdLavender
        case .mushy, .watery: return Color.pdMint
        }
    }

    // MARK: - Weekly Overview
    
    private var weeklyScheduleCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.title3.weight(.bold))
                .foregroundColor(Color.pdBrown)
            
            HStack(spacing: 0) {
                ForEach(viewModel.weeklyOverview, id: \.date) { day in
                    VStack(spacing: 12) {
                        Text(day.dayName)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.pdBrownLight)
                        
                        ZStack {
                            if let type = day.type {
                                PoopIconView(bristolType: type, size: 35)
                            } else {
                                Color.clear
                                    .frame(height: 35)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    if day.dayName != "Sat" {
                        Divider()
                            .background(Color.pdBrown.opacity(0.1))
                            .frame(height: 40)
                    }
                }
            }
            .padding(.vertical, 10)
        }
    }

    // MARK: - Monthly Habit Tracker

    private var monthlyHabitCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button {
                    showMonthPicker.toggle()
                } label: {
                    Text(currentMonthName(for: selectedMonth))
                        .font(.headline)
                        .foregroundColor(Color.pdBrown)
                }
                .sheet(isPresented: $showMonthPicker) {
                    monthPickerView
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    Button {
                        changeMonth(by: -1)
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(Color.pdBrownLight)
                    }
                    
                    Button {
                        changeMonth(by: 1)
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(Color.pdBrownLight)
                    }
                }
            }

            habitGrid(for: selectedMonth)
                .contentShape(Rectangle())
        }
        .pdCard()
        .padding(.top, 20)
    }
    
    private var monthPickerView: some View {
        NavigationStack {
            VStack {
                HStack(spacing: 0) {
                    Picker("Month", selection: Binding(
                        get: { Calendar.current.component(.month, from: selectedMonth) },
                        set: { newMonth in
                            let calendar = Calendar.current
                            var components = calendar.dateComponents([.year, .month], from: selectedMonth)
                            components.month = newMonth
                            components.day = 1
                            if let newDate = calendar.date(from: components) {
                                selectedMonth = newDate
                            }
                        }
                    )) {
                        ForEach(1...12, id: \.self) { month in
                            Text(Calendar.current.monthSymbols[month-1]).tag(month)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    Picker("Year", selection: Binding(
                        get: { Calendar.current.component(.year, from: selectedMonth) },
                        set: { newYear in
                            let calendar = Calendar.current
                            var components = calendar.dateComponents([.year, .month], from: selectedMonth)
                            components.year = newYear
                            components.day = 1
                            if let newDate = calendar.date(from: components) {
                                selectedMonth = newDate
                            }
                        }
                    )) {
                        let currentYear = Calendar.current.component(.year, from: Date())
                        ForEach((currentYear-5)...(currentYear+5), id: \.self) { year in
                            Text(String(format: "%d", year)).tag(year)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Select Month & Year")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showMonthPicker = false }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func habitGrid(for date: Date) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
        let daysInMonth = rangeOfDaysInMonth(for: date)
        let firstWeekday = firstWeekdayOfMonth(for: date)
        let offset = firstWeekday - 1
        let habitData = viewModel.monthlyHabitData(for: date)
        let totalCells = daysInMonth + offset

        return LazyVGrid(columns: columns, spacing: 4) {
            let dayInitials = ["S", "M", "T", "W", "T", "F", "S"]
            ForEach(0..<dayInitials.count, id: \.self) { index in
                Text(dayInitials[index])
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color.pdBrownLight)
            }

            ForEach(0..<totalCells, id: \.self) { index in
                if index < offset {
                    Color.clear
                        .aspectRatio(1, contentMode: .fill)
                } else {
                    let day = index - offset + 1
                    let dayData = habitData[day]
                    let count = dayData?.count ?? 0
                    let type = dayData?.type
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(colorForCount(count))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.pdBrown.opacity(count > 0 ? 0 : 0.05), lineWidth: 1)
                            )
                        
                        if let type = type {
                            PoopIconView(bristolType: type, size: 25)
                                .opacity(0.6)
                        }
                        
                        Text("\(day)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(count > 0 ? Color.pdBrown : Color.pdBrownLight)
                    }
                    .aspectRatio(1, contentMode: .fill)
                }
            }
        }
    }

    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return Color.white
        case 1: return Color.pdMint
        case 2: return Color.pdLavender
        default: return Color.pdPink
        }
    }

    private func currentMonthName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func rangeOfDaysInMonth(for date: Date) -> Int {
        Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 30
    }

    private func firstWeekdayOfMonth(for date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let startOfMonth = calendar.date(from: components)!
        return calendar.component(.weekday, from: startOfMonth)
    }
    
    private func changeMonth(by amount: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: amount, to: selectedMonth) {
            withAnimation(.easeInOut) { selectedMonth = newDate }
        }
    }
}

#Preview("Stats") {
    StatsView(viewModel: StoolViewModel(context: CoreDataStack.preview.container.viewContext))
}
