import Foundation
import SwiftUI

extension CellGridView
{
    internal final class Actions
    {
        private let _cellGridView: CellGridView
        private var _automationInterval: Double
        private var _automation: Bool = false
        private var _automationTimer: Timer? = nil
        private var _dragger: CellGridView.Drag? = nil
        private var _zoomer: CellGridView.Zoom? = nil
        private var _paintMode: Bool = false
        private var _playMode: Bool = false

        internal init(_ cellGridView: CellGridView, automationInterval: Double = Defaults.automationInterval) {
            self._cellGridView = cellGridView
            self._automationInterval = automationInterval
        }

        internal var automationInterval: Double {
            get { return self._automationInterval }
            set {
                if (newValue != self._automationInterval) {
                    self._automationInterval = newValue
                    if (self._automation) {
                        self.automationStop()
                        self.automationStart()
                    }
                }
            }
        }

        internal func automationToggle() {
            if (self._automation) {
                self.automationStop()
                self._automation = false
            }
            else {
                self.automationStart()
                self._automation = true
            }
        }

        internal func automationStart() {
            self._automationTimer = Timer.scheduledTimer(withTimeInterval: self._automationInterval, repeats: true) { _ in
                self._cellGridView.automationStep()
            }
        }

        internal func automationStop() {
            if let automationTimer = self._automationTimer {
                automationTimer.invalidate()
                self._automationTimer = nil
            }
        }

        internal func onTap(_ viewPoint: CGPoint) {
            if let cell: Cell = self._cellGridView.gridCell(viewPoint: viewPoint) {
                cell.select()
                self._cellGridView.onChangeImage()
            }
        }

        internal func togglePaintMode() {
            self._paintMode = !self._paintMode
        }

        internal func togglePlayMode() {
            self._playMode = !self._playMode
            self.automationToggle()
        }

        internal func onDrag(_ viewPoint: CGPoint) {
            guard let dragger: CellGridView.Drag = self._dragger else {
                self._dragger = CellGridView.Drag(self._cellGridView, viewPoint, paintMode: self._paintMode)
                return
            }
            dragger.drag(viewPoint)
            self._cellGridView.onChangeImage()
        }

        internal func onDragEnd(_ viewPoint: CGPoint) {
            if let dragger: CellGridView.Drag = self._dragger {
                dragger.end(viewPoint)
                self._dragger = nil
                self._cellGridView.onChangeImage()
            }
        }

        internal func onZoom(_ zoomFactor: CGFloat) {
            if let zoomer: CellGridView.Zoom = self._zoomer {
                zoomer.zoom(zoomFactor)
            }
            else {
                self._zoomer = CellGridView.Zoom(self._cellGridView, zoomFactor)
            }
            self._cellGridView.onChangeImage()
        }

        internal func onZoomEnd(_ zoomFactor: CGFloat) {
            if let zoomer: CellGridView.Zoom = self._zoomer {
                zoomer.end(zoomFactor)
                self._zoomer = nil
            }
        }
    }
}
