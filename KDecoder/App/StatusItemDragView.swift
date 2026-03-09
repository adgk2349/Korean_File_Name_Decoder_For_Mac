//
//  StatusItemDragView.swift
//  KDecoder
//
//  Created by adgk2349 on 3/2/26.
//

import AppKit

/// 메뉴 바 아이콘 위에서 파일 드래그를 감지하여 팝오버를 열어주는 투명한 뷰
class StatusItemDragView: NSView {
    var onDragEntered: (() -> Void)?
    var onDragExited: (() -> Void)?

    private var isDraggingOver = false
    private var hideWorkItem: DispatchWorkItem?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        hideWorkItem?.cancel()
        isDraggingOver = true
        onDragEntered?()
        return .copy
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        isDraggingOver = false

        // 아이콘에서 마우스가 벗어나면 창이 곧바로 닫히지 않고,
        // 사용자가 팝오버 영역으로 마우스를 옮길 시간을 벌어줍니다 (0.8초)
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self, !self.isDraggingOver else { return }
            self.onDragExited?()
        }
        self.hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: workItem)
    }
}
