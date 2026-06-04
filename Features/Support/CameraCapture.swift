//
//  CameraCapture.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/4/26.
//

import SwiftUI
import AVFoundation

struct CameraCaptureView: View {
	
	let onCapture: (UIImage) -> Void
	
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.dismiss) private var dismiss
	
	@State private var session = AVCaptureSession()
	@State private var output = AVCapturePhotoOutput()
	@State private var capturedImage: UIImage?
	@State private var photoDelegate: PhotoDelegate?
	@State private var currentInput: AVCaptureDeviceInput?
	@State private var cameraPosition: AVCaptureDevice.Position = .back
	@State private var showConfigured: Bool = false
	
	var body: some View {
		ZStack {
			if let image = capturedImage {
				Image(uiImage: image)
					.resizable()
					.scaledToFill()
					.ignoresSafeArea()
				VStack(alignment: .center) {
					Spacer()
					HStack(alignment: .center, spacing: 25) {
						Button {
							capturedImage = nil
						} label: {
							Text("Retake")
								.frame(width: 100, height: 50)
								.overlay { RoundedRectangle(cornerRadius: 25).stroke(.black.opacity(0.2), lineWidth: 6) }
								.glassEffect(.clear.tint(.white).interactive(), in: .rect(cornerRadius: 25))
						}
						Button {
							onCapture(image)
							dismiss()
						} label: {
							Text("Use Photo")
								.foregroundStyle(.white)
								.frame(width: 140, height: 50)
								.overlay { RoundedRectangle(cornerRadius: 25).stroke(.black.opacity(0.2), lineWidth: 6) }
								.glassEffect(.clear.tint(Color.accentColor).interactive(), in: .rect(cornerRadius: 25))
						}
					}
					.font(.system(size: 20, weight: .semibold))
				}
				.padding(.bottom, 40)
			} else {
				GeometryReader { geo in
					ZStack {
						CameraPreview(session: session)
							.ignoresSafeArea()
						VStack {
							Spacer()
							let spacing: CGFloat = 90
							ZStack {
								Button {
									capture()
								} label: {
									Circle()
										.fill(.white)
										.frame(width: 72, height: 72)
										.overlay { Circle().stroke(.black.opacity(0.2), lineWidth: 6) }
								}
								Button {
									switchCamera()
								} label: {
									Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
										.font(.system(size: 25))
										.foregroundStyle(.white)
										.padding()
								}
								.glassEffect(.regular.tint(.black.opacity(0.2)).interactive(), in: .circle)
								.offset(x: spacing)
							}
							.frame(maxWidth: .infinity)
							.padding(.bottom, 30)
						}
					}
				}
			}
		}
		.task {
			guard !showConfigured else { return }
			configure()
			session.startRunning()
			showConfigured = true
		}
		.onDisappear {
			session.stopRunning()
			capturedImage = nil
			photoDelegate = nil
		}
	}
	
	private func configure() {
		
		session.beginConfiguration()
		
		defer { session.commitConfiguration() }
		
		session.sessionPreset = .photo
		
		guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition), let input = try? AVCaptureDeviceInput(device: device), session.canAddInput(input) else { return }
		
		session.addInput(input)
		currentInput = input
		
		guard session.canAddOutput(output) else { return }
		
		session.addOutput(output)
	}
	
	private func capture() {
		let delegate = PhotoDelegate { image in Task { @MainActor in capturedImage = image; photoDelegate = nil } }
		
		photoDelegate = delegate
		output.capturePhoto(with: AVCapturePhotoSettings(), delegate: delegate)
	}
	
	private func switchCamera() {
		guard let currentInput else { return }
		
		let newPosition: AVCaptureDevice.Position = cameraPosition == .back ? .front : .back
		
		guard let newDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition), let newInput = try? AVCaptureDeviceInput(device: newDevice) else { return }
		
		session.beginConfiguration()
		session.removeInput(currentInput)
		
		if session.canAddInput(newInput) {
			session.addInput(newInput)
			self.currentInput = newInput
			self.cameraPosition = newPosition
		} else {
			session.addInput(currentInput)
		}
		
		session.commitConfiguration()
	}
	
	private final class PhotoDelegate: NSObject, AVCapturePhotoCaptureDelegate {
		
		private let completion: (UIImage) -> Void
		
		init(completion: @escaping (UIImage) -> Void) { self.completion = completion }
		
		func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
			guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
			completion(image)
		}
	}
	
	private struct CameraPreview: UIViewRepresentable {
		
		let session: AVCaptureSession
		
		func makeUIView(context: Context) -> PreviewView {
			let view = PreviewView()
			view.videoPreviewLayer.session = session
			view.videoPreviewLayer.videoGravity = .resizeAspectFill
			return view
		}
		
		func updateUIView(_ uiView: PreviewView, context: Context) { uiView.videoPreviewLayer.session = session }
		
		final class PreviewView: UIView {
			
			override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
			
			var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
			
			override func layoutSubviews() {
				super.layoutSubviews()
				videoPreviewLayer.frame = bounds
			}
		}
	}
}
