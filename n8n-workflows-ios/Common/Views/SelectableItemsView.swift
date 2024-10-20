//
//  SelectableItemsView.swift
//  n8n-workflows-ios
//
//  Created by mgarciate on 19/10/24.
//

import SwiftUI

// https://medium.com/@artur.hellmann_85960/a-swiftui-selectable-list-dc56d51541b8
struct SelectableItemsView<Data, ID: Hashable, Content>: View where Content: View {
    let data: [Data]
    @Binding var selectedIds: [ID]
    let id: KeyPath<Data, ID>
    let content: (Data, Binding<Bool>) -> Content

    init(
        _ data: [Data],
        selectedIds: Binding<[ID]>,
        id: KeyPath<Data, ID>,
        @ViewBuilder content: @escaping (Data, Binding<Bool>) -> Content
    ) {
        self.data = data
        self._selectedIds = selectedIds
        self.id = id
        self.content = content
    }

    var body: some View {
        ForEach(data.indices, id: \.self) { index in
            self.content(self.data[index], Binding(
                get: { self.selectedIds.contains(self.data[index][keyPath: self.id]) },
                set: { isSelected in
                    if isSelected {
                        self.selectedIds.append(self.data[index][keyPath: self.id])
                    } else {
                        self.selectedIds.removeAll(where: { $0 == self.data[index][keyPath: self.id] })
                    }
                }
            ))
        }
    }
}

extension SelectableItemsView where ID == Data.ID, Data: Identifiable {
    init(
        _ data: [Data],
        selectedIds: Binding<[ID]>,
        @ViewBuilder content: @escaping (Data, Binding<Bool>) -> Content
    ) {
        self.init(
            data,
            selectedIds: selectedIds,
            id: \Data.id, content: content
        )
    }
}
