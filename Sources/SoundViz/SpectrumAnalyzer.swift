import Accelerate

struct SpectrumFrame {
    let bands: [Float]
    let beat: Float
    let waveform: [Float]
}

final class SpectrumAnalyzer {
    private let sampleRate: Float
    private let bandCount: Int
    private(set) var motionResponsePreset: MotionResponsePreset
    private var motionResponseParameters: MotionResponseParameters
    private let fftSize = 1024
    private let log2FFTSize: vDSP_Length = 10
    private let fftSetup: FFTSetup
    private let window: [Float]
    private var realPart: [Float]
    private var imaginaryPart: [Float]
    private var magnitudes: [Float]
    private var analysisSamples: [Float]
    private var writeIndex = 0
    private var bandRanges: [Range<Int>]
    private var bandPeaks: [Float]
    private var bandEnvelopes: [Float]
    private var previousBandMagnitudes: [Float]?
    private var fluxPeak: Float = 0
    private var beatEnvelope: Float = 0
    private var lastBeatTime: TimeInterval = 0
    private let waveformPointCount = 32
    private var waveformPeak: Float = 0

    init(
        requestedSampleRate: Float,
        requestedBandCount: Int,
        motionResponsePreset: MotionResponsePreset = .balanced
    ) {
        self.motionResponsePreset = motionResponsePreset
        motionResponseParameters = motionResponsePreset.parameters
        sampleRate = max(8000, requestedSampleRate)
        bandCount = max(4, requestedBandCount)
        fftSetup = vDSP_create_fftsetup(log2FFTSize, FFTRadix(kFFTRadix2))!
        let configuredFFTSize = 1024
        window = (0..<configuredFFTSize).map { index in
            0.5 - 0.5 * cos(2 * Float.pi * Float(index) / Float(configuredFFTSize - 1))
        }
        realPart = [Float](repeating: 0, count: configuredFFTSize / 2)
        imaginaryPart = [Float](repeating: 0, count: configuredFFTSize / 2)
        magnitudes = [Float](repeating: 0, count: configuredFFTSize / 2)
        analysisSamples = [Float](repeating: 0, count: configuredFFTSize)
        bandRanges = []
        bandPeaks = [Float](repeating: 0, count: bandCount)
        bandEnvelopes = [Float](repeating: 0, count: bandCount)

        let minimumFrequency: Float = 40
        let maximumFrequency = min(16_000, sampleRate / 2)
        let frequencyRatio = maximumFrequency / minimumFrequency
        for band in 0..<bandCount {
            let lowerFrequency = minimumFrequency * pow(frequencyRatio, Float(band) / Float(bandCount))
            let upperFrequency = minimumFrequency * pow(frequencyRatio, Float(band + 1) / Float(bandCount))
            let lowerBin = max(1, Int(lowerFrequency * Float(fftSize) / sampleRate))
            let upperBin = max(lowerBin + 1, Int(upperFrequency * Float(fftSize) / sampleRate))
            bandRanges.append(lowerBin..<min(upperBin, magnitudes.count))
        }
    }

    deinit {
        vDSP_destroy_fftsetup(fftSetup)
    }

    func process(samples: [Float], timestamp: TimeInterval) -> SpectrumFrame {
        for sample in samples {
            analysisSamples[writeIndex] = sample
            writeIndex = (writeIndex + 1) % fftSize
        }

        var frame = [Float](repeating: 0, count: fftSize)
        for index in 0..<fftSize {
            frame[index] = analysisSamples[(writeIndex + index) % fftSize] * window[index]
        }

        let bandMagnitudes = extractBandMagnitudes(from: frame)
        let normalizedBands = normalizeBandMagnitudes(bandMagnitudes)
        updateEnvelopes(with: normalizedBands)
        updateBeat(bandMagnitudes: bandMagnitudes, timestamp: timestamp)
        return SpectrumFrame(
            bands: bandEnvelopes,
            beat: beatEnvelope,
            waveform: normalizedWaveform()
        )
    }

    func updateMotionResponse(_ preset: MotionResponsePreset) {
        motionResponsePreset = preset
        motionResponseParameters = preset.parameters
    }

    private func extractBandMagnitudes(from frame: [Float]) -> [Float] {
        realPart.withUnsafeMutableBufferPointer { realPointer in
            imaginaryPart.withUnsafeMutableBufferPointer { imaginaryPointer in
                var splitComplex = DSPSplitComplex(
                    realp: realPointer.baseAddress!,
                    imagp: imaginaryPointer.baseAddress!
                )
                frame.withUnsafeBytes { rawBuffer in
                    let complexSamples = rawBuffer.bindMemory(to: DSPComplex.self)
                    for index in 0..<fftSize / 2 {
                        realPointer[index] = complexSamples[index].real
                        imaginaryPointer[index] = complexSamples[index].imag
                    }
                }

                vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2FFTSize, FFTDirection(FFT_FORWARD))
                magnitudes.withUnsafeMutableBufferPointer { magnitudePointer in
                    vDSP_zvmags(
                        &splitComplex,
                        1,
                        magnitudePointer.baseAddress!,
                        1,
                        vDSP_Length(fftSize / 2)
                    )
                }
            }
        }

        return bandRanges.map { range in
            guard !range.isEmpty else { return 0 }
            return magnitudes.withUnsafeBufferPointer { magnitudePointer in
                var squaredTotal: Float = 0
                vDSP_svesq(
                    magnitudePointer.baseAddress! + range.lowerBound,
                    1,
                    &squaredTotal,
                    vDSP_Length(range.count)
                )
                return sqrt(squaredTotal / Float(range.count))
            }
        }
    }

    private func normalizeBandMagnitudes(_ bandMagnitudes: [Float]) -> [Float] {
        bandMagnitudes.enumerated().map { index, magnitude in
            let previousPeak = bandPeaks[index]
            let adaptivePeak = magnitude > previousPeak
                ? previousPeak + (magnitude - previousPeak) * 0.35
                : previousPeak * 0.995
            bandPeaks[index] = max(adaptivePeak, 1e-6)
            let normalized = magnitude / bandPeaks[index]
            return pow(min(1, max(0, normalized)), 0.75)
        }
    }

    private func updateEnvelopes(with normalizedBands: [Float]) {
        for index in 0..<bandCount {
            let target = normalizedBands[index]
            let current = bandEnvelopes[index]
            let blend = target > current
                ? motionResponseParameters.bandAttack
                : motionResponseParameters.bandDecay
            bandEnvelopes[index] = current + (target - current) * blend
        }
    }

    private func updateBeat(bandMagnitudes: [Float], timestamp: TimeInterval) {
        let bassBandCount = min(3, bandMagnitudes.count)
        guard let previousMagnitudes = previousBandMagnitudes else {
            previousBandMagnitudes = bandMagnitudes
            return
        }

        var flux: Float = 0
        for index in 0..<bassBandCount {
            flux += max(0, bandMagnitudes[index] - previousMagnitudes[index])
        }
        flux /= Float(bassBandCount)
        previousBandMagnitudes = bandMagnitudes

        fluxPeak = max(flux, fluxPeak * 0.995)
        let normalizedFlux = flux / max(fluxPeak, 1e-9)
        beatEnvelope *= 0.86

        if normalizedFlux > 0.58, timestamp - lastBeatTime > 0.12 {
            beatEnvelope = 1
            lastBeatTime = timestamp
        }
    }

    private func normalizedWaveform() -> [Float] {
        var orderedSamples = [Float](repeating: 0, count: fftSize)
        for index in 0..<fftSize {
            orderedSamples[index] = analysisSamples[(writeIndex + index) % fftSize]
        }

        var mean: Float = 0
        vDSP_meanv(orderedSamples, 1, &mean, vDSP_Length(fftSize))
        var centeredSamples = [Float](repeating: 0, count: fftSize)
        var negativeMean = -mean
        vDSP_vsadd(orderedSamples, 1, &negativeMean, &centeredSamples, 1, vDSP_Length(fftSize))

        var currentPeak: Float = 0
        vDSP_maxmgv(centeredSamples, 1, &currentPeak, vDSP_Length(fftSize))
        waveformPeak = max(currentPeak, waveformPeak * 0.995)
        let normalizationPeak = max(waveformPeak, 1e-6)

        let stride = max(1, fftSize / waveformPointCount)
        return (0..<waveformPointCount).map { index in
            let sampleIndex = min(fftSize - 1, index * stride)
            return max(-1, min(1, centeredSamples[sampleIndex] / normalizationPeak))
        }
    }
}
