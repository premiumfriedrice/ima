//
//  TaskArchiveView.swift
//  ima/Views/UserTaskViews
//
//  Archive of completed tasks, grouped by date.
//

import SwiftUI
import SwiftData

struct TaskArchiveView: View {
    let tasks: [UserTask]
    @Environment(\.appBackground) private var appBackground
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTask: UserTask?

    var body: some View {
        ZStack {
            appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header matching info sheet style
                VStack(alignment: .leading, spacing: 10) {
                    Text("TASKS")
                        .font(.caption2)
                        .textCase(.uppercase)
                        .kerning(1.0)
                        .opacity(0.5)
                        .foregroundStyle(.white)

                    Text("Archive")
                        .font(.title)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 25)
                .padding(.top, 12)
                .padding(.bottom, 16)

            if tasks.isEmpty {
                VStack {
                    Spacer()
                    Text("No completed tasks yet")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.3))
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(tasks.sorted(by: { ($0.dateCompleted ?? .distantPast) > ($1.dateCompleted ?? .distantPast) })) { task in
                            UserTaskCardView(task: task)
                                .onTapGesture { selectedTask = task }
                        }

                        Color.clear.frame(height: 100)
                    }
                }
                .scrollIndicators(.hidden)
            }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("")
        .toolbarBackground(appBackground, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(item: $selectedTask) { task in
            UserTaskInfoView(userTask: task)
        }
    }
}
