/// 
/// TSVAligner
/// aslr - Copyright 2026
///

import JavaScriptKit

@main
struct TSVAligner {
    nonisolated(unsafe) static var clickHandler: JSClosure?

    static func main() {
        let document = JSObject.global.document
        let formatButton = document.getElementById("formatBtn")
        let inputArea = document.getElementById("inputArea")
        let outputArea = document.getElementById("outputArea")

        let handler = JSClosure { _ in
            let rawText = inputArea.value.string ?? ""
            let formattedText = alignTSV(text: rawText)
            outputArea.value = .string(formattedText)
            return .undefined
        }
        clickHandler = handler
        formatButton.onclick = .object(handler)
    }

    static func alignTSV(text: String) -> String {
        let rows = text
        .split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
        .map { line in
            line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
        }

        guard !rows.isEmpty && !rows.allSatisfy({ $0.isEmpty })
            else { return "" }
        
        // find the maximum number of columns by searching all rows
        let maxCols = rows.map { $0.count }.max() ?? 0

        // store the max width of each column
        var colWidths = Array(repeating: 0, count: maxCols)
        for row in rows {
            for (i, val) in row.enumerated() {
                colWidths[i] = max(colWidths[i], val.count)
            }
        }

        // format each row with padding and single-space separation
        let alignedRows = rows.map { row in
            row.enumerated().map { (i, val) in
                // pad the string to match the column's max width
                let paddingCount = max(0, colWidths[i] - val.count)
                return val + String(repeating: " ", count: paddingCount)
            }.joined(separator: " ")
        }

        return alignedRows.joined(separator: "\n")
    }
}
