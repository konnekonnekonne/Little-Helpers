import SwiftUI

struct TipCalculatorView: View {
    @StateObject private var viewModel = TipCalculatorViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Mode Selector
                Picker("Calculation Mode", selection: $viewModel.mode) {
                    ForEach(TipCalculatorMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Input Card
                VStack(spacing: 16) {
                    // Bill Amount
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Bill Amount")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text(viewModel.currencySymbol)
                                .foregroundStyle(.secondary)
                            TextField("0.00", text: $viewModel.billAmount)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: viewModel.billAmount) { _, newValue in
                                    viewModel.handleNumberInput(newValue, for: &viewModel.billAmount)
                                }
                        }
                        .font(.title2)
                    }
                    
                    Divider()
                    
                    if viewModel.mode == .calculateTotal {
                        // Tip Percentage Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tip Percentage")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            // Quick Tip Options
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(viewModel.quickTipOptions) { option in
                                        Button(action: {
                                            viewModel.setQuickTip(option)
                                        }) {
                                            Text(option.formatted)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(viewModel.tipPercentage == option.percentage ? Color.accentColor : Color(.systemGray5))
                                                )
                                                .foregroundStyle(viewModel.tipPercentage == option.percentage ? .white : .primary)
                                        }
                                    }
                                }
                            }
                            
                            // Custom Percentage Slider
                            Slider(value: $viewModel.tipPercentage, in: 0...100, step: 1) {
                                Text("Tip Percentage")
                            } minimumValueLabel: {
                                Text("0%")
                            } maximumValueLabel: {
                                Text("100%")
                            }
                            
                            Text(viewModel.formatPercentage(viewModel.tipPercentage))
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    } else {
                        // Total Amount Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Total Amount Paid")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            HStack {
                                Text(viewModel.currencySymbol)
                                    .foregroundStyle(.secondary)
                                TextField("0.00", text: $viewModel.totalAmount)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: viewModel.totalAmount) { _, newValue in
                                        viewModel.handleNumberInput(newValue, for: &viewModel.totalAmount)
                                    }
                            }
                            .font(.title2)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                        .shadow(color: Color(.systemGray4).opacity(0.5), radius: 4)
                )
                .padding(.horizontal)
                
                // Results Card
                VStack(spacing: 16) {
                    ResultRow(title: "Tip Amount", amount: viewModel.tipAmount, currencySymbol: viewModel.currencySymbol)
                    Divider()
                    if viewModel.mode == .calculateTotal {
                        ResultRow(title: "Total", amount: viewModel.calculatedTotal, currencySymbol: viewModel.currencySymbol)
                    } else {
                        ResultRow(title: "Tip Percentage", value: viewModel.formatPercentage(viewModel.calculatedPercentage))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                        .shadow(color: Color(.systemGray4).opacity(0.5), radius: 4)
                )
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Tip Calculator")
    }
}

struct ResultRow: View {
    let title: String
    var amount: Double? = nil
    var value: String? = nil
    var currencySymbol: String = "€"
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            if let amount = amount {
                Text("\(currencySymbol)\(String(format: "%.2f", amount))")
                    .font(.headline)
            } else if let value = value {
                Text(value)
                    .font(.headline)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TipCalculatorView()
    }
} 