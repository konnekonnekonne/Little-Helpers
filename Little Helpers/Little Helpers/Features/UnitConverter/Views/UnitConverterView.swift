import SwiftUI

struct UnitConverterView: View {
    @StateObject private var viewModel = UnitConverterViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            // Category Selection
            Picker("Category", selection: $viewModel.selectedType) {
                ForEach(UnitType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Conversion Interface
            VStack(spacing: 20) {
                // Input Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("From")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("0", text: $viewModel.inputValue)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 34, weight: .medium, design: .monospaced))
                    HStack {
                        Spacer()
                        Picker("", selection: $viewModel.fromUnit) {
                            Text("Select").tag(nil as Unit?)
                            ForEach(Unit.getUnits(for: viewModel.selectedType)) { unit in
                                Text("\(unit.symbol) - \(unit.name)").tag(unit as Unit?)
                            }
                        }
                    }
                }
                
                // Swap Button
                Button(action: viewModel.swapUnits) {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.tint)
                }
                .disabled(viewModel.fromUnit == nil || viewModel.toUnit == nil)
                
                // Output Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("To")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let result = viewModel.convert() {
                        Text(viewModel.formatResult(result))
                            .font(.system(size: 34, weight: .medium, design: .monospaced))
                    } else {
                        Text("--")
                            .font(.system(size: 34, weight: .medium, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Spacer()
                        Picker("", selection: $viewModel.toUnit) {
                            Text("Select").tag(nil as Unit?)
                            ForEach(Unit.getUnits(for: viewModel.selectedType)) { unit in
                                Text("\(unit.symbol) - \(unit.name)").tag(unit as Unit?)
                            }
                        }
                    }
                }
            }
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color(.systemGray4).opacity(0.5), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
            
            Spacer()
            
            // Status Footer
            if viewModel.selectedType == .currency {
                VStack(spacing: 4) {
                    if viewModel.isOffline {
                        Label("Using offline rates", systemImage: "wifi.slash")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let lastUpdated = viewModel.formatLastUpdated() {
                        Label("Updated: \(lastUpdated)", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("Unit Converter")
        .background(Color(.systemGroupedBackground))
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