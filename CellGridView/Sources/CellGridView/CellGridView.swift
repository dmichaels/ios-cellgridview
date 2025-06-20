import Foundation
import SwiftUI
import Utils

// A main purpose of this (as first created) is for keeping track of the backing pixel buffer
// indices for the (canonical) cell; for the purpose of being able to write the values very fast
// using block memory copy (Memory.fastcopy). It is ASSUMED that the BufferBlocks.append function
// is called with indices which are monotonically increasing, and are not duplicated or out of order
// or anything weird; assume called from the buffer setting loop in the PixelMap._write method.
//
// Note on terminology: We say "cell-grid" to mean the virtual grid of all cells in existence,
// and "grid-view" to mean the viewable window (image) in which is displayed a subset of the cell-grid.
// We say "point" or "view-point" to mean a pixel-based coordinate (e.g. from a gesture; not scaled)
// within the grid-view. We say "location" or "cell-location" to mean a cell-based (i.e. cell-index)
// coordinate on the cell-grid or grid-view.

open class CellGridView: ObservableObject
{
    // Note that internally all size related properties are stored as scaled;
    // but that all outward facing references to such properties and unscaled,
    // unless otherwise specifed in the property name, e.g. cellSizeScaled.
    //
    // Though we do have the ability to operate in unscaled rather than (the default) scaled mode,
    // i.e. if we pass viewScaling as false to the initialize method, in which case the size related
    // properties values are stored as unscaled; and in this case even the scaled property names,
    // e.g. cellSizeScaled, return the unscaled values. We actually (by default) switch to this mode
    // during zooming/resizing, for performance reasons (since the image buffer is nominall 3x smaller).

    private var _screen: Screen? = nil
    private var _viewWidth: Int = 0
    private var _viewHeight: Int = 0
    private var _viewWidthExtra: Int = 0
    private var _viewHeightExtra: Int = 0
    private var _viewColumns: Int = 0
    private var _viewRows: Int = 0
    private var _viewColumnsExtra: Int = 0
    private var _viewRowsExtra: Int = 0
    private var _viewCellEndX: Int = 0
    private var _viewCellEndY: Int = 0
    private var _viewBackground: Colour = Colour.black
    private var _viewTransparency: UInt8 = 0
    private var _viewScaling: Bool = true

    private var _cellSize: Int = 0
    private var _cellSizeTimesViewWidth: Int = 0
    private var _cellPadding: Int = 0
    private var _cellShape: CellShape = CellShape.rounded
    private var _cellForeground: CellShape = CellShape.rounded

    private var _gridColumns: Int = Defaults.gridColumns
    private var _gridRows: Int = Defaults.gridRows
    private var _gridCellEndX: Int = 0
    private var _gridCellEndY: Int = 0
    private var _gridWrapAround: Bool = Defaults.gridWrapAround
    private var _gridCells: [Cell] = []

    // These change based on moving/shifting the cell-grid around the grid-view.
    //
    private var _shiftCellX: Int = 0
    private var _shiftCellY: Int = 0
    private var _shiftX: Int = 0
    private var _shiftY: Int = 0

    // We store unscaled versions of commonly used properties.
    //
    private var _unscaled_viewWidth: Int = 0
    private var _unscaled_viewHeight: Int = 0
    private var _unscaled_cellSize: Int = 0
    private var _unscaled_cellPadding: Int = 0
    private var _unscaled_shiftCellX: Int = 0
    private var _unscaled_shiftCellY: Int = 0
    private var _unscaled_shiftX: Int = 0
    private var _unscaled_shiftY: Int = 0

    private var _bufferBlocks: CellGridView.BufferBlocks = BufferBlocks(width: 0)
    //
    // The only reason this _buffer is internal and not private is that we factored
    // out the image property into CellGridView+Image.swift which needs it.
    //
    internal var _buffer: [UInt8] = []

    // This _onChangeImage function property is the update function from the caller
    // to be called from CellGridView when the image changes, so that the calling
    // view can make sure the the image updated here is actually visually updated.
    //
    private var _automationMode: Bool = Defaults.automationMode
    private var _selectMode: Bool = Defaults.selectMode
    private var _automationInterval: Double = Defaults.automationInterval
    private lazy var _actions: CellGridView.Actions = CellGridView.Actions(self)

    private var _onChangeImage: () -> Void = {}
    private var _onChangeCellSize: (Int) -> Void = {_ in}

    public init() {}

    // This initialize method should be called on startup as soon as possible,
    // e.g. from the onAppear notification of the main view (ZStack or whatever).
    //
    public final func initialize(screen: Screen,
                                 viewWidth: Int,
                                 viewHeight: Int,
                                 viewBackground: Colour,
                                 viewTransparency: UInt8,
                                 viewScaling: Bool,
                                 cellSize: Int,
                                 cellPadding: Int,
                                 cellSizeFit: Bool,
                                 cellShape: CellShape,
                                 cellForeground: Colour,
                                 gridColumns: Int,
                                 gridRows: Int,
                                 gridCenter: Bool,
                                 selectMode: Bool = Defaults.selectMode,
                                 automationMode: Bool = Defaults.automationMode,
                                 automationInterval: Double = Defaults.automationInterval,
                                 onChangeImage: @escaping () -> Void,
                                 onChangeCellSize: @escaping (Int) -> Void = {_ in})
    {
        self._screen = screen

        let preferredSize: PreferredSize = (
            cellSizeFit
            ? CellGridView.preferredSize(viewWidth: viewWidth, viewHeight: viewHeight, cellSize: cellSize)
            : nil
        ) ?? (cellSize: cellSize, viewWidth: viewWidth, viewHeight: viewHeight)

        self.configure(viewWidth: preferredSize.viewWidth,
                       viewHeight: preferredSize.viewHeight,
                       viewBackground: viewBackground,
                       viewTransparency: viewTransparency,
                       viewScaling: viewScaling,
                       cellSize: preferredSize.cellSize,
                       cellPadding: cellPadding,
                       cellShape: cellShape)

        self._gridColumns = gridColumns > 0 ? gridColumns : self._viewColumns
        self._gridRows = gridRows > 0 ? gridRows : self._viewRows
        self._gridCellEndX = self._gridColumns - 1
        self._gridCellEndY = self._gridRows - 1
        self._gridCells = self.defineGridCells(gridColumns: self._gridColumns,
                                               gridRows: self._gridRows,
                                               foreground: cellForeground)

        #if targetEnvironment(simulator)
            self.printSizes(viewWidthInit: viewWidth, viewHeightInit: viewHeight,
                            cellSizeInit: cellSize , cellSizeFitInit: cellSizeFit)
        #endif

        self._selectMode = selectMode
        self._automationMode = automationMode
        self._automationInterval = automationInterval
        self._onChangeImage = onChangeImage
        self._onChangeCellSize = onChangeCellSize

        gridCenter ? self.center() : self.shiftCells(shiftTotalX: 0, shiftTotalY: 0, scaled: false)

        self.onChangeImage()
    }

    public final func configure(screen: Screen? = nil,
                                viewWidth: Int,
                                viewHeight: Int,
                                viewBackground: Colour,
                                viewTransparency: UInt8,
                                viewScaling: Bool,
                                cellSize: Int,
                                cellPadding: Int,
                                cellShape: CellShape,
                                selectMode: Bool? = nil,
                                automationMode: Bool? = nil,
                                automationInterval: Double? = nil,
                                adjustShift: Bool = false,
                                refreshCells: Bool = false,
                                scaled: Bool = false)
    {
        if (screen != nil) {
            self._screen = screen
        }

        // N.B. This here first so subsequent calls to self.scaled work properly.

        self._viewScaling = [CellShape.square, CellShape.inset].contains(cellShape) ? false : viewScaling

        // Convert to scaled and sanity (max/min) check the cell-size and cell-padding.

        let cellPadding: Int = self.constrainCellPadding(!scaled ? self.scaled(cellPadding) : cellPadding, scaled: true)
        let cellSize: Int = self.constrainCellSize(!scaled ? self.scaled(cellSize) : cellSize, cellPadding: cellPadding, scaled: true)
        let viewWidth: Int = !scaled ? self.scaled(viewWidth) : viewWidth
        let viewHeight: Int = !scaled ? self.scaled(viewHeight) : viewHeight

        // Note that adjustShift implies refreshCells.

        let shiftForRefresh = (
            adjustShift && ((cellSize - self.scaled(self.cellSize)) != 0)
            ? self.shiftForResizeCells(cellSizeIncrement: cellSize - self.scaled(self.cellSize))
            : (refreshCells
               ? (x: self.scaled(self.shiftTotalX), y: self.scaled(self.shiftTotalY))
               : nil)
        )

        self._viewWidth = viewWidth
        self._viewHeight = viewHeight
        self._cellSize = cellSize
        self._cellSizeTimesViewWidth = self._cellSize * self._viewWidth
        self._cellPadding = cellPadding
        self._cellShape = cellShape

        self._unscaled_viewWidth = self.unscaled(viewWidth)
        self._unscaled_viewHeight = self.unscaled(viewHeight)
        self._unscaled_cellSize = self.unscaled(cellSize)
        self._unscaled_cellPadding = self.unscaled(cellPadding)

        // Note that viewColumns/Rows is the number of cells the
        // view CAN (possibly) FULLY display horizontally/vertically.

        self._viewWidthExtra = self._viewWidth % self._cellSize
        self._viewHeightExtra = self._viewHeight % self._cellSize
        self._viewColumns = self._viewWidth / self._cellSize
        self._viewRows = self._viewHeight / self._cellSize
        self._viewColumnsExtra = (self._viewWidthExtra > 0) ? 1 : 0
        self._viewRowsExtra = (self._viewHeightExtra > 0) ? 1 : 0
        self._viewCellEndX = self._viewColumns + self._viewColumnsExtra - 1
        self._viewCellEndY = self._viewRows + self._viewRowsExtra - 1
        self._viewBackground = viewBackground
        self._viewTransparency = viewTransparency

        self._buffer = Memory.allocate(self._viewWidth * self._viewHeight * Screen.channels)
        self._bufferBlocks = BufferBlocks.createBufferBlocks(bufferSize: self._buffer.count,
                                                             viewWidth: self._viewWidth,
                                                             viewHeight: self._viewHeight,
                                                             cellSize: self._cellSize,
                                                             cellPadding: self._cellPadding,
                                                             cellShape: self._cellShape,
                                                             cellTransparency: self._viewTransparency)

        if let selectMode = selectMode { self._selectMode = selectMode }
        if let automationMode = automationMode { self._automationMode = automationMode }
        if let automationInterval = automationInterval { self._automationInterval = automationInterval }

        if let shiftForRefresh = shiftForRefresh {
            self.shiftCells(shiftTotalX: shiftForRefresh.x, shiftTotalY: shiftForRefresh.y, scaled: self.viewScaling)
        }
    }

    public   final var initialized: Bool         { self._screen != nil }
    public   final var screen: Screen            { self._screen! }

    public   final var viewWidth: Int            { self._unscaled_viewWidth }
    public   final var viewHeight: Int           { self._unscaled_viewHeight }
    public   final var viewColumns: Int          { self._viewColumns }
    public   final var viewRows: Int             { self._viewRows }
    public   final var viewBackground: Colour { self._viewBackground }
    public   final var viewTransparency: UInt8   { self._viewTransparency }
    public   final var cellSize: Int             { self._unscaled_cellSize }
    public   final var cellPadding: Int          { self._unscaled_cellPadding }
    public   final var cellShape: CellShape      { self._cellShape }
    public   final var gridColumns: Int          { self._gridColumns }
    public   final var gridRows: Int             { self._gridRows }
    public   final var gridCells: [Cell]         { self._gridCells }
    public   final var gridWrapAround: Bool      { self._gridWrapAround }

    internal final var shiftCellX: Int  { self._unscaled_shiftCellX }
    internal final var shiftCellY: Int  { self._unscaled_shiftCellY }
    internal final var shiftX: Int      { self._unscaled_shiftX }
    internal final var shiftY: Int      { self._unscaled_shiftY }
    internal final var shiftTotalX: Int { self._unscaled_shiftX + (self._unscaled_shiftCellX * self._unscaled_cellSize) }
    internal final var shiftTotalY: Int { self._unscaled_shiftY + (self._unscaled_shiftCellY * self._unscaled_cellSize) }

    internal final var viewWidthScaled: Int      { self._viewWidth }
    internal final var viewHeightScaled: Int     { self._viewHeight }
    internal final var viewCellEndX: Int         { self._viewCellEndX } // xyzzy
    internal final var viewCellEndY: Int         { self._viewCellEndY } // xyzzy
    internal final var viewWidthExtraScaled: Int { self._viewWidthExtra }
    internal final var cellSizeScaled: Int       { self._cellSize }
    internal final var cellPaddingScaled: Int    { self._cellPadding }
    internal final var shiftCellScaledX: Int     { self._shiftCellX }
    internal final var shiftCellScaledY: Int     { self._shiftCellY }
    internal final var shiftScaledX: Int         { self._shiftX }
    internal final var shiftScaledY: Int         { self._shiftY }
    internal final var shiftTotalScaledX: Int    { self._shiftX + (self._shiftCellX * self._cellSize) }
    internal final var shiftTotalScaledY: Int    { self._shiftY + (self._shiftCellY * self._cellSize) }

    public internal(set) var viewScaling: Bool {
        get { self._viewScaling }
        set {
            if (newValue) {
                if (!self._viewScaling) {
                    self.scale()
                }
            }
            else if (self._viewScaling) {
                self.unscale()
            }
        }
    }

    public final var viewScale: CGFloat {
        self.screen.scale(scaling: self._viewScaling)
    }

    internal final func scaled(_ value: Int) -> Int {
        return self.screen.scaled(value, scaling: self._viewScaling)
    }

    internal final func unscaled(_ value: Int) -> Int {
        return self.screen.unscaled(value, scaling: self._viewScaling)
    }

    // Sets the cell-grid within the grid-view to be shifted by the given amount,
    // from the upper-left; note that the given shiftTotalX and shiftTotalY values are unscaled.
    //
    public final func shiftCells(shiftTotalX: Int, shiftTotalY: Int, dragging: Bool = false, scaled: Bool = false)
    {
        #if targetEnvironment(simulator)
            let debugStart = Date()
        #endif

        // If the given scaled argument is false then the passed shiftTotalX/shiftTotalY arguments are
        // assumed to be unscaled and so we scale them, as this function operates on scaled values.

        var shiftX: Int = !scaled ? self.scaled(shiftTotalX) : shiftTotalX, shiftCellX: Int
        var shiftY: Int = !scaled ? self.scaled(shiftTotalY) : shiftTotalY, shiftCellY: Int

        // Normalize the given pixel level shift to cell and pixel level.

        if (shiftX != 0) {
            shiftCellX = shiftX / self._cellSize
            if (shiftCellX != 0) {
                shiftX = shiftX % self._cellSize
            }
        }
        else {
            shiftCellX = 0
        }
        if (shiftY != 0) {
            shiftCellY = shiftY / self._cellSize
            if (shiftCellY != 0) {
                shiftY = shiftY % self._cellSize
            }
        }
        else {
            shiftCellY = 0
        }

        // Restrict the shift to min/max; support different rules:
        //
        // - restrictShiftStrict
        //   Disallow the left-most cell of the cell-grid being right-shifted past the left-most
        //   position of the grid-view, and the right-most cell of the cell-grid being left-shifted
        //   past the right-most position of the grid-view; similarly for the vertical.
        //
        // - restrictShiftLenient
        //   Disallow the left-most cell of the cell-grid being right-shifted past the right-most
        //   position of the grid-view, and the right-most cell of the grid-view being left-shifted
        //   past the left-most position of the grid-view; similarly for the vertical.

        func restrictShiftStrict(shiftCell: inout Int, shift: inout Int,
                                 cellSize: Int,
                                 viewSize: Int,
                                 gridCells: Int,
                                 dragging: Bool = false) {
            var shiftTotal = (shiftCell * cellSize) + shift
            let gridSize: Int = gridCells * cellSize
            if (gridSize < viewSize) {
                //
                // The entire cell-grid being smaller than the grid-view requires
                // slightly difference logic than the presumably more commmon case.
                //
                if ((shift < 0) || (shiftCell < 0)) {
                    shiftCell = 0
                    shift = 0
                }
                else if (shiftTotal > (viewSize - gridSize)) {
                    shiftTotal = (viewSize - gridSize)
                    shiftCell = shiftTotal / cellSize
                    shift = shiftTotal % cellSize
                }
            }
            else if (!dragging) {
                if ((shift > 0) || (shiftCell > 0)) {
                    shift = 0
                    shiftCell = 0
                }
                else if ((shift < 0) || (shiftCell < 0)) {
                    if ((shiftTotal < 0) && ((gridSize + shiftTotal) < viewSize)) {
                        shiftTotal = viewSize - gridSize
                        shiftCell = shiftTotal / cellSize
                        shift = shiftTotal % cellSize
                    }
                }
            }
        }

        func restrictShiftLenient(shiftCell: inout Int, shift: inout Int,
                                  viewCellEnd: Int,
                                  viewSizeExtra: Int,
                                  viewSize: Int,
                                  gridCellEnd: Int) {
            if (shiftCell >= viewCellEnd) {
                if (viewSizeExtra > 0) {
                    let shiftTotal = (shiftCell * self._cellSize) + shift
                    if ((viewSize - shiftTotal) <= self._cellSize) {
                        let viewSizeAdjusted = viewSize - self._cellSize
                        shiftCell = viewSizeAdjusted / self._cellSize
                        shift = viewSizeAdjusted % self._cellSize
                    }
                } else {
                    shiftCell = viewCellEnd
                    shift = 0
                }
            } else if (-shiftCell >= gridCellEnd) {
                shiftCell = -gridCellEnd
                shift = 0
            }
        }

        if (!self._gridWrapAround) {
            if (Defaults.restrictShiftStrict) {
                restrictShiftStrict(shiftCell: &shiftCellX, shift: &shiftX,
                                    cellSize: self._cellSize,
                                    viewSize: self._viewWidth,
                                    gridCells: self._gridColumns,
                                    dragging: dragging)
                restrictShiftStrict(shiftCell: &shiftCellY, shift: &shiftY,
                                    cellSize: self._cellSize,
                                    viewSize: self._viewHeight,
                                    gridCells: self._gridRows,
                                    dragging: dragging)
            }
            else {
                restrictShiftLenient(shiftCell: &shiftCellX,
                                     shift: &shiftX,
                                     viewCellEnd: self._viewCellEndX - self._viewColumnsExtra,
                                     viewSizeExtra: self._viewWidthExtra,
                                     viewSize: self._viewWidth,
                                     gridCellEnd: self._gridCellEndX)
                restrictShiftLenient(shiftCell: &shiftCellY,
                                     shift: &shiftY,
                                     viewCellEnd: self._viewCellEndY - self._viewRowsExtra,
                                     viewSizeExtra: self._viewHeightExtra,
                                     viewSize: self._viewHeight,
                                     gridCellEnd: self._gridCellEndY)
            }
        }

        // Update the shift related values for the view.

        self._shiftCellX = shiftCellX
        self._shiftCellY = shiftCellY
        self._shiftX = shiftX
        self._shiftY = shiftY
        let unscaled_shiftTotalX: Int = self.unscaled(self._shiftX + (self._shiftCellX * self._cellSize))
        let unscaled_shiftTotalY: Int = self.unscaled(self._shiftY + (self._shiftCellY * self._cellSize))
        self._unscaled_shiftCellX = unscaled_shiftTotalX / self._unscaled_cellSize
        self._unscaled_shiftX = unscaled_shiftTotalX % self._unscaled_cellSize
        self._unscaled_shiftCellY = unscaled_shiftTotalY / self._unscaled_cellSize
        self._unscaled_shiftY = unscaled_shiftTotalY % self._unscaled_cellSize

        self._viewColumnsExtra = (self._shiftX != 0 ? 1 : 0)
        if (self._shiftX > 0) {
            if (self._viewWidthExtra > self._shiftX) {
                self._viewColumnsExtra += 1
            }
        }
        else if (self._shiftX < 0) {
            if (self._viewWidthExtra > (self._cellSize + self._shiftX)) {
                self._viewColumnsExtra += 1
            }
        }
        else if (self._viewWidthExtra > 0) {
            self._viewColumnsExtra += 1
        }
        self._viewCellEndX = self._viewColumns + self._viewColumnsExtra - 1

        self._viewRowsExtra = (self._shiftY != 0 ? 1 : 0)
        if (self._shiftY > 0) {
            if (self._viewHeightExtra > self._shiftY) {
                self._viewRowsExtra += 1
            }
        }
        else if (self._shiftY < 0) {
            if (self._viewHeightExtra > (self._cellSize + self._shiftY)) {
                self._viewRowsExtra += 1
            }
        }
        else if (self._viewHeightExtra > 0) {
            self._viewRowsExtra += 1
        }
        self._viewCellEndY = self._viewRows + self._viewRowsExtra - 1

        // Now actually write the cells to the view.

        for vy in 0...self._viewCellEndY {
            for vx in 0...self._viewCellEndX {
                self.writeCell(viewCellX: vx, viewCellY: vy)
            }
        }

        #if targetEnvironment(simulator)
            self.printWriteCellsResult(debugStart)
        #endif
    }

    // Draws at the given grid view cell location (viewCellX, viewCellY), the grid cell currently corresponding
    // to that location, taking into account the current shiftCellX/Y and shiftX/Y values, i.e. the cell and
    // pixel level based shift values, negative meaning to shift the grid cell left or up, and positive
    // meaning to shift the grid cell right or down.
    //
    internal final func writeCell(viewCellX: Int, viewCellY: Int)
    {
        // Get the left/right truncation amount.
        // This was all a lot tricker than you might expect (yes basic arithmetic).

        let truncate: Int

        if (self._shiftX > 0) {
            if (viewCellX == 0) {
                truncate = self._cellSize - self._shiftX
            }
            else if (viewCellX == self._viewCellEndX) {
                if (self._viewWidthExtra > 0) {
                    truncate = -((self._cellSize - self._shiftX + self._viewWidthExtra) % self._cellSize)
                }
                else {
                    truncate = -(self._cellSize - self._shiftX)
                }
            }
            else {
                truncate = 0
            }
        }
        else if (self._shiftX < 0) {
            if (viewCellX == 0) {
                truncate = -self._shiftX
            }
            else if (viewCellX == self._viewCellEndX) {
                if (self._viewWidthExtra > 0) {
                    truncate = -((self._viewWidthExtra - self._shiftX) % self._cellSize)
                }
                else {
                    truncate = self._shiftX
                }
            }
            else {
                truncate = 0
            }
        }
        else if ((self._viewWidthExtra > 0) && (viewCellX == self._viewCellEndX)) {
            truncate = -self._viewWidthExtra
        }
        else {
            truncate = 0
        }

        // Map the grid-view location to the cell-grid location.

        let gridCellX: Int = viewCellX - self._shiftCellX - ((self._shiftX > 0) ? 1 : 0)
        let gridCellY: Int = viewCellY - self._shiftCellY - ((self._shiftY > 0) ? 1 : 0)
        //
        // Another micro optimization could be if this view-cell does not correspond to a cell-grid
        // at all (i.e. the below gridCell call returns nil), i.e this is an empty space, then the
        // cell buffer block that we use can be a simplified one which just writes all background;
        // but this is probably not really a typical/common case for things we can think of for now.
        //
        let foreground: Colour = self.gridCell(gridCellX, gridCellY)?.color ?? self._viewBackground
        let foregroundOnly: Bool = false

        // Setup the offset for the buffer blocks; offset used within writeCellBlock.

        let shiftX: Int = (self._shiftX > 0) ? self._shiftX - self._cellSize : self._shiftX
        let shiftY: Int = (self._shiftY > 0) ? self._shiftY - self._cellSize : self._shiftY
        let offset: Int = ((self._cellSize * viewCellX) + shiftX +
                           (self._cellSizeTimesViewWidth * viewCellY + shiftY * self._viewWidth)) * Screen.channels
        let size: Int = self._buffer.count

        // Precompute as much as possible the specific color values needed in writeCellBlock;
        // the writeCellBlock function is real tight inner loop code so squeezing out optimizations.

        let fg: UInt32 = foreground.value
        let fgr: Float = Float(foreground.red)
        let fgg: Float = Float(foreground.green)
        let fgb: Float = Float(foreground.blue)
        let fga: UInt32 = UInt32(foreground.alpha) << Colour.ASHIFT

        let bg: UInt32 = self._viewBackground.value
        let bgr: Float = Float(self._viewBackground.red)
        let bgg: Float = Float(self._viewBackground.green)
        let bgb: Float = Float(self._viewBackground.blue)

        // Loop through the blocks for the cell and write each of the indices to the buffer with the right colors/blends.
        // Being careful to truncate the left or right side of the cell appropriately (tricky stuff).

        self._buffer.withUnsafeMutableBytes { raw in

            guard let buffer: UnsafeMutableRawPointer = raw.baseAddress else { return }

            func writeCellBlock(_ block: BufferBlocks.BufferBlock, _ index: Int, _ count: Int)
            {
                // Uses/captures from outer scope: buffer; offset; fg, bg, and related values.

                let start: Int = offset + index

                guard start >= 0, (start + (count * Memory.bufferBlockSize)) < size else {
                    //
                    // N.B. Recently changed above guard from "<= size" to  "< size" because it was off by one,
                    // just making a note of it here in case something for some reasone breaks (2025-05-15 12:40).
                    //
                    // At least (and only pretty sure) for the Y (vertical) case we get here on shifting; why;
                    // because we are being sloppy with the vertical, because it was easier; think fine though.
                    //
                    // TODO: But probably not; because these micro optimizations are getting ridiculous:
                    // could precompute the block background times blend values based on the current
                    // view background (which in practice should rarely if ever change), would save
                    // subtraction of blend from 1.0 and its multiplication by background in this
                    // loop; if background did change would need to invalidate the blocks.
                    //
                    return
                }
                if (block.foreground) {
                    if (block.blend != 1.0) {
                        let blend: Float = block.blend
                        let blendr: Float = 1.0 - blend
                        Memory.fastcopy(to: buffer.advanced(by: start), count: count,
                                        value: (UInt32(UInt8(fgr * blend + bgr * blendr)) << Colour.RSHIFT) |
                                               (UInt32(UInt8(fgg * blend + bgg * blendr)) << Colour.GSHIFT) |
                                               (UInt32(UInt8(fgb * blend + bgb * blendr)) << Colour.BSHIFT) | fga)
                    }
                    else {
                        Memory.fastcopy(to: buffer.advanced(by: start), count: count, value: fg)
                    }
                }
                else if (!foregroundOnly) {
                    Memory.fastcopy(to: buffer.advanced(by: start), count: count, value: bg)
                }
            }

            if (truncate != 0) {
                for block in self._bufferBlocks.blocks {
                    block.writeTruncated(truncatex: truncate, write: writeCellBlock)
                }
            }
            else {
                for block in self._bufferBlocks.blocks {
                    writeCellBlock(block, block.index, block.count)
                }
            }
        }
    }

    public func writeCells()
    {
        // Write just/all the visible cells.
        //
        for vx in 0...self._viewCellEndX {
            for vy in 0...self._viewCellEndY {
                if let cell: Cell = self.gridCell(viewCellX: vx, viewCellY: vy) {
                    cell.write()
                }
            }
        }
    }

    public final func center()
    {
        let gridWidth: Int = self.gridColumns * self.cellSize
        let gridHeight: Int = self.gridRows * self.cellSize
        let shiftTotalX: Int = -Int(round(Double(gridWidth) / 2.0))
        let shiftTotalY: Int = -Int(round(Double(gridHeight) / 2.0))
        self.shiftCells(shiftTotalX: shiftTotalX, shiftTotalY: shiftTotalY)
    }

    public final func onChangeImage() {
        self._onChangeImage()
    }

    public final func onChangeCellSize(_ cellSize: Int) {
        self._onChangeCellSize(cellSize)
    }

    public var selectMode: Bool {
        self._selectMode
    }

    public func selectModeToggle() {
        self._selectMode = !self._selectMode
    }

    public var automationMode: Bool {
        self._automationMode
    }

    public func automationModeToggle() {
        if (self._automationMode) {
            self._automationMode = false
            self.automationStop()
        }
        else {
            self._automationMode = true
            self.automationStart()
        }
    }

    open func automationStart() { self._actions.automationStart() }
    open func automationStop() { self._actions.automationStop() }
    open func automationStep() {}

    public final var automationInterval: Double {
        get { return self._automationInterval }
        set {
            if (newValue != self._automationInterval) {
                self._automationInterval = newValue
                if (self._automationMode) {
                    self._actions.automationStop()
                    self._actions.automationStart()
                }
            }
        }
    }

    open func onTap(_ viewPoint: CGPoint) { self._actions.onTap(viewPoint) }
    open func onDrag(_ viewPoint: CGPoint) { self._actions.onDrag(viewPoint) }
    open func onDragEnd(_ viewPoint: CGPoint) { self._actions.onDragEnd(viewPoint) }
    open func onZoom(_ zoomFactor: CGFloat) { self._actions.onZoom(zoomFactor) }
    open func onZoomEnd(_ zoomFactor: CGFloat) { self._actions.onZoomEnd(zoomFactor) }

    open func createCell<T: Cell>(x: Int, y: Int, color: Colour) -> T? {
        return Cell(cellGridView: self, x: x, y: y, color: color) as? T
    }
}
