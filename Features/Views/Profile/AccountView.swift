//
//  AccountView.swift
//  JustOuvrage
//
//  Created by Jules Longin on 6/3/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct AccountView: View {
	
	@Environment(FileImageStorage.self) private var storage
	
	@Bindable private var preferences: Preferences = .unique
	
	@State private var selectedPhotoItem: PhotosPickerItem?
	@State private var selectedUIImage: UIImage?
	@State private var pendingUIImage: UIImage?
	@State private var profileName: String = ""
	@State private var showAddedBanner: Bool = false
	@State private var showPhotoPicker: Bool = false
	@State private var showClearImage: Bool = false
	
	private let circle = Circle()
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 30) {
					Menu {
						Button {
							// Take Photo
						} label: {
							Label("Take Photo", systemImage: "camera")
						}
						Button {
							showPhotoPicker.toggle()
						} label: {
							Label("Choose Photo", systemImage: "photo.on.rectangle")
						}
						Button {
							// Choose File
						} label: {
							Label("Choose File", systemImage: "folder")
						}
					} label: {
						circle
							.fill(.ultraThinMaterial)
							.overlay {
								if let image = selectedUIImage {
									Image(uiImage: image)
										.resizable()
										.scaledToFill()
								} else {
									Image(Constants.defaultProfileImage)
										.resizable()
										.scaledToFill()
								}
							}
							.frame(width: 180, height: 180)
							.clipShape(circle)
					}
					TextField("Account name", text: $profileName)
						.bold()
						.multilineTextAlignment(.center)
						.padding(12)
						.background(Capsule().fill(.thinMaterial))
					HStack(alignment: .top) {
						Text("your ID:")
							.font(.caption)
							.foregroundStyle(.secondary)
						Text(preferences.profileUUID.uuidString)
					}
					.bold()
					.multilineTextAlignment(.center)
					.frame(maxWidth: .infinity)
					.padding(18)
					.background(RoundedRectangle(cornerRadius: 18).fill(.thinMaterial))
					.contentShape(Rectangle())
					.onTapGesture {
						UIPasteboard.general.string = preferences.profileUUID.uuidString
						Task { await showAdded() }
					}
					Text("Exiting the app permanently saves the changes.")
						.font(.caption)
						.foregroundStyle(.secondary)
					HStack {
						Spacer()
						Button {
							showClearImage.toggle()
						} label: {
							Label("Clear Image", systemImage: "trash")
								.foregroundStyle(Color(.label))
								.frame(width: 170, height: 55)
								.glassEffect(.clear.interactive())
						}
					}
				}
				.padding(.horizontal)
				.frame(maxWidth: .infinity, alignment: .bottom)
			}
			.onChange(of: selectedPhotoItem) { _, item in
				guard let item else { return }
				
				Task {
					guard let data = try? await item.loadTransferable(type: Data.self), let image = UIImage(data: data) else { return }
					pendingUIImage = image
					selectedUIImage = image
				}
			}
			.onAppear {
				profileName = preferences.profileName
				
				if let image = try? storage.load(image: preferences.profileImage) {
					selectedUIImage = image
				}
			}
			.onDisappear {
				let trimmed = profileName.trimmingCharacters(in: .whitespacesAndNewlines)
				preferences.profileName = trimmed.isEmpty ? Constants.noAuthor : trimmed
				
				if let pendingUIImage {
					let oldImage = preferences.profileImage
					do {
						let newImage = try storage.save(image: pendingUIImage)
						preferences.profileImage = newImage
						
						if !oldImage.isEmpty {
							try? storage.delete(image: oldImage)
						}
					} catch {
						print(Errors.Image)
					}
				}
				selectedPhotoItem = nil
				selectedUIImage = nil
				pendingUIImage = nil
			}
			.photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
			.overlay(alignment: .top) {
				if showAddedBanner {
					Label("Copied", systemImage: "checkmark.circle.fill")
						.environment(\.layoutDirection, .rightToLeft)
						.font(.subheadline.weight(.medium))
						.padding(EdgeInsets(top: 10, leading: 14, bottom: 10, trailing: 14))
						.background(.regularMaterial)
						.clipShape(Capsule())
						.transition(.move(edge: .top).combined(with: .opacity))
				}
			}
			.navigationTitle("Account")
			.navigationBarTitleDisplayMode(.inline)
			.alert("Clear Image", isPresented: $showClearImage) {
				Button("Clear", role: .destructive) {
					if selectedUIImage != nil || pendingUIImage != nil {
						try? storage.delete(image: preferences.profileImage)
					}
					selectedPhotoItem = nil
					selectedUIImage = nil
					pendingUIImage = nil
					preferences.profileImage = Constants.defaultProfileImage
				}
				Button("Cancel", role: .cancel) { }
			} message: {
				Text("Are you sure you want to clear your profile image?")
			}
			.scrollDismissesKeyboard(.interactively)
			.scrollIndicators(.hidden)
		}
	}
}

fileprivate extension AccountView {
	
	@MainActor private func showAdded() async {
		withAnimation(.snappy) {
			showAddedBanner.toggle()
		}
		try? await Task.sleep(for: .seconds(1.5))
		withAnimation(.snappy) {
			showAddedBanner.toggle()
		}
	}
}

#Preview {
	
	let container = try! ModelContainer(for: Deck.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
	
	return AccountView()
		.modelContainer(container)
		.environment(FileImageStorage())
}
