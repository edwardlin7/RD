//
//  SQLiteDatabase.swift
//  Tutorial5
//
//  Created by Lindsay Wells (updated 2020).
//
//  You are welcome to use this class in your assignments, but you will need to modify it in order for
//  it to do anything!
//
//  Add your code to the end of this class for handling individual tables
//
//  Known issues: doesn't handle versioning and changing of table structure.
//

import Foundation
import SQLite3

class SQLiteDatabase
{
    /* This variable is of type OpaquePointer, which is effectively the same as a C pointer (recall the SQLite API is a C-library). The variable is declared as an optional, since it is possible that a database connection is not made successfully, and will be nil until such time as we create the connection.*/
    private var db: OpaquePointer?
    
    /* Change this value whenever you make a change to table structure.
        When a version change is detected, the updateDatabase() function is called,
        which in turn calls the createTables() function.
     
        WARNING: DOING THIS WILL WIPE YOUR DATA, unless you modify how updateDatabase() works.
     */
    private let DATABASE_VERSION = 4
    
    
    
    // Constructor, Initializes a new connection to the database
    /* This code checks for the existence of a file within the application’s document directory with the name <dbName>.sqlite. If the file doesn’t exist, it attempts to create it for us. Since our application has the ability to write into this directory, this should happen the first time that we run the application without fail (it can still possibly fail if the device is out of storage space).
     The remainder of the function checks to see if we are able to open a successful connection to this database file using the sqlite3_open() function. With all of the SQLite functions we will be using, we can check for success by checking for a return value of SQLITE_OK.
     */
    init(databaseName dbName:String)
    {
        //get a file handle somewhere on this device
        //(if it doesn't exist, this should create the file for us)
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(dbName).sqlite")
        
        //try and open the file path as a database
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK
        {
            print("Successfully opened connection to database at \(fileURL.path)")
            self.dbName = dbName
            checkForUpgrade();
        }
        else
        {
            print("Unable to open database at \(fileURL.path)")
            printCurrentSQLErrorMessage(db)
        }
        
    }
    
    deinit
    {
        /* We should clean up our memory usage whenever the object is deinitialized, */
        sqlite3_close(db)
    }
    private func printCurrentSQLErrorMessage(_ db: OpaquePointer?)
    {
        let errorMessage = String.init(cString: sqlite3_errmsg(db))
        print("Error:\(errorMessage)")
    }
    
    private func createTables()
    {
        //INSERT YOUR createTable function calls here
        //e.g. createMovieTable()
        createAllTable()
    }
    private func dropTables()
    {
        //INSERT YOUR dropTable function calls here
        //e.g. dropTable(tableName:"Movie")
        dropTable(tableName:"Raffle")
        dropTable(tableName:"Ticket")
        dropTable(tableName:"Customer")
    }
    
    /* --------------------------------*/
    /* ----- VERSIONING FUNCTIONS -----*/
    /* --------------------------------*/
    private var dbName:String = ""
    func checkForUpgrade()
    {
        // get the current version number
        let defaults = UserDefaults.standard
        let lastSavedVersion = defaults.integer(forKey: "DATABASE_VERSION_\(dbName)")
        
        // detect a version change
        if (DATABASE_VERSION > lastSavedVersion)
        {
            onUpdateDatabase(previousVersion:lastSavedVersion, newVersion: DATABASE_VERSION);
            
            // set the stored version number
            defaults.set(DATABASE_VERSION, forKey: "DATABASE_VERSION_\(dbName)")
        }
    }
    
    func onUpdateDatabase(previousVersion : Int, newVersion : Int)
    {
        print("Detected Database Version Change (was:\(previousVersion), now:\(newVersion))")
        
        //handle the change (simple version)
        dropTables()
        createTables()
    }
    
    
    
    /* --------------------------------*/
    /* ------- HELPER FUNCTIONS -------*/
    /* --------------------------------*/
    
    /* Pass this function a CREATE sql string, and a table name, and it will create a table
        You should call this function from createTables()
     */
    private func createTableWithQuery(_ createTableQuery:String, tableName:String)
    {
        /*
         1.    sqlite3_prepare_v2()
         2.    sqlite3_step()
         3.    sqlite3_finalize()
         */
        //prepare the statement
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createTableQuery, -1, &createTableStatement, nil) == SQLITE_OK
        {
            //execute the statement
            if sqlite3_step(createTableStatement) == SQLITE_DONE
            {
                print("\(tableName) table created.")
            }
            else
            {
                print("\(tableName) table could not be created.")
                printCurrentSQLErrorMessage(db)
            }
        }
        else
        {
            print("CREATE TABLE statement for \(tableName) could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        
        //clean up
        sqlite3_finalize(createTableStatement)
        
    }
    /* Pass this function a table name.
        You should call this function from dropTables()
     */
    private func dropTable(tableName:String)
    {
        /*
         1.    sqlite3_prepare_v2()
         2.    sqlite3_step()
         3.    sqlite3_finalize()
         */
        
        //prepare the statement
        let query = "DROP TABLE IF EXISTS \(tableName)"
        var statement: OpaquePointer? = nil

        if sqlite3_prepare_v2(db, query, -1, &statement, nil)     == SQLITE_OK
        {
            //run the query
            if sqlite3_step(statement) == SQLITE_DONE {
                print("\(tableName) table deleted.")
            }
        }
        else
        {
            print("\(tableName) table could not be deleted.")
            printCurrentSQLErrorMessage(db)
        }
        
        //clear up
        sqlite3_finalize(statement)
    }
    
    //helper function for handling INSERT statements
    //provide it with a binding function for replacing the ?'s for setting values
    private func insertWithQuery(_ insertStatementQuery : String, bindingFunction:(_ insertStatement: OpaquePointer?)->())
    {
    
        /*
         Similar to the CREATE statement, the INSERT statement needs the following SQLite functions to be called (note the addition of the binding function calls):
         1.    sqlite3_prepare_v2()
         2.    sqlite3_bind_***()
         3.    sqlite3_step()
         4.    sqlite3_finalize()
         */
        // First, we prepare the statement, and check that this was successful. The result will be a C-
        // pointer to the statement:
        var insertStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, insertStatementQuery, -1, &insertStatement, nil) == SQLITE_OK
        {
            //handle bindings
            bindingFunction(insertStatement)
            
            /* Using the pointer to the statement, we can call the sqlite3_step() function. Again, we only
             step once. We check that this was successful */
            //execute the statement
            if sqlite3_step(insertStatement) == SQLITE_DONE
            {
                print("Successfully inserted row.")
            }
            else
            {
                print("Could not insert row.")
                printCurrentSQLErrorMessage(db)
            }
        }
        else
        {
            print("INSERT statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
    
        //clean up
        sqlite3_finalize(insertStatement)
    }
    
    private func deleteAllGames()
       {
    /*
            1.    sqlite3_prepare_v2()
            2.    sqlite3_step()
            3.    sqlite3_finalize()
            */
           
           //prepare the statement
           let query = "DELETE FROM Raffle"
           var statement: OpaquePointer? = nil

           if sqlite3_prepare_v2(db, query, -1, &statement, nil)     == SQLITE_OK
           {
               //run the query
               if sqlite3_step(statement) == SQLITE_DONE {
                   print("Data deleted.")
               }
           }
           else
           {
               print("Data could not be deleted.")
               printCurrentSQLErrorMessage(db)
           }
           
           //clear up
           sqlite3_finalize(statement)
        
          
       }
       
    //helper function to run Select statements
    //provide it with a function to do *something* with each returned row
    //(optionally) Provide it with a binding function for replacing the "?"'s in the WHERE clause
    private func selectWithQuery(
        _ selectStatementQuery : String,
        eachRow: (_ rowHandle: OpaquePointer?)->(),
        bindingFunction: ((_ rowHandle: OpaquePointer?)->())? = nil)
    {
        //prepare the statement
        var selectStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, selectStatementQuery, -1, &selectStatement, nil) == SQLITE_OK
        {
            //do bindings, only if we have a bindingFunction set
            //hint, to do selectMovieBy(id:) you will need to set a bindingFunction (if you don't hardcode the id)
            bindingFunction?(selectStatement)
            
            //iterate over the result
            while sqlite3_step(selectStatement) == SQLITE_ROW
            {
                eachRow(selectStatement);
            }
            
        }
        else
        {
            print("SELECT statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        //clean up
        sqlite3_finalize(selectStatement)
    }
    
    //helper function to run update statements.
    //Provide it with a binding function for replacing the "?"'s in the WHERE clause
    private func updateWithQuery(
        _ updateStatementQuery : String,
        bindingFunction: ((_ rowHandle: OpaquePointer?)->()))
    {
        //prepare the statement
        var updateStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, updateStatementQuery, -1, &updateStatement, nil) == SQLITE_OK
        {
            //do bindings
            bindingFunction(updateStatement)
            
            //execute
            if sqlite3_step(updateStatement) == SQLITE_DONE
            {
                print("Successfully inserted row.")
            }
            else
            {
                print("Could not insert row.")
                printCurrentSQLErrorMessage(db)
            }
        }
        else
        {
            print("UPDATE statement could not be prepared.")
            printCurrentSQLErrorMessage(db)
        }
        //clean up
        sqlite3_finalize(updateStatement)
    }
    
    /* --------------------------------*/
    /* --- ADD YOUR TABLES ETC HERE ---*/
    /* --------------------------------*/
    func createAllTable(){
        
        let createRaffleTableQuery =
        """
            CREATE TABLE Raffle (
                ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                Name CHAR(255),
                Description CHAR(255),
                Cover TEXT,
                Amount INTEGER
            );
        """
        let createTicketTableQuery =
        """
            CREATE TABLE Ticket (
                ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                Name CHAR(255),
                Ticket_number INTEGER,
                Price INTEGER,
                Datetime CHAR(255),
                Customer_name CHAR(255)
            );
        """
        let createCustomerTableQuery =
        """
            CREATE TABLE Customer (
                ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                Name CHAR(255),
                Mobile CHAR(255)
            );
        """
        createTableWithQuery(createRaffleTableQuery, tableName: "Raffle")
        createTableWithQuery(createTicketTableQuery, tableName: "Ticket")
        createTableWithQuery(createCustomerTableQuery, tableName: "Customer")
    }
    
    func insertRaffle(raffle:Raffle){
        let insertStatementQuery = "INSERT INTO Raffle (Name, Description, Cover, Amount) VALUES (?,?,?,?);"
        
        insertWithQuery(insertStatementQuery, bindingFunction: { (insertStatement) in
            sqlite3_bind_text(insertStatement, 1, NSString(string: raffle.name).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, NSString(string: raffle.description).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, NSString(string: raffle.cover).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 4, raffle.amount)
         })
    }
    
    func insertTicket(ticket:Ticket){
        let insertStatementQuery = "INSERT INTO Ticket (Name, Ticket_number, Price, Datetime, Customer_name) VALUES (?,?,?,?,?);"
        
        insertWithQuery(insertStatementQuery, bindingFunction: { (insertStatement) in
            sqlite3_bind_text(insertStatement, 1, NSString(string: ticket.name).utf8String, -1, nil)
            sqlite3_bind_int(insertStatement, 2, ticket.ticket_number)
            sqlite3_bind_int(insertStatement, 3, ticket.price)
            sqlite3_bind_text(insertStatement, 4, NSString(string: ticket.datetime).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 4, NSString(string: ticket.customer_name).utf8String, -1, nil)
         })
    }
    
    func insertCustomer(customer:Customer){
        let insertStatementQuery = "INSERT INTO Customer (Name, Mobile) VALUES (?,?);"
        
        insertWithQuery(insertStatementQuery, bindingFunction: { (insertStatement) in
            sqlite3_bind_text(insertStatement, 1, NSString(string: customer.name).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 1, NSString(string: customer.mobile).utf8String, -1, nil)
            
        })
    }
    
    func selectAllRaffles() ->[Raffle]{
        var result = [Raffle]()
        let selectStatementQuery = "SELECT * FROM Raffle"
        
        selectWithQuery(selectStatementQuery, eachRow: { (row) in //create a game object from each result
                   let raffleArray = Raffle(
                       ID: sqlite3_column_int(row, 0),
                       name: String(cString:sqlite3_column_text(row, 1)),
                       description: String(cString:sqlite3_column_text(row, 2)),
                       cover: String(cString:sqlite3_column_text(row, 3)),
                       amount:sqlite3_column_int(row, 4)
                       )//add it to the result array
                   result += [raffleArray]
        })
        return result
    }
    
    func selectAll(tableName:String) -> [Any]{
        var result:[Any] = []
       
        let selectStatementQuery = "SELECT * FROM \(tableName)"
        
        let tName:String = tableName
        
        switch tName {
        case "Raffle":
            var _result = [Raffle]()
            selectWithQuery(selectStatementQuery, eachRow: { (row) in //create a game object from each result
            let raffleArray = Raffle(
                ID: sqlite3_column_int(row, 0),
                name: String(cString:sqlite3_column_text(row, 1)),
                description: String(cString:sqlite3_column_text(row, 2)),
                cover: String(cString:sqlite3_column_text(row, 3)),
                amount:sqlite3_column_int(row, 4)
                )//add it to the result array
            _result += [raffleArray]
            result = _result
            })
            
        case "Ticket":
            var _result = [Ticket]()
            selectWithQuery(selectStatementQuery, eachRow: { (row) in //create a game object from each result
            let ticketArray = Ticket(
                ID: sqlite3_column_int(row, 0),
                name: String(cString:sqlite3_column_text(row, 1)),
                ticket_number: sqlite3_column_int(row, 2),
                price: sqlite3_column_int(row, 3),
                datetime: String(cString:sqlite3_column_text(row, 4)),
                customer_name: String(cString:sqlite3_column_text(row, 5))
                )//add it to the result array
            _result += [ticketArray]
            result = _result
            })
            
        case "Customer":
            var _result = [Customer]()
            selectWithQuery(selectStatementQuery, eachRow: { (row) in //create a game object from each result
            let customerArray = Customer(
                ID: sqlite3_column_int(row, 0),
                name: String(cString:sqlite3_column_text(row, 1)),
                mobile: String(cString:sqlite3_column_text(row, 2))
                )//add it to the result array
            _result += [customerArray]
            result = _result
            })
            
        default:
            print("No table found")
        }
        
        return result
    }

    func deleteAll(){
        
        deleteAllGames()
    }
    
    
    
    
    
    
    
    
}
