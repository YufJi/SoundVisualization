import AppKit

final class AudioVisualizer {
    private let waveformPointCount = 32
    private(set) var style: VisualizationStyle
    private(set) var bandCount: Int
    private(set) var motionResponsePreset: MotionResponsePreset
    private var motionResponseParameters: MotionResponseParameters
    private var targetBands: [Float]
    private var displayedBands: [CGFloat]
    private var targetWaveform: [Float]
    private var displayedWaveform: [CGFloat]
    private var targetBeat: Float = 0
    private var displayedBeat: CGFloat = 0
    private var renderTimer: Timer?
    var onUpdate: ((NSImage) -> Void)?

    init(
        style: VisualizationStyle,
        bandPreset: BandPreset = .twelve,
        motionResponsePreset: MotionResponsePreset = .balanced
    ) {
        self.style = style
        bandCount = bandPreset.bandCount
        self.motionResponsePreset = motionResponsePreset
        motionResponseParameters = motionResponsePreset.parameters
        targetBands = [Float](repeating: 0, count: bandCount)
        displayedBands = [CGFloat](repeating: 0, count: bandCount)
        targetWaveform = [Float](repeating: 0, count: waveformPointCount)
        displayedWaveform = [CGFloat](repeating: 0, count: waveformPointCount)
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.render()
        }
        RunLoop.main.add(timer, forMode: .common)
        renderTimer = timer
    }

    deinit {
        renderTimer?.invalidate()
    }

    var image: NSImage {
        switch style {
        case .bars:
            return makeBarsImage()
        case .waveform:
            return makeWaveformImage()
        case .spectrumArea:
            return makeSpectrumAreaImage()
        }
    }

    func setStyle(_ newStyle: VisualizationStyle) {
        style = newStyle
    }

    func updateBandPreset(_ preset: BandPreset) {
        let newBandCount = preset.bandCount
        guard newBandCount != bandCount else { return }
        bandCount = newBandCount
        targetBands = [Float](repeating: 0, count: newBandCount)
        displayedBands = [CGFloat](repeating: 0, count: newBandCount)
    }

    func updateMotionResponse(_ preset: MotionResponsePreset) {
        motionResponsePreset = preset
        motionResponseParameters = preset.parameters
    }

    private func makeBarsImage() -> NSImage {
        let size = NSSize(width: 38, height: 18)
        let image = NSImage(size: size)
        image.lockFocusFlipped(false)
        NSColor.labelColor.withAlphaComponent(0.9).setFill()

        let centerY = size.height / 2
        for index in 0..<bandCount {
            let slotWidth = (size.width - 2) / CGFloat(bandCount)
            let barWidth = min(2, slotWidth * 0.65)
            let pulseWeight = pulseWeight(for: index)
            let band = min(1, displayedBands[index] + displayedBeat * pulseWeight)
            let height = max(2, min(size.height - 2, band * (size.height - 2)))
            let x = 1 + CGFloat(index) * slotWidth + (slotWidth - barWidth) / 2
            let rect = NSRect(x: x, y: centerY - height / 2, width: barWidth, height: height)
            NSBezierPath(roundedRect: rect, xRadius: 1, yRadius: 1).fill()
        }
        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    private func makeWaveformImage() -> NSImage {
        let size = NSSize(width: 38, height: 18)
        let image = NSImage(size: size)
        image.lockFocusFlipped(false)

        let centerY = size.height / 2
        let amplitude = (size.height - 7) / 2 * (1 + displayedBeat * 0.28)
        let points = displayedWaveform.enumerated().map { index, value in
            NSPoint(
                x: 2 + CGFloat(index) / CGFloat(waveformPointCount - 1) * (size.width - 4),
                y: centerY - value * amplitude
            )
        }

        let path = NSBezierPath()
        path.lineWidth = 1.4
        path.lineCapStyle = .round
        appendSmoothCurve(to: path, points: points)
        NSColor.labelColor.withAlphaComponent(0.9).setStroke()
        path.stroke()

        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    private func makeSpectrumAreaImage() -> NSImage {
        let size = NSSize(width: 38, height: 18)
        let image = NSImage(size: size)
        image.lockFocusFlipped(false)

        let baseline: CGFloat = 2
        let availableHeight = size.height - 4
        let points = (0..<bandCount).map { index in
            let pulseWeight = pulseWeight(for: index) * 0.8
            let band = min(1, displayedBands[index] + displayedBeat * pulseWeight)
            return NSPoint(
                x: 2 + CGFloat(index) / CGFloat(bandCount - 1) * (size.width - 4),
                y: baseline + band * availableHeight
            )
        }

        let areaPath = NSBezierPath()
        areaPath.move(to: NSPoint(x: 2, y: baseline))
        appendSmoothCurve(to: areaPath, points: points, shouldMove: false)
        areaPath.line(to: NSPoint(x: size.width - 2, y: baseline))
        areaPath.close()
        NSColor.labelColor.withAlphaComponent(0.42).setFill()
        areaPath.fill()

        let strokePath = NSBezierPath()
        appendSmoothCurve(to: strokePath, points: points)
        strokePath.lineWidth = 1.1
        NSColor.labelColor.withAlphaComponent(0.9).setStroke()
        strokePath.stroke()

        image.unlockFocus()
        image.isTemplate = true
        return image
    }

    private func appendSmoothCurve(to path: NSBezierPath, points: [NSPoint], shouldMove: Bool = true) {
        guard let first = points.first else { return }
        if points.count == 1 {
            if shouldMove {
                path.move(to: first)
            }
            return
        }

        if shouldMove {
            path.move(to: first)
        }
        for index in 0..<points.count - 1 {
            let current = points[index]
            let next = points[index + 1]
            let previous = points[max(0, index - 1)]
            let afterNext = points[min(points.count - 1, index + 2)]

            let controlPoint1 = NSPoint(
                x: current.x + (next.x - previous.x) / 6,
                y: current.y + (next.y - previous.y) / 6
            )
            let controlPoint2 = NSPoint(
                x: next.x - (afterNext.x - current.x) / 6,
                y: next.y - (afterNext.y - current.y) / 6
            )
            path.curve(to: next, controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        }
    }

    private func pulseWeight(for index: Int) -> CGFloat {
        0.28 / (CGFloat(index) + 1.25)
    }

    func push(spectrum: SpectrumFrame) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            for index in 0..<self.bandCount where index < spectrum.bands.count {
                self.targetBands[index] = spectrum.bands[index]
            }
            for index in 0..<self.waveformPointCount where index < spectrum.waveform.count {
                self.targetWaveform[index] = spectrum.waveform[index]
            }
            self.targetBeat = spectrum.beat
        }
    }

    private func render() {
        for index in 0..<bandCount {
            let target = max(0, min(1, CGFloat(targetBands[index])))
            let current = displayedBands[index]
            let blend = target > current
                ? CGFloat(motionResponseParameters.bandAttack)
                : CGFloat(motionResponseParameters.bandDecay)
            displayedBands[index] = current + (target - current) * blend
        }
        for index in 0..<waveformPointCount {
            let target = max(-1, min(1, targetWaveform[index]))
            let smoothing = CGFloat(motionResponseParameters.waveformSmoothing)
            displayedWaveform[index] += (CGFloat(target) - displayedWaveform[index]) * smoothing
        }

        let beatDecay = CGFloat(motionResponseParameters.beatDecay)
        displayedBeat = max(CGFloat(targetBeat), displayedBeat * beatDecay)
        targetBeat = 0
        let rendered = image
        DispatchQueue.main.async { [weak self] in
            self?.onUpdate?(rendered)
        }
    }
}
