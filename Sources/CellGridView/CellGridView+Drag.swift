import Foundation
import Utils

extension CellGridView
{
    internal struct Drag
    {
        private let _cellGridView: CellGridView
        private let _startX: Int
        private let _startY: Int
        private let _startShiftedX: Int
        private let _startShiftedY: Int
        private let _startCell: Cell?

        internal init(_ cellGridView: CellGridView, _ viewPoint: CGPoint, selectMode: Bool = false) {
            self._cellGridView = cellGridView
            self._startX = Int(round(viewPoint.x))
            self._startY = Int(round(viewPoint.y))
            self._startShiftedX = cellGridView.shiftTotalX
            self._startShiftedY = cellGridView.shiftTotalY
            self._startCell = selectMode ? cellGridView.gridCell(viewPoint: viewPoint) : nil
        }

        internal func drag(_ viewPoint: CGPoint, end: Bool = false) {
            if let _ = self._startCell, let cell: Cell = self._cellGridView.gridCell(viewPoint: viewPoint) {
                //
                // N.B. On 2025-07-27 changed the dragging true argument below to !end; in response
                // to developing Tetris; was appearing to get a drag start notification at the end
                // of a drag; don't think this will break anything else but noting it here in case.
                //
                cell.select(dragging: !end)
                return
            }
            let dragPoint: ViewPoint = ViewPoint(viewPoint)
            let dragX: Int = dragPoint.x
            let dragY: Int = dragPoint.y
            let dragDeltaX = self._startX - dragX
            let dragDeltaY = self._startY - dragY
            let shiftX =  self._startShiftedX - dragDeltaX
            let shiftY = self._startShiftedY - dragDeltaY
            self._cellGridView.shift(shiftTotalX: shiftX, shiftTotalY: shiftY, dragging: !end)
        }

        internal func end(_ viewPoint: CGPoint) {
            self.drag(viewPoint, end: true)
        }
    }
}
