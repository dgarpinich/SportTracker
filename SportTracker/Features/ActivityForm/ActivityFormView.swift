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
            .navigationTitle("New Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss(false)
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
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
        Section(header: Text("Storage")) {
            Picker("Save to", selection: $storageType) {
                Text("Local").tag(StorageType.local)
                Text("Remote").tag(StorageType.remote)
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    private var detailsSection: some View {
        Section(header: Text("Activity Details")) {
            TextField("Title (e.g., Morning Run)", text: $title)
            TextField("Location (e.g., Stromovka)", text: $location)
        }
    }
    
    private var durationSection: some View {
        Section(header: Text("Duration")) {
            HStack(spacing: 0) {
                Picker("Hours", selection: $hours) {
                    ForEach(0...23, id: \.self) { hour in
                        Text("\(hour) h").tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .clipped()
                Picker(selection: $minutes, label: Text("minutes")) {
                    ForEach(0...59, id: \.self) { minute in
                        Text("\(minute) min").tag(minute)
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
