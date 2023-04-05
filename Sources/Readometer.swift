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
        abstract: "A Swift command-line tool for estimating the reading time of articles.",
        subcommands: [Estimate.self, WordCount.self],
        defaultSubcommand: Estimate.self
    )
    
}

extension Readometer {
    
    /// Helper function to extract contents of a given file
    /// - Parameter filePath: A path to the file
    /// - Returns: Text content after reading the file.
    static func getFileContents(from filePath: FilePath?) throws -> String {
        // Get the path to the file
        guard let inputFile = filePath?.pathString, !inputFile.isEmpty else {
            throw RuntimeError("Please provide the path to a file as an argument.")
        }
        
        // Load the contents of the file into a string
        guard let fileContents = try? String(contentsOfFile: inputFile) else {
            throw RuntimeError("Couldn't read from '\(inputFile)'!")
        }
        
        // Determine file type
        guard let fileType = FileType(filePath: inputFile) else {
            throw RuntimeError("Unsupported file type '\(inputFile)'!")
        }
        
        let plainText: String
        
        switch fileType {
        case .text:
            plainText = fileContents
            
        case .markdown:
            // Strip Markdown syntax if necessary
            /**
             Regex Logic:
             Links (with or without images)
             Bold text (**...** or __...__)
             Inline code (... or ...)
             Italic text (*...* or _..._)
             Headings (# ... followed by a newline)
             Horizontal rules (--- or ___ or *** followed by a newline)
             Code blocks (````...```\n` followed by one or more lines of text)
             */
            guard let regex = try? NSRegularExpression(
                pattern: #"(!?\[.*?\]\(.*?\))|(\*\*.*?\*\*)|(__.*?__)|(`.*?`)|(\*.*?\*)|(_.*?_)|#.*?\n|\n-{3,}\n|`{3}.*?\n|`.*?`"#
            ) else {
                throw RuntimeError("Failed to read Markdown file '\(inputFile)'!")
            }
            plainText = regex.stringByReplacingMatches(
                in: fileContents,
                range: NSRange(fileContents.startIndex..., in: fileContents),
                withTemplate: "$1")
        }
        
        return plainText
    }
    
    /// Counts the number of unique words in a plain text string.
    /// - Parameter plainText: The plain text string to count words in
    /// - Returns: The number of unique words in the given plain text string
    static func wordCount(from plainText: String) -> Int {
        
        // Split the plain text into words and remove any whitespace or non-alphanumeric characters.
        let words = plainText.components(separatedBy: .whitespacesAndNewlines)
            .map { word in
                word.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                    .lowercased()
            }
            .compactMap { $0.isEmpty ? nil : $0 }
        
        return words.count
    }
        
    // MARK: - Subcommands
    
    struct Estimate: ParsableCommand {
        
        // Defines the average reading speed in words per minute (wpm)
        static let averageReadingSpeed = 200
        
        static let configuration = CommandConfiguration(abstract: "Estimates Reading Time.")
        
        @OptionGroup var options: Options
        
        mutating func run() throws {
            
            // Get the path to the file
            var inputFile: FilePath? = options.inputFilePath
            // if users are familiar with argument, we will make their life easy.
            if let filePath = options.filePath {
                inputFile = filePath
            }
            
            // Extract only text contents from the file
            let plainText = try Readometer.getFileContents(from: inputFile)
            
            if options.verbose {
                print("Estimating reading time for '\(String(describing: inputFile?.pathString))'")
            }
            
            // Calculate the estimated reading time in minutes
            let wordCount = Readometer.wordCount(from: plainText)
            let readingTime = Double(wordCount) / Double(Readometer.Estimate.averageReadingSpeed)
            
            print("✨✨✨\nEstimated reading time: \(Int(readingTime.rounded())) minutes\n✨✨✨")
        }
    }
    
    struct WordCount: ParsableCommand {
        
        public static let configuration = CommandConfiguration(abstract: "Word Counter.")
        
        @OptionGroup var options: Options
        
        mutating func run() throws {
            
            // Get the path to the file
            var inputFile: FilePath? = options.inputFilePath
            // if users are familiar with argument, we will make their life easy.
            if let filePath = options.filePath {
                inputFile = filePath
            }
            
            // Extract only text contents from the file
            let plainText = try Readometer.getFileContents(from: inputFile)
            
            if options.verbose {
                print("Calculating word count for '\(String(describing: inputFile?.pathString))'")
            }
            
            let wordCount = Readometer.wordCount(from: plainText)
            
            print("🎉🎉🎉\nWord Count: \(wordCount)\n🎉🎉🎉")
        }
    }
    
    // MARK: - Custom Types
    
    struct FilePath: ExpressibleByArgument {
        var pathString: String
        
        init?(argument: String) {
            self.pathString = argument
        }
    }
    
    struct Options: ParsableArguments {
        @Argument var filePath: FilePath?
        
        @Option(name: [.short, .customLong("input")], help: "A path to a file to read.")
        var inputFilePath: FilePath?
        
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
    
    // MARK: - Error
    
    struct RuntimeError: Error, CustomStringConvertible {
        var description: String
        
        init(_ description: String) {
            self.description = description
        }
    }
}
