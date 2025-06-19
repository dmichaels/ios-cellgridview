import Foundation
import SwiftUI

extension CellGridView
{
    internal final class Actions
    {
        private let _cellGridView: CellGridView
        private var _dragger: CellGridView.Drag? = nil
        private var _zoomer: CellGridView.Zoom? = nil
        private var _selectMode: Bool = CellGridView.Defaults.selectMode
        private var _automationMode: Bool = CellGridView.Defaults.automationMode
        private var _automationInterval: Double
        private var _automationTimer: Timer? = nil

        internal init(_ cellGridView: CellGridView, automationInterval: Double = Defaults.automationInterval) {
            self._cellGridView = cellGridView
            self._automationInterval = automationInterval
        }

        internal var automationInterval: Double {
            get { return self._automationInterval }
            set {
                if (newValue != self._automationInterval) {
                    self._automationInterval = newValue
                    if (self._automationMode) {
                        self.automationStop()
                        self.automationStart()
                    }
                }
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

        internal var selectMode: Bool {
            self._selectMode
        }

        internal func selectModeToggle() {
            self._selectMode = !self._selectMode
        }

        internal var automationMode: Bool {
            self._automationMode
        }

        internal func automationModeToggle() {
            if (self._automationMode) {
                self._automationMode = false
                self.automationStop()
            }
            else {
                self._automationMode = true
                self.automationStart()
            }
        }

        internal func onDrag(_ viewPoint: CGPoint) {
            guard let dragger: CellGridView.Drag = self._dragger else {
                self._dragger = CellGridView.Drag(self._cellGridView, viewPoint, selectMode: self._selectMode)
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
