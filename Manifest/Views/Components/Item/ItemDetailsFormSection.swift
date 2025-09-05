//
//  ItemDetailsFormSection.swift
//  Manifest
//
//  Created by Kevin McCraney on 2025-09-03.
//

import SwiftUI

struct ItemDetailsFormSection: View {
    @Binding var name: String
    @Binding var description: String
    
    var body: some View {
        Section(header: Text("Item Details")) {
            TextField("Name", text: $name)
            
            TextField("Description", text: $description, axis: .vertical)
                .lineLimit(3...6)
        }
    }
}
