//
//  Copyright (c) 2016 Algolia
//  http://www.algolia.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import InstantSearchCore

@objc public enum TransformRefinementList: Int {
    case countAsc
    case countDesc
    case nameAsc
    case nameDsc
    
    public init(named transformName: String) {
        switch transformName.lowercased() {
        case "countasc": self = .countAsc
        case "countdesc": self = .countDesc
        case "nameasc": self = .nameAsc
        case "nameDsc": self = .nameDsc
        default: self = .countDesc
        }
    }
}

extension RefinementMenuViewModel {
    @objc public func getRefinementList(facetCounts: [String: Int]?, andFacetName facetName: String, transformRefinementList: TransformRefinementList, areRefinedValuesFirst: Bool) -> [FacetValue] {
        
        let allRefinements = searcher.params.buildFacetRefinements()
        let refinementsForFacetName = allRefinements[facetName]
        
        let facetList = FacetValue.listFrom(facetCounts: facetCounts, refinements: refinementsForFacetName)
        
        let sortedFacetList = facetList.sorted() { (lhs, rhs) in
            
            let lhsChecked = searcher.params.hasFacetRefinement(name: facetName, value: lhs.value)
            let rhsChecked = searcher.params.hasFacetRefinement(name: facetName, value: rhs.value)
            
            if areRefinedValuesFirst && lhsChecked != rhsChecked { // Refined wins
                return lhsChecked
            }
            
            switch transformRefinementList {
            case .countDesc:
                if lhs.count != rhs.count { // Biggest Count wins
                    return lhs.count > rhs.count
                } else {
                    return lhs.value < rhs.value // Name ascending wins by default
                }
                
            case .countAsc:
                if lhs.count != rhs.count { // Smallest Count wins
                    return lhs.count < rhs.count
                } else {
                    return lhs.value < rhs.value // Name ascending wins by default
                }
                
            case .nameAsc:
                if lhs.value != rhs.value {
                    return lhs.value < rhs.value // Name ascending
                }
                else {
                    return lhs.count > rhs.count // Biggest Count wins by default
                }
                
            case .nameDsc:
                if lhs.value != rhs.value {
                    return lhs.value > rhs.value // Name descending
                }
                else {
                    return lhs.count > rhs.count // Biggest Count wins by default
                }
            }
        }
        
        return sortedFacetList
    }
}