//
//  UnifiedEmptyStateView.swift
//  Manifest
//
//  Single reusable empty state component
//

import SwiftUI

struct UnifiedEmptyStateView: View {
    let config: EmptyStateConfig
    
    struct EmptyStateConfig {
        let icon: String
        let title: String
        let subtitle: String
        let primaryAction: ActionConfig?
        let secondaryAction: ActionConfig?
        
        struct ActionConfig {
            let title: String
            let action: () -> Void
            let style: ButtonStyle
            
            enum ButtonStyle {
                case prominent
                case bordered
                case plain
            }
        }
        
        // Predefined configurations
        static func noItems(onAddItem: @escaping () -> Void) -> EmptyStateConfig {
            return EmptyStateConfig(
                icon: "tray",
                title: "No Items Yet",
                subtitle: "Tap the + button to add your first item",
                primaryAction: ActionConfig(
                    title: "Add Item",
                    action: onAddItem,
                    style: .prominent
                ),
                secondaryAction: nil
            )
        }
        
        static func noSearchResults(searchText: String) -> EmptyStateConfig {
            return EmptyStateConfig(
                icon: "magnifyingglass",
                title: "No Results Found",
                subtitle: "No items found for \"\(searchText)\"\n\nTry searching with different keywords or check your spelling.",
                primaryAction: nil,
                secondaryAction: nil
            )
        }
        
        static func noArchivedItems(onBackToItems: @escaping () -> Void) -> EmptyStateConfig {
            return EmptyStateConfig(
                icon: "tray",
                title: "No Archived Items",
                subtitle: "Items you archive will appear here",
                primaryAction: ActionConfig(
                    title: "Back to All Items",
                    action: onBackToItems,
                    style: .prominent
                ),
                secondaryAction: nil
            )
        }
        
        static func errorState(title: String, subtitle: String, onRetry: (() -> Void)? = nil) -> EmptyStateConfig {
            return EmptyStateConfig(
                icon: "exclamationmark.triangle",
                title: title,
                subtitle: subtitle,
                primaryAction: onRetry.map { retry in
                    ActionConfig(title: "Try Again", action: retry, style: .prominent)
                },
                secondaryAction: nil
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: config.icon)
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text(config.title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(config.subtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                if let primaryAction = config.primaryAction {
                    makeButton(for: primaryAction)
                }
                
                if let secondaryAction = config.secondaryAction {
                    makeButton(for: secondaryAction)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func makeButton(for action: EmptyStateConfig.ActionConfig) -> some View {
        switch action.style {
        case .prominent:
            Button(action.title) {
                action.action()
            }
            .buttonStyle(.borderedProminent)
            
        case .bordered:
            Button(action.title) {
                action.action()
            }
            .buttonStyle(.bordered)
            
        case .plain:
            Button(action.title) {
                action.action()
            }
            .buttonStyle(.plain)
        }
    }
}
