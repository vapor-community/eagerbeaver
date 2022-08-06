import XCTest
@testable import EagerBeaver

final class TokenizerTests: XCTestCase {
    
    func testStartTag() throws {
        
        let content = "<html>"
        
        XCTAssertNoThrow(try Tokenizer().consume(content))
    }
    
    func testDoctype() throws {
        
        let content = "<!DOCTYPE html>"
        
        XCTAssertNoThrow(try Tokenizer().consume(content))
    }
    
    func testComment() throws {
        
        let content = "<!--Comment >"
        
        XCTAssertNoThrow(try Tokenizer().consume(content))
    }
    
    func testEndTag() throws {
        
        let content = "</html>"
        
        XCTAssertNoThrow(try Tokenizer().consume(content))
    }
    
    func testSelfClosing() throws {
        
        let content = "<html/>"
        
        XCTAssertNoThrow(try Tokenizer().consume(content))
    }
    
    func testInvalidCharacterInTagName() throws {
        
        let content = "<?html>"
        
        XCTAssertThrowsError(try Tokenizer().consume(content))
    }
    
    func testMissingTagNameInStartTag() throws {
        
        let content = "<>"
        
        XCTAssertThrowsError(try Tokenizer().consume(content))
    }
    
    func testMissingTagNameInEndTag() throws {
        
        let content = "</>"
        
        XCTAssertThrowsError(try Tokenizer().consume(content))
    }
    
    func testAttribute() throws {
        
        let content = "<html name='value'>"
        
        XCTAssertNoThrow(try Tokenizer().consume(content))
    }
}
