//
//  ContentView.swift
//  KDecoder
//
//  Created by Seung Min Lee on 3/2/26.
//

import SwiftUI
import UniformTypeIdentifiers

/// 버전 버튼 — 호버 시 밝아지는 효과
private struct VersionButton: View {
    @State private var isHovered = false

    var body: some View {
        Button(action: {
            if let url = URL(string: "https://github.com/adgk2349") {
                NSWorkspace.shared.open(url)
            }
        }) {
            Text("v1.0.1")
                .font(.caption2)
                .foregroundColor(isHovered ? .primary : .secondary)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

/// 메인 UI를 담당하는 View — 상태와 로직은 ContentViewModel에 위임
struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        Group {
            if viewModel.hasAccess {
                mainView
            } else {
                OnboardingView {
                    viewModel.requestAccessIfNeeded()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenFiles"))) { notification in
            viewModel.handleOpenFilesNotification(notification)
        }
    }

    // MARK: - 메인 화면

    private var mainView: some View {
        GlassEffectContainer {
            VStack(spacing: 15) {
                // 헤더
                HStack {
                    Text("KDecoder")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Toggle("바탕화면에 유지", isOn: $viewModel.saveToDesktop)
                        .toggleStyle(.checkbox)
                }
                .padding(.horizontal)

                // 드롭 영역
                DropZoneView(isTargeted: viewModel.isTargeted, message: viewModel.resultMessage)
                    .onDrop(of: [.fileURL], isTargeted: $viewModel.isTargeted) { providers in
                        viewModel.processDroppedFiles(providers: providers)
                        return true
                    }

                // 하단 바
                HStack {
                    Button(action: viewModel.selectFilesManually) {
                        Label("직접 선택", systemImage: "plus.circle")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                    .glassEffect(.regular.interactive(), in: .capsule)

                    Spacer()

                    VersionButton()
                }
                .padding(.horizontal)
            }
            .padding(25)
            .frame(minWidth: 450, idealWidth: 450, minHeight: 450, idealHeight: 450)
        }
    }
}
