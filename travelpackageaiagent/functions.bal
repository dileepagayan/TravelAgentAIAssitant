import ballerina/ai;
import ballerina/http;
import ballerina/io;

/// Updates the knowledge base by writing the uploaded request body to a file and ingesting
/// the document data into the vector database.
///
/// @param request The HTTP request containing the uploaded file stream.
/// @return A JSON object indicating the operation status.
function updateKB(http:Request request) returns json {

    io:println("[INFO] Starting knowledge base update process");
    
    // Writes the incoming stream to a file using the `io:fileWriteBlocksFromStream` API
    // by providing the file location to which the content should be written.
    do {
        io:println("[INFO] Receiving file stream from request");
        stream<byte[], io:Error?> streamer = check request.getByteStream();
	    // Writes the incoming stream to a file using the `io:fileWriteBlocksFromStream` API
	    // by providing the file location to which the content should be written.
	    io:println("[INFO] Writing file stream to ./files/ReceivedFile.md");
	    check io:fileWriteBlocksFromStream("./files/ReceivedFile.md", streamer);
        check streamer.close();
        io:println("[INFO] File written successfully");

        //read the file uploaded and ingest to vector db

        io:println("[INFO] Loading document data from uploaded file");
        ai:Document[]|ai:Document kbFileData = check kbDataLoader.load();
        io:println("[INFO] Ingesting documents into vector knowledge base");
        check aiVectorknowledgebase.ingest(kbFileData);
        io:println("[INFO] Knowledge base update completed successfully");
        
        return "{ 'status': 'Successful' }";



    } on fail error err {
        io:println("Error while writing the file: " + err.message());
        return "{ 'status': 'Failed' }";
    }

    

}
