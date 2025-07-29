import Foundation
import SwiftUI
import Utils

extension CellGridView
{
    internal final class Actions
    {
        private let _cellGridView: CellGridView
        private var _dragger: CellGridView.Drag? = nil
        private var _zoomer: CellGridView.Zoom? = nil
        private var _automationMode: Bool = Defaults.automationMode
        private var _automationPaused: Bool = false
        private var _automationInterval: Double = Defaults.automationInterval
        private var _automationTimer: Timer? = nil
        private var _selectRandomMode: Bool = Defaults.selectRandomMode
        private var _selectRandomPaused: Bool = false
        private var _selectRandomInterval: Double = Defaults.selectRandomInterval
        private var _selectRandomTimer: Timer? = nil

        private var _undulationMode: Bool = Defaults.undulationMode
        private var _undulationPaused: Bool = false
        private var _undulationInterval: Double = Defaults.undulationInterval
        private var _undulationTimer: ScheduledTimer? = nil
        private let _undulationCellSizeMin: Int = 12
        private let _undulationCellSizeMax: Int = 300
        private var _undulationCellSizeIncrement: Int = 2

        internal init(_ cellGridView: CellGridView) {
            self._cellGridView = cellGridView
        }

        internal final var automationMode: Bool {
            get { self._automationMode }
            set { if (newValue) { self.automationStart() } else { self.automationStop() } }
        }

        internal final var automationInterval: Double {
            get { self._automationInterval }
            set {
                if (self._automationInterval != newValue) {
                    self._automationInterval = newValue
                    if (self._automationMode) {
                        self.automationStop()
                        self.automationStart()
                    }
                }
            }
        }

        internal func automationModeToggle() {
            self._automationMode ? self.automationStop() : self.automationStart()
        }

        internal func automationStart() {
            guard !self._automationMode || (self._automationTimer == nil) else { return }
            self._automationMode = true
            if let automationTimer: Timer = self._automationTimer {
                if (automationTimer.timeInterval == self._cellGridView.automationInterval) {
                    //
                    // Here, the automation is already running, with the
                    // same time interval as is current in our CellGridView.
                    //
                    return
                }
                //
                // Here, the automation is already running, but with
                // a time interval as is current in our CellGridView.
                //
                automationTimer.invalidate()
            }
            self._automationTimer = Timer.scheduledTimer(withTimeInterval: self._cellGridView.automationInterval,
                                                         repeats: true) { _ in
                if (!self._automationPaused) {
                    self._cellGridView.automationStep()
                }
            }
        }

        internal func automationStop() {
            guard self._automationMode else { return }
            self._automationMode = false
            if let automationTimer = self._automationTimer {
                automationTimer.invalidate()
                self._automationTimer = nil
            }
            self._automationPaused = false // stopping resets any pause (right?)
        }

        internal var automationPaused: Bool {
            self._automationPaused
        }

        internal func automationPause() {
            self._automationPaused = true
        }

        internal func automationResume() {
            self._automationPaused = false
        }

        internal final var selectRandomMode: Bool {
            get { self._selectRandomMode }
            set { if (newValue) { self.selectRandomStart() } else { self.selectRandomStop() } }
        }

        internal final var selectRandomInterval: Double {
            get { self._selectRandomInterval }
            set {
                if (self._selectRandomInterval != newValue) {
                    self._selectRandomInterval = newValue
                    if (self._selectRandomMode) {
                        self.selectRandomStop()
                        self.selectRandomStart()
                    }
                }
            }
        }

        internal final func selectRandomModeToggle() {
            self._selectRandomMode ? self.selectRandomStop() : self.selectRandomStart()
        }

        internal func selectRandomStart() {
            guard !self._selectRandomMode || (self._selectRandomTimer == nil) else { return }
            self._selectRandomMode = true
            if let selectRandomTimer: Timer = self._selectRandomTimer {
                if (selectRandomTimer.timeInterval == self._selectRandomInterval) {
                    return
                }
                selectRandomTimer.invalidate()
            }
            self._selectRandomTimer = Timer.scheduledTimer(withTimeInterval: self._selectRandomInterval,
                                                        repeats: true) { _ in
                if (!self._selectRandomPaused) {
                    self.selectRandom()
                }
            }
        }

        internal func selectRandomStop() {
            guard self._selectRandomMode else { return }
            self._selectRandomMode = false
            if let selectRandomTimer = self._selectRandomTimer {
                selectRandomTimer.invalidate()
                self._selectRandomTimer = nil
            }
        }

        internal final var selectRandomPaused: Bool {
            self._selectRandomPaused
        }

        internal final func selectRandomPause() {
            self._selectRandomPaused = true
        }

        internal final func selectRandomResume() {
            self._selectRandomPaused = false
        }

        internal final func selectRandom() {
            let randomGridCellX: Int = Int.random(in: self._cellGridView.visibleGridCellRangeX)
            let randomGridCellY: Int = Int.random(in: self._cellGridView.visibleGridCellRangeY)
            if let cell: Cell = self._cellGridView.gridCell(randomGridCellX, randomGridCellY) {
                cell.select()
                self._cellGridView.updateImage()
            }
        }

        internal final var undulationMode: Bool {
            get { self._undulationMode }
            set { if (newValue) { self.undulationStart() } else { self.undulationStop() } }
        }

        internal final var undulationInterval: Double {
            get { self._undulationInterval }
            set {
                if (self._undulationInterval != newValue) {
                    self._undulationInterval = newValue
                    if (self._undulationMode) {
                        self.undulationStop()
                        self.undulationStart()
                    }
                }
            }
        }

        internal func undulationModeToggle() {
            self._undulationMode ? self.undulationStop() : self.undulationStart()
        }

        internal func undulationStart() {
            guard !self._undulationMode || (self._undulationTimer == nil) else { return }
            self._undulationMode = true
            if let undulationTimer: ScheduledTimer = self._undulationTimer {
                if (undulationTimer.interval == self._undulationInterval) {
                    return
                }
                undulationTimer.stop()
            }
            self._undulationTimer = ScheduledTimer(interval: self._undulationInterval, mode: .dispatchTimer) {
                if (!self._undulationPaused) {
                    var cellSize: Int = self._cellGridView.cellSizeScaled + self._undulationCellSizeIncrement
                    if (cellSize > self._undulationCellSizeMax) {
                        cellSize = self._undulationCellSizeMax
                        self._undulationCellSizeIncrement = -self._undulationCellSizeIncrement
                    }
                    else if ((cellSize < self._undulationCellSizeMin) ||
                             (cellSize <= self._cellGridView.minimumCellSize)) {
                        cellSize = self._undulationCellSizeMin
                        self._undulationCellSizeIncrement = -self._undulationCellSizeIncrement
                    }
                    self._cellGridView.resizeCells(cellSize: cellSize, adjustShiftOnResizeCells: true, scaled: true)
                    self._cellGridView.updateImage()
                }
            }
        }

        internal func undulationStop() {
            guard self._undulationMode else { return }
            self._undulationMode = false
            if let undulationTimer = self._undulationTimer {
                undulationTimer.stop()
                self._undulationTimer = nil
            }
            self._undulationPaused = false // stopping resets any pause (right?)
        }

        internal var undulationPaused: Bool {
            self._undulationPaused
        }

        internal func undulationPause() {
            self._undulationPaused = true
        }

        internal func undulationResume() {
            self._undulationPaused = false
        }

        internal final func onTap(_ viewPoint: CGPoint) {
            guard self._cellGridView.viewPointInbounds(viewPoint) else { return }
            if let cell: Cell = self._cellGridView.gridCell(viewPoint: viewPoint) {
                cell.select()
                self._cellGridView.updateImage()
            }
        }

        internal final func onDrag(_ viewPoint: CGPoint) {
            guard self._cellGridView.viewPointInbounds(viewPoint) else { return }
            guard let dragger: CellGridView.Drag = self._dragger else {
                self._dragger = CellGridView.Drag(self._cellGridView, viewPoint, selectMode: self._cellGridView.selectMode)
                //
                // Changed on 2025-07-27 to call dragger.drag (and updateImage) here; was
                // missing for some reason; hopefully non-breaking but noting just in case.
                //
                self._dragger!.drag(viewPoint)
                self._cellGridView.updateImage()
                return
            }
            dragger.drag(viewPoint)
            self._cellGridView.updateImage()
        }

        internal final func onDragEnd(_ viewPoint: CGPoint) {
            if let dragger: CellGridView.Drag = self._dragger {
                dragger.end(viewPoint)
                self._dragger = nil
                self._cellGridView.updateImage()
            }
        }

        internal final func onZoom(_ zoomFactor: CGFloat) {
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
            self._cellGridView.updateImage()
        }

        internal final func onZoomEnd(_ zoomFactor: CGFloat) {
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
