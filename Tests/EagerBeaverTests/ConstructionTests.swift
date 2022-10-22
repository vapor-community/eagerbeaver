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
        
        XCTAssertNoThrow(try Parser.shared.process(html))
    }
    
    // Tests parsing the head scope
    func testHeadScope() throws {
        
        let html = """
        <head>\
        <title>Document</title>\
        </head>
        """
        
        XCTAssertNoThrow(try Parser.shared.process(html))
    }
    
    // Tests parsing the body scope
    func testBodyScope() throws {
        
        let html = """
        <body>\
        <h1>Body</h1>\
        </body>
        """
        
        XCTAssertNoThrow(try Parser.shared.process(html))
    }
    
    // Tests parsing the script scope
    func testTableScope() throws {
        
        let html = """
        <table>\
        <tr>\
        <td>Column</td>\
        <td>Column</td>\
        </tr>\
        </table>
        """
        
        XCTAssertNoThrow(try Parser.shared.process(html))
    }
    
    // Tests parsing the script scope
    func testScriptScope() throws {
        
        let html = """
        <script>\
        document.getElementById("greeting").innerHTML = "Hello World!"\
        </script>
        """
        
        XCTAssertNoThrow(try Parser.shared.process(html))
    }
}
