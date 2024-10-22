//
//  SelectableWorkflowsView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 19/10/24.
//

import SwiftUI

struct SelectableWorkflowsView: View {
    @Environment(\.dismiss) private var dismiss
    let workflows: [Workflow]
    @Binding var selectedIds: [String]

    var body: some View {
        NavigationStack {
            Form {
                SelectableItemsView(workflows, selectedIds: $selectedIds) { workflow, isSelected in
                    HStack {
                        Text(workflow.name)
                        Spacer()
                        if isSelected.wrappedValue {
                            Image(systemName: "checkmark")
                                .foregroundColor(Color("AccentColor"))
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isSelected.wrappedValue.toggle()
                    }
                }
            }
            .navigationTitle("Select workflows")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SelectableWorkflowsView(
        workflows: Workflow.dummyWorkflows,
        selectedIds: .constant([Workflow.dummyWorkflows[0].id]))
}
