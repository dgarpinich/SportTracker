//
//  DashboardView.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 25.02.2026.
//

import SwiftUI

struct DashboardView: View {
    var viewModel: DashboardViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView("Loading activities...")
                        .controlSize(.large)
                    
                case .success(let records, let filter, let warningMessage):
                    SuccessView(
                        records: records,
                        filter: filter,
                        onChangeFilter: { viewModel.send(.setFilter($0)) }
                    )
                    .alert(
                        "Warning",
                        isPresented: Binding(
                            get: { warningMessage != nil },
                            set: { isPresented in
                                if !isPresented {
                                    viewModel.send(.dismissWarningAlert)
                                }
                            }
                        ),
                        actions: { Button("Ok", role: .cancel) { } },
                        message: { Text(warningMessage ?? "") }
                    )
                    
                case .error(let message):
                    ErrorView(
                        message: message,
                        onTryAginTap: { viewModel.send(.onAppear) }
                    )
                    .padding()
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", systemImage: "plus.circle.fill") {
                        viewModel.send(.tapAddActivity)
                    }
                }.sharedBackgroundVisibility(.hidden)
            }
            .sheet(item: Binding(
                get: { viewModel.destination },
                set: { if $0 == nil { viewModel.send(.dissmissForm) } }
            )) { destination in
                switch destination {
                case .form(let formViewModel):
                    ActivityFormView(viewModel: formViewModel)
                }
            }
            .onAppear { viewModel.send(.onAppear) }
        }
    }
}

extension DashboardView {
    private struct SuccessView: View {
        let records: [ActivityRecord]
        let filter: ActivityFilter
        let onChangeFilter: (ActivityFilter) -> Void
        
        var body: some View {
            ScrollView {
                Picker("Filter", selection: Binding(
                    get: { filter },
                    set: { onChangeFilter($0) }
                )) {
                    ForEach(ActivityFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Group {
                    if records.isEmpty {
                        ContentUnavailableView(
                            "No activities yet.",
                            systemImage: "figure.run",
                            description: Text("Time to start your first workout!")
                        )
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(records) { record in
                                ActivityCardView(record: record)
                            }
                        }
                        .padding(.top, 16)
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private struct ErrorView: View {
        let message: String
        let onTryAginTap: () -> Void
        
        var body: some View {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.red)
                
                Text(message)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                Button("Try Again") { onTryAginTap() }
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    let mockRepo = MockActivityRepository()
    let viewModel = DashboardViewModel(repository: mockRepo)
    
    DashboardView(viewModel: viewModel)
}
