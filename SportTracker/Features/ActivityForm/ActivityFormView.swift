//
//  ActivityFormView.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 25.02.2026.
//

import SwiftUI

struct ActivityFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    let viewModel: ActivityFormViewModel
    var onDismiss: (Bool) -> Void
    
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var hours: Int = 0
    @State private var minutes: Int = 15
    @State private var storageType: StorageType = .local
    
    private var isLoading: Bool {
        if case .loading = viewModel.state { return true }
        return false
    }
    
    private var isFormValid: Bool {
        let hasText = !title.trimmingCharacters(in: .whitespaces).isEmpty && !location.trimmingCharacters(in: .whitespaces).isEmpty
        let hasTime = (hours * 60 + minutes) > 0
        
        return hasText && hasTime
    }
    
    var body: some View {
        NavigationStack {
            Form {
                storageSection
                detailsSection
                durationSection
                errorSection
            }
            .navigationTitle(.formTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(.commonCancel) {
                        onDismiss(false)
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(.commonSave) { save() }
                        .disabled(!isFormValid || isLoading)
                }
            }
            .overlay {
                if isLoading { loadingOverlay }
            }
            .onChange(of: viewModel.state) {
                if case .saved = viewModel.state {
                    onDismiss(true)
                    dismiss()
                }
            }
        }
    }
    
    private var storageSection: some View {
        Section(header: Text(.formSectionStorage)) {
            Picker(.formStorageSaveTo, selection: $storageType) {
                Text(.formStorageLocal).tag(StorageType.local)
                Text(.formStorageRemote).tag(StorageType.remote)
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    private var detailsSection: some View {
        Section(header: Text(.formSectionDetails)) {
            TextField(.formFieldTitlePlaceholder, text: $title)
            TextField(.formFieldLocationPlaceholder, text: $location)
        }
    }
    
    private var durationSection: some View {
        Section(header: Text(.formSectionDuration)) {
            HStack(spacing: 0) {
                Picker(.formDurationHours, selection: $hours) {
                    ForEach(0...23, id: \.self) { hour in
                        Text(.formHoursValue(hour)).tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .clipped()
                Picker(selection: $minutes, label: Text(.formDurationMinutes)) {
                    ForEach(0...59, id: \.self) { minute in
                        Text(.formMinutesValue(minute)).tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .clipped()
            }
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.1).ignoresSafeArea()
            ProgressView()
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    private var errorSection: some View {
        if case let .error(message) = viewModel.state {
            Section {
                Text(message)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
            .listRowBackground(Color.clear)
        }
    }

    
    private func save() {
        let formData = ActivityFormViewModel.FormData(
            title: title,
            location: location,
            duration: (hours * 60) + minutes,
            storageType: storageType
        )
        
        viewModel.send(.save(formData))
    }
}

//#Preview {
//    let mockRepo = MockActivityRepository()
//    let viewModel = ActivityFormViewModel(repository: mockRepo)
//    
//    ActivityFormView(viewModel: viewModel)
//}
