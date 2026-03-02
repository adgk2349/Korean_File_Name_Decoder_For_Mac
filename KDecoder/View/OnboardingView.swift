//
//  OnboardingView.swift
//  KDecoder
//
//  Created by Seung Min Lee on 3/2/26.
//

import SwiftUI

/// 첫 실행 시 폴더 접근 권한 안내를 보여주는 온보딩 뷰
struct OnboardingView: View {
    var onGrantAccess: () -> Void

    var body: some View {
        GlassEffectContainer {
            VStack(spacing: 20) {
                Spacer()

                Image(systemName: "folder.badge.plus")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)

                Text("KDecoder를 시작하기 전에")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("파일 이름을 변경하려면 폴더 접근 권한이 필요합니다.\n아래 버튼을 누른 뒤, 최상위 폴더(Macintosh HD)를\n선택해주세요.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .lineSpacing(4)

                VStack(alignment: .leading, spacing: 8) {
                    Label("한 번만 설정하면 이후로는 묻지 않습니다", systemImage: "checkmark.circle.fill")
                    Label("파일 내용은 읽지 않고, 이름만 변경합니다", systemImage: "lock.shield.fill")
                }
                .font(.callout)
                .foregroundColor(.secondary)
                .padding(.vertical, 5)
                .padding(.horizontal, 20)
                .glassEffect(.regular, in: .rect(cornerRadius: 12))

                Spacer()

                Button(action: onGrantAccess) {
                    Text("폴더 접근 허용하기")
                        .frame(maxWidth: .infinity)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 30)
                .glassEffect(.regular.interactive(), in: .capsule)

                Text("설정 > 개인정보 보호에서 언제든 해제할 수 있습니다")
                    .font(.caption2)
                    .foregroundColor(.secondary.opacity(0.6))

                Spacer()
                    .frame(height: 10)
            }
            .padding(25)
            .frame(minWidth: 450, idealWidth: 450, minHeight: 450, idealHeight: 450)
        }
    }
}
