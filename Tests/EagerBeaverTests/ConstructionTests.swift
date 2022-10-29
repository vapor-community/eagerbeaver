import XCTest
@testable import EagerBeaver

final class ConstructionTests: XCTestCase {

    // Tests parsing a default document
    func testDefaultDocument() throws {
        
        let html = """
        <!DOCTYPE html>\
        <html lang="en">\
        <head>\
        <title>Document</title>\
        </head>\
        <body></body>\
        </html>
        """
        
        let tokens = try Tokenizer().consume(html)
        
        XCTAssertNoThrow(try Parser(log: .information).process(tokens))
    }
    
    // Tests parsing a default document without a document token
    func testDefaultDocumentWithoutDoctype() throws {
        
        let html = """
        <html lang="en">\
        <head>\
        <title>Document</title>\
        </head>\
        <body></body>\
        </html>
        """
        
        let tokens = try Tokenizer().consume(html)
        
        XCTAssertThrowsError(try Parser(log: .information).process(tokens))
    }
    
    // Tests parsing a default document with an invalid token
    func testDefaultDocumentWithInvalidToken() throws {
        
        let html = """
        <!DOCTYPE html>\
        <head>\
        <title>Document</title>\
        </head>\
        <body></body>\
        </html>
        """
        
        let tokens = try Tokenizer().consume(html)
        
        XCTAssertThrowsError(try Parser(log: .information).process(tokens))
    }
}
