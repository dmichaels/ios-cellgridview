import Foundation
import SwiftUI

extension CellGridView
{
    internal final class Actions
    {
        private let _cellGridView: CellGridView
        private var _dragger: CellGridView.Drag? = nil
        private var _zoomer: CellGridView.Zoom? = nil
        private var _automationTimer: Timer? = nil

        internal init(_ cellGridView: CellGridView) {
            self._cellGridView = cellGridView
        }

        internal func automationStart() {
            self._automationTimer = Timer.scheduledTimer(withTimeInterval: self._cellGridView.automationInterval,
                                                         repeats: true) { _ in
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

        internal func onDrag(_ viewPoint: CGPoint) {
            guard let dragger: CellGridView.Drag = self._dragger else {
                self._dragger = CellGridView.Drag(self._cellGridView, viewPoint, selectMode: self._cellGridView.selectMode)
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
            //
            // Somehow (maybe we are that good), zooming in/out in CellGridView.Fit.fixed
            // mode actually just pretty much falls out; was prepared to do a bunch of work.
            //
            // guard self._cellGridView.fit != CellGridView.Fit.fixed else {
            //     return
            // }
            //
            if let zoomer: CellGridView.Zoom = self._zoomer {
                zoomer.zoom(zoomFactor)
            }
            else {
                self._zoomer = CellGridView.Zoom(self._cellGridView, zoomFactor)
            }
            self._cellGridView.onChangeImage()
        }

        internal func onZoomEnd(_ zoomFactor: CGFloat) {
            //
            // See comment above in onZoom.
            //
            // guard self._cellGridView.fit != CellGridView.Fit.fixed else {
            //     return
            // }
            //
            if let zoomer: CellGridView.Zoom = self._zoomer {
                zoomer.end(zoomFactor)
                self._zoomer = nil
            }
        }
    }
}
