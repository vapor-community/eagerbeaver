import XCTest
import EagerBeaver

final class DocumentTests: XCTestCase {

    func testDocumentInitialization() throws {
        
        let html = """
        <!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\
        <html lang="en">\
        <head>\
        <!--Comment-->\
        <title>Document</title>\
        </head>\
        <body>\
        <h1>Heading</h1>\
        </body>\
        </html>
        """
        
        let document = try HtmlDocument(content: html)
        
        XCTAssertNotNil(document)
    }
}
