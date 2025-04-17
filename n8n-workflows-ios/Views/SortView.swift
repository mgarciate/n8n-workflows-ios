//
//  SortView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 22/12/24.
//

import SwiftUI

public enum WorkflowSortOption: String, CaseIterable {
    case name = "Name"
    case createdAt = "Created"
    case updatedAt = "Updated"
}

extension WorkflowSortOption {
    static var defaultValue: WorkflowSortOption { .updatedAt }
}

public enum SortOrder: String, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"
}

extension SortOrder {
    static var defaultValue: SortOrder { .descending }
}

struct SortView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("sort") private var selectedSortOption: WorkflowSortOption = WorkflowSortOption.defaultValue
    @AppStorage("order") private var selectedSortOrder: SortOrder = SortOrder.defaultValue

    var body: some View {
        NavigationStack {
            List {
                Section("Sort by") {
                    ForEach(WorkflowSortOption.allCases, id: \.self) { sortOption in
                        HStack {
                            Text(sortOption.rawValue)
                            Spacer()
                            if sortOption == selectedSortOption {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle()) // Make the whole row tappable
                        .onTapGesture {
                            selectedSortOption = sortOption // Update the selected option
                        }
                    }
                }
                Section("Order") {
                    ForEach(SortOrder.allCases, id: \.self) { sortOrder in
                        HStack {
                            Text(sortOrder.rawValue)
                            Spacer()
                            if sortOrder == selectedSortOrder {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle()) // Make the whole row tappable
                        .onTapGesture {
                            selectedSortOrder = sortOrder // Update the selected order
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}

#Preview {
    SortView()
}
