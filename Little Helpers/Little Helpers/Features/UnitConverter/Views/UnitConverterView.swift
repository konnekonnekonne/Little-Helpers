import SwiftUI

// MARK: - Unit Type Picker View
private struct UnitTypePicker: View {
    @Binding var selectedType: UnitType
    
    var body: some View {
        Picker("Unit Type", selection: $selectedType) {
            ForEach(UnitType.allCases) { type in
                Text(type.emoji)
                    .tag(type)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - Currency Status View
private struct CurrencyStatusView: View {
    let isOffline: Bool
    let lastUpdated: String?
    let isRefreshing: Bool
    let onRefresh: () -> Void
    
    @State private var showUpdateMessage = false
    
    var body: some View {
        HStack {
            if showUpdateMessage {
                Text("Exchange rates updated")
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
            Spacer()
            Button(action: {
                onRefresh()
                withAnimation {
                    showUpdateMessage = true
                }
                // Hide the message after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showUpdateMessage = false
                    }
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                    .animation(isRefreshing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
            }
            .disabled(isRefreshing)
        }
        .padding(.horizontal)
    }
}

// MARK: - Unit Picker View
private struct UnitPickerView: View {
    let title: String
    @Binding var selectedUnit: Unit?
    let units: [Unit]
    
    var body: some View {
        Picker(title, selection: $selectedUnit) {
            Text("Select").tag(nil as Unit?)
            ForEach(units) { unit in
                Text("\(unit.symbol) - \(unit.name)")
                    .tag(unit as Unit?)
            }
        }
        .frame(width: 150)
    }
}

// MARK: - Conversion Card View
private struct ConversionCardView: View {
    @Binding var inputValue: String
    @Binding var fromUnit: Unit?
    @Binding var toUnit: Unit?
    let unitType: UnitType
    let convertedResult: Double?
    let formatResult: (Double) -> String
    let onSwap: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // From unit
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("Value", text: $inputValue)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 34, weight: .medium, design: .monospaced))
                    
                    UnitPickerView(
                        title: "From Unit",
                        selectedUnit: $fromUnit,
                        units: Unit.getUnits(for: unitType)
                    )
                }
            }
            
            // Swap button
            Button(action: onSwap) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.title2)
            }
            
            // To unit
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let result = convertedResult {
                        Text(formatResult(result))
                            .font(.system(size: 34, weight: .medium, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    } else {
                        Text("Invalid input")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    UnitPickerView(
                        title: "To Unit",
                        selectedUnit: $toUnit,
                        units: Unit.getUnits(for: unitType)
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
    }
}

// MARK: - Main View
struct UnitConverterView: View {
    @StateObject private var viewModel = UnitConverterViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            UnitTypePicker(selectedType: $viewModel.selectedType)
                .padding(.horizontal)
            
            if viewModel.selectedType == .currency {
                CurrencyStatusView(
                    isOffline: viewModel.isOffline,
                    lastUpdated: viewModel.formatLastUpdated(),
                    isRefreshing: viewModel.isRefreshing,
                    onRefresh: viewModel.refreshCurrencyRates
                )
            } else {
                Color.clear.frame(height: 20)
            }
            
            ConversionCardView(
                inputValue: $viewModel.inputValue,
                fromUnit: $viewModel.fromUnit,
                toUnit: $viewModel.toUnit,
                unitType: viewModel.selectedType,
                convertedResult: viewModel.convert(),
                formatResult: viewModel.formatResult,
                onSwap: viewModel.swapUnits
            )
            
            Spacer()
        }
        .padding(.top)
        .background(Color(.systemGray6))
        .navigationTitle("Unit Converter")
        .onChange(of: viewModel.selectedType) { newType in
            if newType == .currency {
                viewModel.updateCurrencyRatesIfNeeded()
            }
        }
    }
}

#Preview {
    NavigationStack {
        UnitConverterView()
    }
} 