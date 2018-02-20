//
//  XMLParser.swift
//  iosExam
//
//  Created by James Abanto on 16/02/2018.
//  Copyright © 2018 carlo. All rights reserved.
//

import Foundation
import Kanna

class FeedParser: NSObject, XMLParserDelegate {
    private var rssItems: [RSSItem] = []
    private var currentElement: String = ""
    private var currentTitle: String = "" {
        didSet {
            currentTitle = currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private var currentPubDate: String = "" {
        didSet {
            currentPubDate = currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }   
    private var currentDescription: String = "" {
        didSet {
            currentDescription = currentDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private var ratingURL: String = "" {
        didSet {
            ratingURL = ratingURL.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private var imgURL: String = "" {
        didSet {
            imgURL = imgURL.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private var inItem: Bool = false
    private var inDescription: Bool = false
    var descriptionData: Data?
    
    private var parserCompletionHandler: (([RSSItem]) -> Void)?
    
    func parseFeed(url: String, completionHandler: (([RSSItem]) -> Void)?) {
        
        self.parserCompletionHandler = completionHandler
        
        let request = URLRequest(url: URL(string: url)!)
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print(error.localizedDescription)
                }
                return
            }
            let parser = XMLParser(data: data)
            parser.delegate = self
            parser.parse()
        }
        task.resume()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        switch currentElement {
        case "item" :
            inItem = true
            currentTitle = ""
            currentPubDate = ""
        case "description" :
            if inItem {
                inDescription = true
                imgURL = ""
                ratingURL = ""
                descriptionData = Data()
            }
        default: break
        }
        
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentElement {
            case "title" :
                currentTitle += string
            case "pubDate" : currentPubDate += string
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if inDescription {
            descriptionData?.append(CDATABlock)
            let starsURL = "<img.*?src=\"([^\"]*)\"".findMatchIn(string: String(data: descriptionData!, encoding: .utf8)! as NSString!, atRangeIndex: 1)
            let bookImgURL = "<img.*?src=\"([^\"]*)\"".firstMatchIn(string: String(data: descriptionData!, encoding: .utf8)! as NSString!, atRangeIndex: 1)
            imgURL += bookImgURL
            ratingURL += starsURL
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            inItem = false
            let rssItem = RSSItem(title: currentTitle, pubDate: currentPubDate, ratingURL: ratingURL, imgURL: imgURL)
            self.rssItems.append(rssItem)
        } else if elementName == "description" {
            inDescription = false
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        parserCompletionHandler?(rssItems)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}

extension String {
    func firstMatchIn(string: NSString!, atRangeIndex: Int!) -> String {
        let re: NSRegularExpression = try! NSRegularExpression(pattern: self, options: .caseInsensitive)
        let match = re.firstMatch(in: string as String, options: .withoutAnchoringBounds, range: NSMakeRange(0, string.length))
        return string.substring(with: match!.rangeAt(atRangeIndex))
    }
    
    func findMatchIn(string: NSString!, atRangeIndex: Int!) -> String {
        let re: NSRegularExpression = try! NSRegularExpression(pattern: self, options: .caseInsensitive)
        let match = re.matches(in: string as String, options: .withoutAnchoringBounds, range: NSMakeRange(0, string.length))
        return string.substring(with: match[1].rangeAt(atRangeIndex))
    }
}

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(url: url as URL)
        
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main) {
                (response: URLResponse?, data: Data?, error: Error?) -> Void in
                self.image = UIImage(data: data!)
            }
        }
    }
}
