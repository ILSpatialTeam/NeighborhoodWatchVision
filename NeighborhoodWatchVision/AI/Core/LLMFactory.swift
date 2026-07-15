//
//  LLMFactory.swift
//  NeighborhoodWatchVision
//
//  Created by Fatakhillah Khaqo on 08/07/26.
//

import Foundation
import MLX
import MLXLLM
import MLXLMCommon
import Hub
import MLXHuggingFace
import Tokenizers
import HuggingFace

public actor LLMFactory {
    public enum LoadState {
        case idle
        case loading(Task<ModelContainer, Error>)
        case loaded(ModelContainer)
    }
    
    private var loadState = LoadState.idle
    
    public init() {}
    
    public func load(progressHandler: @escaping @Sendable (Double, String) -> Void = { _,_ in }) async throws -> ModelContainer {
        switch loadState {
        case .idle:
            let task = Task {
                let config = ModelConfiguration(id: "mlx-community/Qwen2.5-3B-Instruct-4bit")
                
                let conserveMemory = Memory.memoryLimit < 8 * 1024 * 1024 * 1024
                if conserveMemory {
                    Memory.cacheLimit = 1 * 1024 * 1024
                    Memory.memoryLimit = 3 * 1024 * 1024 * 1024
                } else {
                    Memory.cacheLimit = 256 * 1024 * 1024
                }
                
                let downloader = #hubDownloader()
                progressHandler(0.0, "Resolving Model...")
                let resolved = try await resolve(configuration: config, from: downloader, useLatest: false) { progress in
                    progressHandler(progress.fractionCompleted, "Downloading weights...")
                }
                progressHandler(1.0, "Loading into Memory...")
                let container = try await LLMModelFactory.shared.loadContainer(
                    from: resolved.modelDirectory,
                    using: #huggingFaceTokenizerLoader()
                )
                progressHandler(1.0, "Ready")
                return container
            }
            self.loadState = .loading(task)
            let result = try await task.value
            self.loadState = .loaded(result)
            return result
        case .loading(let task):
            return try await task.value
        case .loaded(let result):
            return result
        }
    }
}
