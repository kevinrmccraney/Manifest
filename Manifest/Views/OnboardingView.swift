//
//  OnboardingView.swift
//  Manifest
//
//  Created by Assistant on 2025-09-22.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentPage = 0
    @State private var showingAddItem = false
    let onComplete: () -> Void
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "tray.fill",
            title: "Welcome to Manifest",
            subtitle: "Organize and track all your belongings with ease",
            description: "Keep a digital inventory of your items with photos, descriptions, and smart organization features."
        ),
        OnboardingPage(
            icon: "plus.circle.fill",
            title: "Add Your Items",
            subtitle: "Create detailed records",
            description: "Add photos, descriptions, tags, and even attach files to keep all relevant information in one place."
        ),
        OnboardingPage(
            icon: "magnifyingglass.circle.fill",
            title: "Find Anything Instantly",
            subtitle: "Search, sort, and organize",
            description: "Use powerful search and sorting options to quickly locate any item in your inventory."
        ),
        OnboardingPage(
            icon: "qrcode",
            title: "Physical Connections",
            subtitle: "NFC tags and QR codes",
            description: "Generate QR codes or write NFC tags to bridge the physical and digital worlds."
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress indicator
            HStack {
                ForEach(0..<pages.count, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index <= currentPage ? .blue : Color(.systemGray4))
                        .frame(height: 4)
                        .animation(.easeInOut(duration: 0.3), value: currentPage)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Skip button
            HStack {
                Spacer()
                Button("Skip") {
                    completeOnboarding()
                }
                .foregroundStyle(.secondary)
                .padding(.trailing)
            }
            .padding(.top, 8)
            
            // Content
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Bottom buttons
            VStack(spacing: 16) {
                if currentPage < pages.count - 1 {
                    // Continue button
                    Button("Continue") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                } else {
                    // Final page buttons
                    VStack(spacing: 12) {
                        Button("Add My First Item") {
                            showingAddItem = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button("I'll Do This Later") {
                            completeOnboarding()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.secondaryBackground.ignoresSafeArea())
        .sheet(isPresented: $showingAddItem) {
            AddEditItemView()
                .onDisappear {
                    completeOnboarding()
                }
        }
    }
    
    private func completeOnboarding() {
        OnboardingManager.shared.markOnboardingComplete()
        onComplete()
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            // Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
    }
}

//
//  OnboardingManager.swift
//  Manifest
//
//  Created by Assistant on 2025-09-22.
//

import Foundation

@Observable
class OnboardingManager {
    static let shared = OnboardingManager()
    
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
    }
    
    private init() {}
    
    func markOnboardingComplete() {
        UserDefaults.standard.set(true, forKey: hasCompletedOnboardingKey)
    }
    
    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: hasCompletedOnboardingKey)
    }
}
