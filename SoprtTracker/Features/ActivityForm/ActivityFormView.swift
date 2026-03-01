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
        let hasText = !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !location.trimmingCharacters(in: .whitespaces).isEmpty
        let hasTime = (hours * 60 + minutes) > 0
        return hasText && hasTime
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Storage")) {
                    Picker("Save to", selection: $storageType) {
                        Text("Local").tag(StorageType.local)
                        Text("Remote").tag(StorageType.remote)
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                Section(header: Text("Activity Details")) {
                    TextField("Title (e.g., Morning Run)", text: $title)
                    TextField("Location (e.g., Stromovka)", text: $location)
                }
                
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
                
                if case let .error(message) = viewModel.state {
                    Section {
                        Text(message)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("New Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isLoading)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveActivity() }
                        .disabled(!isFormValid || isLoading)
                }
            }
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.1).ignoresSafeArea()
                        ProgressView()
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
    
    private func saveActivity() {
        Task {
            let duration = (hours * 60) + minutes
            
            let formData = ActivityFormViewModel.FormData(
                title: title,
                location: location,
                duration: duration,
                storageType: storageType
            )
            
            let success = await viewModel.send(.save(formData))
            if success { dismiss() }
        }
    }
}

#Preview {
    let mockRepo = MockActivityRepository()
    let viewModel = ActivityFormViewModel(repository: mockRepo)
    
    ActivityFormView(viewModel: viewModel)
}
