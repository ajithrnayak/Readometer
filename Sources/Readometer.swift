//
//  Readometer.swift
//  
//
//  Created by Ajith Renjala on 05/04/23.
//

import Foundation
import ArgumentParser

@main
struct Readometer: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "A Swift command-line tool for estimating the reading time of articles",
        subcommands: [Estimate.self, WordCount.self],
        defaultSubcommand: Estimate.self)
}

extension Readometer {
    struct FilePath: ExpressibleByArgument {
        var pathString: String
        
        init?(argument: String) {
            self.pathString = argument
        }
    }

    
    struct Options: ParsableArguments {
        @Argument var filePath: FilePath?
        
        @Option(name: [.short, .customLong("input")], help: "A path to a file to read.")
        var inputFilePath: String?
        
        @Flag(name: .shortAndLong, help: "Show status updates for debugging purposes.")
        var verbose = false
    }
    
    enum FileType: CaseIterable {
        case text
        case markdown
        
        init?(filePath: String) {
            guard let type = FileType.allCases.first(where: {
                filePath.hasSuffix($0.fileExtension)
            }) else {
                return nil
            }
            self = type
        }
        
        var fileExtension: String {
            switch self {
            case .text:
                return ".txt"
            case .markdown:
                return ".md"
            }
        }
    }
    
    struct Estimate: ParsableCommand {
        // Defines the average reading speed in words per minute (wpm)
        var averageReadingSpeed = 200
        
        public static let configuration = CommandConfiguration(abstract: "Estimate Reading Time")
        
        @OptionGroup var options: Options
        
        mutating func run() throws {
            
            // Get the path to the file
            var inputFile: String = options.inputFilePath ?? ""
            // if users are familiar with argument, we will make their life easy.
            if let filePath = options.filePath {
                inputFile = filePath.pathString
            }
            
            if options.verbose {
                print("Estimating reading time for '\(inputFile)'")
            }
            
            // Load the contents of the file into a string
            guard let fileContents = try? String(contentsOfFile: inputFile) else {
                throw RuntimeError("Couldn't read from '\(inputFile)'!")
            }
            
            // Determine file type
            guard let fileType = FileType(filePath: inputFile) else {
                throw RuntimeError("Unsupported file type '\(inputFile)'!")
            }
            
            // Strip Markdown syntax if necessary
            let plainText: String
            switch fileType {
            case .text:
                plainText = fileContents
            case .markdown:
                guard let regex = try? NSRegularExpression(pattern: #"\[.*?\]\((.*?)\)"#) else {
                    throw RuntimeError("Failed to read Markdown file '\(inputFile)'!")
                }
                plainText = regex.stringByReplacingMatches(
                    in: fileContents,
                    range: NSRange(fileContents.startIndex..., in: fileContents),
                    withTemplate: "$1")
            }
            
            // Calculate the estimated reading time in minutes
            let wordCount = plainText.components(separatedBy: .whitespacesAndNewlines).count
            let readingTime = Double(wordCount) / Double(averageReadingSpeed)
            
            print("Estimated reading time: \(Int(readingTime.rounded())) minutes")
        }
    }
    
    struct WordCount: ParsableCommand {
        // Defines the average reading speed in words per minute (wpm)
        var averageReadingSpeed = 200
        
        public static let configuration = CommandConfiguration(abstract: "Estimate Reading Time")
        
        @OptionGroup var options: Options
        
        mutating func run() throws {
            
            // Get the path to the file
            var inputFile: String = options.inputFilePath ?? ""
            // if users are familiar with argument, we will make their life easy.
            if let filePath = options.filePath {
                inputFile = filePath.pathString
            }
            
            if options.verbose {
                print("Estimating reading time for '\(inputFile)'")
            }
            
            // Load the contents of the file into a string
            guard let fileContents = try? String(contentsOfFile: inputFile) else {
                throw RuntimeError("Couldn't read from '\(inputFile)'!")
            }
            
            let words = fileContents.components(separatedBy: .whitespacesAndNewlines)
                .map { word in
                    word.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                        .lowercased()
                }
                .compactMap { word in word.isEmpty ? nil : word }
            
            let counts = Dictionary(grouping: words, by: { $0 })
                .mapValues { $0.count }
                .sorted(by: { $0.value > $1.value })
            
            if options.verbose {
                print("Found \(counts.count) words.")
            }
            
            print("Word Count: \(counts.count)")
        }
    }
    
    struct RuntimeError: Error, CustomStringConvertible {
        var description: String
        
        init(_ description: String) {
            self.description = description
        }
    }
}
