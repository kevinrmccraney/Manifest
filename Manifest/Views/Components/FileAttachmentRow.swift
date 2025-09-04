import SwiftUI

struct FileAttachmentRow: View {
    @Bindable var attachment: FileAttachment
    let onPreview: () -> Void
    let onDelete: () -> Void
    @State private var isEditingDescription = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: onPreview) {
                    HStack {
                        Image(systemName: attachment.fileIcon)
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(attachment.filename)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                            
                            Text(attachment.formattedFileSize)
                                .font(.caption2)
                                .foregroundColor(.tertiary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "eye.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Button("Delete") {
                    onDelete()
                }
                .foregroundColor(.red)
                .font(.caption)
            }
            
            HStack {
                if isEditingDescription {
                    TextField("Description", text: $attachment.fileDescription)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            isEditingDescription = false
                        }
                } else {
                    Text(attachment.fileDescription)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .onTapGesture {
                            isEditingDescription = true
                        }
                    
                    Spacer()
                    
                    Button("Edit") {
                        isEditingDescription = true
                    }
                    .font(.caption2)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}
