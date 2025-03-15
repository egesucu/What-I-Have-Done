import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.date, ascending: false)],
        animation: .default)
    private var activities: FetchedResults<Activity>
    
    @State private var isAddingActivity = false
    @State private var selectedCategory: ActivityCategory? = nil
    @State private var selectedDateFilter: DateFilter = .all

    var body: some View {
        NavigationView {
            VStack {
                filterBar
                
                List {
                    ForEach(filteredActivities()) { activity in
                        NavigationLink {
                            Text("Activity: \(activity.title!)")
                        } label: {
                            VStack(alignment: .leading) {
                                Text(activity.title!)
                                    .font(.headline)
                                Text(activity.date ?? Date(), style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Activity Log")
            .overlay(addButton, alignment: .bottom)
        }
        .sheet(isPresented: $isAddingActivity) {
            ActivityAddView(isPresented: $isAddingActivity)
                .transition(.move(edge: .top))
        }
    }

    private var filterBar: some View {
        HStack {
            Picker("Category", selection: $selectedCategory) {
                Text("All").tag(nil as ActivityCategory?)
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category as ActivityCategory?)
                }
            }
            .pickerStyle(.menu)
            
            Picker("Date", selection: $selectedDateFilter) {
                ForEach(DateFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.menu)
        }
        .padding()
    }

    private var addButton: some View {
        Button(action: {
            isAddingActivity.toggle()
        }) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
                .shadow(radius: 5)
        }
        .padding()
    }

    private func filteredActivities() -> [Activity] {
        activities.filter { activity in
            let categoryMatches = selectedCategory == nil || activity.category == selectedCategory
            let dateMatches = selectedDateFilter.matches(activity.date)
            return categoryMatches && dateMatches
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { activities[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// Enum for date filtering
enum DateFilter: String, CaseIterable {
    case all = "All"
    case thisWeek = "This Week"
    case thisMonth = "This Month"

    func matches(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        let calendar = Calendar.current
        switch self {
        case .all:
            return true
        case .thisWeek:
            return calendar.isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
        case .thisMonth:
            return calendar.isDate(date, equalTo: Date(), toGranularity: .month)
        }
    }
}

#Preview {
    ContentView()
        .environment(
            \.managedObjectContext,
             PersistenceController.preview.container.viewContext
        )
}
