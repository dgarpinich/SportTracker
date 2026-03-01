//
//  ActivityCardView.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 23.02.2026.
//

import SwiftUI

struct ActivityCardView: View {
    let record: ActivityRecord
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: record.storageType == .local ? "iphone" : "cloud")
                .font(.title2)
                .foregroundStyle(record.storageType == .local ? .green : .blue)

            VStack(alignment: .leading, spacing: 6) {
                Text(record.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(record.location)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text(record.formattedDuration)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.05), lineWidth: 1)
            )
    }
}

#Preview {
    ZStack {
            Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 16) {
                ActivityCardView(record: ActivityRecord(
                    title: "Ranní běh",
                    location: "Stromovka",
                    durationInMinutes: 45,
                    storageType: .remote
                ))
                .preferredColorScheme(.light)
                
                ActivityCardView(record: ActivityRecord(
                    title: "Cyklovýlet",
                    location: "Karlštejn",
                    durationInMinutes: 138,
                    storageType: .local
                ))
                .preferredColorScheme(.dark)
            }
            .padding()
        }
}
