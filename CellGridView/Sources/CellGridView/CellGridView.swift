import Foundation
import SwiftUI
import Utils

// A main purpose of this (as first created) is for keeping track of the backing pixel buffer
// indices for the (canonical) cell; for the purpose of being able to write the values very fast
// using block memory copy (Memory.fastcopy). It is ASSUMED that the BufferBlocks.append function
// is called with indices which are monotonically increasing, and are not duplicated or out of order
// or anything weird; assume called from the buffer setting loop in the PixelMap._write method.
//
// Note on terminology: We say "cell-grid" to mean the virtual grid of all cells in existence, and "grid-view"
// to mean the viewable window (image) within which is displayed a subset of the currently viewable cell-grid.
// We say "view-point" or "point" to mean a pixel-based coordinate (e.g. from a gesture; unscaled) within the
// grid-view. We say "cell-location" to mean a cell-based (i.e. cell indexed) coordinate on the cell-grid. We
// say "view-location" to mean a cell-based coordinate on the grid-view (always zero-based). We say "location"
// generically to refer to a cell-location or a view-location, as opposed to "point" referring a view-point.

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
    // during zooming/resizing, for performance reasons (since the image buffer is nominally 3x smaller).

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
    private var _viewBackground: Colour = Defaults.viewBackground
    private var _viewTransparency: UInt8 = 0
    private var _viewScaling: Bool = Defaults.viewScaling
    private var _viewScalingArtificiallyDisabled: Bool = false

    private var _cellSize: Int = Defaults.cellSize
    private var _cellSizeTimesViewWidth: Int = 0
    private var _cellPadding: Int = Defaults.cellPadding
    private var _cellShape: CellShape = Defaults.cellShape
    private var _cellShading: Bool = Defaults.cellShading

    private var _gridColumns: Int = Defaults.gridColumns
    private var _gridRows: Int = Defaults.gridRows
    private var _gridWrapAround: Bool = Defaults.gridWrapAround
    private var _fit: CellGridView.Fit = CellGridView.Fit.disabled
    private var _center: Bool = Defaults.center
    private var _cells: [Cell] = []

    // These change based on moving/shifting the cell-grid around the grid-view.
    //
    private var _shiftCellX: Int = 0
    private var _shiftCellY: Int = 0
    private var _shiftX: Int = 0
    private var _shiftY: Int = 0

    // We store unscaled versions of commonly used properties.
    //
    private var _viewWidthUnscaled: Int = 0
    private var _viewHeightUnscaled: Int = 0
    private var _cellSizeUnscaled: Int = 0
    private var _cellPaddingUnscaled: Int = 0
    private var _shiftCellUnscaledX: Int = 0
    private var _shiftCellUnscaledY: Int = 0
    private var _shiftUnscaledX: Int = 0
    private var _shiftUnscaledY: Int = 0

    internal var _bufferBlocks: CellGridView.BufferBlocks = BufferBlocks()
    //
    // The only reason this _buffer is internal and not private is that we factored
    // out the image property into CellGridView+Image.swift which needs it.
    //
    internal var _buffer: [UInt8] = []

    // Various other sundry operational parameters.
    //
    private var _cellColor: Colour = Defaults.cellColor
    private var _restrictShift: Bool = Defaults.restrictShift
    private var _unscaledZoom: Bool = Defaults.unscaledZoom
    private var _cellAntialiasFade: Float = Defaults.cellAntialiasFade
    private var _cellRoundedRadius: Float = Defaults.cellRoundedRadius
    private var _cellSizeMax: Int = Defaults.cellSizeMax
    private var _cellSizeInnerMin: Int = Defaults.cellSizeInnerMin
    private var _cellPaddingMax: Int = Defaults.cellPaddingMax

    private var _selectMode: Bool = Defaults.selectMode
    internal lazy var _actions: CellGridView.Actions = CellGridView.Actions(self)

    // This _updateImage function property is the update function from the caller
    // to be called from CellGridView when the image changes, so that the calling
    // view can make sure the the image updated here is actually visually updated.
    //
    private var _updateImage: () -> Void = {}

    public init() {
        //
        // Note that to use this CellGridView class the initialize method MUST be called!
        // This is because we need the Screen, which is problematic to be create at startup.
        //
    }

    open var config: CellGridView.Config {
        CellGridView.Config(self)
    }

    open func initialize(_ config: CellGridView.Config,
                           screen: Screen,
                           viewWidth: Int,
                           viewHeight: Int,
                           updateImage: (() -> Void)? = nil)
    {
        guard self._screen == nil else { return }
        self._screen = screen
        self._updateImage = updateImage ?? {}
        self.configure(config, viewWidth: viewWidth, viewHeight: viewHeight, _initial: true)
        if (self.automationMode) { self.automationStart() }
        if (self.selectRandomMode) { self.selectRandomStart() }
    }

    public func configure(_ config: CellGridView.Config,
                            viewWidth: Int,
                            viewHeight: Int,
                            adjust: Bool = false,
                            scaled: Bool = false, _initial: Bool = false)
    {
        // Ensure screen is set; otherwise initialize was not called before this configure function.

        guard self._screen != nil else { return }

        // Setting of viewScaling is here first so subsequent calls to self.scaled/unscaled work properly.
        // If the cellShape is a square there is no need for scaling so we forcibly disable it.  
        //
        // This scaling stuff does complicate thing in general a bit; but nice to have the option of an extra
        // performance benefit, and especially where it's done implicitly when the cell-shape is square rather
        // than rounded or circle; note that when we are in unscaled mode the scaled versions of the properties
        // are not really scaled, i.e. the scaled and unscaled properties (internally and externally) are the
        // same, i.e. both unscaled, since when we are in unscaled mode, then nothing is scaled.
        //
        // And one odd thing about what we're doing, in the ios-lifegame imploemention which uses ios-cellgridview,
        // is that we only allow showing/manipulating the cell-size (and padding) in unscalled terms, within the 
        // the SettingsView that is, HOWEVER, when zooming in/out (via pinch gesture) this can occur in scaled terms.

        let viewScalingPrevious: Bool = self._viewScaling
        if (self._viewScalingArtificiallyDisabled) {
            if (!self.cellShapeRequiresNoScaling(config.cellShape)) {
                self._viewScaling = true
                self._viewScalingArtificiallyDisabled = false
            }
            else {
                self._viewScaling = config.viewScaling
            }
        }
        else if (self.cellShapeRequiresNoScaling(config.cellShape) && config.viewScaling) {
            self._viewScaling = false
            self._viewScalingArtificiallyDisabled = true
        }
        else {
            self._viewScaling = config.viewScaling
        }

        // Convert to scaled and sanity (max/min) check the cell-size and cell-padding.

        self._cellSizeInnerMin = config.cellSizeInnerMin
        self._cellSizeMax = config.cellSizeMax
        self._cellPaddingMax = config.cellPaddingMax

        // Careful here: If the given cell-size is UNSCALED and it is EQUAL to the current UNSCALED cell-size,
        // then NO change; i.e. even if the SCALED version of the given cell-size is NOT equal to the current
        // scaled cell-size; e.g. if our current SCALED cell-size is 73 it means the current UNSCALED cell-size
        // is 24, and then if the given scaled argument is false and the given config argument has an cell-size
        // of 24, then we do NOT want to want to use the scaled version of that which would be 72 (24 * 3),
        // which would change the current cell-size from a scaled value of 73 to 72, for no good reason.
        // And note the call below to self.scaled(self.cellSize) i.e. rather than self._cellSize, so that
        // we do the right thing if we are now unscaled (e.g. even if because we switched to square from
        // rounded or circle). And of course, the same goes for cell-padding.
        //
        let cellSizeScaled: Int    = !scaled && (config.cellSize == self._cellSizeUnscaled)
                                     //
                                     // 2025-07-14: Still struggling with this a bit ...
                                     // Doing self.scaled(self.cellSize) does not work for cellSize of 40 (unscaled 13) and
                                     // doing nothing on SettingsView but self._cellSize breaks changing from rounded to square.
                                     //
                                     // ? self.scaled(self.cellSize)
                                     // ? self._cellSize
                                     //
                                     ? (self._viewScaling && viewScalingPrevious ? self._cellSize : self.scaled(self.cellSize))
                                     : (!scaled ? self.scaled(config.cellSize) : config.cellSize)
        let cellPaddingScaled: Int = !scaled && (config.cellPadding == self._cellPaddingUnscaled)
                                     ? (self._viewScaling && viewScalingPrevious ? self._cellPadding : self.scaled(self.cellPadding))
                                     : (!scaled ? self.scaled(config.cellPadding) : config.cellPadding)

        let cellPadding: Int = self.constrainCellPadding(cellPaddingScaled, scaled: true)
        let cellSize: Int = self.constrainCellSize(cellSizeScaled,
                                                   cellPadding: cellPadding, cellShape: config.cellShape, scaled: true)
        let cellSizeIncrement: Int = cellSize - self._cellSize
        let viewWidth: Int = !scaled ? self.scaled(viewWidth) : viewWidth
        let viewHeight: Int = !scaled ? self.scaled(viewHeight) : viewHeight

        let preferred: PreferredSize = _initial || (config.fit == .fixed)
                                       ? CellGridView.preferredSize(cellSize: cellSize,
                                                                    viewWidth: self.scaled(self._screen!.width),
                                                                    viewHeight: self.scaled(self._screen!.height),
                                                                    fit: config.fit,
                                                                    fitMarginMax: Defaults.fitMarginMax)
                                       : (cellSize: cellSize, viewWidth: viewWidth, viewHeight: viewHeight, fit: false)

        // Note that we got the cellSizeIncrement above based on the cellSize value before updating it below.

        var gridColumns: Int = self.constrainGridColumns(config.gridColumns)
        var gridRows: Int = self.constrainGridRows(config.gridRows)

        if (config.fit == CellGridView.Fit.fixed) {
            gridColumns = preferred.viewWidth / preferred.cellSize
            gridRows = preferred.viewHeight / preferred.cellSize
        }

        var shift: (x: Int, y: Int) = (
            adjust && (cellSizeIncrement != 0)
            ? self.shiftForResizeCells(cellSizeIncrement: cellSizeIncrement)
            : (config.center
               ? self.shiftForCenterCells(cellSize: preferred.cellSize,
                                          gridColumns: gridColumns, gridRows: gridRows,
                                          viewWidth: preferred.viewWidth, viewHeight: preferred.viewHeight,
                                          fit: preferred.fit ? config.fit : CellGridView.Fit.disabled)
               : (x: self.scaled(self.shiftTotalX), y: self.scaled(self.shiftTotalY)))
        )
        if (self._fit != config.fit) {
            self._fit = config.fit
            if (!config.center) {
                shift = (x: 0, y: 0)
            }
        }
        self._center = config.center

        self._viewWidth = preferred.viewWidth
        self._viewHeight = preferred.viewHeight
        self._cellSize = preferred.cellSize
        self._cellSizeTimesViewWidth = self._cellSize * self._viewWidth
        self._cellPadding = cellPadding
        self._cellShape = config.cellShape
        self._cellShading = config.cellShading

        self._viewWidthUnscaled = self.unscaled(self._viewWidth)
        self._viewHeightUnscaled = self.unscaled(self._viewHeight)
        self._cellSizeUnscaled = self.unscaled(self._cellSize)
        self._cellPaddingUnscaled = self.unscaled(self._cellPadding)

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
        self._viewBackground = config.viewBackground
        self._viewTransparency = config.viewTransparency

        self._cellColor = config.cellColor
        self._cellAntialiasFade = config.cellAntialiasFade
        self._cellRoundedRadius = config.cellRoundedRadius

        let bufferSize: Int = self._viewWidth * self._viewHeight * Screen.channels
        if (bufferSize != self._buffer.count) {
            self._buffer = Memory.allocate(self._viewWidth * self._viewHeight * Screen.channels)
        }

        // Not actually necessary to call this if any of these arguments have not changed,
        // i.e. if the ones that were in self were all the same as the ones in config, but
        // this configure function is typically only called when at least of these has changed.

        self._bufferBlocks = BufferBlocks.createBufferBlocks(bufferSize: self._buffer.count,
                                                             viewWidth: self._viewWidth,
                                                             viewHeight: self._viewHeight,
                                                             cellSize: self._cellSize,
                                                             cellPadding: self._cellPadding,
                                                             cellShape: self._cellShape,
                                                             cellShading: self._cellShading,
                                                             cellTransparency: self._viewTransparency,
                                                             cellAntialiasFade: self._cellAntialiasFade,
                                                             cellRoundedRadius: self._cellRoundedRadius)
        var defineCells: Bool = false
        let currentGridColumns: Int = self._gridColumns
        let currentGridRows: Int = self._gridRows
        if (gridColumns != self.gridColumns) { self._gridColumns = gridColumns ; defineCells = true }
        if (gridRows    != self.gridRows)    { self._gridRows    = gridRows    ; defineCells = true }
        if (defineCells || (self._cells.count == 0)) {
            self._cells = self.defineCells(
                gridColumns: self._gridColumns,
                gridRows: self._gridRows,
                currentCells: self._cells,
                currentColumns: currentGridColumns,
                currentRows: currentGridRows)
        }

        self._restrictShift = config.restrictShift || (config.fit == CellGridView.Fit.fixed)
        // self._selectMode = config.selectMode

        self.shift(shiftTotalX: shift.x, shiftTotalY: shift.y, scaled: self.viewScaling)

        if (false && self._fit == CellGridView.Fit.enabled) {
            //
            // TODO
            // Experiment; enable initially only then disable; actually forget now
            // why we wanted to do this; it messes up (for iPhone 15 Pro simulator)
            // with cellSize == 23 and fit = .enabled when just going to settings
            // view and doing nothing and back to view; it shifts slightly from the
            // initial nice fit; we will run into the problem this was trying to solve.
            //
            self._fit = CellGridView.Fit.disabled
        }

        self._unscaledZoom = config.unscaledZoom

        self.automationInterval = config.automationInterval
        self.selectRandomInterval = config.selectRandomInterval
    }

    public   final var initialized: Bool          { self._screen != nil }
    public   final var screen: Screen             { self._screen! }

    public   final var viewWidth: Int             { self._viewWidthUnscaled }
    public   final var viewHeight: Int            { self._viewHeightUnscaled }
    public   final var viewColumns: Int           { self._viewColumns }
    public   final var viewRows: Int              { self._viewRows }
    public   final var gridColumns: Int           { self._gridColumns }
    public   final var gridRows: Int              { self._gridRows }
    public   final var fit: CellGridView.Fit      { self._fit }
    public   final var center: Bool               { self._center }
    public   final var cells: [Cell]              { self._cells }

    public   final var viewBackground: Colour     { self._viewBackground }
    public   final var viewTransparency: UInt8    { self._viewTransparency }
    public   final var cellSize: Int              { self._cellSizeUnscaled }
    public   final var cellPadding: Int           { self._cellPaddingUnscaled }
    public   final var cellShape: CellShape       { self._cellShape }
    public   final var cellShading: Bool          { self._cellShading }
    public   final var cellColor: Colour          { self._cellColor }
    public   final var cellSizeMax: Int           { self._cellSizeMax }
    public   final var cellSizeInnerMin: Int      { self._cellSizeInnerMin }
    public   final var cellPaddingMax: Int        { self._cellPaddingMax }
    public   final var cellAntialiasFade: Float   { self._cellAntialiasFade }
    public   final var cellRoundedRadius: Float   { self._cellRoundedRadius }
    public   final var restrictShift: Bool        { self._restrictShift }
    public   final var unscaledZoom: Bool         { self._unscaledZoom }

    public   final var gridWrapAround: Bool         { self._gridWrapAround }

    internal final var shiftCellX: Int  { self._shiftCellUnscaledX }
    internal final var shiftCellY: Int  { self._shiftCellUnscaledY }
    internal final var shiftX: Int      { self._shiftUnscaledX }
    internal final var shiftY: Int      { self._shiftUnscaledY }
    internal final var shiftTotalX: Int { self._shiftUnscaledX + (self._shiftCellUnscaledX * self._cellSizeUnscaled) }
    internal final var shiftTotalY: Int { self._shiftUnscaledY + (self._shiftCellUnscaledY * self._cellSizeUnscaled) }

    internal final var viewWidthScaled: Int       { self._viewWidth }
    internal final var viewHeightScaled: Int      { self._viewHeight }
    public   final var viewCellEndX: Int          { self._viewCellEndX }
    public   final var viewCellEndY: Int          { self._viewCellEndY }
    internal final var viewWidthExtraScaled: Int  { self._viewWidthExtra }
    internal final var cellSizeScaled: Int        { self._cellSize }
    internal final var cellPaddingScaled: Int     { self._cellPadding }
    internal final var shiftCellScaledX: Int      { self._shiftCellX }
    internal final var shiftCellScaledY: Int      { self._shiftCellY }
    internal final var shiftScaledX: Int          { self._shiftX }
    internal final var shiftScaledY: Int          { self._shiftY }
    internal final var shiftTotalScaledX: Int     { self._shiftX + (self._shiftCellX * self._cellSize) }
    internal final var shiftTotalScaledY: Int     { self._shiftY + (self._shiftCellY * self._cellSize) }

    public var visibleGridCellRangeX: ClosedRange<Int> {
        let from = -self.shiftCellX
        let thru = min(self.gridColumns - 1, from + self.viewCellEndX)
        return from...thru
    }

    public var visibleGridCellRangeY: ClosedRange<Int> {
        let from = -self.shiftCellY
        let thru = min(self.gridRows - 1, from + self.viewCellEndY)
        return from...thru
    }

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

    internal final func scaled(_ value: CGFloat) -> CGFloat {
        return self.screen.scaled(value, scaling: self.viewScaling)
    }

    internal final func unscaled(_ value: Int) -> Int {
        return self.screen.unscaled(value, scaling: self._viewScaling)
    }

    // Sets the cell-grid within the grid-view to be shifted by the given amount, from the upper-left;
    // note that the given shiftTotalX and shiftTotalY values, if not already scaled (as indicated by
    // the scaled argument) will be scaled for the execution of this function.
    //
    public final func shift(shiftTotalX: Int, shiftTotalY: Int, dragging: Bool = false, scaled: Bool = false)
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

        if (!self._gridWrapAround) {
            if (self._restrictShift) {
                CellGridView.restrictShiftStrict(shiftCell: &shiftCellX, shift: &shiftX,
                                    cellSize: self._cellSize,
                                    viewSize: self._viewWidth,
                                    gridCells: self._gridColumns,
                                    dragging: dragging)
                CellGridView.restrictShiftStrict(shiftCell: &shiftCellY, shift: &shiftY,
                                    cellSize: self._cellSize,
                                    viewSize: self._viewHeight,
                                    gridCells: self._gridRows,
                                    dragging: dragging)
            }
            else {
                CellGridView.restrictShiftLenient(shiftCell: &shiftCellX,
                                     shift: &shiftX,
                                     cellSize: self._cellSize,
                                     viewCellEnd: self._viewCellEndX - self._viewColumnsExtra,
                                     viewSizeExtra: self._viewWidthExtra,
                                     viewSize: self._viewWidth,
                                     gridCells: self._gridColumns)
                CellGridView.restrictShiftLenient(shiftCell: &shiftCellY,
                                     shift: &shiftY,
                                     cellSize: self._cellSize,
                                     viewCellEnd: self._viewCellEndY - self._viewRowsExtra,
                                     viewSizeExtra: self._viewHeightExtra,
                                     viewSize: self._viewHeight,
                                     gridCells: self._gridRows)
            }
        }

        // Update the shift related values for the view.

        self._shiftCellX = shiftCellX
        self._shiftCellY = shiftCellY
        self._shiftX = shiftX
        self._shiftY = shiftY

        let unscaled_shiftTotalX: Int = self.unscaled(self._shiftX + (self._shiftCellX * self._cellSize))
        let unscaled_shiftTotalY: Int = self.unscaled(self._shiftY + (self._shiftCellY * self._cellSize))
        self._shiftCellUnscaledX = unscaled_shiftTotalX / self._cellSizeUnscaled
        self._shiftUnscaledX = unscaled_shiftTotalX % self._cellSizeUnscaled
        self._shiftCellUnscaledY = unscaled_shiftTotalY / self._cellSizeUnscaled
        self._shiftUnscaledY = unscaled_shiftTotalY % self._cellSizeUnscaled

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
    internal final func writeCell(viewCellX: Int, viewCellY: Int, foregroundOnly: Bool = false)
    {
        // Get the left/right truncation amount.
        // This was all a LOT tricker than you might expect (yes basic arithmetic).

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
        // Being careful to truncate the left or right side of the cell appropriately (this was tricky).

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
                        Memory.fastcopy(
                            to: buffer.advanced(by: start), count: count,
                            value: (UInt32(UInt8(fgr * block.blend + bgr * block.blendr)) << Colour.RSHIFT) |
                                   (UInt32(UInt8(fgg * block.blend + bgg * block.blendr)) << Colour.GSHIFT) |
                                   (UInt32(UInt8(fgb * block.blend + bgb * block.blendr)) << Colour.BSHIFT) | fga)
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

    public final func updateImage() {
        self._updateImage()
    }

    public final var selectMode: Bool             { get { self._selectMode } set { self._selectMode = newValue } }
    public final func selectModeToggle()          { self._selectMode = !self._selectMode }

    public final var  automationMode: Bool       { self._actions.automationMode }
    public final var  automationInterval: Double { get { self._actions.automationInterval }
                                                   set { self._actions.automationInterval = newValue} }
    public final func automationModeToggle()     { self._actions.automationModeToggle() }
    public final func automationStart()          { self._actions.automationStart() }
    public final func automationStop()           { self._actions.automationStop() }
    public final var  automationPaused: Bool     { self._actions.automationPaused }
    public final func automationPause()          { self._actions.automationPause() }
    public final func automationResume()         { self._actions.automationResume() }
    open         func automationStep() {}

    public final var  selectRandomMode: Bool       { self._actions.selectRandomMode }
    public final var  selectRandomInterval: Double { get { self._actions.selectRandomInterval }
                                                     set { self._actions.selectRandomInterval = newValue } }
    public final func selectRandomModeToggle()     { self._actions.selectRandomModeToggle() }
    public final func selectRandomStart()          { self._actions.selectRandomStart() }
    public final func selectRandomStop()           { self._actions.selectRandomStop() }
    public final var  selectRandomPaused: Bool     { self._actions.selectRandomPaused }
    public final func selectRandomPause()          { self._actions.selectRandomPause() }
    public final func selectRandomResume()         { self._actions.selectRandomResume() }
    open         func selectRandom()               { self._actions.selectRandom() }

    open func onTap(_ viewPoint: CGPoint) { self._actions.onTap(viewPoint) }
    open func onDrag(_ viewPoint: CGPoint) { self._actions.onDrag(viewPoint) }
    open func onDragEnd(_ viewPoint: CGPoint) { self._actions.onDragEnd(viewPoint) }
    open func onZoom(_ zoomFactor: CGFloat) { self._actions.onZoom(zoomFactor) }
    open func onZoomEnd(_ zoomFactor: CGFloat) { self._actions.onZoomEnd(zoomFactor) }

    open func createCell<T: Cell>(x: Int, y: Int, color: Colour, previous: T? = nil) -> T? {
        return Cell(cellGridView: self, x: x, y: y, color: color) as? T
    }
}
