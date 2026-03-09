//
//  DropZoneView.swift
//  KDecoder
//
//  Created by adgk2349 on 3/2/26.
//

import SwiftUI

/// 파일 드래그 앤 드롭 영역을 표시하는 재사용 가능한 뷰
struct DropZoneView: View {
    let isTargeted: Bool
    let message: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.clear)

            VStack(spacing: 15) {
                Image(systemName: isTargeted ? "arrow.down.doc.fill" : "doc.badge.arrow.up")
                    .font(.system(size: 50))
                    .foregroundColor(isTargeted ? .accentColor : .secondary)
                    .padding(.bottom, 5)
                Text(isTargeted ? "여기에 놓으세요" : message)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect(.regular.tint(isTargeted ? .accentColor : .clear), in: .rect(cornerRadius: 20))
        .animation(.easeInOut(duration: 0.2), value: isTargeted)
    }
}
