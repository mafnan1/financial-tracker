import SwiftUI
import Combine

struct Expense: Identifiable {
    let id = UUID()
    var title: String
    var entries: [ExpenseEntry]
    
    struct ExpenseEntry: Identifiable {
        let id = UUID()
        var entryTitle: String
        var amount: Double
    }
}

struct ExpenseListView: View {
    @Binding var expenses: [Expense]
    @Binding var isExpanded: [Bool]
    @Binding var newExpenseTitle: String
    @Binding var newEntryTitle: String
    @Binding var newEntryAmount: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(expenses.indices, id: \.self) { expenseIndex in
                    ExpenseDisclosureView(
                        expense: $expenses[expenseIndex],
                        isExpanded: $isExpanded[expenseIndex],
                        newEntryTitle: $newEntryTitle,
                        newEntryAmount: $newEntryAmount
                    )
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                    .padding(.bottom, 8)
                }
            }
            .padding()
            .alignmentGuide(.top) { _ in 0 }
        }
    }
}

struct ExpenseDisclosureView: View {
    @Binding var expense: Expense
    @Binding var isExpanded: Bool
    @Binding var newEntryTitle: String
    @Binding var newEntryAmount: String

    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                ExpenseDetailView(expense: $expense, newEntryTitle: $newEntryTitle, newEntryAmount: $newEntryAmount)
            },
            label: {
                HStack {
                    Text(expense.title)
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                    Text("Total Amount: \(formattedTotalAmount(for: expense))")
                        .font(.headline)
                }
            }
        )
    }
    
    private func formattedTotalAmount(for expense: Expense) -> String {
        let totalAmount = expense.entries.reduce(0) { $0 + $1.amount }
        return String(format: "$%.2f", totalAmount)
    }
}

struct ExpenseDetailView: View {
    @Binding var expense: Expense
    @Binding var newEntryTitle: String
    @Binding var newEntryAmount: String

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(expense.entries) { entry in
                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text("Title:")
                        .font(.headline)
                    Text(entry.entryTitle)
                        .font(.subheadline)
                    Spacer()
                    Text("Amount:")
                        .font(.headline)
                    Text("$\(formattedAmount(for: entry.amount))")
                        .font(.subheadline)
                }
            }
            Divider()
            Form {
                TextField("New Entry Title", text: $newEntryTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("New Entry Amount", text: $newEntryAmount)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onReceive(Just(newEntryAmount)) { newValue in
                        let filtered = newValue.filter { "0123456789.".contains($0) }
                        if filtered != newValue {
                            newEntryAmount = filtered
                        }
                    }
                Button(action: addEntry) {
                        Text("Add entry")
                }
                .disabled(newEntryTitle.isEmpty || newEntryAmount.isEmpty)
            }
        }
    }

    private func formattedAmount(for amount: Double) -> String {
        return String(format: "%.2f", amount)
    }

    private func addEntry() {
        if let amount = Double(newEntryAmount), !newEntryTitle.isEmpty {
            let newEntry = Expense.ExpenseEntry(entryTitle: newEntryTitle, amount: amount)
            expense.entries.append(newEntry)
            newEntryTitle = ""
            newEntryAmount = ""
        }
    }
}

struct ContentView: View {
    @State private var expenses: [Expense] = [
        Expense(title: "Al-Fateh", entries: [
            Expense.ExpenseEntry(entryTitle: "Lunch", amount: 12),
            Expense.ExpenseEntry(entryTitle: "Dinner", amount: 15),
            Expense.ExpenseEntry(entryTitle: "Snacks", amount: 20)
        ]),
        Expense(title: "Pan shop", entries: [
            Expense.ExpenseEntry(entryTitle: "Chewing Gum", amount: 5),
            Expense.ExpenseEntry(entryTitle: "Cigarettes", amount: 7)
        ]),
        Expense(title: "Stationary", entries: [
            Expense.ExpenseEntry(entryTitle: "Notebooks", amount: 8),
            Expense.ExpenseEntry(entryTitle: "Pens", amount: 10),
            Expense.ExpenseEntry(entryTitle: "Paper", amount: 5)
        ])
    ]
    @State private var newExpenseTitle = ""
    @State private var newEntryTitle = ""
    @State private var newEntryAmount = ""
    @State private var isExpanded: [Bool] = Array(repeating: false, count: 3)

    var body: some View {
        VStack(spacing: 16) {
            Text("Expense Tracker")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 16)

//            
            ExpenseListView(
                expenses: $expenses,
                isExpanded: $isExpanded,
                newExpenseTitle: $newExpenseTitle,
                newEntryTitle: $newEntryTitle,
                newEntryAmount: $newEntryAmount
            )

            Divider()

            Form {
                Section(header: Text("Create New Expense")) {
                    TextField("New Expense Title", text: $newExpenseTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Section {
                    Button(action: createNewExpense) {
                        Text("Create Expense")
                    }
                }
                .disabled(newExpenseTitle.isEmpty)
            }
            .padding()
        }
        .padding()
    }

    private func createNewExpense() {
        if !newExpenseTitle.isEmpty {
            let newExpense = Expense(title: newExpenseTitle, entries: [])
            expenses.append(newExpense)
            isExpanded.append(false)
            newExpenseTitle = ""
        }
    }
}

@main
struct ExpenseTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

