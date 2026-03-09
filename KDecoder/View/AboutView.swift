//
//  AboutView.swift
//  KDecoder
//
//  Created by adgk2349 on 3/2/26.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더 그라디언트 영역
            ZStack {
                LinearGradient(
                    colors: [Color.accentColor.opacity(0.8), Color.accentColor.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                VStack(spacing: 12) {
                    Image(nsImage: NSApplication.shared.applicationIconImage)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)

                    Text("KDecoder")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("for Mac")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .offset(y: -8)
                }
                .padding(.vertical, 32)
            }
            .frame(maxWidth: .infinity)

            // 하단 정보 영역
            VStack(spacing: 16) {
                // 버전 정보
                infoRow(label: "버전", value: "2.0.1")
                Divider().opacity(0.4)
                infoRow(label: "개발자", value: "adgk2349")
                Divider().opacity(0.4)
                infoRow(label: "라이선스", value: "MIT License")
                Divider().opacity(0.4)

                // 설명
                Text("윈도우에서 옮긴 한글 파일명이 깨질 때,\n드래그 한 번으로 즉시 복원하는 메뉴바 앱입니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)

                // GitHub 링크 버튼
                Button(action: {
                    if let url = URL(string: "https://github.com/adgk2349/KDecoder_for_Mac") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    Label("GitHub에서 보기", systemImage: "arrow.up.right.square")
                        .font(.caption)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 7)
                }
                .buttonStyle(.plain)
                .background(
                    Capsule()
                        .fill(Color.accentColor.opacity(0.15))
                )
                .overlay(
                    Capsule()
                        .strokeBorder(Color.accentColor.opacity(0.3), lineWidth: 1)
                )

                Text("Copyright (c) 2026 adgk2349")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(24)
            .frame(maxWidth: .infinity)
        }
        .frame(width: 320)
        .background(Color(NSColor.windowBackgroundColor))
    }

    // MARK: - Helper

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}
