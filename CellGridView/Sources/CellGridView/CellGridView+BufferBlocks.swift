import Foundation
import Utils

extension CellGridView
{
    internal final class BufferBlocks
    {
        internal final class BufferBlock
        {
            internal let index: Int
            internal let foreground: Bool
            internal let blend: Float
            internal var count: Int
            internal var width: Int
            internal var indexLast: Int
            internal var truncatexCache: [Int: [(index: Int, count: Int)]] = [:]
            internal typealias WriteCellBlock = (_ block: BufferBlock, _ index: Int, _ count: Int) -> Void

            init(index: Int, count: Int, foreground: Bool, blend: Float, width: Int) {
                self.index = max(index, 0)
                self.count = max(count, 0)
                self.foreground = foreground
                self.blend = blend
                self.width = width
                self.indexLast = self.index
            }

            // Write blocks using the given write function IGNORING indices to the RIGHT of the given truncatex value.
            //
            internal func writeLeft(truncatex: Int, write: WriteCellBlock) {
                self.writeTruncated(truncatex: -truncatex, write: write)
            }

            // Write blocks using the given write function IGNORING indices to the LEFT Of the given truncatex value.
            //
            internal func writeRight(truncatex: Int, write: WriteCellBlock) {
                self.writeTruncated(truncatex: truncatex, write: write)
            }

            // Write blocks using the given write function IGNORING indices which correspond to
            // a shifting left or right by the given (truncatex) amount; tricky due to the row-major
            // organization of grid cells/pixels in the one-dimensional buffer array.
            //
            // A positive truncatex means to truncate the values (pixels) LEFT of the given truncatex value; and
            // a negative truncatex means to truncate the values (pixels) RIGHT of the given truncatex value; and
            //
            // Note that the BufferBlock.index is a byte index into the buffer, i.e. it already has Screen.channels
            // factored into it; and note that the BufferBlock.count refers to the number of 4-byte (UInt32) values,
            //
            internal func writeTruncated(truncatex: Int, write: WriteCellBlock) {

                if let truncatexValues = self.truncatexCache[truncatex] {
                    //
                    // Caching block values (index, count) distinct truncatex values can
                    // can really speed things up noticably (e.g. 0.02874s vs 0.07119s).
                    // FYI for really big cell-sizes (e.g. 250 unscaled) the size of this
                    // cache could exceed 25MB; not too bad really for the performance benefit.
                    // We could pre-populate this but it takes too longer (more than a second) for
                    // larger cell-sizes; it would look like this at the end of createBufferBlocks:
                    //
                    //  for truncatex in 1...(cellSize - 1) {
                    //    func dummyWriteCellBlock(_ block: BufferBlocks.BufferBlock, _ index: Int, _ count: Int) {}
                    //    for block in blocks._blocks {
                    //      block.writeTruncated(truncatex: truncatex, write: dummyWriteCellBlock, debug: false)
                    //      block.writeTruncated(truncatex: -truncatex, write: dummyWriteCellBlock, debug: false)
                    //    }
                    //  }
                    //
                    // self.truncatexCache[truncatex]?.forEach { write(self, $0.index, $0.count) }
                    //
                    truncatexValues.forEach { write(self, $0.index, $0.count) }
                    return
                }

                var truncatexValuesToCache: [(index: Int, count: Int)] = []
                let shiftw: Int = abs(truncatex)
                let shiftl: Bool = (truncatex < 0)
                let shiftr: Bool = (truncatex > 0)
                var index: Int? = nil
                var count: Int = 0
                for i in 0..<self.count {
                    let starti: Int = self.index + i * Memory.bufferBlockSize
                    let shift: Int = (starti / Memory.bufferBlockSize) % self.width
                    if ((shiftr && (shift >= shiftw)) || (shiftl && (shift < shiftw))) {
                        if (index == nil) {
                            index = starti
                            count = 1
                        } else {
                            count += 1
                        }
                    } else {
                        if let j: Int = index {
                            truncatexValuesToCache.append((index: j, count: count))
                            write(self, j, count)
                            if (shiftr && (shift > shiftw)) { break }
                            else if (shiftl && (shift >= shiftw)) { break }
                            index = nil
                            count = 0
                        } else {
                            if (shiftr && (shift > shiftw)) { break }
                            else if (shiftl && (shift >= shiftw)) { break }
                        }
                    }
                }
                if let j: Int = index {
                    truncatexValuesToCache.append((index: j, count: count))
                    write(self, j, count)
                }
                self.truncatexCache[truncatex] = truncatexValuesToCache
            }
        }

        private let _width: Int
        private var _blocks: [BufferBlock] = []

        init(width: Int = 0) {
            self._width = width
        }

        internal var blocks: [BufferBlock] {
            self._blocks
        }

        internal var memoryUsageBytes: Int {
            var totalTuples: Int = 0
            for block in self._blocks {
                totalTuples += block.truncatexCache.values.reduce(0) { $0 + $1.count }
            }
            return totalTuples * MemoryLayout<(Int, Int)>.stride
        }

        internal var blockCount: Int {
            return self._blocks.count
        }

        private func append(_ index: Int, foreground: Bool, blend: Float, width: Int) {
            if let last: BufferBlock = self._blocks.last,
                   last.foreground == foreground,
                   last.blend == blend,
                   index == last.indexLast + Memory.bufferBlockSize {
                last.count += 1
                last.indexLast = index
            } else {
                self._blocks.append(BufferBlock(index: index, count: 1,
                                                foreground: foreground, blend: blend, width: width))
            }
        }

        internal static func createBufferBlocks(
            bufferSize: Int,
            viewWidth: Int,
            viewHeight: Int,
            cellSize: Int,
            cellPadding: Int,
            cellShape: CellShape,
            cellShading: Bool = false,
            //
            // TODO
            // Currently doing nothing with the transparency.
            //
            cellTransparency: UInt8 = Colour.OPAQUE,
            cellAntialiasFade: Float = Defaults.cellAntialiasFade,
            cellRoundedRadius: Float = Defaults.cellRoundedRadius) -> BufferBlocks
        {
            // Note that all size related arguments here are assume to be scaled.

            let blocks: BufferBlocks = BufferBlocks(width: viewWidth)
            let padding: Int = (cellPadding * 2) >= cellSize
                               ? ((cellSize / 2) - 1)
                               : cellPadding
            let cellSizeMinusPadding: Int = cellSize - padding
            let cellSizeMinusPaddingTimesTwo: Int = cellSize - (2 * padding)
            let fade: Float = cellAntialiasFade

            for dy in 0..<cellSize {
                for dx in 0..<cellSize {
    
                    if ((dx >= viewWidth) || (dy >= viewHeight)) { continue }
                    if ((dx < 0) || (dy < 0)) { continue }
                    var coverage: Float

                    switch cellShape {
                    case .square:
                        if ((dx >= padding) && (dx < cellSizeMinusPadding) &&
                            (dy >= padding) && (dy < cellSizeMinusPadding)) {
                            coverage = 1.0
                        }
                        else { coverage = 0.0 }

                    case .circle:
                        let fx: Float = Float(dx) + 0.5
                        let fy: Float = Float(dy) + 0.5
                        let centerX: Float = Float(cellSize / 2)
                        let centerY: Float = Float(cellSize / 2)
                        let dxsq: Float = (fx - centerX) * (fx - centerX)
                        let dysq: Float = (fy - centerY) * (fy - centerY)
                        let circleRadius: Float = Float(cellSizeMinusPaddingTimesTwo) / 2.0
                        let d: Float = circleRadius - sqrt(dxsq + dysq)
                        coverage = max(0.0, min(1.0, d / fade))

                    case .rounded:
                        let fx: Float = Float(dx) + 0.5
                        let fy: Float = Float(dy) + 0.5
                        let cornerRadius: Float = Float(cellSizeMinusPaddingTimesTwo) * cellRoundedRadius
                        let minX: Float = Float(padding)
                        let minY: Float = Float(padding)
                        let maxX: Float = Float(cellSizeMinusPadding)
                        let maxY: Float = Float(cellSizeMinusPadding)
                        if ((fx >= minX + cornerRadius) && (fx <= maxX - cornerRadius)) {
                            if ((fy >= minY) && (fy <= maxY)) { coverage = 1.0 }
                            else { coverage = 0.0 }
                        } else if ((fy >= minY + cornerRadius) && (fy <= maxY - cornerRadius)) {
                            if ((fx >= minX) && (fx <= maxX)) { coverage = 1.0 }
                            else { coverage = 0.0 }
                        } else {
                            let cx: Float = fx < (minX + cornerRadius) ? minX + cornerRadius :
                                            fx > (maxX - cornerRadius) ? maxX - cornerRadius : fx
                            let cy: Float = fy < (minY + cornerRadius) ? minY + cornerRadius :
                                            fy > (maxY - cornerRadius) ? maxY - cornerRadius : fy
                            let dx: Float = fx - cx
                            let dy: Float = fy - cy
                            let d: Float = cornerRadius - sqrt(dx * dx + dy * dy)
                            coverage = max(0.0, min(1.0, d / fade))
                        }
                        //
                        // NEW (3D shading) BUT NOT YET WORKING VERY WELL (VIA CHATGPT) ...
                        // Plus it slows down rendering considerably (noticable mostly on zoom in/out);
                        // and (related) it consumes significantly more memory, i.e. via BufferBlocks.
                        //
                        if (cellShading && (coverage > 0.0)) {
                            let fx = Float(dx - padding)
                            let fy = Float(dy - padding)
                            let size = Float(cellSize - 2 * padding)
                            // normalized [0, 1] coordinate within cell
                            let u = fx / size
                            let v = fy / size
                            // diagonal gradient factor; 0 at top/left; 1 at bottom/right
                            let gradient = (u + v) / 2.0
                            // apply shading; brightens near top/left; darkens near bottom/right
                            let shadingStrength: Float = 1.4 // max effect
                            let shading = shadingStrength * (0.5 - gradient)
                            coverage = max(0.0, min(1.0, coverage + shading))
                        }
                    }

                    let index: Int = (dy * viewWidth + dx) * Screen.channels
                    if ((index >= 0) && ((index + (Screen.channels - 1)) < bufferSize)) {
                        if (coverage > 0.0) {
                            blocks.append(index, foreground: true, blend: coverage, width: viewWidth)
                        } else {
                            blocks.append(index, foreground: false, blend: 0.0, width: viewWidth)
                        }
                    }
                }
            }

            return blocks
        }
    }
}
